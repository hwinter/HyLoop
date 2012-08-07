
MULTI_FOLDERS='/'+['099_25',$
                   '199_25',$
                   '299_25',$
                   '399_25',$
                   '499_25',$
                   '599_25',$
                   '699_25',$
 ;                  '799_25',$
                   '899_25',$
                   '999_25',$
                   '1099_25',$
                   '1199_25',$
                   '1299_25',$
                   '1399_25']+'/'+'run_01/'

X_vals=[099ul,$
        199ul,$
        299ul,$
        399ul,$
        499ul,$
        599ul,$
        699ul,$
;        799ul,$
        899ul,$
        999ul,$
        1099]
;X_LABELS=X_LABELS[0:5]
loop_grid_test_t_n_e, $
                     EXPERIMENT_DIR=EXPERIMENT_DIR, $
                     ALPHA_FOLDERS=ALPHA_FOLDERS, $
                     MULTI_FOLDERS=MULTI_FOLDERS,$
;                     X_LABELS=X_LABELS,$
                     PLOT_PREFIX='grid_test_',$
                     MOVIE_NAME='grid_test',$
                     X_VALS=X_vals
