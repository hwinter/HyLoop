;
;This procedure produces a single plot that charts the %SDEV
;  of Temperature and electron number density as a function of time.
;
pro   mrun_fourplot_test_emiss, map_1_name,map_2_name ,$
  YTITLES=YTITLES,NAMES=NAMES, $
  EXPERIMENT_DIR=EXPERIMENT_DIR, $
  ALPHA_FOLDERS=ALPHA_FOLDERS, $
  GRID_FOLDERS=GRID_FOLDERS, $
  MULTI_FOLDERS=MULTI_FOLDERS,$
  X_LABELS=X_LABELS, PLOT_PREFIX=PLOT_PREFIX,$
  MOVIE_NAME=MOVIE_NAME


if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
  EXPERIMENT_DIR=getenv('DATA')+'/PATC/runs/flare_exp_05/'
if size(MULTI_FOLDERS, /TYPE) ne 7 then begin
    MESSAGE,' Procedure loop_mrun_test3_apex_emiss reqires the keyword MULTI_FOLDERS to be set.'
    stop
endif 
;if size(map_name, /TYPE) ne 7 then begin
;    MESSAGE,' Procedure loop_mrun_test_apex_emiss reqires the  positional parameter (1) map_index.'
;    stop
;end
;if size(test_name, /TYPE) ne 7 then begin
;    MESSAGE,' Procedure loop_mrun_test_apex_emiss reqires the  positional parameter (2) vars_name.'
;    stop
;end

if size(PLOT_PREFIX, /TYPE) ne 7 then $
  PREFIX='fourplot_apex_emiss_' else  PREFIX=PLOT_PREFIX

if size(MOVIE_NAME, /TYPE) ne 7 then $
  MOVIE_NAME=strcompress(STRING(BIN_DATE(), $  
                                Format='(A, I4, 5I2.2, A)'), $
                         /REMOVE)+'fourplot_apex_emiss_'


n_folders=n_elements(EXPERIMENT_DIR)
n_alphas=n_elements(ALPHA_FOLDERS)
n_grids=n_elements(GRID_FOLDERS)
n_mfs=n_elements(MULTI_FOLDERS)

n_e_div=1d8
T_Div=1d6
FONT=0
TITLE='Run Test 3a'
EXTRA=gang_plot_pos(1,1,1)
n_runs_string='# of Runs= '+string(n_mfs, FORMAT='(I03)')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define coordinates
YC=0.0
XC=940.
xr=[XC-20, XC+35]
yr=[YC-50, YC+55]
;Now for the apex box
apex_xr=XC+[0,20]
apex_yr=YC+[-10,20]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make some plotting choices and take stock of the current plotting
;  environment so that we can reset.
old_state=!D.NAME
set_plot, 'ps'
tvlct, r_old,g_old,b_old,/GET
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

for i=0ul,  n_folders-1ul do begin
    for j=0ul, n_alphas-1ul do begin
        for k=0ul, n_grids-1ul do begin
            gif_files=''  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Here we make sure that all of the necessary directories exist        
            Current_folder=EXPERIMENT_DIR+'/'+ $
                           ALPHA_FOLDERS[i]+'/'+ $
                           GRID_FOLDERS[k]+'/'     
            movie_dir=Current_folder+'movies/'
            spawn, 'mkdir '+movie_dir
            movie_dir=movie_dir+'grid_tests/'
            spawn, 'mkdir '+movie_dir
            
            gif_dir=Current_folder+'gifs/'
            spawn, 'mkdir '+gif_dir
            gif_dir=gif_dir+'grid_tests/'
            spawn, 'mkdir '+gif_dir
            
            plots_dir=Current_folder+'plots/'
            spawn, 'mkdir '+plots_dir 
            plots_dir=plots_dir+'grid_tests/'
            spawn, 'mkdir '+plots_dir

            
            

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Count the number of files in each grid folder and take the 
;  smallest one.       
;        n_files=1d35
;        for k=0ul, n_mfs-1ul do begin
;            
;            files=file_search(Current_folder+'/'+MULTI_FOLDERS[k]+'/' ,$
;                              +'maps/'+map_1_name, $
;                              COUNT=N_loops, $
;                              /FULLY_QUALIFY_PATH)
;            
;            n_files<=N_loops
;            
;            files=file_search(Current_folder+'/'+MULTI_FOLDERS[k]+'/' ,$
;                              +'maps/'+map_2_name, $
;                              COUNT=N_loops, $
;                              /FULLY_QUALIFY_PATH)
;            
;            n_files<=N_loops
;        endfor                  ;k loop

