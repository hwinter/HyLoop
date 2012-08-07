;
; NAME: get_loops_hxr_collect
; 
;
; PURPOSE: Cycles through loops files for given runs to collect and
; saves the loop structures. While in loop files, also collects HXR
; info. 
;
; 
;
; CALLING SEQUENCE: loops=get_loops_hxr_collect(INITIAL_PARAMETERS=initial_parameters,RUN_FORMAT=run_format, TOTAL_RUNS=total_runs, START_RUN=start_run, TOTAL_SECONDS=total_seconds, HXR_ARRAY=hxr_array, MAD=MAD)
; 
;
; INPUTS: None
;
; KEYWORD PARAMETERS:
;   Specific Keywords:    
;          HXR_ARRAY=hxr_array  ->Returns an array of average (median) HXR data over time
;          MAD=MAD   ->Median Absolute Deviation of HXR data (measure
;                      of standard deviation
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
; OUTPUTS: Array of loop structures -> loops[run,time]
;
; OPTIONAL OUTPUTS: HXR Array, MAD
; 
; SAVED:   Loops                ->FILENAME='/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_loop_array.sav'
;          HXR_array, MAD       ->FILENAME='/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_hxr_emission.sav'
; 
;
; MODIFICATION HISTORY:
;   Written by: Andrea Egan, July 2011
;


 


function get_loops_hxr_collect,$


   INITIAL_PARAMETERS=initial_parameters,$
   TOTAL_RUNS=total_runs,$
   TOTAL_SECONDS=total_seconds,$
   RUN_FORMAT=run_format,$
   DATA_FOLDER=data_folder, $
   START_RUN=start_run,$
   HXR_ARRAY=hxr_array,$
   MAD=MAD,$
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
     RUN_FORMAT='(I04)'
  if size(DATA_FOLDER,/TYPE) ne 7 then $
     DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
  if size(START_RUN,/TYPE) ne 2 then $
     START_RUN=1
 if size(SAVE_FOLDER,/TYPE) ne 7 then $
     SAVE_FOLDER='/Volumes/Herschel/aegan/Data/saved/'
  print, "Getting Loops..."

;;;;;HXR ADDITION

;Generate dimensions for the final arrays 
  Runs_emissions=make_array(total_Runs-start_run+1,total_Seconds+1)
  MAD=make_array(total_Seconds+1)
  HXR_array=make_array(total_Seconds+1)

;;;;;;;;;;
;Set Index
;;;;;;;;;;
 



;Generate the initial .sav filename to be restored, restore it
  run_directory=data_folder+initial_parameters+'/run_'+string(start_run,FORMAT=run_format)
  loopFile=run_directory+"/patc_test_"+string(0,FORMAT='(I06)')+".loop"
  print, "restoring ", loopFile   
  restore,loopFile
                                ;print, 'done restoring'
 index=where(nt_brems[0].PH_ENERGIES ge 12 and nt_brems[0].PH_ENERGIES le 25); energies 12-25 KeV 
 loops=REPLICATE(loop,total_runs-start_run+1, total_seconds+1)
  loops[0,0]=loop

;;;;;;;;;;;;;;;;;
;Main Loop
;;;;;;;;;;;;;;;;;
  for time=0, total_seconds do begin ;collect over time
     print, 'time=',time
     for run=start_run, total_runs do begin ;collect over runs
      ;;;;;;;;;;;;;
      ;;Restore Loop Files    
        run_directory=data_folder+initial_parameters+'/run_'+string(run,FORMAT=run_format)
        loopFile=run_directory+"/patc_test_"+string(time,FORMAT='(I06)')+".loop"
        restore,loopFile
      ;;;;;;;;;;;;;
      ;;Save loop to array      
        loops[run-start_run,time]=loop
        
      ;;;;;;;;;;;;;
      ;;Calculate HXR values
        totalEmission=total(double(nt_brems.N_PHOTONS[index]),2)*nt_brems[600].PH_ENERGIES[index] 
        Runs_emissions[run-start_run,time]=total(double(totalEmission))

     endfor ;runs

     HXR_array[time]=MEDIAN(runs_emissions[*,time], /DOUBLE) ;Find average (median) over runs
     MAD[time]=median(abs(HXR_array[time]-runs_emissions[*,time]),/DOUBLE) ;find MAD over runs
                                ;print, 'HXR_array=', HXR_array[time]

  endfor ;time


;;;;;;;;;;;;;;;;;;
;Save collected Data
;;;;;;;;;;;;;;;;;  
  save, HXR_array,MAD,FILENAME= SAVE_FOLDER+initial_parameters+'_hxr_emission.sav'

  save, loops, FILENAME=SAVE_FOLDER+initial_parameters+'_loop_array.sav'
  



  return, loops


END
