;This is a function that returns all of the hard x-ray data for the
;loop files

function hxr_collect, $
                                ;  TIME_ARRAY=time_array,$
   MAD=MAD,$
   INITIAL_PARAMETERS=initial_parameters,$
   TOTAL_RUNS=total_runs,$
   TOTAL_SECONDS=total_seconds,$
   RUN_FORMAT=run_format,$
   DATA_FOLDER=data_folder, $
START_RUN=start_run
  
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
if size(START_RUN,/TYPE) ne 2 then $
   START_RUN=1
TIME_ARRAY=indgen(total_seconds+1)





;Generate dimensions for the final array initially
Runs_emissions=make_array(total_Runs-start_run+1,total_Seconds+1)
;Know the values of the index in advance to save time
KeV_range=[12,25]
index=findgen(Kev_range[0]+2)+KeV_range[1]-KeV_range[0]-2
  ;index=where(nt_brems[0].PH_ENERGIES ge 12 and nt_brems[0].PH_ENERGIES le 25) ;set index
MAD=make_array(total_Seconds+1)
Emission_array=make_array(total_Seconds+1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Loop to collect over time
   for time=0, total_Seconds do begin
      loopFile='patc_test_'+string(time, '(I06)')+'.loop'
      print,'time=',time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Loop to collect over runs
      for run=start_run,total_Runs do begin
         runFolder='/run_'+string(run,run_Format)+'/'
       ;  print, 'run=',run
         
         restore, data_Folder+Initial_parameters+runFolder+loopFile
         
                                ;Total emission is sum of photons in index summed over volume*photon energies   
         totalEmission=total(double(nt_brems.N_PHOTONS[index]),2)*nt_brems[600].PH_ENERGIES[index] 
         Runs_emissions[run-start_run,time]=total(double(totalEmission))
      endfor
;Distribution is not Gaussian, use median and median absolute
;deviation to characterize the data
emission_array[time]=MEDIAN(runs_emissions[*,time], /DOUBLE)
print, 'emission_array=', emission_array[time]
MAD[time]=median(abs(emission_array[time]-runs_emissions[*,time]),/DOUBLE)
      
   endfor
HXR_array=emission_array   
save, HXR_array,MAD,FILENAME='/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_hxr_emission.sav'
   return, HXR_array
END