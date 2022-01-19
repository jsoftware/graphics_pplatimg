NB. platimg - image file I/O for specific platform
NB.
NB. readimg and writeimg use RGB matrix (single numbers).
NB.
NB. writeimg also accepts RGB triples hw3 lines h3w or planes 3hw
NB.
NB. Uses GDI+ on Windows, gdk_pixbuf on Linux and Core Graphics on Mac
NB.

coclass 'pplatimg'

pplatimg_linux=: 0 : 0

LIBGLIB=: 'libgobject-2.0.so.0 '
glcd=: 1 : '(LIBGLIB,m)&cd'
g_type_init=: 'g_type_init > x' glcd
g_free=: 'g_free > x x' glcd

LIBGDKPIX=: 'libgdk_pixbuf-2.0.so.0 '
gdpcd=: 1 : '(LIBGDKPIX,m)&cd'

gdk_pixbuf_new             =: 'gdk_pixbuf_new              > x  x x  x x x'gdpcd
gdk_pixbuf_unref           =: 'gdk_pixbuf_unref            > x  x'         gdpcd

gdk_pixbuf_new_from_data   =: 'gdk_pixbuf_new_from_data    > x  *c x i  i i i  i  x x'gdpcd
gdk_pixbuf_save            =: 'gdk_pixbuf_save             > x  x *c *c *x x'gdpcd

gdk_pixbuf_save_to_buffer  =: 'gdk_pixbuf_save_to_buffer     x  x *x *x *c x x'gdpcd

gdk_pixbuf_new_from_file   =: 'gdk_pixbuf_new_from_file    > x  *c *x'     gdpcd
gdk_pixbuf_get_file_info   =: 'gdk_pixbuf_get_file_info    > x  *c *x *x'  gdpcd

gdk_pixbuf_get_width       =: 'gdk_pixbuf_get_width        > x  x'         gdpcd
gdk_pixbuf_get_height      =: 'gdk_pixbuf_get_height       > x  x'         gdpcd
gdk_pixbuf_get_n_channels  =: 'gdk_pixbuf_get_n_channels   > x  x'         gdpcd
gdk_pixbuf_get_bits_per_sample=:'gdk_pixbuf_get_bits_per_sample > x  x'    gdpcd
gdk_pixbuf_get_rowstride   =: 'gdk_pixbuf_get_rowstride    > x  x'         gdpcd
gdk_pixbuf_get_pixels      =: 'gdk_pixbuf_get_pixels       > x  x'         gdpcd
gdk_pixbuf_get_has_alpha   =: 'gdk_pixbuf_get_has_alpha    > x  x'         gdpcd
gdk_pixbuf_add_alpha       =: 'gdk_pixbuf_add_alpha        > x  x  x x x x'gdpcd

INIT=: 0
init=: 3 : 0
if. -.INIT do. g_type_init '' end.
INIT=: 1
()

