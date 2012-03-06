pro mk_sxt_movie,loop,INFILE=INFILE,OUTFILE=OUTFILE, GIF_DIR=GIF_DIR,$
                 RES=RES, STR=STR,thin_al_map=thin_al_map,$
                 dag_map=dag_map, be_map=be_map, thick_al_map=thick_al_map,$
                 mg_map=mg_map
                 
if keyword_set(infile)then restore,file
IF not keyword_set(OUTFILE) THEN OUTFILE='sxt_movie'
IF not keyword_set(GIF_DIR) then GIF_DIR='./'

IF not keyword_set(res) then res=2.5d ;SXT pixel res. arcsec
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
axis=loop[i].axis
axis=(rot2#rot1#axis)nt



animate_index=0
gifs_thin_al=''
for i=0,n_loop-1 do begin



end
image2movie,gifs_thin_al,$
  movie_name=strcompress(gif_dir+'SXT_thin_al_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1


scale_thin_al=255/max(image_struct.thin_al)

animate_index=0
gifs_dag=''
for i=0,n_loop-1 do begin

end
scale_dag=255/max(image_struct.dag)
image2movie,gifs_dag,$
  movie_name=strcompress(gif_dir+'SXT_dag_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1

animate_index=0
gifs_be=''
for i=0,n_loop-1 do begin


end
scale_be=255/max(image_struct.be)
image2movie,gifs_be,$
  movie_name=strcompress(gif_dir+'SXT_be_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1

animate_index=0
gifs_thick_al=''
for i=0,n_loop-1 do begin


end
scale_thick_al=255/max(image_struct.thick_al)
image2movie,gifs_thick_al,$
  movie_name=strcompress(gif_dir+'SXT_thick_al_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1

animate_index=0
gifs_mg=''
for i=0,n_loop-1 do begin

end
scale_mg=255/max(image_struct.mg)
image2movie,gifs_mg,$
  movie_name=strcompress(gif_dir+'SXT_mg_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1
