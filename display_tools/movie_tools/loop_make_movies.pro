gif_dir='/disk/data1/winter/PATC/2005_05_20_exp_loop/gifs/'
save_type1='particles'
gifs1=findfile(strcompress(gif_dir+save_type1+'*'))
save_type2='hd'
gifs2=findfile(strcompress(gif_dir+save_type2+'*'))
save_type3='power_per_vol'
gifs3=findfile(strcompress(gif_dir+save_type3+'*'))


image2movie, gifs1[0:301], movie_name=strcompress(gif_dir+save_type1+'_movie.gif'), $
  gif_animate=1,/nodelete,/loop

image2movie, gifs2[0:301], movie_name=strcompress(gif_dir+save_type2+'_movie.gif'), $
  gif_animate=1,/nodelete,/loop
image2movie, gifs3[0:301], movie_name=strcompress(gif_dir+save_type3+'_movie.gif'), $
  gif_animate=1,/nodelete,/loop


end


