;flux=xrt_los_flux( run, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds, RUN_FORMAT=run_format)
function xrt_los_flux, run, $

                       INITIAL_PARAMETERS=initial_parameters,$
                       TOTAL_RUNS=total_runs,$
                       TOTAL_SECONDS=total_seconds,$
                       
                       RUN_FORMAT=run_format,$
                       DATA_FOLDER=data_folder, $
                       START_RUN=start_run



  if size(INITIAL_PARAMETERS,/TYPE) ne 7 then $
     print, "Please give initial parameters"
  
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




  final_flux=make_array(total_seconds+1)
  time=0
loops_restore='/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_loop_array.sav'
restore,loops_restore
  temps=get_loop_temp(loops[run,time])
  logT_in=alog10(temps)


  losEM=2*loops[run,time].rad*(loops[run,time].state.n_e)^2

  flux=xrt_flux('Be-thick', logT_in[300:400], losEM[300:400])
help, losEM[300:400]
  final_flux[time]=total(flux)



  for time=1, total_seconds do begin

     temps=get_loop_temp(loops[run,time])
     logT_in=alog10(temps)


     losEM=2*loops[run,time].rad*(loops[run,time].state.n_e)^2

     flux=xrt_flux('Be-thick', logT_in[300:400], losEM[300:400], /reinit)

     final_flux[time]=total(flux)


  endfor



  return, final_flux

END
