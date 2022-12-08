Note 'Examples Usage'
 * each line with Ctlr+R
 * select lines and run with diplay Ctrl+E
 * select all Ctrl+A and run Ctrl+E
)

USEPPPNG_z_=: 0

load 'graphics/png bmp'     NB. require toucan.bmp for testing

load 'graphics/pplatimg'    NB. ensure reload for testing

(setalpha 200 300$255) writeimg_pplatimg_ jpath'~temp/blue.png'
(200 300$255) -: 0 setalpha readimg_pplatimg_ jpath'~temp/blue.png'

(setalpha 200 300$256#.255 0 0) writeimg_pplatimg_ jpath'~temp/red.png'
(200 300$256#.255 0 0) -: 0 setalpha readimg_pplatimg_ jpath'~temp/red.png'

(200 300 3 $ 0 0 255) writepng jpath '~temp/blue1.png'
(200 300$255) -: 0 setalpha readimg_pplatimg_ jpath'~temp/blue1.png'
(200 300 3 $ 255 0 0) writepng jpath '~temp/red1.png'
(200 300$256#.255 0 0) -: 0 setalpha readimg_pplatimg_ jpath'~temp/red1.png'

T1=: T=. readimg_pplatimg_ jpath'~addons/graphics/bmp/toucan.bmp'
T1 -:  getimg_pplatimg_ fread '~addons/graphics/bmp/toucan.bmp'   NB. read from memory
T writeimg_pplatimg_ jpath'~temp/toucan.jpg'
T writeimg_pplatimg_ jpath'~temp/toucan.png'
T -: T1=: readimg_pplatimg_ jpath'~temp/toucan.png'
T -: T2=: readpng jpath'~temp/toucan.png'
T1 -: T2

(T=. setalpha i.320 320) writeimg_pplatimg_ jpath'~temp/test1.png'
T -: readimg_pplatimg_ jpath'~temp/test1.png'
T writepng jpath '~temp/test2.png'
T -: readpng jpath'~temp/test2.png'
T -: readimg_pplatimg_ jpath'~temp/test2.png'
