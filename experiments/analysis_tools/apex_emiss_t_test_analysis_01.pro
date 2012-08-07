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
pro apex_emiss_t_test_analysis_01,in_names, out_names, $
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

delvarx, signal
apex_yrange=[-20,10]

max_files=2400
set_plot,'z'
;restore, file

!P.multi=[0,1,2]
for m=0ul, n_map_files-1ul do begin

    Apex_emission=dblarr(n_experiments, n_runs, N_MAPS)

    for i=0ul, n_experiments-1ul do begin
        current_folder=EXPERIMENT_DIRs[i]
                       
        print, 'Now working on: '+current_folder
        print, in_names[m]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                
        for l=0ul, n_runs-1ul do begin         
            map_dir=current_folder+RUN_FOLDERS[l]+'/maps/'
            cd , map_dir
            print, 'Restoring file: '+map_dir+in_names[m]
            restore,in_names[m]; , verbose=1
            
                                ;   map=map[1:*]
            times=(map.time)
            temp_map=map
            temp_map=add_tag(temp_map, 0., 'ROLL')
            temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
            temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
            temp_map.xc=XC
            temp_map.yc=YC
         ;    save, map, file= Map_names[k]
;Apex submap
            sub_map,temp_map,a_map,xrange=apex_xr,yrange=apex_yr ;
            for ll=0,N_MAPS -1ul do begin
                Apex_emission[i, l, ll]=total(a_map[ll].data)  
            endfor              ; ll loop N_MAPS
            delvarx, map, temp_map
        endfor                  ; l Loop, n_runs
        
    endfor                      ; i Loop n_experiments

    t_result=dblarr(N_MAPS)
    confidence=t_result
    for ll=0,N_MAPS -1ul do begin

        t_test=tm_test(Apex_emission[0, *, ll],Apex_emission[1, *, ll] )
        t_result[ll]=t_test[0]
        confidence[ll]=100.-t_test[1]
        
    endfor                      ; ll loop N_MAPS     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a plot

                ps_name=out_names[m]
                gif_name=out_names[m]+'.gif'
                set_plot, 'ps'
                print, ps_name
                device, /portrait, file= ps_name , color=16, /enc
;Plot the temperature array  with no axes on the right
                plot,times[0:n_maps-1],t_result , $
                     YRANGE=[.98*min(t_result),$
                         1.02*max(t_result)], $
                     YSTYLE=9, $
                     POSITION=[.2,.15, .85,.90], $
                     CHARTHICK=1.5, CHARSIZE=1.5, $
                                ;                 TITLE=TITLE, $
                     XTITLE='Time [s]',$
                     YTITLE='T Statistic',$
                     /NODATA, FONT=FONT,$
                     THICK=10, $
                     XRANGE=[min(times[0:n_maps-1]) , max(times[0:n_maps-1])], XS=1
                OPLOT,times[0:n_maps-1],t_result ,  thick=8, COLOR=1
                
                axis, YAXIS=1, $
                      YRANGE=[95, 100], $
                      YTITLE='% Confidence',$
                      /YSTYLE, $
                      CHARTHICK=1.5, CHARSIZE=1.5,$
                      /SAVE, FONT=FONT

                oplot,times[0:n_maps-1],confidence, $
                      COLOR=3,thick=6
                
                legend, ['T Stat.', '% Con.'],line=[0,0],$ ;PSYM=[4,4],$
                        COLOR=[1,3], /RIGHT, BOX=0,$
                        FONT=0,CHARTHICK=1.3, CHARSIZE=1.3, THICK=6
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                xyouts, 0.2,0.91, $
                        titles[m],/NORMAL,FONT=FONT,$
                        CHARTHICK=1.8, CHARSIZE=2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
            
            
                device, /CLOSE
                spawn, 'convert '+ ps_name+' '+gif_name
                print, gif_name   

    
    
endfor                          ; m Loop n_map_files

                

tvlct, r_old,g_old,b_old
set_plot, old_plot_state
END ;Of Main

