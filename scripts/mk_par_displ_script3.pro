;.r mk_hd_movie_script6
cs=1
mpeg=1
;java=1


font=0

exp_dir=getenv('DATA')+'/PATC/runs/flare_exp_05/alpha=-4/699_25/run_01/'
title='!9a!3=-4'
cd , exp_dir
spawn, 'mkdir plots'
spawn, 'mkdir gifs'
spawn, 'mkdir movies'
spawn, 'mkdir tmp'
set_plot, 'z'
MOVIE_NAME='particle.mpg'
gif_dir=exp_dir+'gifs/'
movie_dir=exp_dir+'movies/'

;files=file_search(exp_dir,'patc*.loop', COUNT=FILE_COUNT)
;FILE_COUNT<=40
;gif_files=''
 mk_part_disp_movie1,exp_dir ,$
                  GIF_DIR=GIF_DIR,EXT=EXT,$
                  MOVIE_NAME=movie_dir+MOVIE_NAME,$
                  FILE_PREFIX=FILE_PREFIX,$
                  LOUD=LOUD, JS=JS,$
                  FREQ_OUT=FREQ_OUT, $
                  CS=CS, JAVA=JAVA,$; GIF=GIF,$
                  MPEG=1,LOOP=LOOP, $
                  TITLE=TITLE, font=font
end





