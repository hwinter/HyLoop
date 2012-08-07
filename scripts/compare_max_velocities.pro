;Test the old, incorrect scaling, to new scaling
;.r compare_max_velocities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
data_dir=getenv('DATA')+'/PATC/runs/'
top_dir=data_dir+'piet_scaling_laws/'
top_dirs=top_dir+['serio_total_energy/',$
                  'P_0_eq_avg_P/',$
                  'P_0_eq_const_P/']


subdir=['n_depth=50_n_cells=1000/']
;'alpha=-2.5_beta=2.0/', $
          
P_L_dirs=['alpha=-2.5_beta=0.0/', $
          'alpha=-2.0_beta=0.0/', $
          'alpha=-1.5_beta=0.0/', $
          'alpha=-1.0_beta=0.0/', $
          'alpha=-0.5_beta=0.0/', $
          'alpha=0.0_beta=0.0/', $
          'alpha=0.5_beta=0.0/', $
          'alpha=1.0_beta=0.0/', $
          'alpha=1.5_beta=0.0/', $
          'alpha=2.0_beta=0.0/', $
          'alpha=2.5_beta=0.0/']


CORONA_ONLY=1
prefix='T='
suffix='.loop'
PS='tempearture_comparison.ps'
TEXT_FILE='heating_comparison.txt'
NAME_ARRAY=[ 'Serio Scaled','Avg. P!D0!N', 'Const P!D0!N']


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the run play nice
spawn,'renice 4 -u winter'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for i=0ul, n_elements(P_L_dirs) -1ul do begin
    
    loop_files=file_search( top_dirs[0]+P_L_dirs[i]+subdir,$
                           prefix+'*'+suffix, $
                           COUNT=N_loops_0, $
                           /FULLY_QUALIFY_PATH)

    array_0=dblarr(N_loops_0,2)
    array_0_mach=dblarr(N_loops_0,2)
    for j=0ul, N_loops_0-1ul do begin
        restore, loop_files[j]
        array_0[j,0]=loop.state.time
        array_0[j,1]=max(loop.state.v)/1d5
        
        array_0_mach[j,0]=loop.state.time
        array_0_mach[j,1]=max(abs(loop.state.v/get_loop_cs(loop)))
    endfor

    loop_files=file_search( top_dirs[1]+P_L_dirs[i]+subdir,$
                           prefix+'*'+suffix, $
                           COUNT=N_loops_1, $
                           /FULLY_QUALIFY_PATH)

    array_1=dblarr(N_loops_1,2)
    array_1_mach=dblarr(N_loops_1,2)
    for j=0ul, N_loops_1-1ul do begin
        restore, loop_files[j]
        array_1[j,0]=loop.state.time
        array_1[j,1]=max(loop.state.v)/1d5
        
        array_1_mach[j,0]=loop.state.time
        array_1_mach[j,1]=max(abs(loop.state.v/get_loop_cs(loop)))
        
    endfor

    loop_files=file_search( top_dirs[2]+P_L_dirs[i]+subdir,$
                           prefix+'*'+suffix, $
                           COUNT=N_loops_2, $
                           /FULLY_QUALIFY_PATH)

    array_2=dblarr(N_loops_2,2)
    array_2_mach=dblarr(N_loops_2,2)
    for j=0ul, N_loops_2-1ul do begin
        restore, loop_files[j]
        array_2[j,0]=loop.state.time
        array_2[j,1]=max(loop.state.v)/1d5
        
        array_2_mach[j,0]=loop.state.time
        array_2_mach[j,1]=max(abs(loop.state.v/get_loop_cs(loop)))
        
    endfor

    
    cd , top_dirs[1]+P_L_dirs[i]+subdir
    restore, 'startup_vars.sav'

    TITLE='!9a!3='+ALPHA_STRING+' !9b!3='+Beta_STRING
    POST=top_dir+$ 
         'alpha='+ALPHA_STRING+'_'+ $
         'Beta='+Beta_STRING+ $
         '_velocity_compare'+ $
         '.ps'
    
    hdw_pretty_plot2,array_0,array_1,array_2, $
                     TITLE=TITLE, $
                     YTITLE='Max Velocity [km s!E-1!N]',$
                     XTITLE='Time [s]',$ 
                     POST=POST, $
;Legend keywords:
                     LABELS=NAME_ARRAY,BOX=0, RIGHT=1,$
                     TOP=1,$
;Annotation Keywords:
                     ANNOTATION=ANNOTATION,ABOX=0, $
                     ATOP=1
    

    POST=top_dir+$
         'alpha='+ALPHA_STRING+'_'+ $
         'Beta='+Beta_STRING+ $
         '_velocity_compare_mach'+ $
         '.ps'
    
    hdw_pretty_plot2,array_0_mach,array_1_mach,array_2_mach, $
                     TITLE=TITLE, $
                     YTITLE='Max Velocity Mach',$
                     XTITLE='Time [s]',$ 
                     POST=POST, $
;Legend keywords:
                     LABELS=NAME_ARRAY,BOX=0, RIGHT=1,$
                     TOP=1,$
;Annotation Keywords:
                     ANNOTATION=ANNOTATION,ABOX=0, $
                     ATOP=1
    



endfor


end_jump:
end
