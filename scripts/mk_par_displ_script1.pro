;.r mk_hd_movie_script6
cs=1
mpeg=1
;java=1




exp_dir=getenv('DATA')+'/PATC/runs/flare_exp_01/alpha=-2/699_25/run_01/'
title='!9a!3=-100'
cd , exp_dir
spawn, 'mkdir plots'
spawn, 'mkdir gifs'
spawn, 'mkdir movies'
spawn, 'mkdir tmp'

MOVIE_NAME='movies/particle'
mk_part_disp_movie1,exp_dir ,$
              GIF_DIR='temp',EXT='loop',$
              MOVIE_NAME=MOVIE_NAME,$
              FILE_PREFIX='patc',$
              LOUD=LOUD, JS=JS,$
              FREQ_OUT=FREQ_OUT, $
              CS=CS, JAVA=JAVA,$ ; GIF=GIF,$
              MPEG=MPEG,LOOP=LOOP, $
              TITLE=title

end





