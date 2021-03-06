pro mk_sxt_movie3,loop,INFILE=INFILE,OUTFILE=OUTFILE, GIF_DIR=GIF_DIR,$
                 RES=RES, STR=STR,thin_al_map=thin_al_map,$
                 dag_map=dag_map, be_map=be_map, thick_al_map=thick_al_map,$
                 mg_map=mg_map
                 
xs=600
ys=250

if keyword_set(infile)then restore,infile
IF not keyword_set(OUTFILE) THEN OUTFILE='sxt_movie'
IF not keyword_set(GIF_DIR) then GIF_DIR='./'

IF not keyword_set(res) then res=2.48d ;SXT pixel res. arcsec
pixel=res*700d*1d5
start_time=systime(/julian)
rot1=rotation(2,!dpi/2) 
rot2=rotation(3,-1d*!dpi)
;rot2=rotation(3,!dpi/2)
rot3=rotation(1,!dpi)
n_loop=n_elements(loop)

window,0,xs=xs,ys=ys
window,2,xs=2*xs, ys=2*ys

n_depth=loop[0].n_depth

n_vol=n_elements(loop[0].state.e)-2l
n_x=n_elements(loop[0].s)
loadct, 3,/sile
n_frames=140
begin_index=70
for i=begin_index,n_frames do begin


axis=loop[i].axis
;axis=(rot2#rot1#axis)

axis[0,*]=loop[i].axis[1,*]
axis[1,*]=loop[i].axis[2,*]
axis[2,*]=loop[i].axis[0,*]
    
;For the side tip
;axis=(rot3#axis)
    rad=loop[i].rad
    volumes=get_loop_vol(loop[i].s,loop[i].a)
    signal=get_sxt_emiss(loop[i],/per)

    thin_al=1
    dag=1
    be=1
    thick_al=1
    mg=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Artificially kill the chromospheric signal;
    signal.thin_al[0:(n_depth+6)]=0d
    signal.thin_al[(n_vol-1-(n_depth+6)):n_vol-1]=0
    
    signal.dag[0:n_depth+6]=0d
    signal.dag[(n_vol-1-(n_depth+6)):n_vol-1]=0
   
    signal.be[0:(n_depth+6)]=0d
    signal.be[(n_vol-1-(n_depth+6)):n_vol-1]=0

    signal.thick_al[0:(n_depth+6)]=0d
    signal.thick_al[(n_vol-1-(n_depth+6)):n_vol-1]=0

    signal.mg[0:n_depth+6]=0d
    signal.mg[(n_vol-1-(n_depth+6)):n_vol-1]=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    wset,0
    show_loop_image,axis,rad,$
                    signal.thin_al,pixel=pixel,win=win_num,$
                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=thin_al,/NOSCALE;,/sqrt;,/NOSCALE
    
    show_loop_image,axis,rad,signal.dag,pixel=pixel,win=win_num,$
                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=dag,/NOSCALE;,/sqrt;,/NOSCALE
    
    
    show_loop_image,axis,rad,signal.be,pixel=pixel,win=win_num,$
                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=be,/NOSCALE;,/sqrt;,/NOSCALE 

    
    show_loop_image,axis,rad,signal.thick_al,pixel=pixel,win=win_num,$
                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=thick_al,/NOSCALE;,/sqrt;,/NOSCALE

    
    show_loop_image,axis,rad,signal.mg,pixel=pixel,win=win_num,$
                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=mg,/NOSCALE;,/sqrt;,/NOSCALE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a structure to contain the images before mapping
temp_image_struct={thin_al:thin_al,$
                   dag:dag,$
                   be:be,$
                   thick_al:thick_al,$
                   mg:mg}
    
   
    if n_elements(image_struct) lt 1 then image_struct=temp_image_struct $
      else image_struct=concat_struct(image_struct,temp_image_struct)
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;       
endfor

;image_struct[0].image_171[0:42]=1d6

scale_thin_al=255/max(image_struct.thin_al)
scale_dag=255/max(image_struct.dag)
scale_be=255/max(image_struct.be)
scale_thick_al=255/max(image_struct.thick_al)
scale_mg=255/max(image_struct.mg)


animate_index=0
gifs=''
images=dblarr(n_elements(image_struct[0].mg[*,0]),$
              n_elements(image_struct[0].mg[0,*]), $
              4)

for i=0,n_elements(image_struct)-1l do begin

    time=Strcompress(string(loop[i].state.time,format='(g5.3)'),/remove_all)
    print,'time'+time

    wset,2
    ;tvscl,image_struct[i].thin_al*scale_thin_al
    ;legend,help,image

     ;tvscl,image_struct[i].dag*scale_dag
     ;tvscl,image_struct[i].thick_al*scale_thick_al
     ;tvscl,image_struct[i].be*scale_be
    images[*,*,0]=image_struct[i].thin_al*scale_thin_al
    images[*,*,1]=image_struct[i].dag*scale_dag
    images[*,*,2]=image_struct[i].thick_al*scale_thick_al
    images[*,*,3]=image_struct[i].be*scale_be

    tvmulti,images,[3,3,3,3],$
            LABELS=['Thin Al','Dag','Thick Al','Be'];,row=2;,$
            ;TITLE=time
     
     gif_file=strcompress(gif_dir+ $
                          'SXT_'+string(animate_index,FORMAT= $  
                                                   '(I5.5)')+'.gif')
     
     x2gif,gif_file
     gifs=[gifs,gif_file]



    animate_index+=1
endfor
;stop
gifs=gifs[where(gifs ne '')]

image2movie,gifs,$
  movie_name=strcompress(gif_dir+'SXT_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1

str=image_struct
end
