# IDLvideo

**IDL interface for OpenCV video camera image acquisition**

IDL is the Interactive Data Language, and is a product of
[Exelis Visual Information Solutions](http://www.exelisvis.com)

[OpenCV](http://opencv.org) is the Open Source Computer Vision library.

IDLvideo is licensed under the
[GPLv3](http://www.gnu.org/licenses/licenses.html#GPL).

## What it does

IDLvideo is a video framegrabber for IDL based on the
cross-platform OpenCV library.  Its goal is to provide IDL
with the ability to read images directly from video cameras.
It has been tested with IDL 8.3, 8.4 and 8.5
running on both GNU/linux and MacOS systems.

Typical Usage:

    camera = DGGhwVideo() ; object associated with first available camera
    tvscl, camera.read()  ; display the next image


This package is written and maintained by David G. Grier
(david.grier@nyu.edu)

## INSTALLATION

Requirements include

1. IDL (or possibly GDL)
2. OpenCV, including development libraries and headers.
3. Administrator (sudo) privileges.

Steps

1. unpack the distribution in a convenient directory.
2. `cd idlvideo`
3. `make install`
4. make sure that the `IDL_PATH` and `IDL_DLM_PATH`
   environment variables both include `/usr/local/IDL/idlvideo`.

## UNINSTALLATION

Requires administrator (sudo) privileges

1. `cd idlvideo`
2. `make uninstall`

