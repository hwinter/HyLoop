;+
; NAME:
;      show_loop_image
; PURPOSE
;      given a loop axis axis(3, n) and radii rad(n), draw an image.
;      First draw an axis for the loop, then form the image using
;      the optically-thin model loop_image().  the image formed will
;      have pixels of approximate size pixel (specified in
;      the data units defined by the coordinate axis) to imitate
;      finite instrument resolution.
; USAGE:
;      show_loop_image, axis, rad, phi [, options ]
; ARGUMENTS:
;      axis - array(3,n) specifying points on the loops axis, in data
;             coordinates. [] 
;      rad - array(n) specifying the loop's cross section at each
;            point, in data
;             coordinates. []
;      phi - number of instrument counts per vol. of plasma
;
; KEYWORDS:
;      pixel - the dimensions of an instrument pixel in data
;              coordinates.  (default: pixel = 1.0)
;      over - if set the image will be fored within a pre-exisiting
;             coordinate system
;      add -  if set the current image is added to the previous image.
;             this will also automatically set the over keyword
;      noscale - if the set image will not be scaled
;      subsamp = n - sub-samples by creating n^2 pixels within
;                each instrument pixel
;      sqrt - if set the image displayed will be the sqrt() of the
;             counts
;
; HISTORY:     
; 10/4/99,jln -- added argument phi, described above
; 11/13/00, DWL - various improvements
; 2005-DEC  HDW- various improvements,
;                Added keywords, ,IMAGE_OUT=IMAGE_OUT
;                Made int variables long
; 2006-AUG-20 HDW Added /iso to plot command.
; 2007-NOV-02 HDW Added the PAD keyword.  This adds a padding
;                to the output image size.

;-

PRO show_loop_image, axis, rad, phi, pixel=pixel, over=over, add=add, $
                     noscale=noscale,  subsamp=subsamp, sqrt=sqrt,$
                     WIN_INDEX=WIN_INDEX,$
                     dxp0=dxp0, dyp0=dyp0,$
                     IMAGE_OUT=IMAGE_OUT,$
                     XS=XS, YS=YS, DATA_OUT=DATA_OUT, $
                     PAD=PAD, XC=XC, YC=YC, $
                     XMN_CM=XMN_CM,XMX_CM=XMX_CM,YMN_CM=YMN_CM,$
                     YMX_CM=YMX_CM, _extra=extra

IF( keyword_set( add ) ) THEN over=1
IF( NOT keyword_set(pixel) ) THEN pixel = 1.0;  default value
IF( NOT keyword_set(subsamp) ) THEN subsamp = 1
IF( NOT keyword_set(over) ) THEN BEGIN
;draw coordinate system if not previously defined
    xmx = max( axis[0, *] ) + 2*max( rad )
    xmn = min( axis[0, *] ) - 2*max( rad )
    ymx = max( axis[1, *] ) + 2*max( rad )
    ymn = min( axis[1, *] ) - 2*max( rad )
    
;Pad usually to keep the image from running off the image when convolved with a 
;  PSF

  if keyword_set(PAD) then begin
      xmx=xmx+pad
      xmn=xmn-pad
      ymx=ymx+pad
      ymn=ymn-pad
  endif

 
ENDIF
IF keyword_set(over)  THEN BEGIN

    xmx = !X.crange[1]
    xmn =!X.crange[0]
    ymx = !Y.crange[1]
    ymn = !Y.crange[0]
    
endif
old_axis=axis
old_rad=rad
old_phi=phi
n_s=n_elements(axis[0,*])

ds1=axis[*,0]-axis[*,1]
ds2=axis[*,n_s-1]-axis[*,n_s-2]

x=dblarr(n_s+2)
x[0]=ds1[0]+axis[0,0]
x[1:n_s]=axis[0,* ]
x[n_s+1]=axis[0,n_s-1]+ds2[0]

y=dblarr(n_s+2)
y[0]=ds1[1]+axis[1,0]
y[1:n_s]=axis[1,* ]
y[n_s+1]=axis[1,n_s-1]+ds2[1]

z=dblarr(n_s+2)
z[0]=ds1[2]+axis[2,0]
z[1:n_s]=axis[2,* ]
z[n_s+1]=axis[2,n_s-1]+ds2[2]

