;retall
resolve_routine,'mk_sxt_movie3'
if n_elements(loop) lt 1 then $
  restore, '/Users/winter/programs/PATC/runs/2006_AUG_17/loop_hist.sav'
gif_dir='/Users/winter/programs/PATC/runs/2006_AUG_17/gifs/'
thin_al_map=1
dag_map=1
be_map=1
thick_al_map=1
mg_map=1

mk_sxt_movie3,loop,INFILE=INFILE,OUTFILE=OUTFILE, GIF_DIR=GIF_DIR
             


end
