NB. pplatimg manifest

CAPTION=: 'Platform neutral image I/O utilities'

DESCRIPTION=: 0 : 0
Implementations for Windows, Linux and Mac OS X.
Supports BMP, GIF, JPEG, PNG, TIFF, Exif, ICO, WMF,
and EMF formats where available. Returns pixel matrix
in ARGB (Alpha most significant) integer format.
Expects ARGB, or triples of RGB in any axis of rank 3 array.
Good for glpixels. Uses GDI+, Core Graphics (Quartz),
The gdk-pixbuf Library from GTK+.

Ported to 64-bit platforms by Bill Lam
Based on media/platimg developed by Oleg Kobchenko
)

VERSION=: '1.0.05'

RELEASE=: ''

FOLDER=: 'graphics/pplatimg'

PLATFORMS=: 'linux win darwin'

FILES=: 0 : 0
manifest.ijs
pplatimg.ijs
test.ijs
)
