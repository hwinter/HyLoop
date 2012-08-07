;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;note: once this has run, the script for generating the movie is:
; /usr/local/bin/image2movie /Volumes/Herschel/aegan/plots/XRT_movie/ png 10
;this is AFTER you've cd'd into the directory you'd like the
;movie to end up
pro multi_map_to_png,run, $
   DESTINATION_FOLDER=destination_folder, $
   INITIAL_PARAMETERS=initial_parameters,$
   TOTAL_RUNS=total_runs,$
   TOTAL_SECONDS=total_seconds,$
   RUN_FORMAT=run_format,$
   DATA_FOLDER=data_folder

  if size(RUN, /TYPE) ne 2 then $
     RUN=1
  if size(DESTINATION_FOLDER, /TYPE) ne 7 then $
     DESTINATION_FOLDER='/Volumes/Herschel/aegan/plots/XRT_movie_multi/'
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
param=['pa-4_nt=100','pa_0_nt=100','pa_4_nt=100']

set_plot, 'x'
;load red temperature color table
loadct, 3
;generate the file, restore the map

runFolders='/run_'+string(run,RUN_FORMAT)+'/maps/be_thick.map'
restore, Data_folder+initial_parameters+runFolders
;param_0=map
;param_0.id=param[0]
;restore, Data_folder+param[1]+runFolders
;param_1=map
;param_1.id=param[1]
;restore, Data_folder+param[2]+runFolders
;param_2=map
;param_2.id=param[2]


for t=0, total_seconds do begin
image_file=destination_folder+'xrt_png_multi_'+string(t, '(I04)')+'.png'
;plot_map, param_0[t], MULTI=[2,1]
;plot_map, param_1[t], MULTI=[2,1]
;plot_map, param_2[t], MULTI=[3,1]

write_png,image_file, tvrd(/TRUE)

endfor

END
