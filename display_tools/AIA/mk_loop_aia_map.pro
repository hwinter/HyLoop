;Loops can be either a series of files or an array of loop structures.

function mk_loop_aia_map,loops, $
  RES=RES,PIXEL=PIXEL, STR=STR,$
  A94=A94, A131=A131,$
  A171=A171, $
  A194=A194, A211=A211, A335=A335,$
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
  X_CENTER=X_CENTER, Y_CENTER=Y_CENTER

current_device=!d.name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set keywords
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

IF not keyword_set(res) then res=.6d0 ;AIA pixel res. arcsec
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
IF not keyword_set(FWHM) THEN FWHM=2d0
if not keyword_set(NO_PSF) then $   
  psf = psf_Gaussian( NPIXEL=[10,10], FWHM=FWHM ,$
                      /NORMALIZE) ;, ST_DEV=,  NDIMEN= ] )

xmx=max( loops[0].axis[0, *] ) + 10.*max( loops[0].rad )
xmn=min( loops[0].axis[0, *] ) - 10.*max( loops[0].rad )
ymx=max( loops[0].axis[1, *] ) + 10.*max( loops[0].rad )
ymn=min( loops[0].axis[1, *] ) - 10.*max( loops[0].rad )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;make 171 the default
if (not keyword_set(A94) and $
    not keyword_set(A131) and $
    not keyword_set(A171) and $
    not keyword_set(A194)   and $
    not keyword_set(A211)   and $
    not keyword_set(A335)) then A171=1


Case 1 of 
    keyword_set(A171): ID=ID+" 171"
    keyword_set(A94):  ID=ID+" 94"
    keyword_set(A131): ID=ID+" 131"
    keyword_set(A194): ID=ID+" 194"   
    keyword_set(A211): ID=ID+" 211"
    keyword_set(A335): ID=ID+" 335"
   
endcase
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n_loops=n_elements(loops) 
i=0UL 
done=0
while not done do begin

    exp_time=0d0
    done2=0
    while  not done2 do begin
        
        if size(loops, /type) eq 7 then restore, loops[i] $
        else loop=loops[i]
        if keyword_set(ROT1) then loops[i].axis=(rot1#loops[i].axis)
        if keyword_set(ROT2) then loops[i].axis=(rot2#loops[i].axis)
        if keyword_set(ROT3) then loops[i].axis=(rot3#loops[i].axis)

        
        exp_time+=loop.state.time
        i+=1
        if i gt n_loops-1ul then begin
           ; print, i
            done2=1 
            done=1 
        endif

        if exp_time ge exp then done2=1
    endwhile

    exp_time>=1d0
    xmx_cm=max( loops[0].axis[0, *] ) + 10.*max( loops[0].rad )
    xmn_cm=min( loops[0].axis[0, *] ) - 10.*max( loops[0].rad )
    ymx_cm=max( loops[0].axis[1, *] ) + 10.*max( loops[0].rad )
    ymn_cm=min( loops[0].axis[1, *] ) - 10.*max( loops[0].rad )
    
    current_time=current_time+exp_time
    data=mk_loop_aia_image(loops, $
                           RES=RES, PIXEL=PIXEL, $
                           A94=A94, A131=A131,$
                           A171=A171, $
                           A194=A194, A211=A211, A335=A335,$
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


    data=data/exp_time
    delvarx, loops

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

    temp_map={data:data,$
         xc:XC,$
         yc:YC,$
         dx:res,$                ;pix1d/(3600*700*1d5)),$
         dy:res,$                ;:pixel*(/(700*1d5)),$
         time:time_string,$
         dur: exp_time,$
         ID:ID,$
         UNITS:'arcsecs'}
             
    if size(map, /TYPE) ne 8 then map=temp_map $
    else map=concat_struct(map,temp_map)
;stop
endwhile

return,map
end
