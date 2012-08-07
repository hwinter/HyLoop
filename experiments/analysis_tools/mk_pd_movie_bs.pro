
set_plot,'z'
for i=0ul, n_experiments-1ul do begin
    for j=0ul, n_alphas-1ul do begin    
        for k=0ul,  n_grids-1ul do begin
            for l=0ul, n_runs-1ul do begin
                current_folder=EXPERIMENT_DIR[i]+ $
                               '/'+ALPHA_FOLDERS[j]+ $
                               '/'+GRID_FOLDERS[k]+ $
                               '/'+RUN_FOLDERS[l]+ '/'
                Print, 'Now on folder: '+current_folder
                gif_dir=current_folder+'gifs/'
                spawn, 'mkdir '+gif_dir
                plot_dir=current_folder+'plots/'
                spawn, 'mkdir '+plot_dir

                MOVIE_DIR=current_folder+'movies/'
                spawn, 'mkdir '+MOVIE_DIR


                restore, current_folder+'initial_nt_beam.sav'
                nt_beam=INJECTED_BEAM[0].nt_beam
                for ii=0ul, n_elements(INJECTED_BEAM) -1ul do begin
                    nt_beam=[nt_beam, INJECTED_BEAM[ii].nt_beam]
                endfor

                vary=randomu(seed, n_elements(NT_beam))
                mk_part_disp_movie1, current_folder,$
                                     GIF_DIR=GIF_DIR,PLOT_DIR=PLOT_DIR,$
                                     EXT=EXT,$
                                     MOVIE_NAME=PD_MOVIE_NAME,$
                                     FILE_PREFIX=FILE_PREFIX,$
                                     LOUD=LOUD, JS=JS,$
                                     FREQ_OUT=FREQ_OUT, $
                                     MPEG=MPEG,LOOP=LOOP, $
                                     TITLE=TITLE, font=font, $
                                     MOVIE_DIR=MOVIE_DIR, $
                                     VARY=VARY, MAX_N_FILES=MAX_N_FILES, $
                                     THERMAL_STOP=THERMAL_STOP 
                
            endfor
        endfor
    endfor
endfor
print, 'Now finished with HD movies'
