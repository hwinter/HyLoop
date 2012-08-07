;
; NAME: plot_max_t
; 
;
; PURPOSE: Collects loop.max_t data for one run, plots it over time
;
; 
;
; CALLING SEQUENCE: plot_max_t, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds, RUN_FORMAT=run_format, START_RUN=start_run
; 
;
; INPUTS: 
;
; KEYWORD PARAMETERS:
;   General analysis keywords:
;          INITIAL_PARAMETERS=initial_parameters ->No Default, ex. "pa_0_nt=100"
;          **TOTAL_RUNS=total_runs               ->not used **Default: 65
;          TOTAL_SECONDS=total_seconds           **Default: 900
;          RUN_FORMAT=run_format                 **Default: '(I04)'
;          DATA_FOLDER=data_folder               **Default: '/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
;          START_RUN=start_run                   **Default: 1
;          PLOT_FOLDER=plot_folder               **Default: '/Volumes/Herschel/aegan/plots/'

;
; OUTPUTS: .ps file of the plot ->  filename='/Volumes/Herschel/aegan/plots/'+initial_parameters+'_max_temp_plot.ps'
;
; OPTIONAL OUTPUTS: 
; 
; SAVED:  
;         
; 
;
; MODIFICATION HISTORY:
;   Written by: Andrea Egan, July 2011
;




pro plot_max_t,$
   INITIAL_PARAMETERS=initial_parameters,$
   TOTAL_RUNS=total_runs,$
   TOTAL_SECONDS=total_seconds,$
   TIME_ARRAY=time_array,$
   RUN_FORMAT=run_format,$
   DATA_FOLDER=data_folder,$
   START_RUN=start_run,$
   PLOT_FOLDER=plot_folder
  
  if size(INITIAL_PARAMETERS,/TYPE) ne 7 then begin
     print, 'please specify INITIAL_PARAMETERS'
     STOP
  endif
  if size(TOTAL_RUNS,/TYPE) ne 2 then $
     TOTAL_RUNS=65
  if size(TOTAL_SECONDS,/TYPE) ne 2 then $
     TOTAL_SECONDS=900
  if size(TIME_ARRAY,/N_DIMENSIONS) ne 1 then $
     TIME_ARRAY=indgen(TOTAL_SECONDS+1)
  if size(RUN_FORMAT,/TYPE) ne 7 then    RUN_FORMAT='(I04)'
  if size(DATA_FOLDER,/TYPE) ne 7 then $
     DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
  if size(START_RUN,/TYPE) ne 2 then $
     START_RUN=1
  if size(PLOT_FOLDER,/TYPE) ne 7 then $
     PLOT_FOLDER='/Volumes/Herschel/aegan/plots/'
 
  MAX_Ts=make_array(total_seconds+1) ;to store temp data
  run_directory=data_folder+initial_parameters+'/run_'+string(start_run,FORMAT=run_format) ;for restoring

  for time=0, total_seconds do begin ;collect loops over time
     print, 'time=',time
     loopFile=run_directory+"/patc_test_"+string(time,FORMAT='(I06)')+".loop"
     restore,loopFile

     MAX_Ts[time]=loop.T_MAX



  endfor ;time

;Plot the data
  set_plot, 'ps'
  filename=PLOT_FOLDER+initial_parameters+'_max_temp_plot.ps'
  device, filename=filename, decomposed=0,/color
  plot, indgen(total_seconds+1), MAX_Ts, xtitle="Time(s)",ytitle="Maximum Temperatures (K)",$
        YRANGE=[0,max(Max_Ts)], title=initial_parameters+" Plot of Maximum temperatures"
  
  device, /close


END
