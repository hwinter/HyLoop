; get the temperature and density along the loop length for a given  restored array of loops.
;length_v_temp_dense,initial_parameters=initial_parameters,total_seconds=total_seconds, run_format='(I04)', total_runs=0, start_run=66, loops=loops
;;BE CAREFUL. IF THERE ARE ALREADY SOME LOOPS FLOATING AROUND, they
;;will unintentially be used?
pro length_v_temp_dense,$
   LOOPS=loops,$
   INITIAL_PARAMETERS=initial_parameters,$
   TOTAL_RUNS=total_runs,$
   TOTAL_SECONDS=total_seconds,$
   TIME_ARRAY=time_array,$
   RUN_FORMAT=run_format,$
   DATA_FOLDER=data_folder,$
   START_RUN=start_run, $
   LENGTH=length,$
   TEMPS=temps,$
DENSITY=density
 

if size(INITIAL_PARAMETERS,/TYPE) ne 7 then $
   INITIAL_PARAMETERS='pa-4_nt=100'
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


;Goal is to avg over all of the runs for each second and each
;individual volume cell **use s_alt
total_coords=size(loops[0,0].s_alt,/DIMENSIONS)
loops_dim=size(loops)
vol=get_loop_vol(loops[0,0])
density=loops.state.n_e[1:total_coords-1]/vol
temp_array=make_array(loops_dim[1],total_coords[0])
dens_array=make_array(loops_dim[1],total_coords[0]-1)
temps=make_array(total_seconds+1,total_coords[0])
density=make_array(total_seconds+1,total_coords[0]-1)


for t=0, total_seconds do begin
print, "t=",t
   for run=0, loops_dim[1]-1 do begin

temp_array[run,*]=get_loop_temp(loops[run,t])
;print, 'getting temps', temp_array[run,*]

dens_array[run,*]=loops[run,t].state.n_e[1:total_coords[0]-1]
;help, temp_array
;help, dens_array
endfor ;runs

;avg over runs
temps[t, *]=total(temp_array, 1,/DOUBLE)/double(total_runs-start_run+1)
density[t,*]=total(dens_array,1,/DOUBLE)/double(total_runs-start_run+1)


endfor                          ;time
length=loops[0,0].s_alt

save, length, temps, density, FILENAME='/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_temps_dens.sav'
END
;length_v_temp_dense,initial_parameters=initial_parameters,total_runs=total_runs,total_seconds=total_seconds,run_format=run_format, length=length,temps=temps, density=density
