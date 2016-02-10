; docformat = 'rst'

;+
; Object for extracting properly scaled grayscale video frames from
; VOB files
;
; :Properties:
;    filename
;        Name of the VOB file to read.
;    framenumber
;        Number of the current frame.
;    data
;        Pixel data for the current frame.
;    dimensions
;        [nx, ny] dimensions of the video frames
;    eof
;        End-of-file flag.
;    roi
;        Region of interest within the rescaled video frame.
;
; :Author:
;    David G. Grier and Bhaskar Jyoti Krishnatreya, New York University
;
; :Copyright:
;    Copyright (c) 2013-2016 David G. Grier and
;    Bhaskar Jyoti Krishnatreya
;-

;+
; Read the next available video frame, rescale it, crop it to the ROI
; and return it.
;
; :Returns:
;    Array of byte-valued pixel data.
;
; :Todo: Check options to CONGRID for possible distortions.
; CENTER, CUBIC, INTERP, and MINUS_ONE
;-
function DGGgrVOB::read

  COMPILE_OPT IDL2, HIDDEN

  self.read
  data = congrid(*self.data, self.width, self.height, /center, cubic = -0.5)
  return, data[self.roi[0]:self.roi[1], self.roi[2]:self.roi[3]]
end

;+
; Store the next available video frame and advance the frame number.
;-
pro DGGgrVOB::read

  COMPILE_OPT IDL2, HIDDEN

  if self.eof then return
  
  data = self.DGGgrVideo::Read()
  self.eof = isa(data, /scalar)
  if ~self.eof then $
     self.data = ptr_new(data, /no_copy)
  self.framenumber++
end

;+
; Rewind the current VOB to the beginning.
;-
pro DGGgrVOB::Rewind

  COMPILE_OPT IDL2, HIDDEN

  self.reopen
  self.framenumber = 0
end

;+
; Retrieve properties.
;-
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

;+
; Initialize DGGgrVOB class object.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Params:
;    filename : in, required, type=string
;        Name of VOB file to read.
;
; :Keywords:
;    roi : in, optional, type=`lonarr(4)`
;        Region of interest within video frame.
;-
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

;+
; Define members of the class.
;
; :Fields:
;    data
;        Byte-valued array of pixel values.
;    framenumber
;        Number of the current video frame.
;    eof
;        End-of-file flag.
;    width
;        Width of the output video frame [pixels].
;    height
;        Height of the output video frame [pixels].
;    roi
;        Region of interest within the rescaled video frame.
;
; :Hidden:
;-
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
