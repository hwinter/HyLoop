
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Print, 'Now running loop_mrun_test3_t_n_e'
MULTI_FOLDERS=GRID_FOLDERS+'/'+RUN_FOLDERS+'/'

Print, 'Now making Run Test 1'
loop_mrun_test3_t_6_25kev, $
  EXPERIMENT_DIR=EXPERIMENT_DIR, $
  ALPHA_FOLDERS=ALPHA_FOLDERS, $
  GRID_FOLDERS=GRID_FOLDERS, $
  MULTI_FOLDERS=MULTI_FOLDERS,$
  X_LABELS=X_LABELS, PLOT_PREFIX=PLOT_PREFIX,$
  MOVIE_NAME=MOVIE_NAME
