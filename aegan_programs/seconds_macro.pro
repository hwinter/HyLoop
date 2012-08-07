


START_RUN=5
TOTAL_RUNS=18
  DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_2nd_swing/'

RUN_FORMAT='(I04)'
min_time=901
for run=start_run, total_runs do begin ;collect over runs
      ;;;;;;;;;;;;;
      ;;Restore Loop Files    
        run_directory=data_folder+initial_parameters+'/run_'+string(run,FORMAT=run_format)
      ;  loopFile=run_directory+"/patc_test_"+string(time,FORMAT='(I06)')+".loop"
    
      result=file_search(run_directory+"/patc*", count=count)
if count le min_time then min_time=count
;print, 'run=',run, "count=", count
     endfor ;runs
print, "min_time=", min_time

END
