pro mk_trace_movie5,folder,$
                    GIF_DIR=GIF_DIR,EXT=EXT,$
                    FILE_PREFIX=FILE_PREFIX,$
                    MOVIE_NAME=MOVIE_NAME,$
                    RES=RES, STR=STR, MAP195=MAP195,$
                    MAP171=MAP171, EXP=EXP,$
                    CADENCE=CADENCE, $
                    XSIZE=XSIZE, YSIZE=YSIZE

IF not keyword_set(XSIZE) THEN XSIZE=600
IF not keyword_set(YSIZE) THEN YSIZE=300
if size(folder,/TYPE) ne 7 then folder='../'
IF not keyword_set(FILE_PREFIX) THEN FILE_PREFIX=''
IF not keyword_set(EXT) THEN EXT='.loop'
IF not keyword_set(MOVIE_NAME) THEN MOVIE_NAME ='trace_movie'
IF not keyword_set(GIF_DIR) then GIF_DIR='./'

IF not keyword_set(res) then res=0.5d ;TRACE pixel res. arcsec
pixel=res*700d*1d5

IF not keyword_set(exp) then exp=3d

start_time=systime(/julian)
rot1=rotation(2,!dpi/2) 
rot2=rotation(3,-1d*!dpi)
;rot2=rotation(3,!dpi/2)
rot3=rotation(1,!dpi) 

;n_images=loop[n_loop-1l].time/exp

files=file_search(folder,FILE_PREFIX+'*'+EXT, COUNT=FILE_COUNT)

if FILE_count eq 0 then begin
    MESSAGE, 'No files matching *'+ext+' were found', /CONTINUE
    goto, end_jump
endif
current_device=!d.name
set_plot,'z'
device, Set_Resolution=[XSIZE, YSIZE]
animate_index=1l
tvlct,old_r, old_g, old_b, /GET

begin_index=0
for i=begin_index,FILE_COUNT-1l do begin
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

    axis=loop[0].axis
    ;axis=loop[i].axis
   ; axis=(rot2#rot1#axis)
    axis[0,*]=loop[0].axis[1,*]
    axis[1,*]=loop[0].axis[2,*]
    axis[2,*]=loop[0].axis[0,*]
;For the side tip
;axis=(rot3#axis)
    rad=loop[0].rad
    if max(rad) le 0 then rad=sqrt(loop[0].A/!dpi)
    image_171=1
    image_195=1
    volumes=get_loop_vol(loop[0])
    signal=get_trace_emiss(loop[0],/per);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Artificially kill the chromospheric signal;
    signal.oa171[0:n_depth+6]=0d
    signal.oa171[(n_vol-1-(n_depth+6)):n_vol-1]=0
    signal.oa195[0:n_depth+6]=0d
    signal.oa195[(n_vol-1-(n_depth+6)):n_vol-1]=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    show_loop_image,axis,rad,$
                    signal.oa171,pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_171, $
                    /NOSCALE; , xs=XSIZE, ys=ySIZE ;,/sqrt;

   ; image_171=tvrd()
    if size(array_171, /TYPE) eq 0 then Begin
        array_171=image_171 
        n_old_171_x=n_elements(array_171[*,0,0])
        n_old_171_y=n_elements(array_171[0,*,0])
    endif else begin 
       if (n_elements(image_171[*,0]) ne n_old_171_x or $
           n_elements(image_171[0,*]) ne n_old_171_y ) then $
         image_171=congrid(image_171, n_old_171_x,n_old_171_y)

        array_171=[[[array_171]], [[image_171]]]
    endelse

    erase
    show_loop_image,axis,rad,$
                    signal.oa195,pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_195, $
                    /NOSCALE; , xs=XSIZE, ys=ySIZE ;,/sqrt;


    ;image_195=tvrd()
    if size(array_195, /TYPE) eq 0 then begin
        array_195=image_195
        n_old_195_x=n_elements(array_195[*,0,0])
        n_old_195_y=n_elements(array_195[0,*,0])
    endif else begin 
       if (n_elements(image_195[*,0]) ne n_old_195_x or $
           n_elements(image_195[0,*]) ne n_old_195_y ) then $ 
         image_195=congrid(image_195, n_old_195_x,n_old_195_y)
       
       array_195=[[[array_195]], [[image_195]]]
   endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;stop
endfor

;image_struct[0].image_171[0:42]=1d6

scale171=255/max(array_171)
scale195=255/max(array_195)
;scale171=1
;scale195=1

size_scl_x1=long(XSIZE/n_old_171_x)
size_scl_y1=long(YSIZE/n_old_171_Y)
size_scl_1=min([size_scl_x1, size_scl_y1])

size_scl_x2=long(XSIZE/n_old_195_x)
size_scl_y2=long(YSIZE/n_old_195_Y)
size_scl_2=min([size_scl_x2, size_scl_y2])

for i=0,N_elements(array_171[0,0,*])-1l do begin
    
    erase
    trace_colors,171
    image=congrid(array_171[*,*,i]*scale171, n_old_171_x*size_scl_1, $
            n_old_171_Y*size_scl_1  )
    
    tv,image
    legend, [Strcompress(string(loop.state.time,format='(g10.5)')$
                        ,/remove_all)], BOX=0, /RIGHT
    if size(images171, /TYPE) eq 0 then $
      images171=tvrd() $
      else images171=[[[temporary(images171)]], $
                      [[tvrd()]]]

    erase
    trace_colors,195 
    
    image=congrid(array_195[*,*,i]*scale195, n_old_195_x*size_scl_2, $
            n_old_195_Y*size_scl_2  )
    
    tv,image
    legend, [Strcompress(string(loop.state.time,format='(g10.5)')$
                         ,/remove_all)], BOX=0, /RIGHT
    if size(images195, /TYPE) eq 0 then $
      images195=tvrd() $
      else images195=[[[temporary(images195)]], $
                      [[tvrd()]]]


endfor
;stop

trace_colors,171
tvlct, r,g,b,/GET
image2movie,images171,r,g,b,$
  movie_name=strcompress(gif_dir+'TRACE_171_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1

trace_colors,195
tvlct, r,g,b,/GET
image2movie,images195,r,g,b,$
  movie_name=strcompress(gif_dir+'TRACE_195_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1

;Reset to original color table
tvlct,old_r, old_g, old_b, /GET

;Reset to original device
set_plot, current_device
end_jump:
end
