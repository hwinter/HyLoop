Initial_parameters='pa-4_nt_100_bt_2min'
Total_seconds=83

print, initial_parameters

.r plot_max_t



Initial_parameters='pa-4_nt_75_bt_2min'
Total_seconds=89

print, initial_parameters

.r plot_max_t



Initial_parameters='pa_m4_nt_50_bt_2min'
Total_seconds=83

print, initial_parameters

.r plot_max_t



Initial_parameters='pa_0_nt_100_bt_2min'
Total_seconds=83

print, initial_parameters

.r plot_max_t



Initial_parameters='pa_0_nt_75_bt_2min'
Total_seconds=85

print, initial_parameters

.r plot_max_t



Initial_parameters='pa_0_nt_50_bt_2min'
Total_seconds=114

print, initial_parameters

.r plot_max_t



Initial_parameters='pa_4_nt_100_bt_2min'
Total_seconds=77

print, initial_parameters

.r plot_max_t



Initial_parameters='pa_4_nt_75_bt_2min'
Total_seconds=80

print, initial_parameters

.r plot_max_t



Initial_parameters='pa_4_nt_50_bt_2min'
Total_seconds=79

print, initial_parameters

.r plot_max_t


INITIAL_PARAMETERS='pa_0_nt=50'
INITIAL_KEY='p0nt100'
RUN_FORMAT='(I04)'
TOTAL_RUNS=65
START_RUN=1
TOTAL_SECONDS=900

.r run_everything

INITIAL_PARAMETERS='pa_0_nt=75'
INITIAL_KEY='p0nt100'
RUN_FORMAT='(I04)'
TOTAL_RUNS=65
START_RUN=1
TOTAL_SECONDS=900

.r run_everything








.r get_loops_hxr_collect
.r goes_collect
.r goes_plot_ake
.r hxr_plot
.r xrt_mk_maps_meta
.r xrt_avg_maps
.r xrt_plot_curves
.r plot_all_no_err
.r length_v_temp_dense
.r plot_max_t
!p.multi=0
