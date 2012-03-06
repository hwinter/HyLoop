
INFILE='/Users/winter/programs/PATC/runs/2006_AUG_17/loop_hist.sav'
gif_dir='/Users/winter/programs/PATC/runs/2006_AUG_17/gifs/'

restore,INFILE
 mk_trace_movie3,loop,GIF_DIR=GIF_DIR
thin_al_map=1
dag_map=1
be_map=1
thick_al_map=1
mg_map=1

;mk_sxt_movie3,loop,OUTFILE=OUTFILE, GIF_DIR=GIF_DIR
             



end
