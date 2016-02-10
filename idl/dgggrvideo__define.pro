;+
; Object for acquiring a frame-by-frame sequence of images
; from a video source, based on OpenCV
;
; :Author:
;    David G. Grier, New York University
;
; :Copyright:
;    Copyright (c) 2010-2016 David G. Grier
;-

;+
; Define the base class.
;
; :Hidden:
;-
pro DGGgrVideo__define

  COMPILE_OPT IDL2, HIDDEN
  
  struct = {DGGgrVideo, $
            inherits DGGhwVideo, $
            inherits IDL_Object $
           }
end
