pro mk_trace_movie3,loop,INFILE=INFILE,OUTFILE=OUTFILE, GIF_DIR=GIF_DIR,$
                   RES=RES, STR=STR, MAP195=MAP195,$
                   MAP171=MAP171, EXP=EXP, CADENCE=CADENCE

xs=600
ys=300
if keyword_set(infile)then restore,infile
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

window,0,xs=xs,ys=ys
window,1,xs=xs,ys=ys
window,2,xs=2d*xs,ys=ys
n_depth=loop[0].n_depth

n_vol=n_elements(loop[0].state.e)-2l
n_x=n_elements(loop[0].s)

n_images=loop[n_loop-1l].time/exp
n_frames=140
begin_index=70
for i=begin_index,n_frames do begin


    ;axis=loop[i].axis
    ;axis=(rot2#rot1#axis)
    axis=loop[i].axis
    axis[0,*]=loop[i].axis[1,*]
    axis[1,*]=loop[i].axis[2,*]
    axis[2,*]=loop[i].axis[0,*]
;For the side tip
;axis=(rot3#axis)
    rad=loop[i].rad
    image_171=1
    image_195=1
    volumes=get_loop_vol(loop[i].s,loop[i].a)
    signal=get_trace_emiss(loop[i],/per)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Artificially kill the chromospheric signal;
    signal.oa171[0:n_depth+6]=0d
    signal.oa171[(n_vol-1-(n_depth+6)):n_vol-1]=0
    signal.oa195[0:n_depth+6]=0d
    signal.oa195[(n_vol-1-(n_depth+6)):n_vol-1]=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    wset,0
    trace_colors,171
    show_loop_image,axis,rad,$
                    signal.oa171,pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_171,/NOSCALE ;,/sqrt;
    wset,1
    trace_colors,195
    show_loop_image,axis,rad,signal.oa195,pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_195,/NOSCALE ;,/sqrt;
    temp_image_struct={image_171:image_171,image_195:image_195}
   
    if n_elements(image_struct) lt 1 then image_struct=temp_image_struct $
    else image_struct=[image_struct,temp_image_struct]
        
endfor

;image_struct[0].image_171[0:42]=1d6

scale171=255/max(image_struct.image_171)
scale195=255/max(image_struct.image_195)

animate_index=0
gifs=''
images=dblarr(n_elements(image_struct[0].image_171[*,0]),$
              n_elements(image_struct[0].image_171[0,*]),2)

for i=0,N_elements(image_struct)-1l do begin
    time=' 16-JUN-2006 00:00:'+$
         Strcompress(string(loop[i].state.time,format='(g5.3)'),/remove_all)
    print,'time'+time
;anytim2cal(start_time,form=1)
    wset,2
    ;trace_colors,171
   ; tvscl,image_struct.image_171*scale171
    ; trace_colors,195
   ; tvscl,image_struct.image_195*scale195
    
    images[*,*,0]=image_struct[i].image_171*scale171
    images[*,*,1]=image_struct[i].image_195*scale195
     tvmulti,images,[3,3],$
            LABELS=['TRACE 171','TRACE 195']

    gif_name=strcompress(gif_dir+'trace_frame'+string(animate_index,FORMAT= $  
                                                      '(I5.5)')+'.gif')
    
    x2gif,gif_name
    gifs=[gifs,gif_name]
    animate_index+=1
endfor
;stop
gifs=gifs[where(gifs ne '')]
image2movie,gifs,$
  movie_name=strcompress(gif_dir+'TRACE_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1
str=image_struct
end
