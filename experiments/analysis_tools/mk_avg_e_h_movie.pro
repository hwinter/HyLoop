;.r mk_avg_e_h_movie.pro 


pro mk_avg_e_h_movie, $
  EXPERIMENT_DIR=EXPERIMENT_DIR, $
  ALPHA_FOLDERS=ALPHA_FOLDERS, $
  GRID_FOLDERS=GRID_FOLDERS, $
  RUN_FOLDERS=RUN_FOLDERS

print, 'Running mk_avg_e_h_movie'
 
prefix='e_h_movie_temp' 
movie_name='e_h_movie' 
if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
  EXPERIMENT_DIR=getenv('DATA')+'/PATC/runs/flare_exp_05'

if size(ALPHA_FOLDERS, /TYPE) ne 7 then $
  ALPHA_FOLDERS='alpha=-4'

if size(GRID_FOLDERS, /TYPE) ne 7 then $
  GRID_FOLDERS='699_25'

if size(RUN_FOLDERS, /TYPE) ne 7 then $
  RUN_FOLDERS=['run_01',$
               'run_02',$
               'run_03',$
               'run_04',$
               'run_05']

set_plot, 'z'
n_experiments=n_elements(EXPERIMENT_DIR)
n_folders=n_elements(ALPHA_FOLDERS)
n_grids=n_elements(GRID_FOLDERS)
n_runs=n_elements(RUN_FOLDERS)

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for h=0ul, n_experiments-1ul do begin
    for i=0ul,  n_folders-1ul do begin
        
        for j= 0ul,  n_grids-1ul do begin
            
            gif_files=''
            Current_folder=EXPERIMENT_DIR[h]+'/'+ $
                           ALPHA_FOLDERS[i]+'/'+ $
                           GRID_FOLDERS[j]+'/'
            
            print, 'Now on folder '+Current_folder
            gif_dir=Current_folder+'gifs/'
            spawn, 'mkdir '+gif_dir
            
            plots_dir=Current_folder+'plots/'
            spawn, 'mkdir '+plots_dir
            
            N_loops=ulong(1d6)
            for k=0ul, n_runs-1ul do begin
                
                files=file_search(Current_folder+$
                                  RUN_FOLDERS[k]+'/' ,$
                                  'patc*.loop', $
                                  COUNT=n_files, $
                                  /FULLY_QUALIFY_PATH)
                
                N_loops<=n_files
            endfor              ; k loop
            
            files=strarr(n_runs, N_loops)
            
            for k=0ul, n_runs-1ul do begin
                temp_files=file_search(Current_folder+$
                                       RUN_FOLDERS[k]+'/' ,$
                                       'patc*.loop', $
                                       COUNT=n_files, $
                                       /FULLY_QUALIFY_PATH)
                files[k,*]=  temp_files[0:N_loops-1ul]
            endfor

            min_e_h=1d36
            max_e_h=1d-36
            l=0ul
            restore, files[0,l]
            loops=loop
            for k=1ul, n_runs-1ul do begin
                restore, files[k,l]
                loops=concat_struct(loops, loop)
            endfor              ;k loop
            e_h=get_loops_avg_e_h( loops, STD_DEV=STD_DEV)
            min_e_h<=e_h-STD_DEV
            max_e_h>=e_h+STD_DEV
            loops_arr=loops

            for l=1ul, N_loops-1ul do begin
                restore, files[0,l]
                loops=loop
                for k=1ul, n_runs-1ul do begin
                    restore, files[k,l]
                    loops=concat_struct(loops, loop)
                endfor          ;k loop
                e_h=get_loops_avg_e_h( loops, STD_DEV=STD_DEV)
                min_e_h<=e_h-STD_DEV
                max_e_h>=e_h+STD_DEV
                loops_arr=[[loops_arr],[loops]]
            endfor              ;l loop
            
            for l=1ul, N_loops-1ul do begin
                ps_name=plots_dir+prefix+ $
                        string(loops[0].state.time,format='(I05)')+ $
                        '.eps'
                gif_name=gif_dir+$
                         prefix+string(loops[0].state.time,format='(I05)')+ $
                         '.gif'
                print, gif_name
                loops=reform(loops_arr[*,l])

                plot_avg_e_h, loops, fname=ps_name, $
                              EHRANGE=[min_e_h, max_e_h]

                spawn, 'convert '+ ps_name+' '+gif_name
                gif_files=[gif_files, gif_name]
            endfor              ;l loop

            gif_files=gif_files[1:N_ELEMENTS(gif_files)-1UL]
            print, movie_dir+movie_name
            image2movie,gif_files, $
                        movie_name=movie_name+'.mpg',$
                        movie_dir=movie_dir,$
                        /mpeg,$         ;/java,$
                        scratchdir=gif_dir ;,$  ;nothumbnail=1,$
        endfor                             ;j loop
    endfor                                 ;i loop
endfor                                     ;h loop
 end
