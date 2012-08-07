;show_loop_tactical
Data_dir=getenv('DATA')+'/PATC/runs/'
movie_name='tactical_test.gif'
folder_1=Data_dir+'2007_MAY_23g/'

folder_2=Data_dir+'2007_MAY_20a/'
folder_3=Data_dir+'2007_MAY_20b/'
folder_4=''
folder_5=''

file_prefix='T_*'
file_ext='.loop'
files1=file_search(folder_1, file_prefix+file_ext, COUNT=FILES1_COUNT)
files2=file_search(folder_2, file_prefix+file_ext, COUNT=FILES2_COUNT)
files3=file_search(folder_3, file_prefix+file_ext, COUNT=FILES3_COUNT)
file_count=min([FILES1_COUNT,$
               FILES2_COUNT,$
               FILES3_COUNT])
restore, files1[0]
old_device=!D.NAME
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

TITLE='Title'
WINDOW, 2, XS=600, YS=600
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Top_COLOR=180
bottom_color=0
tvlct, old_r, old_g, old_b,/GET
;Set the new colors
;tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
;Red Temperature
loadct,3;, NCOLORS=NCOLORS
;stretch,bottom_color ,Top_COLOR, /chop
old_plot=!d.name
set_plot, 'X'
;device, SET_RESOLUTION=[800,800]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
THICK=5
Title='Scaling Laws'
LOOP_LINE=1
SURFACE_LINE=0
INITIAL=1
C_SKIP=0
temperature=get_loop_temp(loop)
t_color=Top_COLOR/max(temperature)
fill=temperature*t_color
n_frames=20
Z_begin=90.
z_end=30.
x_begin=0.
x_end=45


XRANGE=[MIN(LOOP.AXIS[0,*]),MAX(LOOP.AXIS[0,*])]
YRANGE=[MIN(LOOP.AXIS[1,*]),MAX(LOOP.AXIS[1,*])]
ZRANGE=[MIN(LOOP.AXIS[2,*]),MAX(LOOP.AXIS[2,*])]

range_min=min([XRANGE[0],YRANGE[0],ZRANGE[0]])
range_max=max([XRANGE[1],YRANGE[1],ZRANGE[1]])
yrange=[range_min,range_max]
xrange=yrange
zrange=yrange

;delvarx, YRANGE,xrange,zrange
delvarx, gifnames
;delvarx,fill
;fill=180.
 no_oplot=0
files_index=0
gif_name_prefix='junk_temp'
for frame=0, n_frames do begin
    temp_gif_name=gif_name_prefix+ $
                  string(frame,FORMAT= $  
                         '(I5.5)')+'.gif'

    ax=x_begin+(x_end*frame/n_frames)
    az=z_begin-((z_begin-z_end)*frame/n_frames)
   

    PRINT, AX, AZ
    


    restore, files3[files_index]
    
    loop.rad=sqrt(loop.a/!dpi)
    loop.axis=(rot1#loop.axis)

    temperature=get_loop_temp(loop)
    t_color=Top_COLOR/max(temperature)
    fill=temperature*t_color
    show_loop_tactical, loop, $
                        XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                        THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                        INITIAL=1, LOOP_LINE=AXIS_LINE,$
                        SURFACE_LINE=SURFACE_LINE,$
                        C_SKIP=C_SKIP, no_oplot=no_oplot



    restore, files1[files_index]
;Rad tag was properly set in all versions.
    loop.rad=sqrt(loop.a/!dpi)
    temperature=get_loop_temp(loop)
    t_color=Top_COLOR/max(temperature)
    fill=temperature*t_color
    show_loop_tactical, loop, $
                        XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                        THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                        INITIAL=0, LOOP_LINE=AXIS_LINE,$
                        SURFACE_LINE=SURFACE_LINE, $
                        C_SKIP=C_SKIP, no_oplot=no_oplot

    restore, files2[files_index]
    
    loop.rad=sqrt(loop.a/!dpi)
    loop.axis=(rot1a#loop.axis)

    temperature=get_loop_temp(loop)
    t_color=Top_COLOR/max(temperature)
    fill=temperature*t_color
    show_loop_tactical, loop, $
                        XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                        THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                        INITIAL=0, LOOP_LINE=AXIS_LINE,$
                        SURFACE_LINE=SURFACE_LINE,$
                        C_SKIP=C_SKIP, no_oplot=no_oplot
X2gif, temp_gif_name
if size( gifnames, /TYPE) eq 0 then $
  gifnames=temp_gif_name else $
  gifnames=[gifnames,temp_gif_name]


endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FILE_COUNT<=550
for files_index=0UL, FILE_COUNT-1ul,20 do begin
    C_SKIP=1
    frame+=1
    temp_gif_name=gif_name_prefix+ $
                  string(frame,FORMAT= $  
                         '(I5.5)')+'.gif'
no_oplot=1


    restore, files3[files_index]
    
    loop.rad=sqrt(loop.a/!dpi)
    loop.axis=(rot1#loop.axis)

    temperature=get_loop_temp(loop)
    t_color=Top_COLOR/max(temperature)
    fill=temperature*t_color
 ;   if n_elements(loop.s) gt 200 then $
 ;     skip=fix(n_elements(loop.s)/200
    show_loop_tactical, loop, $
                        XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                        THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                        INITIAL=1, LOOP_LINE=AXIS_LINE,$
                        SURFACE_LINE=SURFACE_LINE, FILL=FILL,$
                        C_SKIP=C_SKIP, no_oplot=no_oplot


    restore, files2[files_index]
    
    loop.rad=sqrt(loop.a/!dpi)
    loop.axis=(rot1a#loop.axis)

    temperature=get_loop_temp(loop)
    t_color=Top_COLOR/max(temperature)
    fill=temperature*t_color
    show_loop_tactical, loop, $
                        XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                        THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                        INITIAL=0, LOOP_LINE=AXIS_LINE,$
                        SURFACE_LINE=SURFACE_LINE, FILL=FILL,$
                        C_SKIP=C_SKIP, no_oplot=no_oplot



    restore, files1[files_index]
;Rad tag was properly set in all versions.
    loop.rad=sqrt(loop.a/!dpi)
    temperature=get_loop_temp(loop)
    t_color=Top_COLOR/max(temperature)
    fill=temperature*t_color
    show_loop_tactical, loop, $
                        XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                        THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                        INITIAL=0, LOOP_LINE=AXIS_LINE,$
                        SURFACE_LINE=SURFACE_LINE, FILL=FILL,$
                        C_SKIP=C_SKIP, no_oplot=no_oplot

X2gif, temp_gif_name
if size( gifnames, /TYPE) eq 0 then $
  gifnames=temp_gif_name else $
  gifnames=[gifnames,temp_gif_name]

endfor

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
            gif_animate=1,loop=1

for i=0UL, n_elements(gifnames)-1UL do  begin
    spawn, 'rm -f '+gifnames[i]
endfor
set_plot, old_plot
tvlct, old_r, old_g, old_b,/GET
spawn , 'scp '+movie_name+' filament.physics.montana.edu:/www/winter/'
end
