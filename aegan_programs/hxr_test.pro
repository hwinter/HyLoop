function hxr_test, $
                                ;  TIME_ARRAY=time_array,$
   MAD=MAD,$
   INITIAL_PARAMETERS=initial_parameters,$
   TOTAL_RUNS=total_runs,$
   TOTAL_SECONDS=total_seconds,$
   RUN_FORMAT=run_format,$
   DATA_FOLDER=data_folder
  
if size(INITIAL_PARAMETERS,/TYPE) ne 7 then $
   INITIAL_PARAMETERS='pa-4_nt=100'
if size(TOTAL_RUNS,/TYPE) ne 2 then $
   TOTAL_RUNS=65
if size(TOTAL_SECONDS,/TYPE) ne 2 then $
   TOTAL_SECONDS=900
if size(RUN_FORMAT,/TYPE) ne 7 then $
   RUN_FORMAT='(I02)'
if size(DATA_FOLDER,/TYPE) ne 7 then $
   DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'

TIME_ARRAY=indgen(total_seconds+1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Loop to collect over time
   for time=0, total_Seconds do begin
      loopFile='patc_test_'+string(time, '(I06)')+'.loop'
      print,'time=',time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Loop to collect over runs
      for run=1,total_Runs do begin
         runFolder='/run_'+string(run,run_Format)+'/'
       ;  print, 'run=',run
         
         restore, data_Folder+Initial_parameters+runFolder+loopFile
       print, where(nt_brems.n_photons ne 0)
      endfor

      
   endfor

   return, 0
END
