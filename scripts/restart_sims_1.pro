run_start_time=systime(1)
run_start_time_string=systime()
restore,'startup_vars.sav'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Begin Switches to set
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the run play nice
spawn,'renice 4 -u winter'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Loop charactersitics
Tmax = 3d6 ;K
Length=3d9 ;[cm],30 Mega meters
diameter=1d7 ;[cm]
;Any notes to tag to the loop structure?
note=descriptive_text[0]+' '+descriptive_text[1]
;magnetic field strength
B=100
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set heating parameters.
;Exponent of the temperature dependence.
DEFSYSV, '!heat_alpha',0.5d
alpha=!heat_alpha
;Exponent of the pressure/density dependence.
DEFSYSV, '!heat_beta',0.0d
beta=!heat_beta
;Name the heating function.
heat_name='get_p_t_law_heat'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set time parameters
;Time per call to msu_loop
time=60.*60.;sec
;Maximum time to come to equilibrium
max_time=2.*time;sec
;Reporting time; Output a .loop file every DELTA_T simulated seconds
DELTA_T=1. ;sec
;Set the criterion for stability. When max(abs(v)) lt  v_limit then stop
v_limit=1e+5                    ; [cm/s]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Regrid keywords
;Which regrid scheme to use?
REGRID=2
;ds=min(cls)/GRID_safety
GRID_safety=100.
;Maximum step size
max_step=5.0d5;[cm], 5 km
PERCENT_DIFFERENCE=1d7
;Temporal safety factor.  dt=min(Courant)/safety
safety=5.
;Number of cells for original calculation
N_CELLS=1000ul
;Number of initial chromospheric cells
n_depth=100ul
;Dpth into the chromosphere
depth=2d6; [cm]

E_H=1    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Hydro keywords
ATM=1
;VERSION=
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set some naming parameters
;Make a prefix for the save files names.
;These will also be used in the additional descriptive text below.
T_string=strcompress(string(Tmax,FORMAT='(g10.2)'),/remove)
LENGTH_string=strcompress(string(length,FORMAT='(g10.2)'),/remove)
diameter_string=strcompress(string(diameter,FORMAT='(g10.2)'),/remove)
ALPHA_string=strcompress(string(!heat_alpha,FORMAT='(g10.2)'),/remove)
BETA_string=strcompress(string(!heat_beta,FORMAT='(g10.2)'),/remove)


OUTPUT_PREFIX='T='+T_string+'K_' + $
              'L='+LENGTH_string+'cm_'+ $
              'D='+diameter_string+'cm_'+ $
              'Alpha='+ALPHA_string+'_Beta='+BETA_string+'_'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Where to plot to?
set_plot,'z'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot output options.
;Comment out to set to defaults.
FONT=0
THICK=1.5
CHARSIZE=2.0
CHARTHICK=1.5
;Set the variable below for EPS plots
;EPS=1
;Make a title for the plots
TITLE='!9a!3='+ALPHA_STRING+' !9b!3='+Beta_STRING

;Make a plot showing max velocity vs time?  0=No,1=yes
Make_max_velocity_vs_time_plot=1
;Name the plot
PS_VP=OUTPUT_PREFIX+'velocity_plot.ps'

;Make a plot showing max mach # vs time?  0=No,1=yes
Make_max_mach_vs_time_plot=1
;Name the plot
PS_VPM =OUTPUT_PREFIX+'velocity_plot_mach.ps'

;Make a plot comparing Piet's analytical solutions to the numerical
; solutions?  0=No,1=yes
Make_temp_compare_plot=1 
;Name the plot
ps_tcp=OUTPUT_PREFIX+'temp_compare.ps'
;Kill the chromosphere part of the numerical simulations
NO_CHR=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Movie keywords.
;Include trailing /
cd , current=folder
GIF_DIR=folder+'/gifs/'
;Make an HD movie using stateplot2?  0=No,1=yes
Make_hd_movie=1
;Make an TRACE movie?  0=No,1=yes
Make_trace_movie=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a descriptive text file? 0=No,1=yes
Make_read_me_file=1
read_me_file_name='README.txt'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Add to web keywords.
;Add movies and plots to a webfolder? 0=No,1=yes
Add_to_web=1
;Will make a folder named data_dir+'/www/'+Web_folder_name+'/'
cd , current=Web_folder_name
Web_folder_name=strsplit(Web_folder_name, '/',COUNT=string_count, /EXTRACT)
;End of switches
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Finish the descriptive text based on the switches that you set

