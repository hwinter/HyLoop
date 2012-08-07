;This is the overarching macro for collecting all of the necessary
;information for one set of initial conditions. This will take an
;extraordinarly long time to run

;Other optional keywords for all functions:
                                ;TOTAL_RUNS=65
                                ;TOTAL_SECONDS=900
                                ;DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
INITIAL_PARAMETERS='pa_0_nt_75_bt_2min'
INITIAL_KEY='p0nt100'
RUN_FORMAT='(I04)'
TOTAL_RUNS=70
START_RUN=66
TOTAL_SECONDS=31
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;GOES 

;Get the loops
;loops=get_loops(INITIAL_PARAMETERS=initial_parameters,RUN_FORMAT=run_format, TOTAL_RUNS=total_runs, START_RUN=start_run, TOTAL_SECONDS=total_seconds)
                                ;loops saved in ./Data/saved/'initial
                                ;parameters'_loop_array.sav, called l_array
;Collect the GOES data for the loops
goes_long=GOES_collect(loops, SHORT=SHORT, STD_DEV_LONG=std_dev_long, STD_DEV_SHORT=std_dev_short, INITIAL_PARAMETERS=initial_parameters, RUN_FORMAT=run_format, TOTAL_RUNS=total_runs, TOTAL_SECONDS=total_seconds, START_RUN=start_run)
                                ;Results (long and short) and deviation saved in
                                ;./Data/saved/'initial parameters'_GOES_collect.sav'
;; GET LOOPS AND HXR at the same time, takes the same time
loops2=get_loops_hxr_collect(INITIAL_PARAMETERS=initial_parameters,RUN_FORMAT=run_format, TOTAL_RUNS=total_runs, START_RUN=start_run, TOTAL_SECONDS=total_seconds)
;Plot GOES
GOES_plot_AKE, goes_long, std_dev_long, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds
                                ;Returns plot with normalized scales,
                                ;file title initial_parameters+goes_long_plot.ps
                                ;Can also plot goes short using /SHORT keyword
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;HXR

;Returns the median of the values over all of the runs, and the Median
;Absolute Deviation (MAD)
HXR_array=hxr_collect(MAD=MAD, INITIAL_PARAMETERS=initial_parameters, RUN_FORMAT=run_format, TOTAL_RUNS=total_runs, TOTAL_SECONDS=total_seconds, START_RUN=start_run)
                                ;HXR_array and MAD stored in ./Data/saved/'inital_parameters'_hxr_emission.sav

;Plot HXR
hxr_plot, HXR_array, MAD, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;XRT_be_thick


;Make the maps
xrt_mk_maps_meta, INITIAL_PARAMETERS=initial_parameters, RUN_FORMAT=run_format, TOTAL_RUNS=total_runs, START_RUN=start_run
                                ;This function automatically stores
                                ;the maps in the folders with the
                                ;runs, then picked up in the avg_map function                                
                                ;This function needs to be modified to change to any other filter
                                ;It generates the run folders and other input for the
                                ;mk_xrt_be_thick_maps function
;Average the values
xrt_array=xrt_avg_maps(STD_DEV=xrt_dev, INITIAL_PARAMETERS=initial_parameters, RUN_FORMAT=run_format, TOTAL_RUNS=total_runs,TOTAL_SECONDS=total_seconds, START_RUN=start_run)
                                ;Returns the averaged map values, and keyword standard deviation
                                ;Also saves this data along with
                                ;runs_data in ./saved/'initial parameters'_XRT_be_thick_avg.sav'
;Plot XRT
xrt_plot_curves, xrt_array, xrt_dev, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds

;;;;;;;;;;;;;
;plot everything
                                ;automatically restores all of the
                                ;data files
plot_all_no_err, PLOT_SECS=200, INITIAL_PARAMETERS=initial_parameters


start_run=1
total_runs=5
total_seconds=6
