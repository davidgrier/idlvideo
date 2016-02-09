;+
; NAME:
;    DGGgrVOB
;
; PURPOSE:
;    Object for extracting properly scaled grayscale video frames from VOB files
;
; CATEGORY:
;    Video processing
;
; CALLING SEQUENCE:
;    a = DGGgrVOB(filename)
;
; INPUTS:
;    filename: String containing name of VOB file.  May include
;        wildcard specifications
;
; SUBCLASSES:
;    DGGgrVideo
;
; PROPERTIES:
;    filename: File name with wildcards expanded
;    framenumber: Current frame number
;    data: Image data for current image
;    dimensions: [w,h] dimensions of image
;    EOF: flag: set at end of file.
;
; METHODS:
;    DGGGRVOB::Read
;        Reads next video frame into data buffer
;
;    DGGGRVOB::Read()
;        Reads next video frame and returns the data.
;
;    DGGGRVOB::Rewind
;        Closes and reopens video file at first frame.
;
;    GetProperty
;    SetProperty
;
; MODIFICATION HISTORY:
; 08/20/2013 Written by David G. Grier, New York University
; 12/06/2013 DGG and Bhaskar Jyoti Krishnatreya Change default
;    ROI from [4, dim[0]-13, 0, dim[1]-1] to 
;    [8, dim[0]-9, 0, dim[1]-1] for better compatibility with CCD
;    cameras.
; 02/09/2016 DGG revised for DGGgrVideo base class.
;
; Copyright (c) 2013-2016 David G. Grier and Bhaskar Jyoti Krishnatreya
;-

;;;;;
;
; DGGGRVOB::Rewind
;
pro DGGgrVOB::rewind

  COMPILE_OPT IDL2, HIDDEN

  self.DGGgrVideo::Rewind
end

;;;;;
;
; DGGGRVOB::Read()
;
; NOTES: Check options to CONGRID for possible distortions.
; CENTER, CUBIC, INTERP, and MINUS_ONE
;
function DGGgrVOB::read

  COMPILE_OPT IDL2, HIDDEN

  self.read
  data = congrid(*self.data, self.width, self.height, /center, cubic = -0.5)
  return, data[self.roi[0]:self.roi[1], self.roi[2]:self.roi[3]]
end

;;;;;
;
; DGGGRVOB::READ
;
pro DGGgrVOB::read

  COMPILE_OPT IDL2, HIDDEN

  if self.eof then return
  
  data = self.DGGgrVideo::Read()
  self.eof = isa(data, /scalar)
  if ~self.eof then $
     self.data = ptr_new(data, /no_copy)
  self.framenumber++
end

;;;;;
;
; DGGGRVOB::Rewind
;
pro DGGgrVOB::Rewind

  COMPILE_OPT IDL2, HIDDEN

  self.reopen
  self.framenumber = 0
end

;;;;;
;
; DGGGRVOB::GetProperty
;
pro DGGgrVOB::GetProperty, eof = eof, $
                           data = data, $
                           framenumber = framenumber, $
                           dimensions = dimensions, $
                           roi = roi, $
                           _ref_extra = ex

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(eof) then $
     eof = self.eof

  if arg_present(data) then $
     data = ptr_valid(self.data) ? *self.data : 0L
  
  if arg_present(framenumber) then $
     framenumber = self.framenumber
  
  if arg_present(dimensions) then $
     dimensions = [self.roi[1]-self.roi[0]+1, self.roi[3]-self.roi[2]+1]

  if arg_present(roi) then roi = self.roi

  self.DGGgrVideo::GetProperty, _strict_extra = ex
end

;;;;;
;
; DGGGRVOB::Cleanup
;
pro DGGgrVOB::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  self.DGGgrVideo::Cleanup
end

;;;;;
;
; DGGGRVOB::Init()
;
function DGGgrVOB::Init, filename, $
                         roi = roi

  COMPILE_OPT IDL2, HIDDEN

  umsg = 'USAGE: a = DGGgrVOB(filename)'
  
  if n_params() ne 1 then begin
     message, umsg, /inf
     return, 0
  endif

  fn = file_search(filename, count = nfiles)
  if (nfiles ne 1) then begin
     message, umsg, /inf
     message, strtrim(nfiles, 2) + $
              ' files matched the specification ' + filename, /inf
     return, 0
  endif

  self.width = 656
  self.height = 480

  if ~self.DGGgrVideo::Init(fn, /gray) then $
     return, 0
;  self.read
  
  if isa(roi, /number) and (n_elements(roi) eq 4) then begin
     if (roi[0] ge roi[1]) or (roi[2] ge roi[3]) or $
        (roi[0] lt 0) or (roi[1] ge dim[1]) or $
        (roi[2] lt 0) or (roi[3] ge dim[2]) then begin
        message, umsg, /inf
        message, 'ROI: [x0, x1, y0, y1]', /inf
        self.cleanup
        return, 0
     endif
     self.roi = long(roi)
  endif else $
     self.roi = [8, self.width-9, 0, self.height-1]
  
  return, 1
end

;;;;;
;
; DGGGRVOB_DEFINE
;
pro DGGgrVOB__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {DGGgrVOB, $
            inherits DGGgrVideo, $
            data: ptr_new(), $
            framenumber: 0UL, $
            eof: 0L, $
            width: 0L, $
            height: 0L, $
            roi: [0L, 0, 0, 0] $
           }
end
