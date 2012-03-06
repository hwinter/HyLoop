patc_dir=getenv('DATA')
start_file=patc_dir+'/PATC/runs/2006_SEP_19/gcsm_loop.sav'
restore, start_file
regrid,loop,/nosave, /showme

end
