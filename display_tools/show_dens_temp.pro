pro show_dens_temp,loop,INFILE=INFILE,OUTFILE=OUTFILE, GIF_DIR=GIF_DIR,$
                   RES=RES, STR=STR
old_device=!d.name
set_plot,'x'
start_time=' 24-AUG-2006 00:00:'
if keyword_set(infile)then restore,infile
IF not keyword_set(OUTFILE) THEN OUTFILE='dens_temp_movie'
IF not keyword_set(GIF_DIR) then GIF_DIR='./'

IF not keyword_set(res) then res=0.25d ;TRACE pixel res. arcsec
pixel=res*700d*1d5

n_loop=n_elements(loop)

n_depth=loop[0].n_depth

n_vol=n_elements(loop[0].state.e)-2l
n_x=n_elements(loop[0].s)

counter=0
axis=loop[0].axis
axis[0,*]=loop[0].axis[1,*]
axis[1,*]=loop[0].axis[2,*]
axis[2,*]=loop[0].axis[0,*]

image_out_d=1
image_out_t=1
gifs=''
animate_index=0
temperature=get_loop_temp(loop.state)
temperature=temperature[1:n_elements(loop[0].state.n_e)-2l,*]
density=loop.state.n_e[1:n_elements(loop[0].state.n_e)-2l]
temp_scale=alog10(max(temperature))/255
dens_scale=alog10(max(density))/255

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for i=0,n_loop-1l do begin
    temperature=get_loop_temp(loop[i].state)
    temperature=temperature[1:n_elements(loop[i].state.n_e)-2l]
    rad=loop[i].rad
    volumes=get_loop_vol(loop[i].s,loop[i].a)
    signal=(loop[i].state.n_e[1:n_elements(loop[i].state.n_e)-2l]);$
          ; /volumes
    loadct,9,/silent

window,0,xs=700,ys=700
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Artificially kill the chromospheric signal;
    signal[0:n_depth]=0d
    signal[(n_vol-1-n_depth):n_vol-1]=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    show_loop_image,axis,rad,$
                    signal/volumes,pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_out_d ,$
                    /NOSCALE    ;,/sqrt;,/NOSCALE
;    wait,5
            
    loadct,3,/silent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Artificially kill the chromospheric signal;
    temperature=(temperature)
    temperature[0:n_depth]=0d
    temperature[(n_vol-1-n_depth):n_vol-1]=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    show_loop_image,axis,rad,$
                    (temperature),pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_out_t ,$
                    /NOSCALE    ;,/sqrt;,/NOSCALE
;    wait,5
    image=fltarr(n_elements(image_out_d[*,0]),$
                 n_elements(image_out_d[0,*]), $
                 2)
    image[*,*,0]=image_out_d*dens_scale

    image[*,*,1]=image_out_t*temp_scale

    help,image
    wdelete,0
    window,0,xs=1100,ys=500
    tvmulti,image,[9,3], $
            labels=['Density', 'Temperature'],$
            title=string(loop[i].state.time,format='(D4.2)')
    
    gif_file=strcompress(gif_dir+outfile+'_frame'+string(animate_index,FORMAT= $  
                                                         '(I5.5)')+'.gif')
    x2gif,gif_file
    gifs=[gifs,gif_file ]
    
    ;WSET,1
    animate_index+=1
endfor
;stop
gifs=gifs[where(gifs ne '')]
print,'Saving movie to '+ gif_dir+outfile+'.gif'
image2movie,gifs,$
  movie_name=strcompress(gif_dir+outfile+'.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1
set_plot,old_device
end