descriptive_text=[descriptive_text, $
                  'Tmax= '+T_string+'[K]']
descriptive_text=[descriptive_text, $
                  'Length= '+LENGTH_string+'[cm]']
descriptive_text=[descriptive_text, $
                  'Diameter= '+diameter_string+'[cm]']
descriptive_text=[descriptive_text, $
                  'Power Law Heating function. '$
                  + 'Alpha='+ALPHA_string+', Beta='+BETA_string]
descriptive_text=[descriptive_text, $
                  'Initial regrid after loop creation']
descriptive_text=[descriptive_text, $                 
                  'Initial grid settings: '+ $
                  'REGRID='+ STRING(REGRID)+$
                  ' GRID_safety='+STRING(GRID_safety)+ $
                  ' max_step='+STRING(max_step/1D5,$
                                      FORMAT='(g10.2)')+'[km]'+ $
                  ' PERCENT_DIFFERENCE= '+STRING(PERCENT_DIFFERENCE,$
                                                FORMAT='(g10.2)')]
descriptive_text=[descriptive_text, $
                  'Temporal Safety= '+strcompress(string(Safety),/REMOVE_ALL)]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
COMPILE_OPT STRICTARR
resolve_routine,['add_loop_chromo',$
                 'mk_loop_struct',$
                 'mk_semi_circular_loop', $
                 'regrid_step2', $
                 'regrid_inject', $ $
                 'msu_loop',$
                 'msu_loopmodel2',$
                 'get_loop_n_e_cls',$
                 'get_loop_e_cls',$
                 'get_loop_temp_cls',$
                 'get_loop_b_cls',$
                 'get_loop_v_cls',$
                 'msu_loop'], $
                /EITHER, /COMPILE_FULL

patc_dir=getenv('PATC')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make some settings to make use of IDL multithreading
;Most of the defaults are ok.
n_cpu=(!CPU.HW_NCPU-1)
n_cpu>=1
CPU ,TPOOL_MAX_ELTS = 1d6 ,TPOOL_MIN_ELTS = 5d3,$
     TPOOL_NTHREADS=n_cpu

if strupcase(!d.name) eq 'X' then begin
    window, 5
    window_state=1
    window_regrid=0
    showme=1
    debug=1
endif 

area1=!dpi*(diameter/2d0)^2.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOOP=1
mk_semi_circular_loop,diameter,Length, $
  T_MAX=Tmax, outname=outname,N_CELLS=N_CELLS,$
  X_SHIFT=X_SHIFT,Y_SHIFT=Y_SHIFT,$
  Z_SHIFT=Z_SHIFT, LOOP=LOOP,$
  depth=depth, N_DEPTH=N_DEPTH,$
  /ADD_CHROMO

old_loop=loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Test for the new regridding global variables
defsysv, '!MSULoop_axis', Exists=test
if test le 0 then defsysv, '!MSULoop_axis',loop[0].axis else $
  !MSULoop_axis=loop[0].axis 
defsysv, '!MSULoop_s', Exists=test
if test le 0 then defsysv, '!MSULoop_s',loop[0].s else $
  !MSULoop_s=loop[0].s 
defsysv, '!MSULoop_a', Exists=test
if test le 0 then defsysv, '!MSULoop_a',loop[0].a else $
  !MSULoop_a=loop[0].a 
defsysv, '!MSULoop_b', Exists=test
if test le 0 then defsysv, '!MSULoop_b',loop[0].b else $
  !MSULoop_a=loop[0].b 
defsysv, '!MSULoop_g', Exists=test
if test le 0 then defsysv, '!MSULoop_g',loop[0].g else $
  !MSULoop_a=loop[0].g

