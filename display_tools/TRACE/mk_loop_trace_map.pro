

function mk_loop_trace_map,FILES, $
  RES=RES, STR=STR, MAP195=MAP195,$
  MAP171=MAP171, EXP=EXP,$
  CADENCE=CADENCE, $
  XSIZE=XSIZE, YSIZE=YSIZE,$
  XRANGE=XRANGE, YRANGE=YRANGE, $
  XC=XC, YC=YC,$
  DATE=DATE,dxp0=dxp0,dyp0=dyp0 ,$
  DO_171=DO_171, DO_195=DO_195,$
  FREQ_OUT=FREQ_OUT,title_add=title_add,$
  NO_PSF=NO_PSF, FWHM=FWHM,PLOT=PLOT
  


start_time=systime(/julian)
current_device=!d.name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set keywords
IF not keyword_set(XSIZE) THEN XSIZE=600
IF not keyword_set(YSIZE) THEN YSIZE=300
if size(folder,/TYPE) ne 7 then folder='./'
IF not keyword_set(FILE_PREFIX) THEN FILE_PREFIX='T*'
IF n_elements(XRANGE) ne 2 then XRANGE=[900.,1200.]
IF n_elements(YRANGE) ne 2 then YRANGE=[-100.,100.]
IF not keyword_set(XC) THEN XC=990.
IF not keyword_set(YC) THEN YC= 0.
;Need to change
IF not keyword_set(DATE) THEN DATE=systim()
;Default to 171
IF (not keyword_set(DO_171) AND not keyword_set(DO_195)) $
  then DO_171=1
if not keyword_set(FREQ_OUT) then FREQ_OUT=1l else FREQ_OUT=long(FREQ_OUT)
IF not keyword_set(title_add) then title_add=''

IF not keyword_set(res) then res=0.5d     ;TRACE pixel res. arcsec
pixel=res*720d*1d5                        ;TRACE pixel res.in cm.

IF not keyword_set(exp) then exp=1d


IF not keyword_set(FWHM) THEN FWHM=2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the PSF
if not keyword_set(NO_PSF) then $   
    psf = psf_Gaussian( NPIXEL=[10,10], FWHM=FWHM ,$
                        /NORMALIZE) ;, ST_DEV=,  NDIMEN= ] )
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n_files=n_elements(files) 
for i=0UL,n_files-1,FREQ_OUT  do begin
    restore, files[i]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Need to change this
    rot1=rotation(2,!dpi/2) 
    rot2=rotation(3,-1d*!dpi)
;rot2=rotation(3,!dpi/2)
    rot3=rotation(1,!dpi)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    t=get_loop_temp(loop[0])
    junk=where(t le 1d5, n_depth)
    n_depth=long(n_depth/2)+2
    
    time=addecstimes(date,loop.state.time)

                                ;axis=loop[i].axis
                                ;axis=(rot2#rot1#axis)
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
                        reform(signal.oa195),pixel=pixel,win=win_num,$
                        dxp0=dxp0, dyp0=dyp0,DATA_OUT=image_195,$
                        /NOSCALE ;,/sqrt; $ 
        image_195=  image_195*(pixel^2.) 
         
        if not keyword_set(NO_PSF) then $
          image_195=convol(image_195, psf,EDGE_ZERO=1) $
          else image_195=0
        if size(image_arr_195, /TYPE) LE 0 THEN $
        image_arr_195=image_195 $
        else image_arr_195=[[[temporary(image_arr_195)]],[[image_195]]]
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
    if keyword_set(do_171) then begin
        show_loop_image,axis,rad,reform(signal.oa171),pixel=pixel,win=win_num,$
                        dxp0=dxp0, dyp0=dyp0,DATA_OUT=image_171,$
                        /NOSCALE ;,/sqrt;     
        image_171=image_171*(pixel^2.) 
        if not keyword_set(NO_PSF) then $
          image_171=convol(image_171, psf,EDGE_ZERO=1)$
          else image_171=0
        if size(image_arr_171, /TYPE) LE 0 THEN $
        image_arr_171=image_171 $
        else image_arr_171=[[[temporary(image_arr_171)]],[[image_171]]]
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
    if n_elements(time_array_string) lt 1l  then $
      time_array_string=time else $;Strcompress(string(loop[0].state.time,$
                             ;       format='(g5.3)'),/remove_all) else $
      time_array_string=[temporary(time_array_string),$
                         time]
;Strcompress(string(loop[0].state.time,$
                         ;                   format='(g5.3)'),$
                          ;           /remove_all)]

    if n_elements(time_array) lt 1l  then $
      time_array=loop[0].state.time else $
      time_array=[temporary(time_array), loop[0].state.time]

