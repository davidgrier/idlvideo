; docformat = 'rst'

;+
; Object class for acquiring a frame-by-frame sequence of images
; from a video source, based on OpenCV.
;
; :Properties:
;    camera
;        Camera number for video acquisition.
;    filename
;        Name of video file.
;    dimensions
;       Size of image [pixels].
;       Default: hardware default dimensions.
;    grayscale
;       Convert video frames to grayscale.
;    greyscale
;       Synonym for grayscale.
;    properties
;       List of OpenCV properties.  Not all of these
;       may be supported for any particular video source.
;
; :Author:
;    David G. Grier, New York University
;
; :Copyright:
;    Copyright (c) 2010-2016 David G. Grier
;-

;+
; Read next available video frame.
;
; :Returns:
;    Array of byte-valued pixel data.
;_
function DGGhwVideo::Read

  COMPILE_OPT IDL2, HIDDEN

  return, idlvideo_read(*self.capture, self.grayscale)
end

;+
; Set object properties.
;-
pro DGGhwVideo::SetProperty, dimensions = dimensions, $
                             grayscale = grayscale, $
                             greyscale = greyscale, $
                             _ref_extra = propertylist

  COMPILE_OPT IDL2, HIDDEN

  if isa(propertylist) then begin
     foreach name, strlowcase(propertylist) do begin
        if self.properties.haskey(name) then begin
           property = self.properties[name]
           value = double(scope_varfetch(name, /ref_extra))
           err = idlvideo_SetProperty(*self.capture, property, value)
        endif
     endforeach
  endif

  if isa(grayscale, /number, /scalar) then $
     self.grayscale = keyword_set(grayscale)

  if isa(greyscale, /number, /scalar) then $
     self.grayscale = keyword_set(greyscale)

  if isa(dimensions, /number) && (n_elements(dimensions) eq 2) then begin
     err = idlvideo_SetProperty(*self.capture, $
                                self.properties['width'], dimensions[0])
     err = idlvideo_SetProperty(*self.capture, $
                                self.properties['height'], dimensions[1])
  endif
end


;+
; Retrieve object properties
;-
pro DGGhwVideo::GetProperty, camera = camera, $
                             filename = filename, $
                             properties = properties, $
                             dimensions = dimensions, $
                             grayscale = grayscale, $
                             greyscale = greyscale, $
                             _ref_extra = propertylist

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(camera) then $
     camera = (*self.capture).camera

  if arg_present(filename) then $
     filename = (*self.capture).filename
  
  if arg_present(properties) then $
     properties = self.properties.keys()

  if arg_present(dimensions) then begin
     width  = idlvideo_GetProperty(*self.capture, self.properties['width'])
     height = idlvideo_GetProperty(*self.capture, self.properties['height'])
     dimensions = long([width, height])
  endif

  if arg_present(grayscale) then $
     grayscale = self.grayscale

  if arg_present(greyscale) then $
     greyscale = self.grayscale
  
  if isa(propertylist) then begin
     foreach name, strlowcase(propertylist) do begin
        if self.properties.haskey(name) then begin
           property = self.properties[name]
           value = idlvideo_GetProperty(*self.capture, property)
           (scope_varfetch(name, /ref_extra)) = value
        endif 
     endforeach
  endif
end

;+
; Initialize video source properties
;
; :Hidden:
;-
pro DGGhwVideo::InitProperties

  COMPILE_OPT IDL2, HIDDEN

  ;; obtained from .../include/opencv2/highgui_c.h
  properties = ['time',                 $
                'frames',               $
                'avi_ratio',            $
                'width',                $
                'height',               $
                'fps',                  $
                'fourcc',               $
                'frame_count',          $
                'format',               $
                'mode',                 $
                'brightness',           $
                'contrast',             $
                'saturation',           $
                'hue',                  $
                'gain',                 $
                'exposure',             $
                'convert_rgb',          $
                'white_balance_blue_u', $
                'rectification',        $
                'monochrome',           $
                'sharpness',            $
                'autoexposure',         $
                'gamma',                $
                'temperature',          $
                'trigger',              $
                'trigger_delay',        $
                'white_balance_red_v',  $
                'zoom',                 $
                'focus',                $
                'guid',                 $
                'iso_speed',            $
                'max_dc1394',           $
                'backlight',            $
                'pan',                  $
                'tilt',                 $
                'roll',                 $
                'iris'                  $
               ]
  indexes = indgen(n_elements(properties))
  self.properties = orderedhash(properties, indexes)

  ;;; remove inactive properties
  ;;foreach property, properties do $
  ;;   if (idlvideo_GetProperty(*self.capture, self.properties[property]) eq 0) then $
  ;;      self.properties.remove, property
  
  ;; NOTE: Pruning irrelevant properties results in large numbers of
  ;; error messages from some backends.  Just stick with the essentials.
  self.properties = self.properties[['width', 'height']]
