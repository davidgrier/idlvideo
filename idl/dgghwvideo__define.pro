;+
; NAME:
;    DGGhwVideo
;
; PURPOSE:
;    Object for acquiring a frame-by-frame sequence of images
;    from a video source, which subclasses from the IDLgrModel class.
;
; CATEGORY:
;    Multimedia, object graphics
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
; 02/08/2016 DGG First implementation of reading from video file.
;
; Copyright (c) 2010-2016 David G. Grier
;-

;;;;;
;
; DGGhwVideo::Read()
;
function DGGhwVideo::Read

  COMPILE_OPT IDL2, HIDDEN

  return, idlvideo_read(*self.capture, self.grayscale)
end

;;;;;
;
; DGGhwVideo::SetProperty
;
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
     err = idlvideo_SetProperty(*self.capture, self.properties['width'], dimensions[0])
     err = idlvideo_SetProperty(*self.capture, self.properties['height'], dimensions[1])
  endif
end

;;;;;
;
; DGGhwVideo::GetProperty
;
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

;;;;;
;
; DGGhwVideo::InitProperties
;
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

;;;;;
;
; DGGhwVideo::OpenSource
;
pro DGGhwVideo::OpenSource, source

  COMPILE_OPT IDL2, HIDDEN
  
  if isa(source, 'string') then begin
     capture = idlvideo_capturefromfile(source)
  endif else begin
     camera = isa(source, /number, /scalar) ? long(source) : 0L
     capture = idlvideo_capturefromcam(camera)
  endelse

  self.eof = 1
  if isa(capture, 'idlvideo_capture') then begin
     self.capture = ptr_new(capture, /no_copy)
     self.eof = 0
  endif
end

;;;;;
;
; DGGhwVideo::CloseSource
;
pro DGGhwVideo::CloseSource

  COMPILE_OPT IDL2, HIDDEN

  if ptr_valid(self.capture) then begin
     idlvideo_releasecapture, *self.capture
     ptr_free, self.capture
  endif
end

;;;;;
;
; DGGhwVideo::Reopen
;
pro DGGhwVideo::Reopen

  COMPILE_OPT IDL2, HIDDEN

  if ~ptr_valid(self.capture) then return
  if (*self.capture).camera ge 0 then return
  filename = (*self.capture).filename
  self.closesource
  self.opensource, filename
end

;;;;;
;
; DGGhwVideo::Close
;
pro DGGhwVideo::Close

  COMPILE_OPT IDL2, HIDDEN

  obj_destroy, self
end

;;;;;
;
; DGGhwVideo::Cleanup
;
pro DGGhwVideo::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  self.closesource
end

;;;;;
;
; DGGhwVideo::Init()
;
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

;;;;;
;
; DGGhwVideo__define
;
; Define the DGGhwVideo object
;
pro DGGhwVideo__define

  COMPILE_OPT IDL2, HIDDEN
  
  struct = {DGGhwVideo,           $
            capture: ptr_new(),   $
            grayscale: 0L,        $
            properties: obj_new() $
           }
end
