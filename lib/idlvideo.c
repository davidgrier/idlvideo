//
//  idlvideo.c
//
//  IDL-callable library implementing frame-capturing
//  from video sources.  Based on OpenCV.
//
//  Modification history:
//  01/22/2010 Written by David G. Grier, New York University
//  01/26/2010 DGG revised error message code.  Corrected seeking code.
//  01/27/2010 DGG cvGetCaptureProperty returns double.  Return frame
//    number of most recently captured frame (read_videoframe).
//  03/02/2010 DGG OpenCV has problems with frame numbers for some
//    video formats.  Removed frame number references to avoid confusion.
//  04/26/2010 DGG Added video_queryvideocamera.
//  01/01/2011 DGG Search for any kind of camera if camera is not specified.
//    Revised type casts for better compatibility with IDL.
//    Allow user to override default geometry for camera acquisitions.
//    First implementation of getproperty and setproperty.
//  01/11/2011 DGG QueryFrame immediately before image transfer to make
//    live video respond in real time.  This causes loss of the first
//    frame in a video file.
//  02/28/2015 DGG Version suitable for use with LINKIMAGE rather than
//     CALL_EXTERNAL
//  03/14/2015 DGG DLM version.  In transferring data from OpenCV to IDL,
//     take into account that OpenCV images are in BGR order and are
//     vertically flipped.  Image copies take this into account.
//
//  Copyright (c) 2010-2015 David G. Grier
//

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

// IDL support
#include <idl_export.h>

// OpenCV support
#include <cv.h>
#include <highgui.h>

#define IDLVIDEO "idlvideo_capture"

#define cvError(status, func_name, err_msg, file_name, line) (fprintf(stderr,"ok\n");)

//
// idlvideo__capture
//
// utility routine to obtain pointer to capture
// from idlvideo structure
//
CvCapture * idlvideo__capture (IDL_VPTR s)
{
  IDL_StructDefPtr sdef;
  char *s_name;
  IDL_ULONG64 *addr;

  // Ensure argument is a structure with the correct name
  IDL_ENSURE_STRUCTURE(s);
  
  sdef = s->value.s.sdef;
  IDL_StructTagNameByIndex(sdef, 1, IDL_MSG_LONGJMP, &s_name);
  if (strcmp(s_name, IDLVIDEO)) {
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP, "Not a valid camera.");
    return NULL;
  }

  // Get the address of the capture pointer
  addr = (IDL_ULONG64 *) (s->value.s.arr->data + 
			  IDL_StructTagInfoByName(sdef, "CAPTURE",
						  IDL_MSG_LONGJMP, NULL));

  if (addr == NULL)
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP, "Could not access camera data.");

  return (CvCapture *) *addr;
}

//
// idlvideo_CaptureFromCam
//
// Open video camera
//
// command line arguments
// argv[0]: IN camera number
//
IDL_VPTR idlvideo_CaptureFromCAM (int argc, IDL_VPTR argv[])
{
  int camera = 0;
  CvCapture *capture;
  IDL_VPTR idl_capture;

  static IDL_MEMINT one = 1;
  static IDL_STRUCT_TAG_DEF s_tags[] = {
    { "CAMERA", 0, (void *) IDL_TYP_LONG },
    { "CAPTURE", 0, (void *) IDL_TYP_ULONG64 },
    { 0 }
  };

  typedef struct idlvideo_struct {
    IDL_LONG camera;
    IDL_ULONG64 capture;
  } IDLVIDEO_STRUCT;

  static IDLVIDEO_STRUCT data;
  void *d;
  IDL_VPTR v;
  
  if (argc == 1)
    camera = (int) IDL_LongScalar(argv[0]);

  capture = cvCaptureFromCAM(camera);
  if (!capture) {
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP, "Could not open specified camera.");
  }

  // Store camera info in IDLVIDEO structure
  data.camera = (IDL_LONG) camera;
  data.capture = (IDL_ULONG64) capture;
  d = IDL_MakeStruct(IDLVIDEO, s_tags);
  v = IDL_ImportArray(1, &one, IDL_TYP_STRUCT, (UCHAR *) &data, 0, d);

  return v;
}

//
// idlvideo_ReleaseCapture
//
// Close video capture that was opened with idlCaptureFromCAM
//
void idlvideo_ReleaseCapture (int argc, IDL_VPTR argv[])
{
  CvCapture *capture;
  
  capture = idlvideo__capture(argv[0]);
  cvReleaseCapture(&capture);
  IDL_StoreScalarZero(argv[0], IDL_TYP_LONG);
}