endfor



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
for i=0, n_elements(time_array) -1 do begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the map & map array  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;195
    if  keyword_set(DO_195) then begin
        map={data:image_arr_195[*,*,i],$
             xc:XC,yc:YC,$
             dx:res,$            ;pix1d/(3600*700*1d5)),$
             dy:res,$            ;:pixel*(/(700*1d5)),$
             time:(time),$
             ID:'TRACE: 195'+title_add,$
             UNITS:'arcsecs'}
    
        if n_elements(MAP195) lt 1ul then  MAP195=map $
        else MAP195=concat_struct(MAP195,map)
    endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;171
    if  keyword_set(DO_171) then begin
        map={data:image_arr_171[*,*,i],$
             xc:XC,yc:YC,$
             dx:res,$            ;pix1d/(3600*700*1d5)),$
             dy:res,$            ;:pixel*(/(700*1d5)),$
             time:(time),$
             ID:'TRACE: 171'+title_add,$
             UNITS:'arcsecs'}
        
        if n_elements(MAP171) lt 1ul then  MAP171=map $
        else MAP171=concat_struct(MAP171,map)
    endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Do the exposure part here.  Probably the least efficient way 
;  to do this.  May want to rethink
if  keyword_set(EXP) then begin
    if  keyword_set(DO_171) then begin
        n_elem=n_elements(MAP171)
        if n_elem le 1 then goto, end_171_loop
        begin_time= time_array[0]
        data=MAP171[0].data
        for i=1ul, n_elem-1 do begin
            delta_t=(time_array[i] - begin_time)
            if delta_t lt exp then begin
                data=data+MAP171[i].data
                
            endif else begin
                if size(new_map,/TYPE) eq 0 then $
                  new_map=MAP171[0] else $
                  new_map=[new_map, MAP171[0]]
                
                new_map.data=data/delta_t
                new_map.time=time_array[i]
                if not (i + 1 gt n_elem-1) then begin
                    begin_time=  time_array[i+1]
                    data[*,*]=0d
                endif
                
            endelse        
         endfor

        MAP171=new_map
    endif
end_171_loop:

    if  keyword_set(DO_195) then begin
        n_elem=n_elements(MAP195)
        if n_elem le 1 then goto, end_195_loop
        begin_time= time_array[0]
        data=MAP195[0].data
        for i=1ul, n_elem-1 do begin
            delta_t=(time_array[i] - begin_time)
            if delta_t lt exp then begin
                data=data+MAP195[i].data
                
            endif else begin
                if size(new_map,/TYPE) eq 0 then $
                  new_map=MAP195[0] else $
                  new_map=[new_map, MAP195[0]]
                
                new_map.data=data/delta_t
                new_map.time=time_array[i]
                if not (i + 1 gt n_elem-1) then begin
                    begin_time=  time_array[i+1]
                    data[*,*]=0d
                endif
                
            endelse        
        endfor
        MAP195=new_map
     endif
end_195_loop:
 endif


    









if keyword_set(DO_195) then map=MAP195
if keyword_set(DO_171) then map=MAP171
return,map
end
