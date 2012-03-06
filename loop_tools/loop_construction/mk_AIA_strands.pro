 
data_dir=getenv('DATA')
;Pixels extent in " times cm/"  Guestimate
pixel=.6d*750d*1d3*1d2

dir=data_dir+'/AIA/aia_strands/'
mk_dir,dir

mk_loop_strands, STR_DIAM=pixel*.3,$
  LOOP_DIAM=3d*pixel,$
  dir=dir





end