//
// idlvideo_read
//
// Grab one frame, decode it and return it
//
IDL_VPTR idlvideo_read(int argc, IDL_VPTR argv[])
{
  CvCapture *capture;
  IDL_LONG gray;
  IplImage *frame;
  IDL_VPTR idl_image;
  UCHAR *image, *buffer, pixel;
  unsigned int r, g, b, value;
  IDL_MEMINT dims[3], x, y;

  capture = idlvideo__capture(argv[0]);
  gray = (argc == 2) ? IDL_LongScalar(argv[1]) : 0;
  
  frame = cvQueryFrame(capture);

  buffer = (UCHAR *) frame->imageData;
  if (frame->nChannels == 1) { // Native grayscale image
    dims[0] = frame->width;
    dims[1] = frame->height;
    image = (UCHAR *)
      IDL_MakeTempArray(IDL_TYP_BYTE, 2, dims, IDL_ARR_INI_NOP, &idl_image);
    image += (frame->height - 1) * frame->width; // start at last line
    for (y = 0; y < frame->height; y++) {
      memcpy(image, buffer, frame->width);
      image -= frame->width;
      buffer += frame->widthStep;
    }
  } else if (gray) {           // Grayscale image (convert from native BGR)
    dims[0] = frame->width;
    dims[1] = frame->height;
    image = (UCHAR *)
      IDL_MakeTempArray(IDL_TYP_BYTE, 2, dims, IDL_ARR_INI_NOP, &idl_image);
    buffer += (frame->height - 1) * frame->widthStep; // start at last line
    for (y = 0; y < frame->height; y++) {
      for (x = 0; x < frame->width; x++) {
	b = *buffer++;
	g = *buffer++;
	r = *buffer++;
	value = (r*77) + (g*151) + (b*28);
	*image++ = (UCHAR) (value >> 8);
      }
      buffer -= frame->widthStep + frame->nChannels*frame->width;
    }
  } else {                     // RGB image (convert from native BGR)
    dims[0] = frame->nChannels;
    dims[1] = frame->width;
    dims[2] = frame->height;
    image = (UCHAR *)
      IDL_MakeTempArray(IDL_TYP_BYTE, 3, dims, IDL_ARR_INI_NOP, &idl_image);
    buffer += (frame->height - 1) * frame->widthStep; // start at last line
    for (y = 0; y < frame->height; y++) {
      for (x = 0; x < frame->width; x++) {
	*image++ = *(buffer + 2); // R
	*image++ = *(buffer + 1); // G
	*image++ = *buffer;       // B
	buffer += 3;
      }
      buffer -= frame->widthStep + frame->nChannels*frame->width;
    }
  }
	
  return idl_image;
}

//
// idlvideo_getproperty
//
// Retrieve specified property
//
IDL_VPTR idlvideo_getproperty(int argc, IDL_VPTR argv[])
{
  CvCapture *capture;
  int property;
  double value;

  capture = idlvideo__capture(argv[0]);
  IDL_ENSURE_SIMPLE(argv[1]);
  property = (int) IDL_LongScalar(argv[1]);
  value = cvGetCaptureProperty(capture, property);

  return IDL_GettmpDouble(value);
}

//
// idlvideo_setproperty
//
// Set specified property
//
IDL_VPTR idlvideo_setproperty(int argc, IDL_VPTR argv[])
{
  CvCapture *capture;
  int property;
  double value;
  int res;

  capture = idlvideo__capture(argv[0]);
  IDL_ENSURE_SIMPLE(argv[1]);
  property = (int) IDL_LongScalar(argv[1]);
  IDL_ENSURE_SIMPLE(argv[2]);
  value = (double) IDL_DoubleScalar(argv[2]);

  res = cvSetCaptureProperty(capture, property, value);
  return IDL_GettmpLong(res);
}

//
// IDL_Load
//
int IDL_Load (void)
{
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { idlvideo_CaptureFromCAM, "IDLVIDEO_CAPTUREFROMCAM", 0, 1, 0, 0},
    { idlvideo_read, "IDLVIDEO_READ", 1, 2, 0, 0 },
    { idlvideo_getproperty, "IDLVIDEO_GETPROPERTY", 2, 2, 0, 0},
    { idlvideo_setproperty, "IDLVIDEO_SETPROPERTY", 3, 3, 0, 0},
  };

  static IDL_SYSFUN_DEF2 procedure_addr[] = {
    { (IDL_SYSRTN_GENERIC) idlvideo_ReleaseCapture, "IDLVIDEO_RELEASECAPTURE", 1, 1, 0, 0 },
  };

  return IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr)) &&
    IDL_SysRtnAdd(procedure_addr, FALSE, IDL_CARRAY_ELTS(procedure_addr));
}
