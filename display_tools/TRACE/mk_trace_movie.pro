pro mk_trace_movie,folder, $
                   GIF_DIR=GIF_DIR,EXT=EXT,$
                   FILE_PREFIX=FILE_PREFIX,$
                   MOVIE_NAME=MOVIE_NAME,$
                   RES=RES, STR=STR, MAP195=MAP195,$
                   MAP171=MAP171, EXP=EXP,$
                   CADENCE=CADENCE, $
                   XSIZE=XSIZE, YSIZE=YSIZE,$
                   XRANGE=XRANGE, YRANGE=YRANGE, $
                   XC=XC, YC=YC,$
                   DATE=DATE,dxp0=dxp0,dyp0=dyp0  ,$
                   DO_171=DO_171, DO_195=DO_195,$
                   FREQ_OUT=FREQ_OUT
                   
                   

current_device=!d.name
IF not keyword_set(XSIZE) THEN XSIZE=600
IF not keyword_set(YSIZE) THEN YSIZE=300
if size(folder,/TYPE) ne 7 then folder='./'
IF not keyword_set(FILE_PREFIX) THEN FILE_PREFIX=''
IF not keyword_set(EXT) THEN EXT='.loop'
IF not keyword_set(MOVIE_NAME) THEN MOVIE_NAME ='TRACE_movie'
IF not keyword_set(GIF_DIR) then GIF_DIR='./'
IF n_elements(XRANGE) ne 2 then XRANGE=[900.,1200.]
IF n_elements(YRANGE) ne 2 then YRANGE=[-100.,100.]
IF not keyword_set(XC) THEN XC=990.
IF not keyword_set(YC) THEN YC= 0.
IF not keyword_set(DATE) THEN DATE=' 16-JUN-2007 00:00:'
IF (not keyword_set(DO_171) AND not keyword_set(DO_195)) then DO_171=1 & DO_195=1
if not keyword_set(FREQ_OUT) then FREQ_OUT=1.

IF not keyword_set(res) then res=0.5d ;TRACE pixel res. arcsec
pixel=res*720d*1d5 ;TRACE pixel res.in cm.

IF not keyword_set(exp) then exp=1d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the PSF
FWHM=2
psf = psf_Gaussian( NPIXEL=[5,5], FWHM=FWHM ,$
                     /NORMALIZE);, ST_DEV=,  NDIMEN= ] )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


files=file_search(folder,FILE_PREFIX+'*'+EXT, COUNT=FILE_COUNT)

if FILE_count eq 0 then begin
    MESSAGE, 'No files matching *'+ext+' were found', /CONTINUE
    goto, end_jump
endif

start_time=systime(/julian)
rot1=rotation(2,!dpi/2) 
rot2=rotation(3,-1d*!dpi)
;rot2=rotation(3,!dpi/2)
rot3=rotation(1,!dpi)



set_plot,'z'
device, SET_RESOLUTION=[800,800]
;window,0,xs=400,ys=800
;window,1,xs=400,ys=800
FILE_COUNT<=3600UL
for i=0UL,FILE_COUNT-1UL do begin
    if i MOD FREQ_OUT eq 0. then begin
        print, 'Now working on file '+files[i]
        restore, files[i]
        n_vol=n_elements(loop[0].state.e)-2l
        n_x=n_elements(loop[0].s)
        
        n_depth=loop[0].n_depth
        if  n_depth le 0 then begin
            t=get_loop_temp(loop[0])
            junk=where(t le 1d5, n_depth)
            n_depth=long(n_depth/2)
            
        end
        
        
                                ;axis=loop[i].axis
                                ;axis=(rot2#rot1#axis)
        rad=loop[0].rad
        image_171=1
        image_195=1
        volumes=get_loop_vol(loop[0])
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
;Arrays for the non-map movie
        axis=loop[0].axis
        axis[0,*]=loop[0].axis[1,*]
        axis[1,*]=loop[0].axis[2,*]
        axis[2,*]=loop[0].axis[0,*]
        
        image_171a=1
        image_195a=1
        
        show_loop_image,axis,rad,$
                        signal.oa171,pixel=pixel,win=win_num,$
                        dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_171a,/NOSCALE ;,/sqrt;
        
        show_loop_image,axis,rad,signal.oa195,pixel=pixel,win=win_num,$
                        dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_195a,/NOSCALE ;,/sqrt;
        image_195a=image_171a*(pixel^2.)
        data=convol(data, psf,EDGE_ZERO=1)
        temp_image_struct={image_171:}
        
        if n_elements(image_struct_a) lt 1 then image_struct_a=temp_image_struct $
        else image_struct_a=concat_struct(temporary(image_struct_a),temp_image_struct)
        
        if n_elements(time_array) lt 1  then $
          time_array=Strcompress(string(loop[0].state.time,$
                                        format='(g5.3)'),/remove_all) else $
          time_array=[time_array,Strcompress(string(loop[0].state.time,$
                                                    format='(g5.3)'),/remove_all)]
;stop
    endif
    
endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ruct.image_195)

scale171_a=255/max(image_struct_a.image_171)
scale195_a=255/max(image_struct_a.image_195)


for i=0,FILE_COUNT-1 do begin
    if i MOD FREQ_OUT eq 0. then begin
        time=DATE+time_array[i]
        print,'time'+time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Now make the non-map movie array
     
        erase
        tv, image_struct_a[i].image_171*scale171_a
        legend, time_array[i], BOX=0,/RIGHT
        
        if size(plot_array_171_a,/TYPE) eq 0 then $
          plot_array_171_a=tvrd() else $
          plot_array_171_a=[[[temporary(plot_array_171_a)]],[[tvrd()]]]
        
        erase
        tv, image_struct_a[i].image_195*scale195_a
        legend, time_array[i], BOX=0,/RIGHT
        
        if size(plot_array_195_a,/TYPE) eq 0 then $
          plot_array_195_a=tvrd() else $
          plot_array_195_a=[[[temporary(plot_array_195_a)]],[[tvrd()]]]
    endif

        
endfor
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the map image arrays into movies
trace_colors,171,r,g,b
image2movie,plot_array_171,r,g,b,$
            movie_name=strcompress(gif_dir+MOVIE_NAME+'_171_Map.gif',/REMOVE_ALL), $
            gif_animate=1,loop=1

trace_colors,195,r,g,b
image2movie,plot_array_195,r,g,b,$
            movie_name=strcompress(gif_dir+MOVIE_NAME+'_195_Map.gif',/REMOVE_ALL), $
            gif_animate=1,loop=1s

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the non-map image arrays into movies
trace_colors,171,r,g,b
image2movie,plot_array_171_a,r,g,b,$
            movie_name=strcompress(gif_dir+MOVIE_NAME+'_171.gif',/REMOVE_ALL), $
            /mpeg;gif_animate=1,loop=1

trace_colors,195,r,g,b
image2movie,plot_array_195_a,r,g,b,$
            movie_name=strcompress(gif_dir+MOVIE_NAME+'_195.gif',/REMOVE_ALL), $
           /mpeg; gif_animate=1,loop=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
str=image_struct
str2=image_struct_a
end_jump:
set_plot, current_device
end
