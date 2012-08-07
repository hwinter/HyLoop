
data_dir=getenv('DATA')
data_dir=data_dir+'/PATC/'

cd, data_dir
dirs=file_search('./', 'alpha=*', /TEST_DIRECTORY, /FULLY_QUALIFY_PATH)
subdirs=file_search(dirs, 'GS*', /TEST_DIRECTORY,$
                    /FULLY_QUALIFY_PATH, COUNT=N_FOLDERS) 

for I=0, N_FOLDERS-1 do begin
    cd , subdirs[i]
    restore, 'startup_vars.pro'
    files=file_search('./', 'T*.loop', COUNT=N_FILES) 
    restore,files[N_FILES-1ul]

    Web_folder_name=subdirs[i]
    Web_folder_name=strsplit(Web_folder_name, '/',COUNT=string_count, /EXTRACT)
    
    spawn_cmd='mkdir '+data_dir+'/www/'+Web_folder_name[string_count-2L]+'/'
    spawn,spawn_cmd 
    spawn_cmd='mkdir '+data_dir+'/www/' $
              +Web_folder_name[string_count-2L]+$
              '/'+Web_folder_name[string_count-1L]+'/'
    spawn,spawn_cmd 
    Web_folder_name=Web_folder_name[string_count-2L]+ '/'+$
                    Web_folder_name[string_count-1L]
    spawn_cmd='cp *.txt '+data_dir+'/www/'+Web_folder_name+'/'
    spawn,spawn_cmd 
    spawn_cmd='cp *.ps '+data_dir+'/www/'+Web_folder_name+'/'
    spawn,spawn_cmd 
    spawn_cmd='cp *.gif '+data_dir+'/www/'+Web_folder_name+'/'
    spawn,spawn_cmd 
    spawn_cmd='cp *.mpg '+data_dir+'/www/'+Web_folder_name+'/'
    spawn,spawn_cmd 
    spawn_cmd='cp gifs/*.mpg '+data_dir+'/www/'+Web_folder_name+'/'
    spawn,spawn_cmd 
    spawn_cmd='cp '+read_me_file_name+' '+data_dir+'/www/'+Web_folder_name+'/'
    spawn,spawn_cmd 
    spawn_cmd="rsync -avuCz --exclude '*~' -e 'ssh' " $
              +data_dir+$
              '/www/ filament.physics.montana.edu:/www/winter/loop_sim/sims'
    spawn,spawn_cmd 
endfor






end
