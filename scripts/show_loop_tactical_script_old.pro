;show_loop_tactical
Data_dir=getenv('DATA')
file=Data_dir+'/PATC/runs/2007_MAY_24_PATC_test/gcsm_loop.sav'
movie_name='tactical_test1.gif'
files=['']
files=file
restore, file
old_device=!D.NAME
delvarx, plot_array
;Record the orignal _ matrix so that we can reset it later
old_p_dot_t=!P.T
;Rad tag was properly set in all versions.
loop.rad=sqrt(loop.a/!dpi)
axis=[loop.axis[0,*]+2.5d9,loop.axis[1,*], loop.axis[2,*]]

;For later use.
;Rotate about the Y-Axis
rot1=rotation(2,!dpi/2) 
;Rotate about the Z-Axis
rot2=rotation(3,-1d*!dpi)
;rot2=rotation(3,!dpi/2)
;Rotate about the X-Axis
rot3=rotation(1,!dpi)
;;axis=(rot2#rot1#axis)
;axis=rot1#axis
;matrix=rotate_loop()

TITLE='Title' 
CHARTHICK=2.
CHARSIZE=2.
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
temperature=get_loop_temp(loop)
t_color=Top_COLOR/max(temperature)
n_frames=100

YRANGE=[MIN(LOOP.AXIS[1,*]),MAX(LOOP.AXIS[1,*])]

delvarx, gifnames
gif_name_prefix='junk_temp'
for frame=0, n_frames do begin
    temp_gif_name=gif_name_prefix+ $
                  string(frame,FORMAT= $  
                         '(I5.5)')+'.gif'

    C_STRUCT=0
    ax=0.+(45.*frame/n_frames)
    PRINT, AX
    
    AZ=90.-(60.*frame/n_frames)
    SURFACE, [[0,0], [0,0]], /NODATA, /SAVE,$ 
             xrange=[0, 5d9], yrange=YRANGE, zrange=[0, 2.5d9], $
             thick=5, AX=AX, AZ=AZ,TITLE=TITLE, CHARSIZE=CHARSIZE, $
             CHARTHICK=CHARTHICK
plots, axis[0,*], axis[1,*],axis[2,*], /t3d, line=1  
show_loop_skeleton, axis, loop.rad,CIRC=CIRC, C_STRUCT=C_STRUCT, /THREED, $
                    LINESTYLE=2, /NO_PLOT

n_struct=n_elements(C_STRUCT)

;Loop to create a section if the are of the cylinder perpendicular to the axis.
;Each section will have four corners in 3d space 
for i=0UL, n_struct-2UL do begin
  
;The indices i & j will correspond to the circles that define the surface of  
; the cylinder parallel to the axis
    j=i+1UL
    
    n_circ_points=n_elements(C_STRUCT[i].circ[0,*])
;The indices m & n correspond to the points along each circle.
    for m=0UL, n_circ_points-2UL do begin
        n=m+1UL
;Attach the last point to the first.
        if n ge n_circ_points then n=0UL
;Define the x coordinates of each corner of the current section. 
        x_array=[C_STRUCT[i].circ[0,m], $
                C_STRUCT[j].circ[0,m], $
                C_STRUCT[j].circ[0,n], $
                C_STRUCT[i].circ[0,n]]
;Define the y coordinates of each corner of the current section. 
        y_array=[C_STRUCT[i].circ[1,m], $
                C_STRUCT[j].circ[1,m], $
                C_STRUCT[j].circ[1,n], $
                C_STRUCT[i].circ[1,n]]
;Define the z coordinates of each corner of the current section. 
        z_array=[C_STRUCT[i].circ[2,m], $
                C_STRUCT[j].circ[2,m], $
                C_STRUCT[j].circ[2,n], $
                C_STRUCT[i].circ[2,n]]
;        polyfill, x_array, y_array,z_array, $
;                  COLOR=1,/T3D;,/LINE_FILL, 
        polyfill, x_array, y_array,z_array, $
                  COLOR=temperature[i]*t_color,/T3D ;,/LINE_FILL,
    endfor
endfor  
show_loop_skeleton, axis, loop.rad,CIRC=CIRC, C_STRUCT=C_STRUCT, /THREED, $
                    LINESTYLE=2; , /NO_PLOT

;        if size(plot_array,/TYPE) eq 0 then $
;          plot_array=tvread() else $
;          plot_array=[[[temporary(plot_array)]],[[tvread()]]]

X2gif, temp_gif_name
if size( gifnames, /TYPE) eq 0 then $
  gifnames=temp_gif_name else $
  gifnames=[gifnames,temp_gif_name]


endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
for i=0, n_elements(files)-1 do begin
    restore , files[i]
    
endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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