end

;+
; Open video source
;
; :Params:
;    source : in, optional, default=0, type=integer|string
;        Camera number or video file name to use as video source.
;
; :Hidden:
;-
pro DGGhwVideo::OpenSource, source

  COMPILE_OPT IDL2, HIDDEN

  self.closesource
  if isa(source, 'string') then begin
     capture = idlvideo_capturefromfile(source)
  endif else begin
     camera = isa(source, /number, /scalar) ? long(source) : 0L
     capture = idlvideo_capturefromcam(camera)
  endelse

  if isa(capture, 'idlvideo_capture') then $
     self.capture = ptr_new(capture, /no_copy)
end

;+
; Open video source and return status
;
; :Params:
;    source : in, optional, default=0, type=integer|string
;        Camera number or video file name to use as video source
;
; :Hidden:
;-
function DGGhwVideo::OpenSource, source

  COMPILE_OPT IDL2, HIDDEN

  self.OpenSource, source
  return, ptr_valid(self.capture)
end

;+
; Close video source.
;
; :Hidden:
;-
pro DGGhwVideo::CloseSource

  COMPILE_OPT IDL2, HIDDEN

  if ptr_valid(self.capture) then begin
     idlvideo_releasecapture, *self.capture
     ptr_free, self.capture
  endif
end

;+
; Reopen video source, equivalent to rewinding video.
;-
pro DGGhwVideo::Reopen

  COMPILE_OPT IDL2, HIDDEN

  if ~ptr_valid(self.capture) then return
  if (*self.capture).camera ge 0 then return
  filename = (*self.capture).filename
  self.closesource
  self.opensource, filename
end
;+
; Reopen video source, returning status
;-
function DGGhwVideo::Reopen

  COMPILE_OPT2, HIDDEN

  self.Reopen
  return, ptr_valid(self.capture)
end

;+
; Close the video object.
;-
pro DGGhwVideo::Close

  COMPILE_OPT IDL2, HIDDEN

  obj_destroy, self
end

;+
; End-of-life cleanup
;
; :Hidden:
;-
pro DGGhwVideo::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  self.closesource
end

;+
; Initialize the video object.
;
; :Returns:
;    1 for success, 0 for failure.
;
; :Params:
;    source : in, optional, default=0, type=integer|string
;        Video source.  Default is the first available video camera.
;        If a number is provided, that camera number will be used
;        as the video source, if it can be opened.
;        If a filename is provided, that file will be the video source.
;
; :Keywords:
;    dimensions : in, optional, type=lonarr(2)
;        [width, height] of video frame.  Default is
;        the default geometry of the source.
;
;    grayscale : in, optional, type=boolean
;        Convert video frames to grayscale.
;    greyscale : in, optional, type=boolean
;        Synonym for grayscale.
;-
function DGGhwVideo::Init, source, $
                           dimensions = dimensions, $
                           grayscale = grayscale, $
                           greyscale = greyscale

  COMPILE_OPT IDL2, HIDDEN

  self.opensource, source
  if ~isa(*self.capture, 'idlvideo_capture') then $
     return, 0B

  self.initproperties

  if isa(dimensions, /number) && (n_elements(dimensions) eq 2) then begin
     err = idlvideo_SetProperty(*self.capture, $
                                self.properties['width'], dimensions[0])
     err = idlvideo_SetProperty(*self.capture, $
                                self.properties['height'], dimensions[1])
  endif
  
  self.grayscale = keyword_set(grayscale) || keyword_set(greyscale)
  
  return, 1B
end

;+
; Define the video object class.
;
; :Fields:
;    capture : private
;        Pointer to structure of image capture information
;    grayscale : type=boolean
;        Convert to grayscale.
;    properties
;        Structure of properties provided by OpenCV for the
;        video source.
;
; :Hidden:
;-
pro DGGhwVideo__define

  COMPILE_OPT IDL2, HIDDEN
  
  struct = {DGGhwVideo,           $
            capture: ptr_new(),   $
            grayscale: 0L,        $
            properties: obj_new() $
           }
end
