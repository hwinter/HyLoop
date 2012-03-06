pro mk_sxt_movie,loop,INFILE=INFILE,OUTFILE=OUTFILE, GIF_DIR=GIF_DIR,$
                 RES=RES, STR=STR,thin_al_map=thin_al_map,$
                 dag_map=dag_map, be_map=be_map, thick_al_map=thick_al_map,$
                 mg_map=mg_map
                 
if keyword_set(infile)then restore,file
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

window,0,xs=700,ys=700
window,1,xs=700,ys=700
window,2,xs=700,ys=700
window,3,xs=700,ys=700
window,4,xs=700,ys=700
n_depth=loop[0].n_depth

n_vol=n_elements(loop[0].state.e)-2l
n_x=n_elements(loop[0].s)
loadct, 3,/sile
for i=0,n_loop-1l do begin


axis=loop[i].axis
axis=(rot2#rot1#axis)
    
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
    signal.thin_al[0:n_depth]=0d
    signal.thin_al[(n_vol-1-n_depth):n_vol-1]=0
    
    signal.dag[0:n_depth]=0d
    signal.dag[(n_vol-1-n_depth):n_vol-1]=0
   
    signal.be[0:n_depth]=0d
    signal.be[(n_vol-1-n_depth):n_vol-1]=0

    signal.thick_al[0:n_depth]=0d
    signal.thick_al[(n_vol-1-n_depth):n_vol-1]=0

    signal.mg[0:n_depth]=0d
    signal.mg[(n_vol-1-n_depth):n_vol-1]=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    wset,0
    show_loop_image,axis,rad,$
                    signal.thin_al,pixel=pixel,win=win_num,$
                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=thin_al,/NOSCALE;,/sqrt;,/NOSCALE
    wset,1
    show_loop_image,axis,rad,signal.dag,pixel=pixel,win=win_num,$
                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=dag,/NOSCALE;,/sqrt;,/NOSCALE
    
    wset,2
    show_loop_image,axis,rad,signal.be,pixel=pixel,win=win_num,$
                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=be,/NOSCALE;,/sqrt;,/NOSCALE 

    wset,3
    show_loop_image,axis,rad,signal.thick_al,pixel=pixel,win=win_num,$
                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=thick_al,/NOSCALE;,/sqrt;,/NOSCALE

    wset,4
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
gifs_thin_al=''
gifs_dag=''
gifs_thick_al=''
gifs_be=''
gifs_mg=''

for i=0,n_loop-1 do begin

    time=' 16-JUN-2006 00:00:'+Strcompress(string(loop[i].state.time,format='(g5.3)'),/remove_all)
    print,'time'+time

    wset,0
    ;tvscl,image_struct[i].image_171*scale171
     map={data:image_struct[i].thin_al*scale_thin_al,$
         xc:1000,yc:0,dx:res,$    ;pix1d/(3600*700*1d5)),$
         dy:res,$                ;:pixel*(/(700*1d5)),$
         time:(time),$
         ID:'SXT: Thin Al'}
;     if n_elements(Thin_Al_map) lt 1 then  Thin_Al_map=map $
;     else Thin_Al_map=concat_struct(Thin_Al_map,map)

     plot_map,Map,XRANGE=[900,1200],YRANGE=[-250,250],$
              /limb_plot,lmthick=1,grid=50 
;,/nodata;;composite=1,/over,/average,/INTER


     gif_file=strcompress(gif_dir+ $
                          'thin_al_'+string(animate_index,FORMAT= $  
                                                   '(I5.5)')+'.gif')
     x2gif,gif_file
     gifs_thin_al =[gifs_thin_al,gif_file]

     wset,1
                                ;tvscl,image_struct[i].image_171*scale171
     map={data:image_struct[i].dag*scale_dag,$
          xc:1000,yc:0,dx:res,$  ;pix1d/(3600*700*1d5)),$
          dy:res,$               ;:pixel*(/(700*1d5)),$
          time:(time),$
          ID:'SXT: DAG'}
  ;   if n_elements(DAG_map) lt 1 then  DAg_map=map $
  ;   else Dag_map=concat_struct(dag_map,map)

     plot_map,Map,XRANGE=[900,1200],YRANGE=[-250,250],$
              /limb_plot,lmthick=1,grid=50 
