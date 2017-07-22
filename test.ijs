Note 'Examples Usage'
 * each line with Ctlr+R
 * select lines and run with diplay Ctrl+E
 * select all Ctrl+A and run Ctrl+E
)

require 'viewmat bmp'          NB. require toucan.bmp for testing

load 'graphics/pplatimg'       NB. ensure reload for testing

viewrgb T=. readimg_pplatimg_ jpath'~addons/graphics/bmp/toucan.bmp'
T writeimg_pplatimg_ jpath'~temp/toucan.jpg'
T writeimg_pplatimg_ jpath'~temp/toucan.png'
viewrgb readimg_pplatimg_ jpath'~temp/toucan.jpg'
viewrgb readimg_pplatimg_ jpath'~temp/toucan.png'

(setalpha T=. i.320 320) writeimg_pplatimg_ jpath'~temp/test1.png'
T -: 0&setalpha readimg_pplatimg_ jpath'~temp/test1.png'
viewrgb readimg_pplatimg_ jpath'~temp/test1.png'
viewrgb T
