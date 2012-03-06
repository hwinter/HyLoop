;.r loop_trace_map
files='/Users/winter/Data/PATC/runs/2007_MAY_16f/a_2.0_b0_00001.loop'
title_add=''
xc=0
yc=0
restore, files 
stateplot2,loop.s, loop.state,/screen
print, max(get_loop_temp(loop))/1d6,'MK'
n_depth=where(get_loop_temp(loop) gt 1.1*1d4)
n_depth=n_depth[0]
IF not keyword_set(res) then res=0.5d ;TRACE pixel res. arcsec
pixel=res*720d*1d5 ;TRACE pixel res.in cm.

IF not keyword_set(exp) then exp=1d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the PSF
FWHM=2
psf = psf_Gaussian( NPIXEL=[5,5], FWHM=FWHM ,$
                     /NORMALIZE);, ST_DEV=,  NDIMEN= ] ) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

help, i
do_195=1
do_171=1
time=loop.state.time
axis=loop[0].axis
axis[0,*]=loop[0].axis[2,*]
axis[1,*]=loop[0].axis[1,*]
axis[2,*]=loop[0].axis[0,*]
;For the side tip
;axis=(rot3#axis)
rad=loop[0].rad
image_171=1
image_195=1
volumes=get_loop_vol(loop[0])
n_vol=n_elements(volumes)
rad=loop[0].rad
if max(rad) le 0 then rad=sqrt(loop[0].A/!dpi)
signal=get_trace_emiss(loop[0],/per)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Artificially kill the chromospheric signal;
signal.oa171[0:n_depth]=0d
signal.oa171[(n_vol-1-n_depth):n_vol-1]=0
signal.oa195[0:n_depth]=0d
signal.oa195[(n_vol-1-n_depth):n_vol-1]=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Arrays for the map
if keyword_set(do_195) then begin
    show_loop_image,axis,rad,$
                    signal.oa195,pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_195,/NOSCALE ;,/sqrt; $ 
    image_195=  image_195*(pixel^2.) 
   ; image_195=convol(image_195, psf,EDGE_ZERO=1)
    
endif else image_195=0

if keyword_set(do_195) then begin
    show_loop_image,axis,rad,signal.oa195,pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_195,/NOSCALE ;,/sqrt;     
    image_195=image_195*(pixel^2.) 
    image_195=convol(image_195, psf,EDGE_ZERO=1)
endif else image_195=0

temp_image_struct={image_171:image_171,image_195:image_195}

if n_elements(image_struct) lt 1l then image_struct=temp_image_struct $
else image_struct=concat_struct(TEMPORARY(image_struct),temp_image_struct)

if n_elements(time_array) lt 1l  then $
  time_array=Strcompress(string(loop[0].state.time,$
                                format='(g5.3)'),/remove_all) else $
  time_array=[temporary(time_array),Strcompress(string(loop[0].state.time,$
                                                       format='(g5.3)'),/remove_all)]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

scale195=255/max(image_struct.image_195)
;;;;;;;;;;;;;;;;;;;;;
;Make the map & map array  
map={data:image_struct[i].image_195*scale195,$
     xc:XC,yc:YC,$
     dx:res,$                    ;pix1d/(3600*700*1d5)),$
     dy:res,$                    ;:pixel*(/(700*1d5)),$
     time:(time),$
     ID:'TRACE: 195'+title_add,$
     UNITS:'arcsecs'}

if n_elements(MAP195) lt 1ul then  MAP195=map $
else MAP195=concat_struct(MAP195,map)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;plot it to the Z-buffer
trace_colors,195
plot_map,Map,XRANGE=XRANGE,YRANGE=YRANGE,$
         /limb_plot,lmthick=1,grid=50 ;,/nodata;,grid=50;composite=1,/over,/average,/INTER
        
x2gif,'trace.gif'

window,2
end
