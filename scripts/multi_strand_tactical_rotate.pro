;multi_strand_tactical_rotate.pro

;A program to;
;a) restore multiple loop strands
;b) make a show_loop_tactical image
;c) rotate the loops
;d) make another show_loop_tactical image
;e) Repeat c & D then create a movie

Data_dir='/Volumes/scratch_2/Users/hwinter/programs/HyLoop/experiments/2011_04_multi_strand_nano/'
movie_name=Data_dir+'2011_strand_tac_movie.gif'
gif_name_prefix=''
FONT=1
OFFSET1=.5
file_prefix='strand_start*'
file_ext='.loop'

files1=file_search(Data_dir, file_prefix+file_ext, COUNT=FILES1_COUNT)
gif_name_prefix='strand_img'

restore, files1[0]
loops=loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for files_index=1UL, FILES1_COUNT-4ul, 5 do begin
    restore, files1[files_index]
    loops=concat_struct(loops, loop)
endfor    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;stop
old_device=!D.NAME
set_plot, 'PS' 
c_skip=10 
;DEVICE, SET_PIXEL_DEPTH    = 24, $
;  ;      SET_RESOLUTION     = [1024, 768], $
;        SET_CHARACTER_SIZE = [6, 10], $
;        Z_BUFFERING        = 0
delvarx, plot_array
;Record the orignal _ matrix so that we can reset it later
old_p_dot_t=!P.T

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Rotate about the Y-Axis
rot1=rotation(2,!dpi/2.8)
rot1a=rotation(2,-1.*!dpi/2.8)
;Rotate about the Z-Axis
rot2=rotation(3,-.5d*!dpi)
;rot2=rotation(3,!dpi/2)

;Rotate about the X-Axis
rot3=rotation(1,!dpi)
;;axis=(rot2#rot1#axis)
;axis=rot1#axis
;matrix=rotate_loop()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tvlct, old_r, old_g, old_b,/GET
;Set the new colors
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
;device, SET_RESOLUTION=[800,800]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
THICK=5
Title='Loops Test'
LOOP_LINE=1
SURFACE_LINE=0
INITIAL=1

n_frames=100
Z_begin=0.
z_end=200.
x_begin=45.
x_end=0.
min_temp=1d4
max_temp=3d6
;for files_index=0UL, FILES1_COUNT-1ul,10 do begin


;endfor

min_x=MIN(loops.AXIS[0,*]+max(loops.rad))
max_x=MAX(loops.AXIS[0,*])+max(loops.rad)

XRANGE=[min_x,max_x]
YRANGE=[MIN(loops.AXIS[1,*]),MAX(loops.AXIS[1,*])]
ZRANGE=[MIN(loops.AXIS[2,*]),MAX(loops.AXIS[2,*])]
range_min=min([XRANGE[0],YRANGE[0],ZRANGE[0]])
range_max=max([XRANGE[1],YRANGE[1],ZRANGE[1]])
delta_range=range_max-range_min
yrange=[YRANGE[0],YRANGE[0]+delta_range]
xrange=[XRANGE[0],XRANGE[0]+delta_range]
zrange=[XRANGE[0],ZRANGE[0]+delta_range]


delta_x_range_0=abs(XRANGE[1]-XRANGE[0])
delta_x_range_1=abs(min_x-min(XRANGE))
;delvarx, YRANGE,xrange,zrange
delvarx, gifnames
;delvarx,fill
;fill=180.
 no_oplot=0
files_index=0
d_step=delta_x_range_1/(n_frames)



for frame=0, n_frames do begin
    temp_gif_name=gif_name_prefix+ $
                  string(frame,FORMAT= $  
                         '(I5.5)')+'.gif'
    temp_png_name=gif_name_prefix+ $
                  string(frame,FORMAT= $  
                         '(I5.5)')+'.png'
    
    temp_ps_name=gif_name_prefix+ $
                  string(frame,FORMAT= $  
                         '(I5.5)')+'.ps'
    new_x_min=XRANGE[0]-d_step*frame
    new_x_max=new_x_min+delta_x_range_0

    xrange=[new_x_min, new_x_max]
    ax=x_begin-(x_begin*frame/n_frames)
    az=z_begin+((z_end-z_begin)*frame/n_frames)
   

    PRINT, AX, AZ
    no_oplot=0
;    goto, skip
;Rad tag was properly set in all versions.
  
 ;    window, 3
;    plot,loop.s_alt[1:n_elements(loop.s_alt)-2],loop.e_h
;    for ii=0, n_elements(loop.e_h)-1 do begin
;        plots,loop.s_alt[ii+1] ,loop.e_h[ii], $
;              color=fill[ii],psym=2
;    endfor 
;    wset,2
 ;   loop[0].axis[0, *]=loop[0].axis[0, *]+0.5*max(xrange)
    device, color=16, /landscape, file=temp_ps_name
    show_loop_tactical, loops[0], $
                        XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                        THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                        INITIAL=1,line_color=2,  $
                        C_SKIP=C_SKIP, $
                        c_color=2;fsc_color('green')
    
    for j=1, n_elements(loops)-1ul do begin
       
    show_loop_tactical, loops[j], $
                        THICK=THICK, AX=AX, AZ=AZ,$
                        line_color=2, $
                        C_SKIP=C_SKIP, $
                        c_color=2;fsc_color('green')
       

    endfor


    xyouts, (xrange[0]+(xrange[1]+xrange[0])/2.)*OFFSET1,max(loops.axis[2,*]+loops.rad)*.5 ,$
        '', charsize=3.0, charthick=1.9,$;/t3d ,$
        z=max(loops.axis[2,*]+loops.rad);, FONT=FONT,/DATA;,$
                                ; ORIENTATION=90
    
 ;   if !d.name eq 'Z' then $
 ;     z2gif, temp_gif_name else $
 ;     x2gif, temp_gif_name 


    DEVICE, /CLOSE
    SPAWN, "convert "+temp_ps_name+" "+ temp_gif_name
    SPAWN, "convert "+temp_ps_name+" "+ temp_png_name
    SPAWN, "convert -rotate '-90' "+temp_gif_name +" "+  temp_gif_name
    if size( gifnames, /TYPE) eq 0 then $
  gifnames=temp_gif_name else $
  gifnames=[gifnames,temp_gif_name]


 endfor
;stop
image2movie,gifnames,$
            movie_name=strcompress(movie_name,/REMOVE_ALL), $
            mpeg=1;gif_animate=1,loop=1
print, 'Movie Name='+strcompress(movie_name,/REMOVE_ALL)
;for i=0UL, n_elements(gifnames)-1UL do  begin
;    spawn, 'rm -f '+gif_name_prefix+'*'
;endfor
tvlct, old_r, old_g, old_b,/GET


skip:

files=file_search('./', '*.ps')
delvarx,gifnames 
;stop
for k=0, n_elements(files)-1 do begin
   temp_ps_name=files[k]
   temp_gif_name=temp_ps_name+'.gif'
   SPAWN, "convert "+temp_ps_name+" "+ temp_gif_name
   SPAWN, "convert -rotate '-90' "+temp_gif_name +" "+  temp_gif_name
   if size( gifnames, /TYPE) eq 0 then $
      gifnames=temp_gif_name else $
         gifnames=[gifnames,temp_gif_name]
endfor
image2movie,gifnames,$
            movie_name=strcompress(movie_name,/REMOVE_ALL), $
            mpeg=1;gif_animate=1,loop=1
print, 'Movie Name='+strcompress(movie_name,/REMOVE_ALL)
end
