;This is built to cycle through all of the runs of the loop files in
;/Data/HyLoop/runs/2011_REU_pre_arrival/pa-4_nt=75/ for each
;individual time collecting data for average emission and average
;temperature data.
 


function get_loops,$


   STD_DEV=std_dev,$
   INITIAL_PARAMETERS=initial_parameters,$
   TOTAL_RUNS=total_runs,$
   TOTAL_SECONDS=total_seconds,$
   TIME_ARRAY=time_array,$
   RUN_FORMAT=run_format,$
   DATA_FOLDER=data_folder, $
START_RUN=start_run

if size(INITIAL_PARAMETERS,/TYPE) ne 7 then $
   INITIAL_PARAMETERS='pa-4_nt=100'
if size(TOTAL_RUNS,/TYPE) ne 2 then $
   TOTAL_RUNS=65
if size(TOTAL_SECONDS,/TYPE) ne 2 then $
   TOTAL_SECONDS=900
if size(TIME_ARRAY,/N_DIMENSIONS) ne 1 then $
   TIME_ARRAY=indgen(TOTAL_SECONDS+1)
if size(RUN_FORMAT,/TYPE) ne 7 then $
   RUN_FORMAT='(I02)'
if size(DATA_FOLDER,/TYPE) ne 7 then $
   DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
if size(START_RUN,/TYPE) ne 2 then $
   START_RUN=1

print, "Getting Loops..."

;Generate the initial .sav filename to be restored, restore it
   run_directory=data_folder+initial_parameters+'/run_'+string(start_run,FORMAT=run_format)
   loopFile=run_directory+"/patc_test_"+string(0,FORMAT='(I06)')+".loop"
print, "restoring"   
restore,loopFile
print, 'done restoring'
l_array=REPLICATE(loop,total_runs-start_run+1, total_seconds+1)
l_array[0,0]=loop
for time=0, total_seconds do begin
print, 'time=',time
   for run=start_run, total_runs do begin
      run_directory=data_folder+initial_parameters+'/run_'+string(run,FORMAT=run_format)
      loopFile=run_directory+"/patc_test_"+string(time,FORMAT='(I06)')+".loop"
      restore,loopFile
      l_array[run-start_run,time]=loop
  
   endfor
endfor
loops=l_array
save, loops, FILENAME='/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_loop_array.sav'
return, loops


END
