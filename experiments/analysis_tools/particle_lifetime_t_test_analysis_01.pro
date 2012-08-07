;.mk_average_maps1.pro
;Average the runs 
;3-6 keV band
;in_names: Names of the map files to restore and analyze.  No path.
;  Program will look for the file:
;      EXPERIMENT_DIR_x+RUN_FOLDERS_x/maps/in_names[i]
;out_names: the names of the plots to be output.  Full path.
;     Number should be equal to n_elements(in_names)
;TITLE: Title of each plot. 
;     Number should be equal to n_elements(in_names)
;EXPERIMENT_DIR_1: Path of the first experiment to be compared.
;EXPERIMENT_DIR_2: Path of the second experiment to be compared.
;RUN_FOLDERS_1: Names of the run folders under the directory EXPERIMENT_DIR_1.
;RUN_FOLDERS_2: Names of the run folders under the directory EXPERIMENT_DIR_2

; fe05_mk3_6_7arc_average_map
pro particle_lifetime_t_test_analysis_01,in_names, out_names, $
                                      EXPERIMENT_DIR_1=EXPERIMENT_DIR_1, $
                                      EXPERIMENT_DIR_2=EXPERIMENT_DIR_2, $
                                      RUN_FOLDERS_1=RUN_FOLDERS_1, $
                                      RUN_FOLDERS_2=RUN_FOLDERS_2, $
                                      N_MAPS=N_MAPS, TITLES=TITLES
old_plot_state=!D.NAME

set_plot, 'z'
font=0
;N_MAPS=300
n_map_files=n_elements(in_names)
if n_map_files ne n_elements(out_names) then begin
    print, 'Error:  Number of in files does not much number of out files.'
    print, 'apex_emiss_t_test_analysis_01 quitting.'
    stop
endif
t0=systime(0)

n_experiments=n_elements(EXPERIMENT_DIR_1)+n_elements(EXPERIMENT_DIR_2)
if n_experiments ne 2 then begin
    
    print, 'Error: Must define two EXPERIMENT_DIRs'
    print, 'apex_emiss_t_test_analysis_01 quitting.'
    stop
endif

experiment_dirs=[[EXPERIMENT_DIR_1], [EXPERIMENT_DIR_2]]

n_runs=n_elements(RUN_FOLDERS_1)
if n_runs le 1 then begin
    
    print, 'Error: Must define more than one RUN_FOLDERS_01'
    print, 'mk_average_map quitting.'
    stop
endif

n_runs2=n_elements(RUN_FOLDERS_2)
if n_runs le 1 then begin
    
    print, 'Error: Must define more than one RUN_FOLDERS_02'
    print, 'mk_average_map quitting.'
    stop
endif

if not keyword_set(TITLES) then TITLES='T Test'
if n_elements(TITLES) ne n_map_files then $
  TITLES=replicate(TITLES[0], n_map_files)

n_runs=min([n_runs,n_runs2])
RUN_FOLDERS=[[RUN_FOLDERS_1],[RUN_FOLDERS_2]]

cthick=5
n_images=120


max_files=2400
n_maps=1d6


for i=0ul, n_experiments-1ul do begin
    current_folder=EXPERIMENT_DIRs[i]
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;        
    for l=0ul, n_runs-1ul do begin 
        
        files=file_search(Current_folder+'/'+RUN_FOLDERS[l]+'/' ,$
                          'patc*.loop', $
                          COUNT=N_loops, $
                          /FULLY_QUALIFY_PATH)
        
        n_maps<=  N_loops
    endfor                      ; l Loop, n_runs
        
endfor                          ; i Loop n_experiments
    
dead_times=dblarr(n_experiments, n_runs)

for i=0ul, n_experiments-1ul do begin
    current_folder=EXPERIMENT_DIRs[i]
    
    print, 'Now working on: '+current_folder
    ;print, in_names[m]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       
        
    for l=0ul, n_runs-1ul do begin 
        
        files=file_search(Current_folder+'/'+RUN_FOLDERS[l]+'/' ,$
                          'patc*.loop', $
                          COUNT=N_loops, $
                          /FULLY_QUALIFY_PATH)
        
        done=0
        loop_counter=0ul
         print, 'Now working on: '+Current_folder+'/'+RUN_FOLDERS[l]+'/'
        while done le 0 do begin
            print, loop_counter
            restore, files[loop_counter]
            alive_ind=where(nt_beam.state eq 'NT')
            if alive_ind[0] eq -1 then begin
                dead_times[i,l]=loop.state.time
                done=1
            endif
            loop_counter +=1ul
            if loop_counter ge n_maps then begin
                dead_times[i,l]=1d6
                done=1
            endif
        endwhile                  ; m Loop, n_maps

    endfor                      ; l Loop, n_runs
        
endfor                          ; i Loop n_experiments


t_result=dblarr(N_MAPS)
confidence=t_result

t_test=tm_test(dead_times[0, *],dead_times[1, *] )
t_result=t_test[0]
confidence=100.-t_test[1]

help, t_result, confidence

print, EXPERIMENT_DIRs[0]
result=moment(dead_times[0, *], sdev=sdev)
print, result
print, sdev
print, EXPERIMENT_DIRs[1]
result=moment(dead_times[1, *], sdev=sdev)
print, result
print, sdev


END ;Of Main

