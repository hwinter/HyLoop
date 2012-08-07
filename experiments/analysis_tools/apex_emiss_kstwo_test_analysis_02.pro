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
;May have f'd this up
pro apex_emiss_kstwo_test_analysis_02,in_names,$
  out_names,var_names, $
  EXPERIMENT_DIR_1=EXPERIMENT_DIR_1, $
  EXPERIMENT_DIR_2=EXPERIMENT_DIR_2, $
  RUN_FOLDERS_1=RUN_FOLDERS_1, $
  RUN_FOLDERS_2=RUN_FOLDERS_2, $
  N_MAPS=N_MAPS, TITLES=TITLES

old_plot_state=!D.NAME

set_plot, 'z'
tvlct, r_old,g_old,b_old,/GET
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]

font=0
if not keyword_set(N_MAPS) then N_MAPS=300
n_map_files=n_elements(in_names)
if n_map_files ne n_elements(out_names) then begin
    
    print, 'Error:  Number of in files does not much number of out files.'
    print, 'apex_emiss_kstwo_test_analysis_01 quitting.'
    stop
endif
t0=systime(0)

n_experiments=n_elements(EXPERIMENT_DIR_1)+n_elements(EXPERIMENT_DIR_2)
if n_experiments ne 2 then begin
    
    print, 'Error: Must define two EXPERIMENT_DIRs'
    print, 'apex_emiss_kstwo_test_analysis_01 quitting.'
    stop
endif

experiment_dirs=[[EXPERIMENT_DIR_1], [EXPERIMENT_DIR_2]]

n_runs=n_elements(RUN_FOLDERS_1)
if n_runs le 1 then begin
    
    print, 'Error: Must define more than one RUN_FOLDERS_01'
    print, 'apex_emiss_kstwo_test_analysis_01 quitting.'
    stop
endif

n_runs2=n_elements(RUN_FOLDERS_2)
if n_runs le 1 then begin
    
    print, 'Error: Must define more than one RUN_FOLDERS_02'
    print, 'apex_emiss_kstwo_test_analysis_01 quitting.'
    stop
endif

if not keyword_set(TITLES) then TITLES='T Test'
if n_elements(TITLES) ne n_map_files then $
  TITLES=replicate(TITLES[0], n_map_files)

n_runs=min([n_runs,n_runs2])
RUN_FOLDERS=[[RUN_FOLDERS_1],[RUN_FOLDERS_2]]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define coordinates
YC=0.0
XC=940.
xr=[XC-10, XC+35]
yr=[YC-40, YC+50]

;Now for the apex box
apex_xr=XC+[0,20]
apex_yr=YC+[-10,20]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
outs_y=30
outs_x=15.
cthick=5
n_images=120
bin_size=4
delvarx, signal
apex_yrange=[-20,10]

max_files=2400
set_plot,'z'
;restore, file

!P.multi=[0,1,2]
for m=0ul, n_map_files-1ul do begin

    Apex_emission=dblarr(n_experiments, N_MAPS)

    for i=0ul, n_experiments-1ul do begin
        current_folder=EXPERIMENT_DIRs[i]
                       
        print, 'Now working on: '+current_folder
        print, in_names[m]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                
       ; for l=0ul, n_runs-1ul do begin         
            map_dir=current_folder+'/maps/'
            cd , map_dir
            print, 'Restoring file: '+map_dir+in_names[m]
            restore,in_names[m]; , verbose=1
            
                                ;   map=map[1:*]
            
            temp_map=time_bin_map(map,bin_size)
            times=(temp_map.time)
            temp_map=add_tag(temp_map, 0., 'ROLL')
            temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
            temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
            temp_map.xc=XC
            temp_map.yc=YC
         ;    save, map, file= Map_names[k]
;Apex submap
            sub_map,temp_map,a_map,xrange=apex_xr,yrange=apex_yr ;
            for ll=0,N_MAPS -1ul do begin
                Apex_emission[i, ll]=total(a_map[ll].data)  
            endfor              ; ll loop N_MAPS
            delvarx, map, temp_map
      ;  endfor                  ; l Loop, n_runs
        
    endfor                      ; i Loop n_experiments
    

;    t_result=dblarr(N_MAPS)
;    confidence=t_result
 ;   for ll=0,N_MAPS -1ul do begin
    kstwo,Apex_emission[0, *] ,Apex_emission[1, *]  , D, prob
;        t_test=tm_test(Apex_emission[0, *, ll],Apex_emission[1, *, ll] )
;        t_result[ll]=t_test[0]
;        confidence[ll]=100.-t_test[1]
 ;       D_result=D
        confidence=(1.-prob)*100.
      
        
  ;  endfor                      ; ll loop N_MAPS     
  ;  d=t_result
help, d,confidence,prob
    save, d,confidence,$
          FILE=var_names[m]

            endfor
 

                         ; m Loop n_map_files

                

tvlct, r_old,g_old,b_old
set_plot, old_plot_state
END ;Of Main

