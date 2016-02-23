; docformat = 'rst'

;+
; Object for extracting properly scaled grayscale video frames from
; VOB files.
;
; :Examples:
; Read a frame from a VOB file::
;
;    a = DGGgrVOB(filename)
;    b = a.read()
;    tvscl, b
;
; Play an entire VOB file using function graphics::
;
;    a = DGGgrVOB(filename)
;    im = image(a.read())
;    while ~a.eof do im.putdata, a.read()
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
;
; :Author:
;    David G. Grier and Bhaskar Jyoti Krishnatreya, New York University
;
; :Copyright:
;    Copyright (c) 2013-2016 David G. Grier and
;    Bhaskar Jyoti Krishnatreya
;-

;+
; Read the next available video frame, crop its padding, rescale it, 
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
  data = (*self.data)[0:-16, *]
  return, congrid(data, self.width, self.height, /center, cubic = -0.5)
end

;+
; Store the next available video frame and advance the frame number.
;-
pro DGGgrVOB::read

  COMPILE_OPT IDL2, HIDDEN

  if self.eof then return
  
  data = self.DGGgrVideo::Read()
  self.eof = isa(data, /scalar)
  if ~self.eof then begin
     self.data = ptr_new(data, /no_copy)
     self.framenumber++
  endif
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
; Seek specified frame number.
;
; :Params:
;    framenumber : in, required, type=integer
;-
pro DGGgrVOB::Seek, framenumber

  COMPILE_OPT IDL2, HIDDEN

  if self.eof || (self.framenumber gt framenumber) then $
     self.rewind
  while self.framenumber lt framenumber do begin
     self.read
     if self.eof then break
  endwhile
  if self.eof then $
     message, 'end of file encountered before requested frame', /inf
end

;+
; Retrieve properties.
;-
pro DGGgrVOB::GetProperty, eof = eof, $
                           data = data, $
                           framenumber = framenumber, $
                           dimensions = dimensions, $
                           _ref_extra = ex

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(eof) then $
     eof = self.eof

  if arg_present(data) then $
     data = ptr_valid(self.data) ? *self.data : 0L
  
  if arg_present(framenumber) then $
     framenumber = self.framenumber
  
  if arg_present(dimensions) then $
     dimensions = [self.width, self.height]

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
;-
function DGGgrVOB::Init, filename

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

  self.width = 640
  self.height = 480

  if ~self.DGGgrVideo::Init(fn, /gray) then $
     return, 0

  self.eof = 0
  
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
            height: 0L $
           }
end
