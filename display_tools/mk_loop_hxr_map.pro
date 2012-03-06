;

function mk_loop_hxr_map,loops,nt_brems, $
  RES=RES,PIXEL=PIXEL, STR=STR,$
  e_range=e_range, $
  EXP=EXP,$
  CADENCE=CADENCE, $
  XSIZE=XSIZE, YSIZE=YSIZE,$
  XRANGE=XRANGE, YRANGE=YRANGE, $
  XC=XC, YC=YC,$
  dxp0=dxp0,dyp0=dyp0 ,$
  FREQ_OUT=FREQ_OUT,title_add=title_add,$
  NO_PSF=NO_PSF, FWHM=FWHM,PLOT=PLOT,$
  specfile=specfile,$
  NO_CHROMO=NO_CHROMO,$
  ROT1=ROT1, ROT2=ROT2, ROT3=ROT3, DATE=DATE,$
  START_HOUR=START_HOUR, START_MINUTE=START_MINUTE,$
  PAD=PAD,NO_PAD=NO_PAD , OVER=OVER,$
  ID=ID,$
  XMN_CM=XMN_CM,XMX_CM=XMX_CM,$
  YMN_CM=YMN_CM,YMX_CM=YMX_CM, $
  X_CENTER=X_CENTER, Y_CENTER=Y_CENTER, $
  NT_ONLY=NT_ONLY, THERM_ONLY=THERM_ONLY

current_device=!d.name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set keywords
IF not keyword_set(e_range) THEN e_range=[6., 12.]
IF not keyword_set(XSIZE) THEN XSIZE=600
IF not keyword_set(YSIZE) THEN YSIZE=300
if size(folder,/TYPE) ne 7 then folder='./'
IF not keyword_set(FILE_PREFIX) THEN FILE_PREFIX='T*'
IF (size(XC,/TYPE) eq 0) THEN XC=990. else xc=xc
IF (size(YC,/TYPE) eq 0) THEN YC= 0. else xc=xc
IF n_elements(XRANGE) ne 2 then XRANGE=[xc-100.,xc+100.]
IF n_elements(YRANGE) ne 2 then YRANGE=[YC-100.,YC+100.]
if not keyword_set(FREQ_OUT) then FREQ_OUT=1l else $
  FREQ_OUT=long(FREQ_OUT)
IF not keyword_set(title_add) then title_add=''

IF not keyword_set(res) then res=2d0 ;AIA pixel res. arcsec
pixel=res*720d*1d5                    ;AIA pixel res.in cm.

IF not keyword_set(exp) then exp=1d

IF not keyword_set(ID) then ID='AIA ' 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;time tag
Result = STRSPLIT( systim(), ' ', /extract) 
Result2 = STRSPLIT( Result[1], ':', /extract) 
IF not keyword_set(DATE) then begin    
    curr_DATE=Result[0]
endif else curr_DATE=DATE


IF not keyword_set(START_HOUR) then curr_HOUR=fix(Result2[0]) $
else curr_HOUR=START_HOUR
IF not keyword_set(START_MINUTE) then curr_MINUTE=fix(Result2[1]) $
else curr_MINUTE=START_MINUTE


current_time=(FIX(curr_HOUR)*3600.)+$
             (FIX(curr_MINUTE)*60.)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the PSF
IF not keyword_set(FWHM) THEN FWHM=3d0
if not keyword_set(NO_PSF) then $   
  psf = psf_Gaussian( NPIXEL=[10,10], FWHM=FWHM ,$
                      /NORMALIZE) ;, ST_DEV=,  NDIMEN= ] )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the energy
low_ind=where(abs(e_range[0]-nt_brems[0].PH_ENERGIES) $
              eq min(abs(e_range[0]-nt_brems[0].PH_ENERGIES)))
high_ind=where(abs(e_range[1]-nt_brems[0].PH_ENERGIES) $
              eq min(abs(e_range[1]-nt_brems[0].PH_ENERGIES)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loop=loops[0]
done=0

if size(loops, /type) eq 7 then restore, loops[0] $
else loop=loops[0]

signal=get_xr_emiss(loop, nt_brems, $
                    E_RANGE=e_range,ENERGIES=ENERGIES, $
                    NT_ONLY=NT_ONLY, THERM_ONLY=THERM_ONLY, $
                    /PER_VOL)
signal=total(signal,2)
goto, skip_cheat
;Cheat.Averaging from both sides to make an initial image.
        n_vols=n_elements(signal)
        half_point=n_vols/2
        if n_vols mod 2 ne 0 then begin
            temp_signal_1=signal[0:half_point-1]
;            temp_signal_2=signal[half_point+1:*]
            signal[half_point+1:*]=reverse(temp_signal_1)
;            signal[half_point+1:*]=signal[half_point+1:*]+temp_signal_1
;            signal[0:half_point-1]=signal[0:half_point-1]+temp_signal_2
;            signal[half_point]=signal[half_point]+signal[half_point]
;            signal=signal/2d0
        endif else begin
            temp_signal_1=signal[0:half_point-1]
;            temp_signal_2=signal[half_point:*]
;            signal[half_point:*]=signal[half_point:*]+temp_signal_1
;            signal[0:half_point-1]=signal[0:half_point-1]+temp_signal_2
;            signal=signal/2d0
            signal[half_point:*]=reverse(temp_signal_1)
        endelse
skip_cheat:

    current_time=current_time+exp

;Signal units are [photons s^-1 sr^-1 cm ^-3] 
    data=mk_loop_hxr_image(loop,signal,  $
                           RES=RES, PIXEL=PIXEL, $
                           EXP=EXP,$
                           XSIZE=XSIZE, YSIZE=YSIZE,$
                           XRANGE=XRANGE, YRANGE=YRANGE, $
                           XC=XC, YC=YC,$
                           dxp0=dxp0,dyp0=dyp0 ,$
                           NO_PSF=NO_PSF, FWHM=FWHM,PLOT=PLOT,$
                           specfile=specfile,$
                           NO_CHROMO=NO_CHROMO, NO_PAD=NO_PAD , $
                           OVER=OVER,$
                           XMN_CM=XMN_CM,XMX_CM=XMX_CM,$
                           YMN_CM=YMN_CM,YMX_CM=YMX_CM, $
                           X_CENTER=X_CENTER, Y_CENTER=Y_CENTER)

    data=data*pixel*pixel
    delvarx, loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
;Make a string for time
    curr_HOUR=fix(current_time/3600.) 
    leftover=current_time mod 3600.
    curr_MINUTE=fix(leftover/60) 
    curr_Sec=(leftover mod 60)

    time_string=curr_DATE+' '+ $
                strcompress(string(curr_HOUR, FORMAT='(i02)')+ $
                            ':'+$
                            string(curr_MINUTE, FORMAT='(i02)')+ $
                            ':'+string(curr_Sec,FORMAT='(f05.2)'),$
                            /REMOVE_ALL)

    map={data:data,$
         xc:XC,$
         yc:YC,$
         dx:res,$                ;pix1d/(3600*700*1d5)),$
         dy:res,$                ;:pixel*(/(700*1d5)),$
         time:time_string,$
         dur: exp,$
         ID:ID,$
         UNITS:'arcsecs'}
             ;stop
return,map
end