;,/nodata;;composite=1,/over,/average,/INTER

     gif_file=strcompress(gif_dir+ $
                         'dag_'+string(animate_index,FORMAT= $  
                                                   '(I5.5)')+'.gif')
     x2gif,gif_file
     gifs_dag =[gifs_dag,gif_file]

;wset,2,
                                ;tvscl,image_struct[i].image_171*scale171
 ;    map={data:image_struct[i].be*scale_be,$
;          xc:1000,yc:0,dx:res,$  
;          dy:res,$               
 ;         time:(time),$
;          ID:'SXT: Be'}
 ;    if n_elements(Be_map) lt 1 then  Be_map=map $
;     else Be_map=concat_struct(be_map,map)

;     plot_map,Map,XRANGE=[900,1200],YRANGE=[-250,250],$
;              /limb_plot,lmthick=1,grid=50 
;,/nodata;;composite=1,/over,/average,/INTER

;     gif_file=strcompress(gif_dir+ $
;                          outname+'be_`'+string(animate_index,FORMAT= $  
;                                                   '(I5.5)')+'.gif')
;     x2gif,gif_file
;     gifs_be =[gifs_be,gif_file]

wset,3
                                ;tvscl,image_struct[i].image_171*scale171
     map={data:image_struct[i].thick_al*scale_thick_al,$
          xc:1000,yc:0,dx:res,$  
          dy:res,$               
          time:(time),$
          ID:'SXT: Thick Al'}
 ;    if n_elements(thick_al_map) lt 1 then  thick_al_map=map $
  ;   else thick_al_map=concat_struct(thick_al_map,map)

     plot_map,Map,XRANGE=[900,1200],YRANGE=[-250,250],$
              /limb_plot,lmthick=1,grid=50 
;,/nodata;;composite=1,/over,/average,/INTER

     gif_file=strcompress(gif_dir+ $
                          'thick_al_'+string(animate_index,FORMAT= $  
                                                   '(I5.5)')+'.gif')
     x2gif,gif_file
     gifs_thick_al =[gifs_thick_al,gif_file]

;wset,4
                                ;tvscl,image_struct[i].image_171*scale171
 ;    map={data:image_struct[i].mg*scale_mg,$
 ;         xc:1000,yc:0,dx:res,$  
 ;         dy:res,$               
 ;         time:(time),$
 ;         ID:'SXT: Mg'}
 ;    if n_elements(mg_map) lt 1 then  mg_map=map $
 ;    else mg_map=concat_struct(mg_map,map)

;     plot_map,Map,XRANGE=[900,1200],YRANGE=[-250,250],$
;              /limb_plot,lmthick=1,grid=50 
;,/nodata;;composite=1,/over,/average,/INTER

 ;    gif_file=strcompress(gif_dir+ $
 ;                         outname+'mg_'+string(animate_index,FORMAT= $  
 ;                                                  '(I5.5)')+'.gif')
 ;    x2gif,gif_file
 ;    gifs_mg=[gifs_mg,gif_file]



    animate_index+=1
endfor
;stop
gifs_thin_al=gifs_171[where(gifs_thin_al ne '')]
gifs_dag=gifs_171[where(gifs_dag ne '')]
;gifs_be=gifs_171[where(gifs_be ne '')]
gifs_thick_al=gifs_171[where(gifs_thick_al ne '')]
;gifs_mg=gifs_171[where(gifs_mg ne '')]

image2movie,gifs_thin_al,$
  movie_name=strcompress(gif_dir+'SXT_thin_al_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1
image2movie,gifs_dag,$
  movie_name=strcompress(gif_dir+'SXT_dag_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1
;image2movie,gifs_be,$
;  movie_name=strcompress(gif_dir+'SXT_be_movie.gif',/REMOVE_ALL), $
;  gif_animate=1,loop=1
image2movie,gifs_thick_al,$
  movie_name=strcompress(gif_dir+'SXT_thick_al_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1
;image2movie,gifs_mg,$
;  movie_name=strcompress(gif_dir+'SXT_mg_movie.gif',/REMOVE_ALL), $
;  gif_animate=1,loop=1


str=image_struct
end
