;.r mk_hd_movie_script6
cs=1
mpeg=1
;java=1




exp_dir=getenv('DATA')+'/PATC/runs/flare_exp_01a/alpha=-4/699_25/run_01/'
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

files=file_search(exp_dir,'patc*.loop', COUNT=FILE_COUNT)
FILE_COUNT<=40
gif_files='' 
for j=0ul , FILE_COUNT-1 do begin
    restore, files[j]
    
    index_string= string(j,FORMAT= $  
                         '(I5.5)')
    gif_file=gif_dir+'part_disp_'+ $
             '_'+index_string+'.gif'
    particle_display, loop,NT_beam,E_min=10,E_max=200,$
                      plot_title=title, font=0
    legend, 'Time: '+string(loop.state.time,FORMAT= $  
                         '(I5.5)'), box=0
    z2gif, gif_file
    gif_files=[gif_files,gif_file ]
    
endfor
gif_files=gif_files[1:*]

    image2movie,gif_files, $
                movie_name=movie_dir+movie_name,$
                /mpeg,$         ;/java,$
                scratchdir=gif_dir ,$;nothumbnail=1,$
                /nodelete
end





