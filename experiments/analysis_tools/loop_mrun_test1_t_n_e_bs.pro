
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Print, 'Now running loop_mrun_test1_t_n_e'
MULTI_FOLDERS=GRID_FOLDERS+'/'+RUN_FOLDERS+'/'


loop_mrun_test1_t_n_e, $
  EXPERIMENT_DIR=EXPERIMENT_DIR, $
  ALPHA_FOLDERS=ALPHA_FOLDERS, $
  GRID_FOLDERS=GRID_FOLDERS, $
  MULTI_FOLDERS=MULTI_FOLDERS,$
                ;     X_LABELS=strcompress(string(indgen(n_runs)+1),$
                                ;       /REMOVE_ALL), $
  PLOT_PREFIX='run_test1_',$
  MOVIE_NAME='run_test1'
