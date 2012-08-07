;
; NAME: xrt_mk_maps_meta
; 
;
; PURPOSE: This is a macro/procedure for making the use of the mk map functions
;          a bit easier
;                This function automatically stores
;                the maps in the folders with the
;                runs, then picked up in the avg_map function                                
;                This function needs to be modified to change to any other filter
;                It generates the run folders and other input for the
;                mk_xrt_be_thick_maps function
; 
;
; CALLING SEQUENCE: xrt_mk_maps_meta, INITIAL_PARAMETERS=initial_parameters, RUN_FORMAT=run_format, TOTAL_RUNS=total_runs, START_RUN=start_run
;
; INPUTS: None
;
; KEYWORD PARAMETERS:
;   General analysis keywords:
;          INITIAL_PARAMETERS=initial_parameters ->No Default, ex. "pa_0_nt=100"
;          TOTAL_RUNS=total_runs                 **Default: 65
;          **TOTAL_SECONDS=total_seconds         ->This function determines total_seconds on its own
;          RUN_FORMAT=run_format                 **Default: '(I04)'
;          DATA_FOLDER=data_folder               **Default: '/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
;          START_RUN=start_run                   **Default: 1
;
; 
; 
;
; OUTPUTS: Uses mk_xrt_be_thick_maps to save map files in the data folders
;
; OPTIONAL OUTPUTS: 
; 
; SAVED:  See above
;          
; 
;
; MODIFICATION HISTORY:
;   Written by: Andrea Egan, July 2011
;
pro xrt_mk_maps_meta,$
   TOTAL_RUNS=total_runs,$
   INITIAL_PARAMETERS=initial_parameters,$
   START_RUN=start_run,$;run to start with
   RUN_FORMAT=run_format,$
   DATA_FOLDER=data_folder
  
  if size(INITIAL_PARAMETERS,/TYPE) ne 7 then $
     INITIAL_PARAMETERS='pa-4_nt=100/'
  if size(TOTAL_RUNS,/TYPE) ne 2 then $
     TOTAL_RUNS=65
  if size(RUN_FORMAT,/TYPE) ne 7 then $
     RUN_FORMAT='(I02)'
  if size(DATA_FOLDER,/TYPE) ne 7 then $
     DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
  if size(START_RUN, /TYPE) ne 2 then $
     START_RUN=1


;Generate EXPERIMENT_DIR
experiment_dir=data_folder+initial_parameters

;Generate RUN_FOLDERS
x=indgen(total_Runs+1-start_run)+start_run
run_folders='run_'+string(x,run_Format)


;Run the program

mk_xrt_be_thick_maps, EXPERIMENT_DIR=experiment_dir,RUN_FOLDERS=run_folders,prefix='patc'


END
