;
; NAME: temp_dense_em
; 
;
; PURPOSE: Collects (average) temperature, density, and losEM data for a
;          given restored array of loops, passes them out of the
;          function via keyword.
;          Loops can be restored from a saved file, or passed
;          through as a keyword
;
; 
;
; CALLING SEQUENCE:
; temp_dense_em,initial_parameters=initial_parameters,total_runs=total_runs,total_seconds=total_seconds,run_format=run_format, length=length,temps=temps,losEM=losEM, dens_dev, temp_dev
; 
;
; INPUTS: None
;
; KEYWORD PARAMETERS:
;   Specific Keywords:    
;          TEMPS=temps ->temperatures in space and time (avg over runs)
;          DENSITY=density->densities in space and time (avg over runs)
;          losEM=EM ->Line of sight EM approximated using the radius
;          LENGTH=length ->loop.s_alt array
;          LOOPS=loops ->option to pass through array of loops in runs
;                        and time instead of restoring
;          DENS_DEV=dens_dev ->density std deviation
;          TEMP_DEV=temp_dev ->temperature std deviation
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
; OUTPUTS: 
;
; OPTIONAL OUTPUTS: TEMPS, DENSITY,losEM, LENGTH, DENS_DEV, TEMP_DEV ->(See above)
; 
; SAVED:   length, temps, density, dens_dev, losEM, temp_dev
;                          ->FILENAME='/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_temps_dens.sav'
; 
;
; MODIFICATION HISTORY:
;   Written by: Andrea Egan, July 2011
;

pro temp_dense_em,$

   LOOPS=loops,$
   TEMPS=temps,$
   DENSITY=density,$
   LOSEM=losEM,$
   DENS_DEV=dens_dev,$ 
   TEMP_DEV=temp_dev, $
   LENGTH=length,$


   INITIAL_PARAMETERS=initial_parameters,$
   TOTAL_RUNS=total_runs,$
   TOTAL_SECONDS=total_seconds,$
   TIME_ARRAY=time_array,$
   RUN_FORMAT=run_format,$
   DATA_FOLDER=data_folder,$
   START_RUN=start_run,$
   SAVE_FOLDER=save_folder
  
  
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
  if size(RUN_FORMAT,/TYPE) ne 7 then $   RUN_FORMAT='(I04)'
     if size(DATA_FOLDER,/TYPE) ne 7 then $
        DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
  if size(START_RUN,/TYPE) ne 2 then $
     START_RUN=1
  if size(LOOPS,/TYPE) ne 8 then begin
     print, 'restoring loops...'
     FILENAME='/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_loop_array.sav'
     restore, FILENAME
  endif
  if size(SAVE_FOLDER,/TYPE) ne 7 then $
     SAVE_FOLDER='/Volumes/Herschel/aegan/Data/saved/'

;Set up some of the dimensions
  total_coords=size(loops[0,0].s_alt,/DIMENSIONS)
  loops_dim=size(loops)

;Make some of the arrays to store the data
  temps=make_array(total_seconds+1,total_coords[0])
  density=make_array(total_seconds+1,total_coords[0])
  losEM_array=make_array(loops_dim[1],total_coords[0]-1)
  losEM=make_array(total_seconds+1,total_coords[0]-1)
  temp_dev=make_array(total_seconds+1,total_coords[0])
  dens_dev=make_array(total_seconds+1, total_coords[0])

  for t=0, total_seconds do begin ;loops over time
     print, 't=',t
     run_loops=loops[*,t]
     temps[t,*]=get_loops_avg_temp(run_loops, std_dev=std_dev, variance=var) ;get temps averaged over runs
     temp_dev[t, *]=std_dev
     density[t,*]=get_loops_avg_dens(run_loops, std_dev=std_dev); get densities averaged over runs
     dens_dev[t,*]=std_dev
                                ;Still collecting los_em over runs (going to fix that?)

     for run=0, loops_dim[1]-1 do begin ;loop over runs
        losEM_array[run,*]=double(2*loops[run,t].rad*(loops[run,t].state.n_e)^2)
     endfor                     ;run
  losEM[t, *]=average(losEM_array, 1)
  endfor                        ;time

  length=loops[0,0].s_alt

  save, length, temps, density,dens_dev, temp_dev,losEM,FILENAME=SAVE_FOLDER+initial_parameters+'_temps_dens.sav'
END
