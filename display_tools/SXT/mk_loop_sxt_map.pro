;Loops can be either a series of files or an array of loop structures.

function mk_loop_sxt_map,loops, $
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
                         FREQ_OUT=FREQ_OUT,title_add=title_add,$
                         NO_PSF=NO_PSF, FWHM=FWHM,PLOT=PLOT,$
                         specfile=specfile,$
                         NO_CHROMO=NO_CHROMO,$
                         ROT1=ROT1, ROT2=ROT2, ROT3=ROT3, DATE=DATE,$
                         START_HOUR=START_HOUR, START_MINUTE=START_MINUTE,$
                         NO_PAD=NO_PAD, PAD=PAD, OVER=OVER, $
                         XMN_CM=XMN_CM,XMX_CM=XMX_CM,YMN_CM=YMN_CM,YMX_CM=YMX_CM, $
                         X_CENTER=X_CENTER, Y_CENTER=Y_CENTER, $
                         NO_SAT=NO_SAT, PER_CM2=PER_CM2
  
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

IF not keyword_set(res) then res=2.5d     ;SXT PFI pixel platescale  arcsec
pixel=res*720d*1d5                        ;SXT pixel res.in cm.


IF not keyword_set(exp) then exp_in=1d else exp_in=exp

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ID='SXT (Model)'
if not keyword_set(FILTER_INDEX) then begin
    case 1 of 
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
     
case 1 of        
    filter_index eq 0:   ID=ID+' Open'
    filter_index eq 1:   ID=ID+' Thin Al'
    filter_index eq 2:   ID=ID+' DAG'
    filter_index eq 3:   ID=ID+' Be'
    filter_index eq 4:   ID=ID+' Thick Al'
    filter_index eq 5:   ID=ID+' Mg'
    else:
endcase
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get the xrt temperature response function
xrt_resp= CALC_XRT_TEMP_RESP( specfile=specfile) 

n_loops=n_elements(loops) 
i=0UL 
done=0
while not done do begin

    exp_time=0d0
    done2=0
    while  not done2 do begin
        
        if size(loops, /type) eq 7 then restore, loops[i] $
        else loop=loops[i]
        if keyword_set(ROT1) then loop.axis=(rot1#loop.axis)
        if keyword_set(ROT2) then loop.axis=(rot2#loop.axis)
        if keyword_set(ROT3) then loop.axis=(rot3#loop.axis)

        if size(loop_array, /TYPE) ne 8 then loop_array=loop $
        else loop_array=concat_struct(loop_array,loop)
        exp_time+=loop.state.time
        i+=1
        if i gt n_loops-1ul then begin
            ;print, i
            done2=1 
            done=1 
        endif

        if exp_time ge exp_in then done2=1
    endwhile

    current_time=current_time+exp_time
    data=mk_loop_sxt_image(loop_array, $
                           RES=RES, STR=STR,$
                           FILTER_INDEX=FILTER_INDEX,$
                           OPEN=OPEN,$
                           THIN_AL=THIN_AL,$
                           DAG=DAG,$
                           BE=BE,$
                           THICK_AL=THICK_AL,$
                           MG=MG,$         
                           XSIZE=XSIZE, YSIZE=YSIZE,$
                           XRANGE=XRANGE, YRANGE=YRANGE, $
                           XC=XC, YC=YC,$
                           dxp0=dxp0,dyp0=dyp0 ,$
                           NO_PSF=NO_PSF, FWHM=FWHM,PLOT=PLOT,$
                           specfile=specfile,$
                           NO_CHROMO=NO_CHROMO,$
                           PAD=PAD, NO_PAD=NO_PAD , $
                           OVER=OVER, $
                           XMN_CM=XMN_CM,XMX_CM=XMX_CM,$
                           YMN_CM=YMN_CM,YMX_CM=YMX_CM, $
                           new_xc=new_xc,new_yc=new_yc, $
                           X_CENTER=X_CENTER, Y_CENTER=Y_CENTER, $
                           NO_SAT=NO_SAT,PER_CM2=PER_CM2)


    if exp_time gt 0 then data=data/exp_time
    delvarx, loop_array
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
         xc:new_yc,$
         yc:new_yc,$
         dx:res,$               
         dy:res,$               
         time:time_string,$
         dur: exp_time,$
         ID:ID,$
         UNITS:'arcsecs'}
   ; print, 'xc, yc, arcsec',xc, yc
    ;temp_map=shift_map(temp_map, xc=xc, yc=yc)       
    if size(map, /TYPE) ne 8 then map=temp_map $
    else map=concat_struct(map,temp_map)
;stop
endwhile
;stop
return,map
end