n_files=501        
Current_folder=EXPERIMENT_DIR+'/'+ $
               ALPHA_FOLDERS[i]+'/'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;apex_emission([time], [number of runs], [# of maps to test])
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            N_MAPS=2
            
            Apex_emission=dblarr(n_files, n_mfs, N_MAPS)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For each step in time make a plot that shows how the temperature
            k=0ul
            map_dir=Current_folder+MULTI_FOLDERS[k]+'maps/'
            restore, map_dir+map_1_name
            times=(map.time)
            temp_map=map
            temp_map=add_tag(temp_map, 0., 'ROLL')
            temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
            temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
            temp_map.xc=XC
            temp_map.yc=YC
;Apex submap
            sub_map,temp_map,a_map,xrange=apex_xr,yrange=apex_yr ;
            for ll=0,N_files -1ul do begin
                Apex_emission[ll, k, 0]=total(a_map[ll].data)  
            endfor              ; ll loop N_MAPS

            restore, map_dir+map_2_name
            temp_map=map
            temp_map=add_tag(temp_map, 0., 'ROLL')
            temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
            temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
            temp_map.xc=XC
            temp_map.yc=YC
;Apex submap
            sub_map,temp_map,a_map,xrange=apex_xr,yrange=apex_yr ;
            for ll=0,N_files -1ul do begin
                Apex_emission[ll, k, 1]=total(a_map[ll].data)  
            endfor              ; ll loop N_MAPS

            for k=1ul, n_mfs-1ul do begin
                 map_dir=Current_folder+MULTI_FOLDERS[k]+'maps/'
            restore, map_dir+map_1_name
            temp_map=map
            temp_map=add_tag(temp_map, 0., 'ROLL')
            temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
            temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
            temp_map.xc=XC
            temp_map.yc=YC
;Apex submap
            sub_map,temp_map,a_map,xrange=apex_xr,yrange=apex_yr ;
            for ll=0,N_files -1ul do begin
                Apex_emission[ll, k, 0]=total(a_map[ll].data)  
            endfor              ; ll loop N_MAPS

            restore, map_dir+map_2_name
            temp_map=map
            temp_map=add_tag(temp_map, 0., 'ROLL')
            temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
            temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
            temp_map.xc=XC
            temp_map.yc=YC
;Apex submap
            sub_map,temp_map,a_map,xrange=apex_xr,yrange=apex_yr ;
            for ll=0,N_files-1ul do begin
                Apex_emission[ll, k, 1]=total(a_map[ll].data)  
            endfor              ; ll loop N_MAPS   
         
        endfor                  ; n_mfs loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    emiss_one_error=dblarr(n_files)
    emiss_two_error=emiss_one_error

    for ll=0ul, n_files-1ul do begin
        junk=moment(Apex_emission[ll,*,0],SDEV=SDEV)
        emiss_one_error[LL]=(SDEV/junk[0])*100.
        junk=moment(Apex_emission[ll,*,1],SDEV=SDEV)
        emiss_two_error[LL]=(SDEV/junk[0])*100


    endfor
x=dindgen(n_elements(Apex_emission[0,*,0]))
x=reform(x)
times=times[0:n_files-1ul]           
for ll=0ul,n_elements(times) do begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a plot      
            ps_name=plots_dir+prefix+string(ll,format='(I05)')+'.eps'
            gif_name=gif_dir+prefix+string(ll,format='(I05)')+'.gif'
   ;         ps_name=plots_dir+prefix+'.eps'
   ;         gif_name=gif_dir+prefix+'.gif'
            device, /portrait, file= ps_name , color=16, /enc

            font=0
          ;  charsize=1.3
           ; charthick=1.3
            fourplot, x, reform(Apex_emission[ll,*,0]),$
                      color='red', back='white',$
                      font=font, charsize=charsize,$
                      charthick=charthick,$
                      xticks=3

            legend, times[LL], BOX=0, /LEFT, /TOP



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
            device, /CLOSE
            print, ps_name
            
            spawn, 'convert '+ ps_name+' '+gif_name
            print, gif_name
            gif_files=[gif_files, gif_name]

            print, ps_name
                                ;      print, movie_dir+movie_name
                                ;     image2movie,gif_files, $
   ;                 movie_name=movie_name+'.mpg',$
 ;                   movie_dir=movie_dir,$
 ;                   /mpeg,$     ;/java,$
 ;                   scratchdir=gif_dir
 ;   
        endfor;ll loop
    

            gif_files=gif_files[1:N_ELEMENTS(gif_files)-1UL]
            image2movie,gif_files, $
                    movie_name=movie_name+'.mpg',$
                    movie_dir=movie_dir,$
                    /mpeg,$     ;/java,$
                    scratchdir=gif_dir

        endfor           ;k loop Grids
    endfor                     ;j loop Alphas

endfor                         ;i loop Experiments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset the plotting environment.
tvlct, r_old,g_old,b_old
set_plot, old_state
end
