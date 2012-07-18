
;Signal input should have units of: 
; output {watts, ergs,  photons, whatever) s^-1 sr^-1 cm^-3
;NB this is NOT a spectral radiance, even though the units are the same!
;It is a Radiant intensity per unit volume.
;The show_loop procedure does a path length integration which then makes the 
; output units per cm^-2 or if the units above are used, the radiance.
function mk_loop_signal2image,loop, signal, $
  RES=RES, PIXEL=PIXEL, $
  EXP=EXP,$
  SKIP=SKIP, $
  XC=XC, YC=YC,$
  dxp0=dxp0,dyp0=dyp0 ,$
  NO_PSF=NO_PSF, FWHM=FWHM,$
  NO_PAD=NO_PAD,PAD=PAD, $
  OVER=OVER, $
  XMN_CM=XMN_CM,XMX_CM=XMX_CM,$
  YMN_CM=YMN_CM,YMX_CM=YMX_CM, $
  X_CENTER=X_CENTER, Y_CENTER=Y_CENTER, $
  FLUX_OUT=FLUX_OUT


current_device=!d.name
set_plot,'z'
device, set_resolution=[1000, 1000]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set keywords
IF size(XC,/TYPE) eq 0 THEN XC=990.
IF size(YC,/TYPE) THEN YC= 0.
IF not keyword_set(SKIP) then skip_in=1 else skip_in=SKIP
;Need to change
;Default to 171
IF not keyword_set(res) then res_in=2d else res_in=res     ; arcsec
IF not keyword_set(exp) then exp=1d
IF not keyword_set(FWHM) THEN FWHM=2d0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set(NO_PAD) then PAD=0 else $
    if not keyword_set(PAD) then pad=FWHM*4.*pixel

;pad=8.0*pixel
cm_per_arcsec=(7.2d+7)
arcsec_per_cm=1./(7.2d+7)
pixel_in=res_in*cm_per_arcsec                     ; cm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the PSF
if not keyword_set(NO_PSF) then $   
  psf = psf_Gaussian( NPIXEL=[10,10], FWHM=FWHM ,$
                      /NORMALIZE) ;, ST_DEV=,  NDIMEN= ] )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n_loops=n_elements(loop) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;signal is expected to be in photons s^-1 sr^-1 cm^-3
    show_loop_image,loop[ii].axis,loop[ii].rad,$
                    signal,pixel=pixel_in,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,data_OUT=image_temp,$
                    image_out=image_out,/NOSCALE, $
                    OVER=OVER, ADD=ADD, PAD=PAD, $
                    XMN_CM=XMN_CM,XMX_CM=XMX_CM,$
                    YMN_CM=YMN_CM,YMX_CM=YMX_CM, $, $
                    XC=OUT_CENTER_X, YC=OUT_CENTER_Y
    
;Now image_temp is  in  photons s^-1 sr^-1 cm^-2

 if keyword_set(FLUX_OUT) then $
     image_temp=image_temp*((!dpi*!dpi)/(180.*180.*3600*3600)) $
                (pixel*pixel) *(res_in*res_in)   else $
   image_temp=image_temp*(2*!dpi)*(res_in*res_in) /((1.496d13)*(1.496d13))
;Now image_temp is  in  photons s^-1 if FLUX_OUT keyword is set
; else mage_temp is  in  photons s^-1 cm^-2 at Earth


    ;if (keyword_set(XMN_CM) and keyword_set(y_CENTER)) then begin
        X_CENTER=xmn_cm+abs((xmx_cm-xmn_cm)/2.)
        Y_CENTER=ymn_cm+abs((ymx_cm-ymn_cm)/2.)
        new_xc=xc+((X_CENTER+OUT_CENTER_X)*arcsec_per_cm)
        new_yc=yc+((Y_CENTER+OUT_CENTER_y)*arcsec_per_cm)
; help,    image_temp
;help, image_out
    if not keyword_set(NO_PSF) then $
      image_temp=convol(image_temp, psf,EDGE_ZERO=1)
    
 endfor ;ii



set_plot, current_device
return,abs(image_temp/exp);map.data/exp
end
