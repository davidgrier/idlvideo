;;;;;
;
; compile_idlvideo.pro
;
; IDL batch file to compile the shared library that provides
; an IDL interface for the video acquisition capabilities of
; OpenCV.
;
; Modification History:
; 02/28/2015 Written by David G. Grier, New York University
;
project_directory = './'
compile_directory = './build'
infiles = 'idlvideo'
outfile = 'idlvideo'

;;; OpenCV support
; Make sure that OpenCV is installed
spawn, 'pkg-config --modversion opencv', version, err
if strlen(err) gt 0 then begin $
    print, 'OpenCV not found' & $
    exit & $
endif
print, 'Building idlvideo with opencv '+version

; CC flags
spawn, 'pkg-config --cflags opencv', extra_cflags
; LD flags
; OpenCV 2.4.0 broke support for
; pkg-config --libs.  We have to extract the necessary
; information by hand. Version 2.4.10 is sane again
ver = fix(strsplit(version, '.', /extract))
if ver[1] lt 4 || ver[2] ge 10 then begin $
   spawn, 'pkg-config --libs opencv', extra_lflags & $
endif else begin $
   spawn, 'pkg-config --libs opencv', info & $
   res = stregex(info, '[^ ]+highgui[^ ]+', /extract) & $
   libpath = '-L'+stregex(res, '.*/', /extract) & $
   extra_lflags = libpath+' -lopencv_highgui -lopencv_core' & $
endelse

;;;;
; Build the library
make_dll, infiles, outfile, 'IDL_Load', $
          extra_cflags = extra_cflags, $
          extra_lflags = extra_lflags, $
          input_directory = project_directory, $
          output_directory = project_directory, $
	  compile_directory = compile_directory, $
          /platform_extension

exit
