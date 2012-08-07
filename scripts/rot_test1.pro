;.r rot_test1
Data_dir=getenv('DATA')+'/PATC/runs/piet_scaling_laws/joule_heating_const_depth_big/n_depth=25_n_cells=500/'
;Data_dir=getenv('DATA')+'/PATC/runs/test/'
folder_1=Data_dir
spawn, 'renice 4 -u winter' 
FONT=1
OFFSET1=.4
freq_out=10
file_prefix='T*'
file_ext='.loop'

files1=file_search(folder_1, file_prefix+file_ext, COUNT=FILES1_COUNT)

set_plot,'x'
ax=90.
az=90.
n_frames=3.

Z_begin=0.
z_end=0.
x_begin=0.
x_end=90.
restore, files1[0]
erase
;set_plot,'z'
gif_name_prefix='junk_frame_'
counter=0
gif_names=''
;goto, next
for frame=2, n_frames do begin


    ax=x_begin+((x_end-x_begin)*frame/n_frames)
    ;az=z_begin+((z_end-z_begin)*frame/n_frames)
    az=90.
    ax=89
    print,ax,ax,frame
    THICK=5
    Title='Scaling Laws'
    LOOP_LINE=1
    SURFACE_LINE=0
    INITIAL=1
    rot11=rotation(2,((!dpi*ax)/180.))
    rot22=rotation(3,((!dpi*az/180.)))
    rota=rot11#rot22
    for j=0, FILES1_COUNT-1uldo begin
        temp_gif_name=gif_name_prefix+ $
                      string(j,FORMAT= $  
                             '(I5.5)')+'.gif'
        gif_names=[gif_names,temp_gif_name]
        map=mk_loop_xrt_map(loop[0], filter=0,rot1=rot11, rot2=rot22)
        erase
        loadct, 3
        plot_map,map,$                   ;_extra=gang_plot_pos(2,1,0),OFFSET=[0.1,.6], $
                                         ; SIZE=[1.0,1.0]    ),$
                 /iso ,/square_sc;, /noaxes,/noerase,  /NOTITLE 
        
        x2gif, temp_gif_name
        gif_names=gif_names[1:n_elements(gif_names)-1ul]
        image2movie, gif_names, /mpeg, movie_mame='xrt_test'
        endfor
   ; em=get_loop_em(loop, t=loop_temp)
   ; 
   ; plot, loop.s_alt[1:n_elements(loop.s_alt)-2ul], loop_temp,$
   ;       _extra=gang_plot_pos(2,1,1), $
   ;                            ;SIZE=[.8,.8]    ) , ys=24,$
   ;       xrange=[-3.5d9, loop.l+2.5d9], /xs,$
   ;      /nodata,xtitle='s [cm]',ytitle='T [K]'
   ; 
   ; tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
   ; oplot, loop.s_alt[1:n_elements(loop.s_alt)-2ul], loop_temp,color=1
   ; axis, yaxis=1, yrange=[min(em), max(em)], /ylog,$
   ;       ytitle='EM cm!e-3!N'
   ; oplot, loop.s_alt[1:n_elements(loop.s_alt)-2ul],em,  color=2;,$
   ;        yrange=[min(em), max(em)];, /ylog

stop
    counter+=1
endfor
    az=90.
    ax=89
rot11=rotation(2,((!dpi*ax)/180.))
rot22=rotation(3,((!dpi*az/180.)))
rota=rot11#rot22
delvarx, map_array
max_image=0d0
next:
for i=0ul , FILES1_COUNT-1ul , freq_out do begin
    
    restore, files1[i]
    
    
       
    map=mk_loop_xrt_map(loop[0], filter=0,rot1=rota11, rot2=rot22)
    if max(map.data) gt max_image then begin
        max_image=max(map.data)
        max_i=i
    end
    if size(map_array, /TYPE) eq 0 then map_array=map $
      else map_array=concat_struct( map_array, map)
    erase
    loadct, 3       ; , /noaxes,/noerase,  /NOTITLE 
    ;em=get_loop_em(loop, t=loop_temp)
   ; 
   ; plot, loop.s_alt[1:n_elements(loop.s_alt)-2ul], loop_temp,$
   ;       _extra=gang_plot_pos(2,1,1, $
   ;                            SIZE=[.8,.8]    ) , ys=24,$
   ;       xrange=[-3.5d9, loop.l+2.5d9], /xs,$
   ;      /nodata,xtitle='s [cm]',ytitle='T [K]'
   ; 
   ; tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
   ; oplot, loop.s_alt[1:n_elements(loop.s_alt)-2ul], loop_temp,color=1
   ; axis, yaxis=1, yrange=[min(em), max(em)], /ylog,$
   ;       ytitle='EM cm!e-3!N'
   ; oplot, loop.s_alt[1:n_elements(loop.s_alt)-2ul],em,  color=2;,$
   ;        ;yrange=[min(em), max(em)];, /ylog
    
endfor
for i=0ul ,n_elements(map_array) -1ul do begin  
    temp_gif_name=gif_name_prefix+ $
                  string(counter,FORMAT= $  
                         '(I5.5)')+'.gif'
    
    gif_names=[gif_names,temp_gif_name]    
    plot_map,map_array[i],$;_extra=gang_plot_pos(2,1,0),OFFSET=[0.1,.6], $
                                ;      SIZE=[1.0,1.0]    ),$
             /iso, LAST_SCALE= map_array[max_i]   

    x2gif, temp_gif_name
endfor
end
