;multi_strand_tactical.pro

;A program to;
;a) restore multiple loop strands
;b) make a show_loop_tactical image
;c) rotate the loops
;d) make another show_loop_tactical image
;e) Repeat c & D then create a movie


Data_dir='/Volumes/scratch_2/Users/hwinter/programs/HyLoop/experiments/2011_04_multi_strand_nano/'
movie_name=Data_dir+'2011_strand_tac_movie.gif'
folder_1=Data_dir+;'alpha=-100/699_25/run_01/'
movie_folder=Data_dir
spawn, 'mkdir  '+getenv('DATA')+'/PATC/movies/'
spawn, 'mkdir  '+movie_folder
FONT=1
OFFSET1=.5
file_prefix='strand_save*'
file_ext='.loop'
files1=file_search(folder_1, file_prefix+file_ext, COUNT=FILES1_COUNT)

restore, files1[0]
help, loop
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
;Rad tag was properly set in all versions.
loop.rad=sqrt(loop.a/!dpi)
;loop.axis=[loop.axis[0,*]+2.5d9,loop.axis[1,*], loop.axis[2,*]]


;For later use.
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

;WINDOW, 2, XS=800, YS=800
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bottom_color=15
Top_COLOR=254-bottom_color
top_color=254
tvlct, old_r, old_g, old_b,/GET
;Set the new colors
;tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
;Red Temperature
loadct,3;, NCOLORS=NCOLORS
;stretch,bottom_color ,Top_COLOR, /chop
;device, SET_RESOLUTION=[800,800]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
THICK=5
Title='PA Test'
LOOP_LINE=1
SURFACE_LINE=0
INITIAL=1
temperature=get_loop_temp(loop)
;t_color=Top_COLOR/max(temperature)
;fill=temperature*t_color
n_frames=100
Z_begin=30.
z_end=90.
x_begin=45.
x_end=0.
min_temp=1d4
max_temp=3d6
;for files_index=0UL, FILES1_COUNT-1ul,10 do begin


;endfor

min_x=MIN(LOOP.AXIS[0,*]+max(loop.rad))
max_x=MAX(LOOP.AXIS[0,*])+max(loop.rad)

XRANGE=[min_x,max_x]
YRANGE=[MIN(LOOP.AXIS[1,*]),MAX(LOOP.AXIS[1,*])]
ZRANGE=[MIN(LOOP.AXIS[2,*]),MAX(LOOP.AXIS[2,*])]
range_min=min([XRANGE[0],YRANGE[0],ZRANGE[0]])
range_max=max([XRANGE[1],YRANGE[1],ZRANGE[1]])
delta_range=range_max-range_min
yrange=[YRANGE[0],YRANGE[0]+delta_range]
xrange=[XRANGE[0],XRANGE[0]+delta_range]
zrange=[XRANGE[0],ZRANGE[0]+delta_range]

loop[0].axis[0, *]=loop[0].axis[0, *]+0.5*max(xrange)
delta_x_range_0=abs(XRANGE[1]-XRANGE[0])
delta_x_range_1=abs(min_x-min(XRANGE))
;delvarx, YRANGE,xrange,zrange
delvarx, gifnames
;delvarx,fill
;fill=180.
 no_oplot=0
files_index=0
gif_name_prefix=getenv('DATA')+'/PATC/movies/junk_temp'
d_step=delta_x_range_1/(n_frames)

max_heat=max_e_dep


for frame=0, n_frames do begin
    temp_gif_name=gif_name_prefix+ $
                  string(frame,FORMAT= $  
                         '(I5.5)')+'.gif'
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
    
;Rad tag was properly set in all versions.
    loop.rad=sqrt(loop.a/!dpi)
    loop1=loop
    ;loop1.rad=loop.rad*5.

    e_color=Top_COLOR/max_heat
    fill=get_loop_temp(loop)*f1+f2
    ;fill=(loop.e_h/max_e_dep)*255
    pmm , fill
