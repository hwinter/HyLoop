

function mk_loop_sxt_image, loop, $
                           RES=RES, STR=STR,$
                           FILTER_INDEX=FILTER_INDEX,$
                           OPEN=OPEN,$
                           THIN_AL=THIN_AL,$
                           DAG=DAG,$
                           BE=BE,$
                           THICK_AL=THICK_AL,$
                           MG=MG,$                          
                           EXP=EXP,$
                           CADENCE=CADENCE, $
                           XSIZE=XSIZE, YSIZE=YSIZE,$
                           XRANGE=XRANGE, YRANGE=YRANGE, $
                           XC=XC, YC=YC,$
                           dxp0=dxp0,dyp0=dyp0 ,$
                           NO_PSF=NO_PSF, FWHM=FWHM,PLOT=PLOT,$
                           specfile=specfile,$
                           NO_CHROMO=NO_CHROMO,$
                           NO_PAD=NO_PAD, PAD=PAD, $
                           OVER=OVER, $
                           XMN_CM=XMN_CM,XMX_CM=XMX_CM,$
                           YMN_CM=YMN_CM,YMX_CM=YMX_CM, $
                           X_CENTER=X_CENTER, Y_CENTER=Y_CENTER,$
                           OUT_CENTER_X=OUT_CENTER_X,OUT_CENTER_Y=OUT_CENTER_Y,$
                           new_xc=new_xc,new_yc=new_yc, SCREEN_IMAGE=SCREEN_IMAGE, $
                           NO_SAT=NO_SAT, PER_CM2=PER_CM2

start_time=systime(/julian)
current_device=!d.name
set_plot,'z'
device, set_resolution=[1000, 1000]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set keywords
IF not keyword_set(XSIZE) THEN XSIZE=600
IF not keyword_set(YSIZE) THEN YSIZE=300
if size(folder,/TYPE) ne 7 then folder='./'
IF not keyword_set(FILE_PREFIX) THEN FILE_PREFIX='T*'
IF n_elements(XRANGE) ne 2 then XRANGE=[900.,1200.]
IF n_elements(YRANGE) ne 2 then YRANGE=[-100.,100.]
if not keyword_set(XC) then XC=0.
if not keyword_set(YC) then YC=0.
IF size(XC,/TYPE) eq 0 THEN XC=0.
IF size(YC,/TYPE) THEN YC= 0.
;Need to change
;Default to 171
IF not keyword_set(res) then res=2.5d     ;SXT PFI pixel platescale  arcsec
pixel=res*720d*1d5                        ;SXT pixel res.in cm.

IF not keyword_set(exp) then exp=1d
IF not keyword_set(FWHM) THEN FWHM=2d0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set(NO_PAD) then PAD=0 else $
    if not keyword_set(PAD) then pad=FWHM*3.*pixel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the PSF
if not keyword_set(NO_PSF) then $   
  psf = psf_Gaussian( NPIXEL=[10,10], FWHM=FWHM ,$
                      /NORMALIZE) ;, ST_DEV=,  NDIMEN= ] )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

if not keyword_set(XMX_CM) then $
   XMX=max( loop.axis[0, *] ) + 10.*max( loop.rad ) else $
      XMX=XMX_CM
if not keyword_set(XMN_CM) then $
   XMN=min( loop.axis[0, *] ) - 10.*max( loop.rad ) else $
      XMN=XMN_CM
if not keyword_set(YMX_CM) then $
   YMX=max( loop.axis[1, *] ) + 10.*max( loop.rad ) else $
      YMX=YMX_CM
if not keyword_set(YMN_CM) then $
   YMN=min( loop.axis[1, *] ) - 10.*max( loop.rad ) else $
      YMN=YMN_CM

if not keyword_set(FILTER_INDEX) then begin
   case 1 of
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;Thin_al is the default     
      keyword_set(OPEN) : filter_index=0    
      keyword_set(THIN_AL) : filter_index=1
      keyword_set(DAG) :  filter_index=2
      keyword_set(BE) : filter_index=3
      keyword_set(THICK_AL) : filter_index=4
      keyword_set(MG) :  filter_index=5
      else:filter_index=1
   endcase
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n_loops=n_elements(loop) 

for i=0UL,n_loops-1 do begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
    volumes=get_loop_vol(loop[i])
    n_vol=n_elements(volumes)

    em=get_loop_em(loop[i],VOL=vol, t=loop_temp)
    loop_temp=alog10(loop_temp)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Artificially kill the chromospheric signal if desired.;
    if keyword_set(NO_CHROMO) then begin
        em[0:loop.n_depth]=0d
        em[(n_vol-1-loop.n_depth):n_vol-1]=0d
    endif


    if keyword_set(PER_CM2) then $
       signal=sxt_flux(loop_temp, filter_index, EM=em)/(pixel^2) else $
          signal=sxt_flux(loop_temp, filter_index, EM=em)
    
    signal>=0.
    show_loop_image,loop[i].axis,loop[i].rad,$
                    signal/VOL,pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,DATA_OUT=image_temp,$
                    /NOSCALE,PAD=PAD , OVER=OVER, $
                    XMN_CM=XMN,XMX_CM=XMX,$
                    YMN_CM=YMN,YMX_CM=YMX, $, 
                    XC=OUT_CENTER_X, YC=OUT_CENTER_Y,$
                    IMAGE_OUT=SCREEN_IMAGE

    ;if (keyword_set(MN_CM) and keyword_set(y_CENTER)) then begin
        arcsec_per_cm=1./(7.2d+7)
        X_CENTER=xmn+abs((xmx-xmn)/2.)
        Y_CENTER=ymn+abs((ymx-ymn)/2.)
        new_xc=xc+((X_CENTER+OUT_CENTER_X)*arcsec_per_cm)
        new_yc=yc+((Y_CENTER+OUT_CENTER_y)*arcsec_per_cm)
   ; endif
    
    
    image_temp=image_temp*pixel^2d0
    if not keyword_set(NO_PSF) then $
      image_temp=convol(image_temp, psf,EDGE_ZERO=1)



    
    time_array_string=Strcompress(string(loop[0].state.time,$
                                         format='(g5.3)'),/remove_all)




    
    map_temp={data:image_temp,$
              xc:new_xc,yc:new_yc,$
              dx:res,$           
              dy:res,$          
              time:loop[i].state.time,$       
              UNITS:'arcsecs'}
    if size(map,/TYPE) eq 0 then map=map_temp $
    else map=merge_map(map, map_temp)
    
 endfor

map.data/=exp

if not keyword_set(NO_SAT) then $
   map.data<= 235.
;map=shift_map(map, XC=XC, YC=YC)
set_plot, current_device
;stop
;Output is DN/cm^2 if per_cm2 keyword is set otherwise
; DN/Pixel
return, map.data
end
