;Initial_parameters_macro /copy and paste


          INITIAL_PARAMETERS='pa_4_nt_75_bt_2min';em movie done
          TOTAL_RUNS=19
         ; TOTAL_SECONDS=565
          RUN_FORMAT='(I04)'
          DATA_FOLDER	='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_2nd_swing/'
          START_RUN=5	
          SAVE_FOLDER=	'/Volumes/Herschel/aegan/Data/saved2/'
          PLOT_FOLDER='/Volumes/Herschel/aegan/plots2/'
;all done!/running

          INITIAL_PARAMETERS='pa_4_nt_50_bt_2min';em movie done
          TOTAL_RUNS=19
        ;  TOTAL_SECONDS=400
          RUN_FORMAT='(I04)'
          DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_2nd_swing/'
          START_RUN=5	
          SAVE_FOLDER=	'/Volumes/Herschel/aegan/Data/saved2/'
          PLOT_FOLDER='/Volumes/Herschel/aegan/plots2/'
.r run_everything
loops=0
          INITIAL_PARAMETERS='pa_4_nt_100_bt_2min';em movie done
          TOTAL_RUNS=19
        ;  TOTAL_SECONDS=400
          RUN_FORMAT='(I04)'
          DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_2nd_swing/'
          START_RUN=5	
          SAVE_FOLDER=	'/Volumes/Herschel/aegan/Data/saved2/'
          PLOT_FOLDER='/Volumes/Herschel/aegan/plots2/'
.r run_everything
          INITIAL_PARAMETERS='pa_m4_nt_50_bt_2min';em movie done
          TOTAL_RUNS=19
       ;   TOTAL_SECONDS=400
          RUN_FORMAT='(I04)'
          DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_2nd_swing/'
          START_RUN=5	
          SAVE_FOLDER=	'/Volumes/Herschel/aegan/Data/saved2/'
          PLOT_FOLDER='/Volumes/Herschel/aegan/plots2/'
.r run_everything
          INITIAL_PARAMETERS='pa-4_nt_75_bt_2min' ;em movie done
          TOTAL_RUNS=19
        ;  TOTAL_SECONDS=400
          RUN_FORMAT='(I04)'
          DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_2nd_swing/'
          START_RUN=5	
          SAVE_FOLDER=	'/Volumes/Herschel/aegan/Data/saved2/'
          PLOT_FOLDER='/Volumes/Herschel/aegan/plots2/'
.r run_everything
          INITIAL_PARAMETERS='pa-4_nt_100_bt_2min';em movie done
          TOTAL_RUNS=19
       ;   TOTAL_SECONDS=400
          RUN_FORMAT='(I04)'
          DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_2nd_swing/'
          START_RUN=5	
          SAVE_FOLDER=	'/Volumes/Herschel/aegan/Data/saved2/'
          PLOT_FOLDER='/Volumes/Herschel/aegan/plots2/'
.r run_everything
          INITIAL_PARAMETERS='pa_0_nt_50_bt_2min';em movie done
          TOTAL_RUNS=19
       ;   TOTAL_SECONDS=400
          RUN_FORMAT='(I04)'
          DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_2nd_swing/'
          START_RUN=5	
          SAVE_FOLDER=	'/Volumes/Herschel/aegan/Data/saved2/'
          PLOT_FOLDER='/Volumes/Herschel/aegan/plots2/'
.r run_everything
          INITIAL_PARAMETERS='pa_0_nt_75_bt_2min' ;em movie done
          TOTAL_RUNS=19
    ;      TOTAL_SECONDS=400
          RUN_FORMAT='(I04)'
          DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_2nd_swing/'
          START_RUN=5	
          SAVE_FOLDER=	'/Volumes/Herschel/aegan/Data/saved2/'
          PLOT_FOLDER='/Volumes/Herschel/aegan/plots2/'
.r run_everything
          INITIAL_PARAMETERS='pa_0_nt_100_bt_2min'
          TOTAL_RUNS=18
        ;  TOTAL_SECONDS=400
          RUN_FORMAT='(I04)'
          DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_2nd_swing/'
          START_RUN=5	
          SAVE_FOLDER=	'/Volumes/Herschel/aegan/Data/saved2/'
          PLOT_FOLDER='/Volumes/Herschel/aegan/plots2/'
.r run_everything

          DELTA_T, INITIAL_PARAMETERS=INITIAL_PARAMETERS, SAVE_FOLDER=save_folder