;    window, 3
;    plot,loop.s_alt[1:n_elements(loop.s_alt)-2],loop.e_h
;    for ii=0, n_elements(loop.e_h)-1 do begin
;        plots,loop.s_alt[ii+1] ,loop.e_h[ii], $
;              color=fill[ii],psym=2
;    endfor 
;    wset,2
 ;   loop[0].axis[0, *]=loop[0].axis[0, *]+0.5*max(xrange)
    device, color=16, /landscape, file=temp_ps_name
    show_loop_tactical, loop1, $
                        XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                        THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                        INITIAL=1, LOOP_LINE=AXIS_LINE,$
                        SURFACE_LINE=SURFACE_LINE, $
                        C_SKIP=C_SKIP, no_oplot=no_oplot
    xyouts, (xrange[0]+(xrange[1]+xrange[0])/2.)*OFFSET1,max(loop1.axis[2,*]+loop1.rad)*.5 ,$
        '', charsize=3.0, charthick=1.9,$;/t3d ,$
        z=max(loop1.axis[2,*]+loop1.rad);, FONT=FONT,/DATA;,$
                                ; ORIENTATION=90
    
 ;   if !d.name eq 'Z' then $
 ;     z2gif, temp_gif_name else $
 ;     x2gif, temp_gif_name 
    DEVICE, /CLOSE
    SPAWN, "convert "+temp_ps_name+" "+ temp_gif_name
    SPAWN, "convert -rotate '-90' "+temp_gif_name +" "+  temp_gif_name
    if size( gifnames, /TYPE) eq 0 then $
  gifnames=temp_gif_name else $
  gifnames=[gifnames,temp_gif_name]


endfor
goto, end_jump
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FILES1_COUNT<=900
for files_index=0UL, 250 do begin ; FILES1_COUNT-2ul, 10 do begin
    C_SKIP=1
    frame+=1
    temp_gif_name=gif_name_prefix+ $
                  string(frame,FORMAT= $  
                         '(I5.5)')+'.gif'

;    print, files_index
    print, files1[files_index]
    restore, files1[files_index]
;Rad tag was properly set in all versions.
    loop.rad=sqrt(loop.a/!dpi)
    ;loop1=loop
    ;loop1.rad=loop.rad*5.

    e_color=Top_COLOR/max_heat
    ;fill=loop.e_h*e_color+bottom_color
    fill=get_loop_temp(loop)*f1+f2
    pmm, fill
 ;   window, 3
 ;   plot,loop.s_alt[1:n_elements(loop.s_alt)-2],loop.e_h
 ;   for ii=0, n_elements(loop.e_h)-1 do begin
 ;       plots,loop.s_alt[ii+1] ,loop.e_h[ii], $
 ;             color=fill[ii],psym=2
 ;   endfor 
 ;   wset,2
    device, color=16, /landscape, file=temp_ps_name
    show_loop_tactical, loop1, $
                        XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                        THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                        INITIAL=1, LOOP_LINE=AXIS_LINE,$
                        SURFACE_LINE=SURFACE_LINE,$
                        C_SKIP=C_SKIP
    show_loop_tactical, loop, $
                        XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                        THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                        INITIAL=0, LOOP_LINE=AXIS_LINE,$
                        SURFACE_LINE=SURFACE_LINE, FILL=FILL,$
                        C_SKIP=C_SKIP, no_oplot=1

xyouts, (xrange[0]+(xrange[1]+xrange[0])/2.)*OFFSET1,max(loop1.axis[2,*]+loop1.rad)*.5 ,$
        'Temperature', charsize=3.0, charthick=1.9,$;/t3d ,$
        z=max(loop1.axis[2,*]+loop1.rad);, FONT=FONT,/DATA;,$
       ; ORIENTATION=90       ; ORIENTATION=90
    
 ;   if !d.name eq 'Z' then $
 ;     z2gif, temp_gif_name else $
 ;     x2gif, temp_gif_name 
    DEVICE, /CLOSE
    SPAWN, "convert "+temp_ps_name+" "+ temp_gif_name
    SPAWN, "convert -rotate '-90' "+temp_gif_name +" "+  temp_gif_name
if size( gifnames, /TYPE) eq 0 then $
  gifnames=temp_gif_name else $
  gifnames=[gifnames,temp_gif_name]

endfor
end_jump:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Leave the t matrix as you found it.

!P.T=old_p_dot_t
set_plot, old_device
;tvlct, r,g,b,/GET
;image2movie,plot_array,r,g,b,$
;            movie_name=strcompress('tactical_test.gif',/REMOVE_ALL), $
;            gif_animate=1,loop=1
image2movie,gifnames,$
            movie_name=strcompress(movie_name,/REMOVE_ALL), $
            mpeg=1;gif_animate=1,loop=1
print, 'Movie Name='+strcompress(movie_name,/REMOVE_ALL)
;for i=0UL, n_elements(gifnames)-1UL do  begin
;    spawn, 'rm -f '+gif_name_prefix+'*'
;endfor
tvlct, old_r, old_g, old_b,/GET
;spawn , 'scp '+movie_name+' filament.physics.montana.edu:/www/winter/'
end
