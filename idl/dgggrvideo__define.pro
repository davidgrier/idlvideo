;+
; NAME:
;    DGGgrVideo
;
; PURPOSE:
;    Object for acquiring a frame-by-frame sequence of images
;    from a video source, which subclasses from the IDLgrModel class.
;
; CATEGORY:
;    Multimedia, object graphics
;
; SUBCLASSES
;    DGGhwVideo
;    IDL_Object
;
; PROPERTIES:
; [IG ] CAMERA: Number of camera to use.
;       Default: 0
;
; [IG ] FILENAME: Name of video file to read.
;
; [IGS] DIMENSIONS: [nx, ny] Size of image [pixels]
;       Default: hardware default dimensions.
;
; [IGS] GRAYSCALE: If set, return grayscale images.
;
; [ GS] PROPERTIES: List of OpenCV properties.  Not all of these
;       may be supported for any particular camera.
;
; METHODS:
;    GetProperty
;    SetProperty
;
;    DGGhwVideo::Read()
;        Return next available video frame.
;
; MODIFICATION HISTORY:
; 12/30/2010 Written by David G. Grier, New York University
; 01/11/2010 DGG Added DGGhwVideo::Snap() function
; 03/14/2015 DGG Revamped for DLM interface.
; 02/08/2015 DGG First support for reading video files.
;
; Copyright (c) 2010-2016 David G. Grier
;-
;;;;;
;
; DGGgrVideo__define
;
pro DGGgrVideo__define

  COMPILE_OPT IDL2, HIDDEN
  
  struct = {DGGgrVideo, $
            inherits DGGhwVideo, $
            inherits IDL_Object $
           }
end
