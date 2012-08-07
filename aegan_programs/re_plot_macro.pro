

INITIAL_PARAMETERS='pa-4_nt=100'
RUN_FORMAT='(I04)'
TOTAL_RUNS=65
START_RUN=1
TOTAL_SECONDS=900


FILENAME='/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_loop_array.sav'
restore, filename

print, 'loops restored', initial_parameters

goes_long=GOES_collect(loops, SHORT=SHORT, STD_DEV_LONG=std_dev_long, STD_DEV_SHORT=std_dev_short, INITIAL_PARAMETERS=initial_parameters, RUN_FORMAT=run_format, TOTAL_RUNS=total_runs, TOTAL_SECONDS=total_seconds, START_RUN=start_run)

GOES_plot_AKE, goes_long, std_dev_long, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds


plot_all_no_err, INITIAL_PARAMETERS=initial_parameters, total_seconds=total_seconds, plot_secs=150

INITIAL_PARAMETERS='pa_4_nt=100'
RUN_FORMAT='(I04)'
TOTAL_RUNS=65
START_RUN=1
TOTAL_SECONDS=900


FILENAME='/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_loop_array.sav'
restore, filename

print, 'loops restored', initial_parameters

goes_long=GOES_collect(loops, SHORT=SHORT, STD_DEV_LONG=std_dev_long, STD_DEV_SHORT=std_dev_short, INITIAL_PARAMETERS=initial_parameters, RUN_FORMAT=run_format, TOTAL_RUNS=total_runs, TOTAL_SECONDS=total_seconds, START_RUN=start_run)

GOES_plot_AKE, goes_long, std_dev_long, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds


plot_all_no_err, INITIAL_PARAMETERS=initial_parameters, total_seconds=total_seconds, plot_secs=150

END

