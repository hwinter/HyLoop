 
GIF_DIR='/Users/winter/programs/PATC/runs/2006_AUG_17/gifs/'
loop_file='/Users/winter/programs/PATC/runs/2006_AUG_17/loop_hist.sav'
start_file='/Users/winter/programs/PATC/runs/2006_AUG_17/gcsm_loop.sav'
old_loop=loop
restore, loop_file
loop=concat_struct(old_loop,Loop) 
mk_hd_movie, loop,beam_struct,GIF_DIR=GIF_DIR


end
