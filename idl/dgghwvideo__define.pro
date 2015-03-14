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
;    [IG ] CAMERA: Number of camera to use.
;        Default: 0
;    [IGS] GRAYSCALE: If set, return grayscale images.
;    [ GS] PROPERTIES: List of OpenCV properties.  Not all of these
;        may be supported for any particular camera.
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
;
; Copyright (c) 2010-2015 David G. Grier
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
pro DGGhwVideo::SetProperty, grayscale = grayscale, $
                             _ref_extra = propertylist

  COMPILE_OPT IDL2, HIDDEN

  if isa(propertylist) then begin
     foreach name, strlowcase(propertylist) do begin
        if self.properties.haskey(name) then begin
           propertyid = self.properties[name]
           value = double(scope_varfetch(name, /ref_extra))
           err = idlvideo_SetProperty(*self.capture, propertyid, value)
        endif else $
           message, name + ' is not a valid property for this camera.', /inf
     endforeach
  endif

  if isa(grayscale, /number, /scalar) then $
     self.grayscale = keyword_set(grayscale)
end

;;;;;
;
; DGGhwVideo::GetProperty
;
pro DGGhwVideo::GetProperty, properties = properties, $
                             grayscale = grayscale, $
                             _ref_extra = propertylist

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(properties) then $
     properties = self.properties.keys()

  if arg_present(grayscale) then $
     grayscale = self.grayscale
  
  if isa(propertylist) then begin
     foreach name, strlowcase(propertylist) do begin
        if self.properties.haskey(name) then begin
           propertyid = self.properties[name]
           prop = idlvideo_GetProperty(*self.capture, propertyid)
           (scope_varfetch(name, /ref_extra)) = prop
        endif else begin
           message, name + ' is not a valid property for this camera.', /inf
           (scope_varfetch(name, /ref_extra)) = 0
        endelse
     endforeach
  endif
end

;;;;;
;
; DGGhwVideo::Cleanup
;
pro DGGhwVideo::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  if ptr_valid(self.capture) then begin
     idlvideo_releasecapture, *self.capture
     ptr_free, self.capture
  endif
end

;;;;;
;
; DGGhwVideo::Init()
;
function DGGhwVideo::Init, camera = camera, $
                           grayscale = grayscale

  COMPILE_OPT IDL2, HIDDEN

  camera = isa(camera, /number, /scalar) ? long(camera) : 0L
  capture = idlvideo_capturefromcam(camera)
  if ~isa(capture, 'idlvideo_capture') then $
     return, 0B
  self.capture = ptr_new(capture, /no_copy)

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

  self.grayscale = keyword_set(grayscale)
  
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