rgba2bgra=: ,@(_4&(2 1 0 3&{\))&.(2&(3!:4))"1  NB. little-endian 32-bit color

NB. =========================================================
readimg=: 3 : 0
init''
try. assert buf=. gdk_pixbuf_new_from_file y;,0
catch. 0$0 return. end.
if. gdk_pixbuf_get_has_alpha buf do.
w=. gdk_pixbuf_get_width buf
h=. gdk_pixbuf_get_height buf
a=. gdk_pixbuf_get_pixels buf
z=. (h,w) $ , _2&(3!:4)@:(2 1 0 3&{)("1) _4]\ memr a,0,(4*w*h),JCHAR
else.
assert img=. gdk_pixbuf_add_alpha buf;0;0;0;0
w=. gdk_pixbuf_get_width img
h=. gdk_pixbuf_get_height img
a=. gdk_pixbuf_get_pixels img
z=. (h,w) $ , _2&(3!:4)@:(2 1 0 3&{)("1) _4]\ memr a,0,(4*w*h),JCHAR
gdk_pixbuf_unref img
end.
gdk_pixbuf_unref buf
z
()

NB. y rank-1 byte string
getimg=: 3 : 0
init''
if. IFUNIX do.
t=. '.image',~ LF -.~ 2!:0 'mktemp'
else.
t=. '.image',~ jpath '~temp/pplatimg_', ":2!:6 ''
end.
y 1!:2 <t
z=. readimg t
(1!:55 :: _1:) <t
z
()

infoimg=: 3 : 0
init''
w=. ,_1
h=. ,_1
assert i=. gdk_pixbuf_get_file_info y;w;h
w,h
()

parimg=: 3 : 0
init''
assert b=. gdk_pixbuf_new_from_file y;,0
z=. gdk_pixbuf_get_width b
z=. z,gdk_pixbuf_get_height b
z=. z,gdk_pixbuf_get_n_channels b
z=. z,gdk_pixbuf_get_bits_per_sample b
z=. z,gdk_pixbuf_get_rowstride b
gdk_pixbuf_unref b
z
()

NB. =========================================================
writeimg=: 4 : 0
init''
'y quality'=. 2{.(boxopen y), <75
'h w'=. $x=. rgbmat x
x=. , (2 1 0 3&{)("1) _4]\ (2&(3!:4)) ,x
type=. encoder y

assert buf=. gdk_pixbuf_new_from_data x;0;1;8;w;h;(4*w);0;0
if. type-:'jpeg' do.
assert (LIBGDKPIX,' gdk_pixbuf_save > x x *c *c x *c *c x')&cd buf;y;type;0;'quality';(":<.quality);0
elseif. type-:'png' do.
assert (LIBGDKPIX,' gdk_pixbuf_save > x x *c *c x *c *c x')&cd buf;y;type;0;'compression';(,'0');0
elseif. do.
assert (LIBGDKPIX,' gdk_pixbuf_save > x x *c *c x x')&cd buf;y;type;0;0
end.
gdk_pixbuf_unref buf

4*w*h
()

putimg=: 4 : 0
init''
'y quality'=. 2{.(boxopen y), <75
'h w'=. $x=. rgbmat x
x=. , (2 1 0 3&{)("1) _4]\ (2&(3!:4)) ,x
type=. encoder y

assert buf=. gdk_pixbuf_new_from_data x;0;1;8;w;h;(4*w);0;0
IMG=. ,_1
SIZ=. ,_1
if. type-:'jpeg' do.
assert >@{. cdrc=. (LIBGDKPIX,' gdk_pixbuf_save_to_buffer x  x *x *x *c x *c *c x')&cd buf;IMG;SIZ;type;0;'quality';(":<.quality);0
elseif. type-:'png' do.
assert >@{. cdrc=. (LIBGDKPIX,' gdk_pixbuf_save_to_buffer x  x *x *x *c x *c *c x')&cd buf;IMG;SIZ;type;0;'compression';(,'0');0
elseif. do.
assert >@{. cdrc=. (LIBGDKPIX,' gdk_pixbuf_save_to_buffer x  x *x *x *c x x')&cd buf;IMG;SIZ;type;0;0
end.
'IMG SIZ'=. ; 2 3{cdrc
img=. memr IMG,0,SIZ
g_free IMG
gdk_pixbuf_unref buf
img
()

EXT=: cut 'bmp gif ico jpg;jpeg png tif;tiff '
UTI=: cut 'bmp gif ico jpeg png tiff '

encoder=: 3 : 0
UTI {::~ y typendx EXT
()
)

NB. platimg/win - image files for Windows

pplatimg_win=: 0 : 0

3 : 0''
s=. 'Ok GenericError InvalidParameter OutOfMemory ObjectBusy InsufficientBuffer '
s=. s,'NotImplemented Win32Error WrongState Aborted FileNotFound ValueOverflow '
s=. s,'AccessDenied UnknownImageFormat FontFamilyNotFound FontStyleNotFound '
s=. s,'NotTrueTypeFont UnsupportedGdiplusVersion GdiplusNotInitialized '
s=. ;:s,'PropertyNotFound PropertyNotSupported ProfileNotFound'

assi=: {::&s assert 0=]
''
()

cdi=: (&cd)(assi@)

PixelFormatGDI           =: 16b00020000 NB. Is a GDI-supported format
PixelFormatAlpha         =: 16b00040000 NB. Has an alpha component
PixelFormatCanonical     =: 16b00200000

PixelFormatUndefined=: 16b0
PixelFormatDontCare=: PixelFormatUndefined
PixelFormatMax=: 16bf
PixelFormat1_8=: 16b100
PixelFormat4_8=: 16b400
PixelFormat8_8=: 16b800
PixelFormat16_8=: 16b1000
PixelFormat24_8=: 16b1800
PixelFormat32_8=: 16b2000
PixelFormat48_8=: 16b3000
PixelFormat64_8=: 16b4000
PixelFormat16bppRGB555=: 16b21005
PixelFormat16bppRGB565=: 16b21006
PixelFormat16bppGrayScale=: 16b101004
PixelFormat16bppARGB1555=: 16b61007
PixelFormat24bppRGB=: 16b21808
PixelFormat32bppRGB=: 16b22009
PixelFormat32bppARGB=: 16b26200a
PixelFormat32bppPARGB=: 16bd200b
PixelFormat48bppRGB=: 16b10300c
PixelFormat64bppARGB=: 16b34400d
PixelFormat64bppPARGB=: 16b1c400e
PixelFormatGDI=: 16b20000
PixelFormat1bppIndexed=: 16b30101
PixelFormat4bppIndexed=: 16b30402
PixelFormat8bppIndexed=: 16b30803
PixelFormatAlpha=: 16b40000
PixelFormatIndexed=: 16b10000
PixelFormatPAlpha=: 16b80000
PixelFormatExtended=: 16b100000
PixelFormatCanonical=: 16b200000

GdiplusStartup           =: 'gdiplus GdiplusStartup              i   *x *x x         ' &cd
GdiplusShutdown          =: 'gdiplus GdiplusShutdown           > n   x               ' &cd

GdipCreateBitmapFromGdiDib=:'gdiplus GdipCreateBitmapFromGdiDib   i  x x *x       ' &cd
GdipCreateBitmapFromStream=:'gdiplus GdipCreateBitmapFromStream   i  x *x           ' &cd
GdipCreateBitmapFromFile =: 'gdiplus GdipCreateBitmapFromFile    i   *w *x           ' &cd
GdipCreateBitmapFromScan0=: 'gdiplus GdipCreateBitmapFromScan0   i   i i  i i   x *x ' &cd
GdipSaveImageToFile      =: 'gdiplus GdipSaveImageToFile       > i   x *w *c *c      ' cdi
GdipSaveImageToStream    =: 'gdiplus GdipSaveImageToStream     > i   x x *c *c       ' cdi
GdipDisposeImage         =: 'gdiplus GdipDisposeImage          > i   x               ' cdi

GdipBitmapLockBits       =: 'gdiplus GdipBitmapLockBits          i   x *x i i *x      ' &cd
GdipBitmapUnLockBits     =: 'gdiplus GdipBitmapUnlockBits      > i   x *x            ' cdi

GdipGetImageEncodersSize =: 'gdiplus GdipGetImageEncodersSize    i   *i *i           ' &cd
GdipGetImageEncoders     =: 'gdiplus GdipGetImageEncoders        i    i  i  *c       ' &cd
GdipGetImageWidth        =: 'gdiplus GdipGetImageWidth           i    x  *i          ' &cd
GdipGetImageHeight       =: 'gdiplus GdipGetImageHeight          i    x  *i          ' &cd

CreateStreamOnHGlobal    =: 'ole32 CreateStreamOnHGlobal         i   x i *x' &cd
GetHGlobalFromStream     =: 'ole32 GetHGlobalFromStream          i   x *x' &cd
OleRelease               =: 'olecli32 OleRelease                 i   x'&cd

GlobalAlloc              =: 'kernel32 GlobalAlloc              > x   i x'&cd
GlobalSize               =: 'kernel32 GlobalSize               > x   x'&cd
GlobalLock               =: 'kernel32 GlobalLock               > x   x'&cd
GlobalUnlock             =: 'kernel32 GlobalUnlock             > i   x'&cd
GlobalFree               =: 'kernel32 GlobalFree               > i   x'&cd
coRelease=: ('1 2 > x x')&cd

ImageLockModeRead=: 1
ImageLockModeUserInputBuf=: 4
GUID=: 'WWWWXXYYZZZZZZZZ'
BitmapData=: 'WdthHghtStrdFrmtScanRsrv'
GdiplusStartupInput=: 1 0 0 0
iad=: 15!:14@boxopen

NB. =========================================================
readimg=: 3 : 0
BMP=. TOK=. ,_1
DATA=. i.4%~#BitmapData
assi rc [ 'rc TOK'=. ; 2{. GdiplusStartup TOK;GdiplusStartupInput;0
try.
assi >@{.cdrc [ cdrc=. GdipCreateBitmapFromFile (u:y,2#{.a.);BMP
BMP=. {. _1{::cdrc
catch. 0$0 [ GdiplusShutdown TOK return. end.
assi rc [ 'rc DATA'=. 0 _1{ GdipBitmapLockBits BMP;(<0);ImageLockModeRead;PixelFormat32bppARGB;DATA
if. IF64 do.
  'wh sf p r'=. 4{.DATA
  'w h'=. _2&ic 3&ic wh
  's f'=. _2&ic 3&ic sf
   z=. |.^:(s<0) w&{."1^:(w~:|s%4) _2&ic("1) (h,|s)$memr p,((s<0)*s*<:h),(h*<.|s),JCHAR
else.
  'w h s f p r'=. DATA
   z=. |.^:(s<0) w&{."1^:(w~:|s%4) (h,|s%4)$memr p,((s<0)*s*<:h),(h*<.|s%4),JINT
end.
GdipBitmapUnLockBits BMP;DATA
GdipDisposeImage BMP
GdiplusShutdown TOK
z
()

NB. usage
NB.    testgdiplus ''  NB. 0 is success
NB.    r=: getimg_pplatimg_ (rank-1 byte string)
NB.    r=: readimg_pplatimg_ 'D:/photo/u1_6004.jpg'
NB.    r writeimg_pplatimg_ 'D:/photo/u1_60042.jpg' ; {.jpegqty
NB.    a=: r putimg_pplatimg_ 'D:/photo/u1_60042.jpg'; 90

NB. =========================================================
testgdiplus=: 3 : 0
TOK=. ,_1
try.
  if. 0= rc [ 'rc TOK'=. ; 2{. GdiplusStartup TOK;GdiplusStartupInput;0 do. GdiplusShutdown TOK end.
  rc
catch.
  1
end.
()

NB. y rank-1 byte string
getimg=: 3 : 0
NB.  allocate global Memory (GMEM_MOVEABLE GMEM_NONDISCARDABLE) and copy byte array into it
HDL=. GlobalAlloc 16b2 ; #y
y memw (GlobalLock <HDL), 0, #y
TOK=. BMP=. STR=. ,_1
assi rc [ 'rc TOK'=. ; 2{. GdiplusStartup TOK;GdiplusStartupInput;0
NB.  we create an IStream from the global memory
assi rc [ 'rc STR'=. ; 0 _1{ CreateStreamOnHGlobal HDL ; 1 ; STR
NB.  GDI+ takes this stream, and creates the image
z=. ''
try.
assi >@{.cdrc [ cdrc=. GdipCreateBitmapFromStream STR;BMP
BMP=. {. _1{::cdrc
DATA=. i.4%~#BitmapData
assi rc [ 'rc DATA'=. 0 _1{ GdipBitmapLockBits ({.BMP);(<0);ImageLockModeRead;PixelFormat32bppARGB;DATA
if. IF64 do.
  'wh sf p r'=. 4{.DATA
  'w h'=. _2&ic 3&ic wh
  's f'=. _2&ic 3&ic sf
   z=. |.^:(s<0) w&{."1^:(w~:|s%4) _2&ic("1) (h,|s)$memr p,((s<0)*s*<:h),(h*<.|s),JCHAR
else.
  'w h s f p r'=. DATA
  z=. |.^:(s<0) w&{."1^:(w~:|s%4) (h,|s%4)$memr p,((s<0)*s*<:h),(h*<.|s%4),JINT
end.
GdipBitmapUnLockBits BMP;DATA
GdipDisposeImage BMP
catch. end.
coRelease STR
GdiplusShutdown TOK
GlobalUnlock <HDL
GlobalFree <HDL
z
()

NB. get clipboard cf_dib data
getcfdib=: 3 : 0
z=. ''
TOK=. BMP=. ,_1
assi rc [ 'rc TOK'=. ; 2{. GdiplusStartup TOK;GdiplusStartupInput;0
'user32 OpenClipboard i x'&cd <0
if. 0~:HDL=. 'user32 GetClipboardData > x i'&cd <8 do.
try.
assi >@{.cdrc [ cdrc=. GdipCreateBitmapFromGdiDib HDL;(HDL+40);BMP
BMP=. {. _1{::cdrc
DATA=. i.4%~#BitmapData
assi rc [ 'rc DATA'=. 0 _1{ GdipBitmapLockBits BMP;(<0);ImageLockModeRead;PixelFormat32bppARGB;DATA
if. IF64 do.
  'wh sf p r'=. 4{.DATA
  'w h'=. _2&ic 3&ic wh
  's f'=. _2&ic 3&ic sf
   z=. |.^:(s<0) w&{."1^:(w~:|s%4) _2&ic("1) (h,|s)$memr p,((s<0)*s*<:h),(h*<.|s),JCHAR
else.
  'w h s f p r'=. DATA
  z=. |.^:(s<0) w&{."1^:(w~:|s%4) (h,|s%4)$memr p,((s<0)*s*<:h),(h*<.|s%4),JINT
end.
GdipBitmapUnLockBits BMP;DATA
GdipDisposeImage BMP
catch. end.
GlobalUnlock <HDL
end.
'user32 CloseClipboard i'&cd ''
GdiplusShutdown TOK
z
()

NB. =========================================================
NB. // Setting the jpeg quality
NB. int Quality = 90;
NB. encoderParameters.Count = 1;
NB. encoderParameters.Parameter[0].Guid = mEncoderQuality;               // 16
NB. encoderParameters.Parameter[0].NumberOfValues = 1;                   // 4
NB. encoderParameters.Parameter[0].Type = EncoderParameterValueTypeLong; // 4
NB. encoderParameters.Parameter[0].Value = &Quality;                     // 4/8

EncoderQuality=: (1&(3!:4) (16b1d5b,~ 16be4b5), 16bfa4a 16b452d), a.{~ 16b9c 16bdd 16b5d 16bb3 16b51 16b05 16be7 16beb

writeimg=: 4 : 0
'y quality'=. 2{.(boxopen y), <75
NB. TODO adcntr not used because memory leak if error
qual=. 'qual', ": 1 [ adcntr=: >:adcntr
(qual)=: <.quality
parm=. ((IF64{2 3)&(3!:4) 1), EncoderQuality, (2&(3!:4) 1 4), (IF64{2 3)&(3!:4) iad qual
x=. rgbmat x
'h w'=. $x
TOK=. ,_1 [ BMP=. ,_1
assi rc [ 'rc TOK'=. ; 2{. GdiplusStartup TOK;GdiplusStartupInput;0
try.
x=. 2&(3!:4)@:,^:IF64 x
assi >@{.cdrc [ cdrc=. GdipCreateBitmapFromScan0 w;h;(w*4);PixelFormat32bppARGB;(iad 'x');BMP
BMP=. {. _1{::cdrc
catch. _1 [ 4!:55 <qual [ GdiplusShutdown TOK return. end.
ENC=. encoder y
GdipSaveImageToFile BMP;(u:y,{.a.);ENC;parm
GdipDisposeImage BMP
GdiplusShutdown TOK
4!:55 <qual
4*w*h
()

putimg=: 4 : 0
'y quality'=. 2{.(boxopen y), <75
NB. TODO adcntr not used because memory leak if error
qual=. 'qual', ": 2 [ adcntr=: >:adcntr
(qual)=: <.quality
parm=. ((IF64{2 3)&(3!:4) 1), EncoderQuality, (2&(3!:4) 1 4), (IF64{2 3)&(3!:4) iad qual
x=. rgbmat x
'h w'=. $x
TOK=. ,_1 [ BMP=. ,_1
assi rc [ 'rc TOK'=. ; 2{. GdiplusStartup TOK;GdiplusStartupInput;0
try.
x=. 2&(3!:4)@:,^:IF64 x
assi >@{.cdrc [ cdrc=. GdipCreateBitmapFromScan0 w;h;(w*4);PixelFormat32bppARGB;(iad 'x');BMP
BMP=. {. _1{::cdrc
catch. '' [ 4!:55 <qual [ GdiplusShutdown TOK return. end.
ENC=. encoder y

STR=. ,_2 [ HDL=. ,_2
assi rc [ 'rc STR'=. ; 0 _1{ CreateStreamOnHGlobal 0;1;STR
GdipSaveImageToStream BMP;STR;ENC;parm
assi rc [ 'rc HDL'=. ; 0 _1{ GetHGlobalFromStream STR;HDL
img=. memr (GlobalLock <HDL), 0, GlobalSize <HDL
GlobalUnlock <HDL

GdipDisposeImage BMP
coRelease STR
GdiplusShutdown TOK
4!:55 <qual
img
()

NB. =========================================================
wstr=: (''"_)`([: ({.~ i.&({.a.)) 6: u: [:memr ,&(0,40))@.*("0)

encoder=: 3 : 0
NUM=. ,_1 [ SZ=. ,_1
assi >@{.cdrc [ cdrc=. GdipGetImageEncodersSize NUM;SZ
'NUM SZ'=. ; 1 2{cdrc
ENCS=. (IF64{76,104)]\SZ#'z'
assi >@{.cdrc [ cdrc=. GdipGetImageEncoders NUM;SZ;ENCS
ENCS=. _1{::cdrc
ENCS=. NUM{.ENCS
guids=. (#GUID){.("1) ENCS
infoaddr=. (IF64{_2 _3)(3!:4)("1) ( (0,2*#GUID) ,: _,(IF64{4 8)*5 ) ];.0 ENCS
infos=. <@wstr infoaddr
guids {~ y typendx tolower&.> 3{("1) infos
()
)

NB. platimg/darwin - image files for macos

pplatimg_darwin=: 0 : 0

cfcd=: 1 : '(''/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation '',m)&cd'

CFStringCreateWithCString=:     'CFStringCreateWithCString     > x   x *c i    ' cfcd
CFURLCreateWithFileSystemPath=: 'CFURLCreateWithFileSystemPath > x   x x x i   ' cfcd
CFDataCreateMutable=:           'CFDataCreateMutable           > x   x x       ' cfcd
CFDataGetMutableBytePtr=:       'CFDataGetMutableBytePtr       > x   x         ' cfcd
CFDataGetLength=:               'CFDataGetLength               > x   x         ' cfcd
CFRelease=:                     'CFRelease                     > n   x         ' cfcd

kCFStringEncodingUTF8=: 16b08000100
kCFURLPOSIXPathStyle=: 0

cfstr=: 3 : 'CFStringCreateWithCString 0;y;kCFStringEncodingUTF8'

ascd=: 1 : '(''/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices '',m)&cd'

CGImageSourceCreateWithURL=:         'CGImageSourceCreateWithURL       > x   x x       ' ascd
CGImageSourceCreateImageAtIndex=:    'CGImageSourceCreateImageAtIndex  > x   x x x     ' ascd

CGImageDestinationCreateWithURL=:    'CGImageDestinationCreateWithURL  > x   x x   x x ' ascd
CGImageDestinationCreateWithData=:   'CGImageDestinationCreateWithData > x   x x   x x ' ascd
CGImageDestinationAddImage=:         'CGImageDestinationAddImage       > n   x x x     ' ascd
CGImageDestinationFinalize=:         'CGImageDestinationFinalize       > i   x         ' ascd

CGBitmapContextCreateImage=:         'CGBitmapContextCreateImage       > x   x         ' ascd
CGImageGetWidth=:                    'CGImageGetWidth                  > x   x         ' ascd
CGImageGetHeight=:                   'CGImageGetHeight                 > x   x         ' ascd
CGImageRelease=:                     'CGImageRelease                   > n   x         ' ascd

CGColorSpaceCreateWithName=:         'CGColorSpaceCreateWithName       > x   x         ' ascd
CGColorSpaceRelease=:                'CGColorSpaceRelease              > n   x         ' ascd

CGBitmapContextCreate=:              'CGBitmapContextCreate            > x   x  x x   x x x i ' ascd
CGContextRelease=:                   'CGContextRelease                 > n   x         ' ascd
CGContextDrawImage=:                 (IF64{::'CGContextDrawImage       > n   x f f f f x ';'CGContextDrawImage > n x x x x x x x x x x ') ascd

kCGColorSpaceGenericRGB=: 'kCGColorSpaceGenericRGB'
kCGImageAlphaPremultipliedFirst=: 2

NB. =========================================================
pMAT=: 0
bitmapContext=: 4 : 0       NB.  release ctx
  s=. cfstr kCGColorSpaceGenericRGB
  CFRelease s [ cs=. CGColorSpaceCreateWithName s

  ctx=. CGBitmapContextCreate pMAT;x;y;8;(x*4);cs;kCGImageAlphaPremultipliedFirst
  CGColorSpaceRelease cs
  ctx
()

urlFromStr=: 3 : 0                 NB. release url
  s=. cfstr y
  CFRelease s [ url=. CFURLCreateWithFileSystemPath 0;s;kCFURLPOSIXPathStyle;0
  s=. cfstr y
  url
()

NB. =========================================================
readimg=: 3 : 0
  img=. imageFromSource y

  w=. CGImageGetWidth img
  h=. CGImageGetHeight img

  pMAT=: mema 4*h*w
  ctx=. w bitmapContext h

  if. IF64 do.
  'w1 h1'=. (_3&ic)@(2&fc)@(+&(-~1.5)) w,h
NB. amd64 CGFloat is double, CGRect structure is 32 bytes
NB. sysv abi, structure size > 16 bytes always passed on stack
  CGContextDrawImage ctx;img;_1;_1;_1;_1;0;0;w1;h1
  else.
  CGContextDrawImage ctx;0;0;w;h;img
  end.
  CGContextRelease ctx
  CGImageRelease img
  z=. (h,w)$_2 ic , |.("1) _4]\ memr pMAT,0,(4*h*w),2
  pMAT=:0 [ memf pMAT
  z
()

NB. y rank-1 byte string
getimg=: 3 : 0
if. IFUNIX do.
t=. '.image',~ LF -.~ 2!:0 'mktemp'
else.
t=. '.image',~ jpath '~temp/pplatimg_', ":2!:6 ''
end.
y 1!:2 <t
z=. readimg t
(1!:55 :: _1:) <t
z
()

imageFromSource=: 3 : 0     NB. release img
  url=. urlFromStr y

  CFRelease url [ is=. CGImageSourceCreateWithURL url;0
  'image not found' assert is

  CFRelease is [ img=. CGImageSourceCreateImageAtIndex is;0;0
  img
()

NB. =========================================================
writeimg=: 4 : 0
  'y quality'=. 2{.(boxopen y), <75
  x=. rgbmat x
  'h w'=. $x

  pMAT=: mema 4*h*w
  if. IF64 do.
  (, |.@(4&{.)("1) _8]\ 3 ic ,x) memw pMAT,0,(4*h*w),2
  else.
  ((h,w)$_2 ic , |.("1) _4]\ 2 ic ,x) memw pMAT,0,(h*w),4
  end.
  ctx=. w bitmapContext h

  img=. CGBitmapContextCreateImage ctx
  dest=. imageDest y
  CGImageDestinationAddImage dest;img;0
  CFRelease dest [ CGImageDestinationFinalize dest

  CGImageRelease img
  CGContextRelease ctx
  pMAT=: 0 [  memf pMAT
  4*w*h
()

putimg=: 4 : 0
  'y quality'=. 2{.(boxopen y), <75
  x=. rgbmat x
  'h w'=. $x

  pMAT=: mema 4*h*w
  if. IF64 do.
  (, |.@(4&{.)("1) _8]\ 3 ic ,x) memw pMAT,0,(4*h*w),2
  else.
  ((h,w)$_2 ic , |.("1) _4]\ 2 ic ,x) memw pMAT,0,(h*w),4
  end.
  ctx=. w bitmapContext h

  img=. CGBitmapContextCreateImage ctx
  data=. CFDataCreateMutable 0;0
  dest=. data imageDest y
  CGImageDestinationAddImage dest;img;0
  CFRelease dest [ CGImageDestinationFinalize dest
  buf=. memr (CFDataGetMutableBytePtr data),0,CFDataGetLength data
  CFRelease data
  CGImageRelease img
  CGContextRelease ctx
  pMAT=: 0 [ memf pMAT
  buf
()

imageDest=: 0&$: : (4 : 0)     NB. release dest
  type=. encoder y
  if. x do.
    dest=. CGImageDestinationCreateWithData x;type;1;0
  else.
    url=. urlFromStr y
    CFRelease url [ dest=. CGImageDestinationCreateWithURL url;type;1;0
  end.
  CFRelease type
  'cannot create destination' assert dest
  dest
()

EXT=: cut 'bmp gif jpg;jpeg png tif;tiff '
UTI=: cut 'com.microsoft.bmp com.compuserve.gif public.jpeg public.png public.tiff '

encoder=: 3 : 0
  cfstr UTI {::~ y typendx EXT
()

)


NB.*readimg v returns RGB matrix from file
NB.   rgbMatrix=. readimg_pplatimg_ filename

NB.*writeimg v writes RGB data to file
NB.   bytesWritten=: rgbData writeimg_pplatimg_ filename

NB.*putimg v converts RGB data to format buffer
NB.   formatData=: rgbData putimg_pplatimg_ format   'png','jpg',...

NB. =========================================================
NB. common internal operations

adcntr=: 0

macrofix=: 3 : 0
y=. toJ y
y=. <;.2 y, LF
m=. y = <'()', LF
;(<')', LF) (I.m) } y
)

(0!:100) macrofix ('pplatimg_',tolower UNAME)~

rgbmat=: 3 : 0
'empty data' assert 0<#y
'rank error' assert 3>:#$y
while. 2 > #$y do. y=. ,:y end.
if. 3=#$y do.
  assert 3 e. $y
  y=. 256#.(|:~ (i.3) A.~ _1 + 2 ^ 2 - 3 i.~$) y
end.
y
)

fileext=: #~ [:-. [:+./\.'.'&=
hex=: ([: ;:^:_1("1) [: <("1) ('0123456789abcdef'"_) {~ (16"_) #.^:_1 ])@(([: , (_4:) _2&(3!:4)@|.\ ])^:(2: = 3!:0))

typendx=: 4 : 0
assert 0<# ext=. tolower fileext x
'image type' assert #ndcs=. (<ext) I.@:(+./@E.&>) y
{.ndcs
)

