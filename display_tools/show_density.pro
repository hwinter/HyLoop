pro show_density,loop,INFILE=INFILE,OUTFILE=OUTFILE, GIF_DIR=GIF_DIR,$
                   RES=RES, STR=STR
old_device=!d.name
set_plot,'x'
start_time=' 24-AUG-2006 00:00:'
if keyword_set(infile)then restore,infile
IF not keyword_set(OUTFILE) THEN OUTFILE='density_movie'
IF not keyword_set(GIF_DIR) then GIF_DIR='./'

IF not keyword_set(res) then res=0.25d ;TRACE pixel res. arcsec
pixel=res*700d*1d5

n_loop=n_elements(loop)

window,0,xs=700,ys=700
n_depth=loop[0].n_depth

n_vol=n_elements(loop[0].state.e)-2l
n_x=n_elements(loop[0].s)

counter=0
axis=loop[0].axis
axis[0,*]=loop[0].axis[1,*]
axis[1,*]=loop[0].axis[2,*]
axis[2,*]=loop[0].axis[0,*]

loadct,9

image_out=1
gifs=''
animate_index=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for i=0,n_loop-1l do begin
   
    rad=loop[counter].rad
    volumes=get_loop_vol(loop[counter].s,loop[counter].a)
    signal=loop[counter].state.n_e[1:n_elements(loop[counter].state.n_e)-2l]$
           /volumes

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Artificially kill the chromospheric signal;
    signal[0:n_depth]=0d
    signal[(n_vol-1-n_depth):n_vol-1]=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    show_loop_image,axis,rad,$
                    signal,pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_out; ,$
                    ;/NOSCALE    ;,/sqrt;,/NOSCALE
;    wait,5
    window,0,xs=700,ys=700
    tvscl,image_out
    gif_file=strcompress(gif_dir+outfile+$
                         '_frame'+string(animate_index,FORMAT= $  
                                         '(I5.5)')+'.gif')
    print,gif_file
    x2gif,gif_file
    gifs=[gifs,gif_file ]

    ;WSET,1
    animate_index=animate_index+1
endfor
;stop
gifs=gifs[where(gifs ne '')]
image2movie,gifs,$
  movie_name=strcompress(gif_dir+outfile+'.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1
set_plot,old_device
end
