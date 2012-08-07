;.r update_web_script
data_dir=getenv('DATA')+'/PATC/runs/piet_scaling_laws'
web_dir_local=getenv('DATA')+'/PATC/www/'
web_dir_online="filament.physics.montana.edu:/www/winter/loop_sim/sims"
patc_dir=getenv('PATC')
exclude_file=patc_dir+'/scripts/web_sync_exclude.txt'
for i=0ul , n_elements(data_dir)-1ul do begin
    spawn_cmd= "rsync -avuCz  -e 'ssh' --delete " $
               +"--exclude-from="+exclude_file+" " $
               +"--include '*.mpg' " $
               +data_dir+' '+web_dir_local
    print, spawn_cmd
    spawn, spawn_cmd
endfor
    spawn_cmd= "rsync -avuCz  -e 'ssh' --delete " $
               +"--exclude-from="+exclude_file+" " $
               +"--include '*.mpg' " $
               +web_dir_local+' '+web_dir_online
    print, spawn_cmd
    spawn,spawn_cmd 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


END