axis=transpose([[x], [y], [z]])  
    
rad=[rad[0], rad, rad[n_s-1ul]]
phi=[0,phi, phi[n_elements(phi)-1ul]]  
IF KEYWORD_SET(XMN_CM) then xmn=XMN_CM
IF KEYWORD_SET(XMX_CM) then xmx=XMX_CM
IF KEYWORD_SET(YMN_CM) then ymn=YMN_CM
IF KEYWORD_SET(YMX_CM) then ymx=YMX_CM
IF( NOT keyword_set(over) ) THEN $
  plot, [0], [0], /nodata, xst=16, yst=16, xr=[xmn, xmx], yr=[ymn, ymx ], $
        xticklen=-0.015, yticklen=-0.015, /iso

; find locations (in data coords) of instrument pixels
corners = convert_coord([0,1],[0,1], /device, /to_data )
;size of a device pixel in data coordinates
xp = corners[0,1] - corners[0,0]
yp = corners[1,1] - corners[1,0]


;#of screen pixels in x
nspx = ulong64( (pixel/xp) + 1 )
;#of screen pixels in y
nspy = ulong64( (pixel/yp) + 1 ) 

;new instrument pixels
;number of screen pixels * the size of each
xpixel = nspx * xp
ypixel = nspy * yp

 
wp_pix = convert_coord( !x.window, !y.window, /normal, /to_data )
xp0 = wp_pix[0,0] ; x of lower left pixel
yp0 = wp_pix[1,0] ; y of lower left pixel
xp1 = wp_pix[0,1] ; x of upper right pixel
yp1 = wp_pix[1,1] ; y of upper right pixel

;Calculate the center of the image
xc=(xp1-xp0)/(2d0)
yc=(yp1-yp0)/(2d0)

;Calculate the number of instrument pixels. 
x_num_inst_pix = ulong64( (xp1-xp0) / xpixel ) >1
y_num_inst_pix = ulong64( (yp1-yp0) / ypixel ) >1
;stop
;Centers of each pixel in data coordinates
;HDWIII added the >1 2010-7-19
x_pix = xp0 + ( xpixel * ((l64indgen((subsamp*x_num_inst_pix)>1)+.5)/subsamp)>1 )
y_pix = yp0 + ( ypixel * ((l64indgen((subsamp*y_num_inst_pix)>1)+.5)/subsamp)>1 ) 

ss_img = loop_image( axis, rad, phi, x_pix, y_pix )
img =  rebin( ss_img, x_num_inst_pix, y_num_inst_pix )
;img =  congrid( ss_img, x_num_inst_pix, y_num_inst_pix,/center )
IF( keyword_set(sqrt) ) THEN img =  sqrt(abs(img))

; expand img until it fills coordinate axes
screen_image = rebin( img, x_num_inst_pix * nspx, y_num_inst_pix * nspy, $
  /sample)

;back to device coord. for tvscl
dwp_pix = convert_coord( !x.window, !y.window, /normal, /to_device )
dxp0 = dwp_pix[0,0]+1; x of lower left pixel
dyp0 = dwp_pix[1,0]+1; y of lower left pixel

IF keyword_set(WIN_INDEX) then wset,WIN_INDEX
;help,!D.unit
if( keyword_set( add ) ) then begin
    print,'add'
  old_screen = tvrd()
  ;window,3
  ;pmm,old_screen
  dxp1 = dxp0 + x_num_inst_pix * nspx - 1
  dyp1 = dyp0 + y_num_inst_pix * nspy - 1
  ;screen_image = old_screen+screen_image; 
  screen_image = screen_image+ old_screen[ dxp0:dxp1, dyp0:dyp1 ]
 ; tvscl,old_screen;screen_image
;  wset,win_INDEX
ENDIF

if( keyword_set( noscale ) ) then begin
  tv, long(screen_image < 255), dxp0, dyp0
endif else begin
  tvscl, screen_image, dxp0, dyp0, _extra=extra
endelse
IMAGE_OUT=screen_image
data_out=ss_img
;stop

;print, 'xc, yc:',xc,',', yc
axis=old_axis
rad=old_rad
phi=old_phi
RETURN

END
