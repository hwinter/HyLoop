;
; NAME: get_loops_hxr_collect
; 
;
; PURPOSE: Takes input of loops, returns GOES long and short data
;          based on Emission Measure and Temperature
;
; 
;
; CALLING SEQUENCE: goes_long=GOES_collect(loops, SHORT=SHORT,STD_DEV_LONG=std_dev_long, $ 
;                          STD_DEV_SHORT=std_dev_short, $
;                          INITIAL_PARAMETERS=initial_parameters, $
;                          RUN_FORMAT=run_format,$
;                          TOTAL_RUNS=total_runs,$
;                          TOTAL_SECONDS=total_seconds, $
;                          START_RUN=start_run)
; 
;
; INPUTS: Loops ->array of loop structures over [run, time] (see get_loops_hxr_collect)
;
; KEYWORD PARAMETERS:
;   Specific Keywords:    
;          STD_DEV_LONG=std_dev_long  ->standard deviation for the
;                                       long GOES data
;          SHORT=SHORT ->returns the GOES data on the shorter wavelengths
;          STD_DEV_SHORT=std_dev_short ->standard deviation for the
;                                        GOES short data
;                  
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
;
; OUTPUTS: long ->averaged goes long data over time
;
; OPTIONAL OUTPUTS: SHORT, std_dev_long, std_dev_short ->See above
; 
; SAVED:   long, short, std_dev_long, std_dev_short
;                ->FILENAME=SAVE_FOLDER+initial_parameters+'_GOES_collect.sav'
; 
;
; MODIFICATION HISTORY:
;   Written by: Andrea Egan, July 2011
;



function GOES_collect, loops,$
                       LONG=long,$
                       SHORT=short,$
                       STD_DEV_SHORT=std_dev_short,$
                       STD_DEV_LONG=std_dev_long,$
                       
                       INITIAL_PARAMETERS=initial_parameters,$
                       TOTAL_RUNS=total_runs,$
                       TOTAL_SECONDS=total_seconds,$
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
  if size(RUN_FORMAT,/TYPE) ne 7 then $
     RUN_FORMAT='(I02)'
  if size(DATA_FOLDER,/TYPE) ne 7 then $
     DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
  if size(START_RUN,/TYPE) ne 2 then $
     START_RUN=1
  
  if size(SAVE_FOLDER,/TYPE) ne 7 then $
     SAVE_FOLDER='/Volumes/Herschel/aegan/Data/saved/'
  N=size(loops[0,0].s,/n_elements)
;;;;;;;;;;;;;;;
;Create all of the arrays for storage
  long_array=make_array(total_runs-start_run+1, total_seconds+1)
  short_array=make_array(total_runs-start_run+1, total_seconds+1)
  LONG=make_array(total_seconds+1)
  SHORT=make_array(total_seconds+1)
  STD_DEV_LONG=make_array(total_seconds+1)
  STD_DEV_SHORT=make_array(total_seconds+1)

  print, 'Collecting GOES...'

;;;;;;;;;;;;;;;;;
;Main Loop
;;;;;;;;;;;;;;;;;
  for time=0, total_seconds do begin ;collect over time
     print, 'time=',time 
     for run=0,total_runs-start_run do begin ;collect over run
                                ;  print,'***run',run
        loop=loops[run,time]
        
      ;Get EM and temp data
        E_M=get_loop_em(loop) ;(returns alog10(EM) )
        T=get_loop_temp(loop)
     ;;;;;;;;
     ;;goes_fluxes requires temps in MegaK
     ;;and EM to be in multiples of 10^49
     ;;;;;;;;;;;;
        MegaK=T[1:N-1]/(1E6)
        Corrected_E_M=E_M-49 
        Corrected_E_M=10^Corrected_E_M  

     ;;;;;;;;;;;;;;;
     ;Plug data into GOES program
     ;;;;;;;;;;;;;;;
        goes_fluxes, MegaK, corrected_E_M, flong, fshort, SATELLITE=8

        
     ;Total GOES results over volume
        long_array[run,time]=Total(flong,/DOUBLE)
        short_array[run,time]=Total(fshort, /DOUBLE)
     
     endfor                     ;run

;;;;;;;;;;;;;;;;
;Calculate avg vals & std_dev over runs
;;;;;;;;;;;;;;;;
     short_moment=moment(double(short_array[*,time]),SDEV=sdev_s)
     SHORT[time]=short_moment[0]
     std_dev_short[time]=sdev_s
     long_moment=moment(double(long_array[*,time]),SDEV=sdev_l)
     LONG[time]=long_moment[0]
     std_dev_long[time]=sdev_l
 
  endfor                        ;time


;Save data
  save,short,long,std_dev_short, std_dev_long,$
       FILENAME=SAVE_FOLDER+initial_parameters+'_GOES_collect.sav'



  return,LONG


END

