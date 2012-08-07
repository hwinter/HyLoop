; This is a function for returning the required arrays for GOES long
; and short, for all 900 seconds, but only 1 run.


function GOES_collect_run, loops,$
                       LONG=long,$
                       SHORT=short,$
                       STD_DEV_SHORT=std_dev_short,$
                       STD_DEV_LONG=std_dev_long,$
                      
                       INITIAL_PARAMETERS=initial_parameters,$
                       TOTAL_RUNS=total_runs,$
                       TOTAL_SECONDS=total_seconds,$
                       TIME_ARRAY=time_array,$
                       RUN_FORMAT=run_format,$
                       DATA_FOLDER=data_folder
 

if size(INITIAL_PARAMETERS,/TYPE) ne 7 then $
   INITIAL_PARAMETERS='pa-4_nt=100/'
if size(TOTAL_RUNS,/TYPE) ne 7 then $
   TOTAL_RUNS=65
if size(TOTAL_SECONDS,/TYPE) ne 7 then $
   TOTAL_SECONDS=900
if size(TIME_ARRAY,/N_DIMENSIONS) ne 1 then $
   TIME_ARRAY=indgen(TOTAL_SECONDS+1)
if size(RUN_FORMAT,/TYPE) ne 7 then $
   RUN_FORMAT='(I02)'
if size(DATA_FOLDER,/TYPE) ne 7 then $
   DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'

N=size(loops[0,0].s,/n_elements)
print, 'n=',N
;long_array=make_array(total_seconds+1)
;short_array=make_array(total_seconds+1)
long_vol=make_array(N-1) ;array over volume
short_vol=make_array(N-1) ;array over volume
LONG=make_array(total_seconds+1)
SHORT=make_array(total_seconds+1)
STD_DEV_LONG=make_array(total_seconds+1)
STD_DEV_SHORT=make_array(total_seconds+1)
function_out=make_array(N-1, total_seconds+1)


for time=0, total_seconds-1 do begin
   print, 'time=',time 
   
   loop=loops[1,time]
   
;Get loop data, correct for the input
   E_M=get_loop_em(loop)
   T=get_loop_temp(loop)
   MegaK=T[1:N-1]/10^5.
   Corrected_E_M=E_M-49
   Corrected_E_M=10^Corrected_E_M  

;Plug this data into the GOES program
   goes_fluxes, MegaK, corrected_E_M, flong, fshort, SATELLITE=8
   help, flong
function_out[*,time]=flong

;print, flong

;Take results from GOES program, total over volume
   long[time]=Total(flong,/DOUBLE)

   short[time]=Total(fshort, /DOUBLE)
;print, 'long and short', long[time], short[time] 
  endfor

save,short,long, short_array,function_out, long_array,long_vol, short_vol,std_dev_short, std_dev_long,$
FILENAME='/Volumes/Herschel/aegan/Data/saved/GOES_collect_run_debug.sav'zx
return,LONG




END

