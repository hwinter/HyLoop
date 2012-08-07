;.r mk_hd_movie_script4
cs=1
mpeg=1
;java=1




exp_dir=getenv('DATA')+'/PATC/runs/flare_exp_01/'

grid_dirs='699_25/'
n_grid_dirs=n_elements(grid_dirs)

cd , exp_dir
alpha_dirs=file_search('alpha=*', $
                       /TEST_DIRECTORY, COUNT=ALPHA_COUNT,$
                       /FULLY_QUALIFY_PATH )


for i=0ul, ALPHA_COUNT-1UL DO BEGIN
    for j=0ul, n_grid_dirs-1ul do begin
        cd, alpha_dirs[i]+'/'+grid_dirs[j]
        spawn, 'mkdir plots'
        spawn, 'mkdir gifs'
        spawn, 'mkdir movies'
        spawn, 'mkdir tmp'
        restore, 'startup_vars.sav'
        run_folders=file_search('run*', $
                                /TEST_DIRECTORY, COUNT=ALPHA_COUNT,$
                                /FULLY_QUALIFY_PATH )
        MOVIE_NAME='movies/hd_plot'
        mk_hd_movie4, run_folders,$
                      GIF_DIR='temp',EXT='loop',$
                      MOVIE_NAME=MOVIE_NAME,$
                      FILE_PREFIX='patc',$
                      LOUD=LOUD, JS=JS,$
                      FREQ_OUT=FREQ_OUT, $
                      CS=CS, JAVA=JAVA,$ ; GIF=GIF,$
                      MPEG=MPEG,LOOP=LOOP, $
                      TITLE=alpha_dist_string
    endfor ;grid loop

endfor ;Alpha_loop
end





