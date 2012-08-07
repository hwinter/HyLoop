;
; NAME: run_everything
; 
;
; PURPOSE: Macro that executes all of the necessary programs to
;          collect data for GOES, HXR, and XRT be thick, and then plots them
;          all individually and in a group plot. 
;
; 
;
; CALLING SEQUENCE: .r run_everything (after already setting all of
;                   the General analysis keywords)
; 
;   General analysis keywords:
;          INITIAL_PARAMETERS=initial_parameters ->No Default, ex. "pa_0_nt=100"
;          TOTAL_RUNS=total_runs                 **Default: 65
;          TOTAL_SECONDS=total_seconds           **Default: 900
;          RUN_FORMAT=run_format                 **Default: '(I04)'
;          DATA_FOLDER=data_folder               **Default: '/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
;          START_RUN=start_run                   **Default: 1
;          SAVE_FOLDER=save_folder               **Default: '/Volumes/Herschel/aegan/Data/saved/'
;          PLOT_FOLDER=plot_folder               **Default: '/Volumes/Herschel/aegan/plots/'
; 
;
; OUTPUTS: 
;   Plots:
;          GOES_plot_AKE ->FILENAME=PLOT_FOLDER+initial_parameters+'_GOES_plot_long_new.ps'
;          HXR_plot ->filename=PLOT_FOLDER+initial_parameters+'_HXR_plot.ps'
;          XRT_plot_curves ->filename=PLOT_FOLDER+initial_parameters+'_XRT_be_thick_plot.ps'
;          plot_all_no_err->filename=PLOT_FOLDER+initial_parameters+'_total_plot_'+string(plot_secs,'(I03)')+'_new.ps'
; OPTIONAL OUTPUTS: 
; 
; SAVED:   Loops                ->FILENAME=SAVE_FOLDER+initial_parameters+'_loop_array.sav'
;          HXR_array, MAD       ->FILENAME=SAVE_FOLDER+initial_parameters+'_hxr_emission.sav'
;          length, temps, density, dens_dev, losEM, temp_dev
;                               ->FILENAME=SAVE_FOLDER+initial_parameters+'_temps_dens.sav'
;          xrt_array, std_dev,runs_data 
;                               ->FILENAME=SAVE_FOLDER+initial_parameters+'_XRT_be_thick_emission_avg.sav'
;          long, short, std_dev_long, std_dev_short
;                               ->FILENAME=SAVE_FOLDER+initial_parameters+'_GOES_collect.sav'
; MODIFICATION HISTORY:
;   Written by: Andrea Egan, July 2011
;

TOTAL_RUNS=65

TOTAL_SECONDS=500

RUN_FORMAT='(I04)'       

DATA_FOLDER='/Volumes/itch/Users/hwinter/Data/HyLoop/runs/2011_REU_2nd_swing/'       

START_RUN=1

SAVE_FOLDER= '/Volumes/Herschel/aegan/Data/saved_90_percent/'       

PLOT_FOLDER= '/Volumes/Herschel/aegan/plots_90_percent/'



;INITIAL_PARAMETERS='pa-4_nt_90_bt_2min'

;INITIAL_PARAMETERS='pa_4_nt_90_bt_2min'

INITIAL_PARAMETERS='pa_0_nt_90_bt_2min'



  if size(INITIAL_PARAMETERS,/TYPE) ne 7 then begin
     print, 'please specify INITIAL_PARAMETERS'
     STOP
  endif
  if size(TOTAL_RUNS,/TYPE) ne 2 then $
     TOTAL_RUNS=65
  if size(TOTAL_SECONDS,/TYPE) ne 2 then $
     TOTAL_SECONDS=900
  if size(PLOT_SECS,/TYPE) ne 2 then $
     PLOT_SECS=900
  if size(RUN_FORMAT,/TYPE) ne 7 then $
     RUN_FORMAT='(I04)'
  if size(DATA_FOLDER,/TYPE) ne 7 then $
     DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
 if size(PLOT_FOLDER,/TYPE) ne 7 then $
     PLOT_FOLDER='/Volumes/Herschel/aegan/plots/'
 if size(SAVE_FOLDER,/TYPE) ne 7 then $
     SAVE_FOLDER='/Volumes/Herschel/aegan/Data/saved/'

;; GET LOOPS AND HXR at the same time, takes the same time
loops=get_loops_hxr_collect(INITIAL_PARAMETERS=initial_parameters,$
                            RUN_FORMAT=run_format, $
                            TOTAL_RUNS=total_runs, $
                            START_RUN=start_run, $
                            TOTAL_SECONDS=total_seconds, $
                            SAVE_FOLDER=save_folder,$
                            HXR_ARRAY=hxr_array, $
                            DATA_FOLDER=data_folder,$
                            MAD=MAD)



