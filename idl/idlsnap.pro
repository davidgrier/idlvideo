; docformat = 'rst'
;+
; Grab one image from a video camera
; using the IDLvideo interface
;
; :Examples:
; Acquire a frame from the default camera::
;
;    a = idlsnap()
;
; :Params:
;    camera : in, optional, default=0, type=integer
;        Camera number.
;
; :Keywords:
;    stabilize : in, optional, type=integer
;        Keep taking pictures until no pixel varies by more
;        than this value.
;
;    grayscale : in, optional, type=boolean
;        Convert image to grayscale.
;
;    quiet : in, optional, type=boolean
;        If set, do not provide diagnostic messages.
;
; :Returns:
;    [xsize,ysize] byte array of pixels.
;    Returns -1 if image acquisition failed.
;
; :History:
; 04/30/2003: David G. Grier, The University of Chicago, created.
;
; 09/29/2004: DGG New York University:
;                  replaced KEYWORD_SET with N_PARAMS.
;                  implemented STABILIZE keyword.
;
; Version 1.1 DGG, New York University.
;       Updated for IDL 6.1.
;       Try again if library call fails, rather than returning junk.
;
; Version 2.0 DGG: Updated for OpenCV interface
;
; 06/04/2010 DGG major overhaul
;
; 06/10/2010 DGG Return -1 on failure.  Add COMPILE_OPT.
;
; 12/29/2010 DGG use default geometry for cameras.
;
; 03/14/2015 DGG updated for DLM interface.
;
; :Author:
;    David G. Grier, New York University
; :Copyright:
;    Copyright (c) 2003-2015 David G. Grier
;-
function idlsnap, camera, $
                  grayscale = grayscale, $
                  stabilize = stabilize, $
                  quiet = quiet

  COMPILE_OPT IDL2

  report = ~keyword_set(quiet)

  camera = isa(camera, /number, /scalar) ? long(camera) : 0L
  capture = idlvideo_capturefromcam(camera)

  grayscale = keyword_set(grayscale)
  
  image = idlvideo_read(capture, grayscale)

  if keyword_set(stabilize) then begin
     npix = 1
     maxpix = 60                ; more than 2 seconds
     image2 = image
     repeat begin
        image = idlvideo_read(capture, grayscale)
        delta = max(abs(fix(image)-fix(image2)))
        image = image2
        npix++
     endrep until (delta lt stabilize) or (npix ge maxpix)
     if npix ge maxpix and report then $
        message, "Image not stabilized", /inf
  endif

  idlvideo_releasecapture, capture

  return, image
end


