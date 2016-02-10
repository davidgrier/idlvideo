;+
; :Description:
;    Generate documentation for the idlvideo package.
;
; :Uses:
;    IDLdoc by Michael Galloy
;
; :Author:
;    David G. Grier, New York University
;
; :Copyright:
;    Copyright (c) 2016 David G. Grier
;-
if file_which('idldoc.*') then begin $
   idldoc, root='.', output='docs', $
           title='API documentation for idlvideo', $
           subtitle='Video acquisition for IDL based on OpenCV', $
           /nosource, $
           format_style='rst', markup_style='rst' & $
endif else $
   message, "Creating documentation requires Michael Galloy's IDLdoc package"

exit