;loops=get_loops(INITIAL_PARAMETERS=initial_parameters,RUN_FORMAT=run_format, TOTAL_RUNS=total_runs, START_RUN=start_run, TOTAL_SECONDS=total_seconds)
                                ;loops saved in ./Data/saved/'initial
                                ;parameters'_loop_array.sav, called l_array
;Collect the GOES data for the loops
goes_long=GOES_collect(loops, $
                       SHORT=SHORT, $
                       STD_DEV_LONG=std_dev_long, $
                       STD_DEV_SHORT=std_dev_short, $
                       INITIAL_PARAMETERS=initial_parameters, $
                       RUN_FORMAT=run_format, $
                       TOTAL_RUNS=total_runs, $
                       TOTAL_SECONDS=total_seconds, $
                       SAVE_FOLDER=save_folder,$
                       DATA_FOLDER=data_folder,$
                       START_RUN=start_run)
                                ;Results (long and short) and deviation saved in
                                ;./Data/saved/'initial parameters'_GOES_collect.sav'
;Plot GOES
GOES_plot_AKE, goes_long, std_dev_long, $
               INITIAL_PARAMETERS=initial_parameters, $
               PLOT_FOLDER=plot_folder,$
               TOTAL_SECONDS=total_seconds
                                ;Returns plot with normalized scales,
                                ;file title initial_parameters+goes_long_plot.ps
                                ;Can also plot goes short using /SHORT keyword
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;HXR

;Returns the median of the values over all of the runs, 
;and the Median Absolute Deviation (MAD)
;HXR_array=hxr_collect(MAD=MAD, INITIAL_PARAMETERS=initial_parameters, RUN_FORMAT=run_format, TOTAL_RUNS=total_runs, TOTAL_SECONDS=total_seconds, START_RUN=start_run)
                                ;HXR_array and MAD stored in ./Data/saved/'inital_parameters'_hxr_emission.sav

;Plot HXR
hxr_plot, HXR_array, MAD, $ 
          INITIAL_PARAMETERS=initial_parameters, $
          PLOT_FOLDER=plot_folder,$
          TOTAL_SECONDS=total_seconds

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;XRT_be_thick


;Make the maps
;xrt_mk_maps_meta, $
   ;; INITIAL_PARAMETERS=initial_parameters, $
   ;; RUN_FORMAT=run_format, $
   ;; TOTAL_RUNS=total_runs, $
   ;; DATA_FOLDER=data_folder,$
   ;; START_RUN=start_run
                                ;This function automatically stores
                                ;the maps in the folders with the
                                ;runs, then picked up in the avg_map function                                
                                ;This function needs to be modified to change to any other filter
                                ;It generates the run folders and other input for the
                                ;mk_xrt_be_thick_maps function
;Average the values
;xrt_array=xrt_avg_maps(STD_DEV=xrt_dev, $
                       ;; INITIAL_PARAMETERS=initial_parameters, $
                       ;; RUN_FORMAT=run_format, $
                       ;; TOTAL_RUNS=total_runs,$
                       ;; TOTAL_SECONDS=total_seconds, $
                       ;; SAVE_FOLDER=save_folder,$
                       ;; DATA_FOLDER=data_folder,$
                       ;; START_RUN=start_run)
                                ;Returns the averaged map values, and keyword standard deviation
                                ;Also saves this data along with
                                ;runs_data in ./saved/'initial parameters'_XRT_be_thick_avg.sav'
;Plot XRT
;xrt_plot_curves, xrt_array, xrt_dev, $
                 ;; INITIAL_PARAMETERS=initial_parameters, $
                 ;; TOTAL_SECONDS=total_seconds,$
                 ;; PLOT_FOLDER=plot_folder

;;;;;;;;;;;;;
;plot everything
                                ;automatically restores all of the
                                ;data files
plot_all_no_err, INITIAL_PARAMETERS=initial_parameters, $
                 total_seconds=total_seconds, $
                 plot_secs=400, $
                 SAVE_FOLDER=save_folder,$
                 PLOT_FOLDER=plot_folder


;Collect temperature, density, and line of sight EM with spatial
;resolution over time
temp_dense_em,initial_parameters=initial_parameters,$
              total_runs=total_runs,$
              total_seconds=total_seconds,$
              run_format=run_format,$
              length=length,$
              temps=temps,$
              losEM=losEM,$
              SAVE_FOLDER=SAVE_FOLDER,$
              DATA_FOLDER=data_folder,$
              loops=loops       ;optional!


print, "Initial Parameters:", initial_parameters, "Total Seconds:", total_seconds

;plot_max_t, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds, RUN_FORMAT=run_format, START_RUN=start_run, TOTAL_RUNS=total_runs

END
