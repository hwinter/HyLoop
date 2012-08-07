

data_dir=getenv('DATA')+'/PATC/runs/'

cd, data_dir
dirs=file_search('./', 'alpha=*', /TEST_DIRECTORY, /FULLY_QUALIFY_PATH)
subdirs=file_search(dirs, 'GS*', /TEST_DIRECTORY,$
                    /FULLY_QUALIFY_PATH, COUNT=N_FOLDERS) 

NO_CHR=1
freq_out=1

for i=0UL, N_FOLDERS-1ul do begin
    cd, subdirs[i]
    print,  subdirs[i]
    Web_folder_name=subdirs[i]
    Web_folder_name=strsplit(Web_folder_name, $
                             '/',COUNT=string_count, /EXTRACT)
    
    restore, 'startup_vars.sav'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if Make_max_velocity_vs_time_plot gt 0 then begin
        tmk=T_string
        LENGTH=LENGTH_string
        max_velocity_display, subdirs[i], FILE_PREFIX=OUTPUT_PREFIX, $
          EXT=EXT, PS=PS_VP, TITLE=TITLE, EPS=EPS, FONT=FONT, $
          CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK, THICK=THICK,$
          LINESTYLE=LINESTYLE, TMK=TMK, LENGTH=LENGTH
    endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if Make_max_mach_vs_time_plot gt 0 then begin
        tmk=T_string
        LENGTH=LENGTH_string
        max_velocity_display, subdirs[i], FILE_PREFIX=OUTPUT_PREFIX, $
          EXT=EXT, PS=PS_VPM, TITLE=TITLE, EPS=EPS, FONT=FONT, $
          CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK, THICK=THICK,$
          LINESTYLE=LINESTYLE,TMK=TMK, LENGTH=LENGTH,$
          MACH=1
    endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if Make_temp_compare_plot gt 0 then begin
        tmk=T_string
        LENGTH=LENGTH_string
        temp_compare_plot, subdirs[i], FILE_PREFIX=FILE_PREFIX, $
                           EXT=EXT, PS=PS_TCP, TITLE=TITLE, $
                           EPS=EPS, FONT=FONT, $
                           CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK,$
                           THICK=THICK,$
                           LINESTYLE=LINESTYLE, ALPHA=!heat_alpha,$
                           BETA=!heat_beta,$
                           NO_CHR=NO_CHR,$
                           TMK=TMK, LENGTH=LENGTH
    endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if Make_hd_movie ne 0 then $
      mk_hd_movie2, './',$
                    GIF_DIR=GIF_DIR,EXT='loop',$        
                    FILE_PREFIX=OUTPUT_PREFIX
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if Make_trace_movie ne 0 then $
      mk_trace_movie, './',GIF_DIR=GIF_DIR , $
                      file_prefix=OUTPUT_PREFIX, ext='loop'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    run_time=systime(1)-run_start_time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Finish the descriptive_text
;What was the actual Tmax?
    t=max(get_loop_temp(temp_loop))
    T_string=strcompress(string(T,FORMAT='(g10.2)'),/remove)
    T_string='Acutal Tmax='+Strcompress(T_string, /REMOVE_ALL)
    descriptive_text=[descriptive_text,$
                      T_string]

    descriptive_text=[descriptive_text,$
                      'This simulation took ~' $
                      +strcompress(string(run_time/60.),$
                                   /REMOVE_ALL)+$
                      ' minutes to run']
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;make restarting a snap!
save, alpha, beta, tmax,length, diameter, $
      q0,T_string, length_string, diameter_string, $
      alpha_string, beta_string, descriptive_text, $
      file='startup_vars.sav'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if Make_read_me_file ne 0 then begin
    print,'Making readme file.'
    print,read_me_file_name


    openw, lun, read_me_file_name,/GET_LUN
    for k=0, n_elements(descriptive_text)-1ul do begin
        PRINTF, LUN, descriptive_text[k]
    endfor
    close, lun
    free_lun, lun
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if Add_to_web ne 0  then begin
    data_dir=getenv('DATA')
    data_dir=data_dir+'/PATC/'
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
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


END
