pro mk_trace_movie2,loop,INFILE=INFILE,OUTFILE=OUTFILE, GIF_DIR=GIF_DIR,$
                   RES=RES, STR=STR, MAP195=MAP195,$
                   MAP171=MAP171, EXP=EXP, CADENCE=CADENCE

start_time=' 16-JUN-2006 00:00:'
if keyword_set(infile)then restore,file
IF not keyword_set(OUTFILE) THEN OUTFILE='trace_movie'
IF not keyword_set(GIF_DIR) then GIF_DIR='./'

IF not keyword_set(res) then res=0.5d ;TRACE pixel res. arcsec
pixel=res*700d*1d5

IF not keyword_set(exp) then exp=3d

start_time=systime(/julian)
rot1=rotation(2,!dpi/2) 
rot2=rotation(3,-1d*!dpi)
;rot2=rotation(3,!dpi/2)
rot3=rotation(1,!dpi)
n_loop=n_elements(loop)

window,0,xs=700,ys=700
window,1,xs=700,ys=700
n_depth=loop[0].n_depth

n_vol=n_elements(loop[0].state.e)-2l
n_x=n_elements(loop[0].s)

n_images=loop[n_loop-1l].state.time/exp
dt=loop[n_loop-1l].state.time-loop[n_loop-2l].state.time
counter=0
for i=0,n_images-1l do begin
    duration=0
    axis=loop[i].axis
    axis=(rot2#rot1#axis)
;For the side tip
;axis=(rot3#axis)
    rad=loop[counter].rad
    image_171=1
    image_195=1
    volumes=get_loop_vol(loop[counter].s,loop[counter].a)
    while duration lt exp do begin
        temp_signal=get_trace_emiss(loop[counter],/per)
        if n_elements(signal) lt 1 then  signal=temp_signal Else begin 
            signal.oa171=signal.oa171+temp_signal.oa171
            signal.oa195=signal.oa195+temp_signal.oa171
        endelse
        duration=duration+dt
        counter=counter+1l
        help, duration
        help, loop[counter].state.time
    endwhile

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Artificially kill the chromospheric signal;
    signal.oa171[0:n_depth]=0d
    signal.oa171[(n_vol-1-n_depth):n_vol-1]=0
    signal.oa195[0:n_depth]=0d
    signal.oa195[(n_vol-1-n_depth):n_vol-1]=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    wset,0
    trace_colors,171
    show_loop_image,axis,rad,$
                    signal.oa171,pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_171 ;,/sqrt;,/NOSCALE
    wset,1
    trace_colors,195
    show_loop_image,axis,rad,signal.oa195,pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_195 ;,/sqrt;,/NOSCALE
    temp_image_struct={image_171:image_171,image_195:image_195}
    
    if n_elements(image_struct) lt 1 then image_struct=temp_image_struct $
    else image_struct=[image_struct,temp_image_struct]
    
endfor

;image_struct[0].image_171[0:42]=1d6

scale171=255/max(image_struct.image_171)
scale195=255/max(image_struct.image_195)

animate_index=0
gifs_171=''
gifs_195=''
window,0,xs=700,ys=700
window,1,xs=700,ys=700
for i=0,n_images-1l  do begin
    time=start_time+Strcompress(string(exp,format='(g5.3)'),/remove_all)
    help,time
    print,'time'+time
;anytim2cal(start_time,form=1)
    wset,0
    trace_colors,171
    ;tvscl,image_struct[i].image_171*scale171
     map={data:image_struct[i].image_171*scale171,$
         xc:1000,yc:0,dx:.5,$    ;pix1d/(3600*700*1d5)),$
         dy:.5,$                ;:pixel*(/(700*1d5)),$
         time:(time),$
         ID:'TRACE: 171'}
     if n_elements(MAP171) lt 1 then  MAP171=map $
     else MAP171=concat_struct(MAP171,map)

plot_map,Map,XRANGE=[900,1200],YRANGE=[-250,250],$
  /limb_plot,lmthick=1,grid=50;,/nodata;,grid=50;composite=1,/over,/average,/INTER
;plot_map,map,XRANGE=[900,1200],YRANGE=[-250,250],/noerase;,/limb_plot
    ;legend,'Time: '+Strcompress(string(loop[i].state.time),/remove_all), /bottom,/left,box=0
    ;legend,'TRACE 171',center=1,/top_LEGEND,box=0

    x2gif,strcompress(gif_dir+'trace_171_frame'+string(animate_index,FORMAT= $  
                                                       '(I5.5)')+'.gif')
    gifs_171=[gifs_171,strcompress(gif_dir+'trace_171_frame'+string(animate_index,FORMAT= $  
                                                     '(I5.5)')+'.gif')]

    WSET,1
    trace_colors,195
    ;tvscl,image_struct[i].image_195*scale195
    ;Strcompress(string(loop[i].state.time),/remove_all)
    
     map={data:image_struct[i].image_195*scale195,$
         xc:1000,yc:0,dx:.5,$    ;pix1d/(3600*700*1d5)),$
         dy:.5,$                ;:pixel*(/(700*1d5)),$
         time:(time),$
         ID:'TRACE: 195'}
     if n_elements(MAP195) lt 1 then  MAP1=map $
     else MAP195=concat_struct(MAP195,map)                       

 plot_map,Map,XRANGE=[900,1200],YRANGE=[-250,250],$
  /limb_plot,lmthick=1,grid=50;,/nodata;,grid=50;composite=1,/over,/average,/INTER
 ;plot_map,map,XRANGE=[900,1200],YRANGE=[-350,350],/noerase;,/limb_plot
    
   ; legend,'Time: '+Strcompress(string(loop[i].state.time),/remove_all), /bottom,/left,box=0
    ;legend,'TRACE 195',center=1,/top_LEGEND,box=0
         x2gif,strcompress(gif_dir+'trace_195_frame'+string(animate_index,FORMAT= $  
                                                     '(I5.5)')+'.gif')
          gifs_195=[gifs_195,strcompress(gif_dir+'trace_195_frame'+string(animate_index,FORMAT= $  
                                                     '(I5.5)')+'.gif')]
    animate_index+=1
endfor
;stop
gifs_171=gifs_171[where(gifs_171 ne '')]
image2movie,gifs_171,$
  movie_name=strcompress(gif_dir+'TRACE_171_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1
gifs_195=gifs_195[where(gifs_195 ne '')]
image2movie,gifs_195,$
  movie_name=strcompress(gif_dir+'TRACE_195_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1
str=image_struct
end
