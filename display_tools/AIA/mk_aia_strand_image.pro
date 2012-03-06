; IDL Version 6.2 (linux x86_64 m64)
; Journal File for winter@mithra
; Working directory: /disk/hl2/data/winter/data1/PATC/loop_tools
; Date: Sat Feb 11 00:45:35 2006
 
patc_dir=get_environ('PATC')
data_dir=get_environ('DATA')
gif_dir=data_dir+'/gifs/'  
mk_dir,gif_dir
;Define Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    kB = 1.38e-16               ;Boltzmann constant (erg/K)
    mp = 1.67e-24               ;proton mass (g)
    gamma = 5.0/3.0             ;ratio of specific heats, Cp/Cv
    gs = 2.74e4                 ;solar surface gravity
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;figure out grid size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
file=file_search(data_dir+'/AIA/strand_start*')

rot1=rotation(2,-1*!pi/2)
gif_names=''
gif_names2=''
    animate_index=0l
window,1, xs=700,ys=800
for i=0,n_elements(file)-1 do begin
    break_file,file[i],disk,dir,filename,ext
    restore,file[i]
    pixel=700d*.6*1d5
    AXIS=ROT1#AXIS
       N = n_elements(lhist.v) 
;x on the volume element grid (like e, n_e)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    x_alt = [2*x[0]-x[1],(x[0:N-3]+x[1:N-2])/2.0,2*x[N-2]-x[N-3]]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;find midpoint along loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    midpt = max(x_alt)/2.0 
;Calculate the temperature 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    T = lhist.e/(3.0*lhist.n_e*kB)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    em=loop_em(x,a,lhist[0])
    phi=t[1:400]
;phi=em
    
;window,1
;plot_3dbox,axis[0,*],axis[1,*],axis[2,*]
    axis=matrix_multiply(rot,axis)
    rot=rotation(1,!dpi/2) 
    axis=matrix_multiply(rot,axis)
;rot=rotation(2,.1d*!dpi/2) 
;axis=matrix_multiply(rot,axis)
;rot=rotation(3,.1d*!dpi) 
;axis=matrix_multiply(rot,axis)
;window,2
;plot_3dbox,axis[0,*],axis[1,*],axis[2,*]
window,0
;stop
    loadct,3
 ;for i=0,n_elements(lhist)-1l do begin
    image_out=1
    
    show_loop_image,axis,rad,phi,pixel=pixel,win=win_num,$
      dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
                                ;IMAGE_OUT=smooth(IMAGE_OUT,smooth_p)
gif_name2=strcompress(gif_dir+'bstrnd_mov_temp'+$
                  string(animate_index,FORMAT='(I5.5)')+'.gif')
x2gif, gif_name2
gif_names2=[gif_names2,gif_name2]
    map={data:IMAGE_OUT,$
         xc:950,yc:0,dx:.6,$    ;pix1d/(3600*700*1d5)),$
         dy:.6,$                ;:pixel*(/(700*1d5)),$
         time:'17-Apr-2006 15:23:16.000',$
         ID:'AIA: A194'}
     ; x2gif,strcompress(gif_dir+'loop_mov_temp'
;                +string(animate_index,FORMAT=$
;                               '(I5.5)')+'.gif'
;print,tresponse;
 ;endfor
 rmap=rot_map(map,90)
;map=[map,temp_map]
 IF I EQ 0 THEN BEGIN
     n_x=n_elements(image_out[*,0])
     n_y=n_elements(image_out[0,*])
     image_array=dblarr(n_x,$
                       n_y )
     image_array[*,*]=IMAGE_OUT
     ;WINDOW,1

 ENDIF else begin
     IMAGE_OUT=congrid(IMAGE_OUT,n_x,n_y,/minus_one)
     image_array[*,*]=image_array+IMAGE_OUT
endelse
     WSET,1
map={data:IMAGE_array,$
         xc:950,yc:0,dx:.6,$    ;pix1d/(3600*700*1d5)),$
         dy:.6,$                ;:pixel*(/(700*1d5)),$
         time:'17-Apr-2006 15:23:16.000',$
         ID:'AIA: A194'}
     ; x2gif,strcompress(gif_dir+'
;rmap=rot_map(map,+90)
plot_map,map,XRANGE=[700,1200],YRANGE=[-350,350],$
  /limb_plot,lmthick=2,/nodata,grid=50;composite=1,/over,/average,/INTER
plot_map,map,XRANGE=[700,1200],YRANGE=[-350,350],/noerase,/limb_plot
gif_name=strcompress(gif_dir+'strnd_mov_temp'+$
                  string(animate_index,FORMAT='(I5.5)')+'.gif')
x2gif, gif_name
gif_names=[gif_names,gif_name]
print,gif_name
animate_index=animate_index+1l
endfor

gif_names=gif_names[1:n_elements(gif_names)-1]

;PLOT_MAP,MAP[0],/OVER
;     x2gif,strcompress(gif_dir+'loop_mov_temp'+string(animate_index,FORMAT=$
      ;           
;Define Constants
 image2movie,gif_names,$
   movie_name=strcompress(gif_dir+'loop_movie.gif',/REMOVE_ALL), $
   gif_animate=1,loop=1,/nodelete

 image2movie,gif_names,$
   movie_name=strcompress(gif_dir+'loop_movie',/REMOVE_ALL), $
   /mpeg;gif_animate=1,loop=1,/nodelete
;junk=delete_file(gifs)


end
