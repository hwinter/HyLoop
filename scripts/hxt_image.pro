
INFILE='/Users/winter/Data/PATC/runs/2006_AUG_21/loop_hist.sav'
gif_dir='/Users/winter/Data/PATC/runs/'
BREMSFILE='/Users/winter/Data/PATC/runs/2006_AUG_17/brems.sav'
restore,INFILE
restore, BREMSFILE
;mk_hxt_movie3,loop,brems_struct



end
