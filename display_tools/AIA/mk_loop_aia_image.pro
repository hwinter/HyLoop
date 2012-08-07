

function mk_loop_aia_image,loop, $
  RES=RES, PIXEL=PIXEL, $
  A94=A94, A131=A131,$
  A171=A171, $
  A194=A194, A211=A211, A335=A335,$
  EXP=EXP,$
  CADENCE=CADENCE, $
  XSIZE=XSIZE, YSIZE=YSIZE,$
  XRANGE=XRANGE, YRANGE=YRANGE, $
  XC=XC, YC=YC,$
  dxp0=dxp0,dyp0=dyp0 ,$
  NO_PSF=NO_PSF, FWHM=FWHM,PLOT=PLOT,$
  specfile=specfile,$
  NO_CHROMO=NO_CHROMO,$
  NO_PAD=NO_PAD,PAD=PAD, $
  OVER=OVER, $
  XMN_CM=XMN_CM,XMX_CM=XMX_CM,$
  YMN_CM=YMN_CM,YMX_CM=YMX_CM, $
  X_CENTER=X_CENTER, Y_CENTER=Y_CENTER


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
IF size(XC,/TYPE) eq 0 THEN XC=990.
IF size(YC,/TYPE) THEN YC= 0.
;Need to change
;Default to 171
IF not keyword_set(res) then res=.6d     ;AIA pixel res. arcsec
pixel=res*720d*1d5                       ;AIA pixel res. cm
IF not keyword_set(exp) then exp=1d
IF not keyword_set(FWHM) THEN FWHM=2d0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set(NO_PAD) then PAD=0 else $
    if not keyword_set(PAD) then pad=FWHM*4.*pixel

;pad=8.0*pixel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the PSF
if not keyword_set(NO_PSF) then $   
  psf = psf_Gaussian( NPIXEL=[10,10], FWHM=FWHM ,$
                      /NORMALIZE) ;, ST_DEV=,  NDIMEN= ] )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;make 171 the default
if (not keyword_set(A94) and $
    not keyword_set(A131) and $
    not keyword_set(A171) and $
    not keyword_set(A194)   and $
    not keyword_set(A211)   and $
    not keyword_set(A335)) then A171=1
    

n_loops=n_elements(loop) 

for i=0UL,n_loops-1 do begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;help,pixel
;help, res
    signal=mk_loop_aia_signal(loop[i], res=res, pixel=pixel, $
                       A94=A94, A131=A131,A171=A171, $
                       A194=A194, A211=A211, A335=A335,$
                       /PER_VOL, /no_chromo)

;    stop
;help,pixel
;help, res
    show_loop_image,loop[i].axis,loop[i].rad,$
      signal,pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,data_OUT=image_temp,$
                    image_out=image_out,/NOSCALE, $
                    OVER=OVER, ADD=ADD, PAD=PAD, $
                    XMN_CM=XMN_CM,XMX_CM=XMX_CM,$
                    YMN_CM=YMN_CM,YMX_CM=YMX_CM, $, $
                    XC=OUT_CENTER_X, YC=OUT_CENTER_Y

    ;if (keyword_set(XMN_CM) and keyword_set(y_CENTER)) then begin
        arcsec_per_cm=1./(7.2d+7)
        X_CENTER=xmn_cm+abs((xmx_cm-xmn_cm)/2.)
        Y_CENTER=ymn_cm+abs((ymx_cm-ymn_cm)/2.)
        new_xc=xc+((X_CENTER+OUT_CENTER_X)*arcsec_per_cm)
        new_yc=yc+((Y_CENTER+OUT_CENTER_y)*arcsec_per_cm)
; help,    image_temp
;help, image_out
    if not keyword_set(NO_PSF) then $
      image_temp=convol(image_temp, psf,EDGE_ZERO=1)
        
 ;   time_array_string=Strcompress(string(loop[0].state.time,$
 ;                                        format='(g5.3)'),/remove_all)
 ;   
 ;   map_temp={data:image_temp,$
 ;             xc:XC,yc:YC,$
 ;             dx:res,$          ;pix1d/(3600*700*1d5)),$
 ;             dy:res,$          ;:pixel*(/(700*1d5)),$
 ;            time:loop[i].state.time,$
              
 ;   UNITS:'arcsecs'}
 ;   if size(map,/TYPE) eq 0 then map=map_temp $
 ;   else map=merge_map(map, map_temp)
     
endfor


set_plot, current_device
return,image_temp/exp;map.data/exp
end