defsysv, '!MSULoop_loop', Exists=test
if test le 0 then defsysv, '!MSULoop_loop',loop[0] else $
  !MSULoop_loop=loop[0]

t2=get_loop_temp(loop) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get the amount of heating [ergs] needed to heat a loop of a certain length
Q0=get_serio_heat( loop.L,Tmax)	
DEFSYSV, '!bg_heat', Q0
DEFSYSV, '!heat_rate', Q0
;Make an initial regrid for smooth grid spacing
regrid_step2, loop,  grid_safety=grid_safety,$
             PERCENT_DIFFERENCE=PERCENT_DIFFERENCE,$
             WINDOW=WINDOW_REGRID,$
             MAX_STEP=MAX_STEP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;make restarting a snap!
save, alpha, beta, tmax,length, diameter, $
      q0,T_string, length_string, diameter_string, $
      alpha_string, beta_string, descriptive_text, $
      file='startup_vars.sav'


done=0
counter=0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
while not done do begin
    print, !Computer
    print, 'Tmax=',Tmax
    current_time=time*counter
    s_form=loop[0].e_h;
    temp_loop=loop[n_elements(loop)-1]
;
    msu_loopmodel2 ,temp_loop, $
                    time, $               ;
                    T0=1d4,  src=1,$      ; uri=uri, fal=fal, $
                    safety= safety , $;SHOWME=SHOWME, DEBUG=DEBUG   , $
                    QUIET=QUIET, HEAT_FUNCTION=heat_name,$
                    ;PERCENT_DIFFERENCE=1d7, MAX_STEP=MAX_STEP, $
                    ;so=so,grid_safety= grid_safety ,regrid=REGRID , $
                    E_H=E_H, FILE_PREFIX=OUTPUT_PREFIX
                   

    print, 'Actual Tmax=',max(get_loop_temp(temp_loop))
;WINDOW_STATE=window_state, WINDOW_REGRID=window_regrid 
;SO=SO,
  ;                              ;depth=loop[n_elements(loop)-1].depth, $
    ;files=file_search('outp*.loop',COUNT=FILE_COUNT, /FOLD_CASE)
    ;restore, files[FILE_COUNT-1]
    loop=temp_loop
    max_v=max(abs(loop.state.v))
    counter+=1 
    case 1 of 
        max_v le v_limit : done=1
        current_time ge max_time : done=1
        else: 
    endcase
    
endwhile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Profiler, /SYSTEM, /REPORT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if Make_max_velocity_vs_time_plot gt 0 then begin
    tmk=T_string
    LENGTH=LENGTH_string
    max_velocity_display, folder, FILE_PREFIX=OUTPUT_PREFIX, $
      EXT=EXT, PS=PS_VP, TITLE=TITLE, EPS=EPS, FONT=FONT, $
      CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK, THICK=THICK,$
      LINESTYLE=LINESTYLE, TMK=TMK, LENGTH=LENGTH
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if Make_max_mach_vs_time_plot gt 0 then begin
    tmk=T_string
    LENGTH=LENGTH_string
    max_velocity_display, folder, FILE_PREFIX=OUTPUT_PREFIX, $
      EXT=EXT, PS=PS_VPM, TITLE=TITLE, EPS=EPS, FONT=FONT, $
      CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK, THICK=THICK,$
      LINESTYLE=LINESTYLE,TMK=TMK, LENGTH=LENGTH,$
      MACH=1
endif


if Make_temp_compare_plot gt 0 then begin
    tmk=T_string
    LENGTH=LENGTH_string
    temp_compare_plot, folder, FILE_PREFIX=FILE_PREFIX, $
                       EXT=EXT, PS=PS_TCP, TITLE=TITLE, EPS=EPS, FONT=FONT, $
                       CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK, THICK=THICK,$
                       LINESTYLE=LINESTYLE, ALPHA=!heat_alpha, BETA=!heat_beta,$
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
;PROFILER , DATA=profiler_data, OUTPUT=profiler_report, /REPORT, /SYSTEM

;Clear out the profiler's memory
;Profiler, /RESET

end
