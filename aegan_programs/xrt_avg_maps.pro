 
;
; NAME: xrt_avg_maps
; 
;
; PURPOSE: Averages map values (produced by xrt_mk_maps_meta) over runs and
;          totals over volume. This function also returns an optional
;          standard_deviation
;
; 
;
; CALLING SEQUENCE: xrt_array=xrt_avg_maps(STD_DEV=xrt_dev, INITIAL_PARAMETERS=initial_parameters, RUN_FORMAT=run_format, TOTAL_RUNS=total_runs,TOTAL_SECONDS=total_seconds, START_RUN=start_run)
; 
;
; INPUTS: None
;
; KEYWORD PARAMETERS:
;   Specific Keywords:    
;          STD_dev=xrt_dev ->Standard deviation calculated using MOMENT
;   General analysis keywords:
;          INITIAL_PARAMETERS=initial_parameters ->No Default, ex. "pa_0_nt=100"
;          TOTAL_RUNS=total_runs                 **Default: 65
;          TOTAL_SECONDS=total_seconds           **Default: 900
;          RUN_FORMAT=run_format                 **Default: '(I04)'
;          DATA_FOLDER=data_folder               **Default: '/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
;          START_RUN=start_run                   **Default: 1
;          SAVE_FOLDER=save_folder               **Default: '/Volumes/Herschel/aegan/Data/saved/'
; 
; 
;
; OUTPUTS: XRT_array, xrt_dev  ->XRT be thick light curve over time
;                                with std_deviation
;
; OPTIONAL OUTPUTS: 
; 
; SAVED:   xrt_array, std_dev,runs_data 
;                        ->FILENAME=SAVE_FOLDER+initial_parameters+'_XRT_be_thick_emission_avg.sav'
; 
;
; MODIFICATION HISTORY:
;   Written by: Andrea Egan, July 2011
;

function xrt_avg_maps,$
   STD_DEV=std_dev, $
   INITIAL_PARAMETERS=initial_parameters,$
   TOTAL_RUNS=total_runs,$
   TOTAL_SECONDS=total_seconds,$
   RUN_FORMAT=run_format,$
   DATA_FOLDER=data_folder,$
   START_RUN=start_run, $
   SAVE_FOLDER=save_folder

  if size(INITIAL_PARAMETERS,/TYPE) ne 7 then begin
     print, 'please specify INITIAL_PARAMETERS'
     STOP
  endif
  if size(TOTAL_RUNS,/TYPE) ne 2 then $
     TOTAL_RUNS=65
  if size(TOTAL_SECONDS,/TYPE) ne 2 then $
     TOTAL_SECONDS=900
  if size(RUN_FORMAT,/TYPE) ne 7 then $
     RUN_FORMAT='(I02)'
  if size(DATA_FOLDER,/TYPE) ne 7 then $
     DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
  if size(START_RUN,/TYPE) ne 2 then $
     START_RUN=1

 if size(SAVE_FOLDER,/TYPE) ne 7 then $
     SAVE_FOLDER='/Volumes/Herschel/aegan/Data/saved/'

;Generate array for storing all of the run data
  runs_data=make_array(total_runs-start_run+1,total_Seconds+1)
  xrt_array=make_array(total_seconds+1)



;;;;;;;;;;;;;;;;;
;Main Loop
;;;;;;;;;;;;;;;;;
  for run=start_run, total_Runs do begin   ;over runs
     
     ;first, restore all of the .map files, find the values for total data
     ;over time
     runFolders='/run_'+string(run,RUN_FORMAT)+'/maps/be_thick.map'
     restore, Data_folder+initial_parameters+runFolders

     ;map.data has 3 dimensions, X, Y and time. I total x first, then y. 
     ;(DataTotal is left as an array the size of totalSeconds+1
     dataTotal=TOTAL(map.data,1)
     dataTotal=TOTAL(dataTotal,1)

     runs_data[run-start_run,*]=dataTotal[0:total_seconds]
                                ;(this 0:total_seconds fixed the occasional bug of having the wrong
                                ;total_seconds set for the intitial
                                ;parameters (if mk_maps seconds>total_seconds
 
  endfor                        ;runs

;Calculate average, std_dev for each second, over all of the runs
  std_dev=make_array(total_seconds+1)

  for time=0, total_Seconds do begin ;over time 
     Moment=MOMENT(runs_data[*,time],SDEV=sdev)
     xrt_array[time]=moment[0]
     std_dev[time]=sdev
  endfor

  save, xrt_array, xrt_dev,runs_data,FILENAME=SAVE_FOLDER+initial_parameters+'_XRT_be_thick_emission_avg.sav'
  return, xrt_array

END





