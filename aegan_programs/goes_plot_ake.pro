;
; NAME: goes_plot_ake
; 
;
; PURPOSE: Plots GOES data and standard deviation over time to .ps files
;
; 
;
; CALLING SEQUENCE: GOES_plot_AKE, goes_long, std_dev_long, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds
; 
;
; INPUTS: goes_long, std_dev_long ->see GOES_collect function
;
; KEYWORD PARAMETERS:
;   Specific Keywords:
;          SHORT=short   ->Can set this keyword to plot short data
;                          instead (changes titles, etc)
;   General analysis keywords:
;          INITIAL_PARAMETERS=initial_parameters ->No Default, ex. "pa_0_nt=100"
;          TOTAL_SECONDS=total_seconds           **Default: 900
;          PLOT_FOLDER=plot_folder               **Default: '/Volumes/Herschel/aegan/plots/'
;
; 
; 
;
; OUTPUTS: .ps file of the plot ->FILENAME='/Volumes/Herschel/aegan/plots/'+initial_parameters+'_GOES_plot_long_new.ps'
;
; OPTIONAL OUTPUTS: 
; 
; SAVED:  
;         
; 
;
; MODIFICATION HISTORY:
;   Written by: Andrea Egan, July 2011
;


 

pro GOES_plot_ake, emission_array, std_dev, $
                   INITIAL_PARAMETERS=initial_parameters,$
                   TOTAL_RUNS=total_runs,$
                   TOTAL_SECONDS=total_seconds,$
                   RUN_FORMAT=run_format,$
                   DATA_FOLDER=data_folder,$
                   SHORT=SHORT, $
                   PLOT_FOLDER=plot_folder

  

  if size(INITIAL_PARAMETERS,/TYPE) ne 7 then begin
     print, 'please specify INITIAL_PARAMETERS'
     STOP
  endif
  if size(TOTAL_RUNS,/TYPE) ne 2 then $
     TOTAL_RUNS=65
  if size(TOTAL_SECONDS,/TYPE) ne 2 then $
     TOTAL_SECONDS=900
  if size(RUN_FORMAT,/TYPE) ne 7 then $
     RUN_FORMAT='(I04)'
  if size(DATA_FOLDER,/TYPE) ne 7 then $
     DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
  if size(PLOT_FOLDER,/TYPE) ne 7 then $
     PLOT_FOLDER='/Volumes/Herschel/aegan/plots/'
;;;;;;;;;;;;;;;;
;;Set the plot and file title
;;;;;;;;;;;;;;;;
  if keyword_set(SHORT) then begin
     filename=PLOT_FOLDER+initial_parameters+'_GOES_plot_short.ps'
     plot_title=initial_parameters+ ' GOES flux of Simulated Loops (Short)'
  endif else begin
     filename=PLOT_FOLDER+initial_parameters+'_GOES_plot_long_new.ps'
     plot_title=initial_parameters+ ' GOES flux of Simulated Loops (Long)'
  endelse



 
  
  set_plot,'ps'
  device,filename=fileName,decomposed=0,/color,/landscape

;Set plot characteristics

  x_title='Time (s)'
  y_title='GOES Flux'
  lineColor=4

  time_array=indgen(total_Seconds+1) ;x-coords



;;;;;;;;;;;;;;;;;;;;;;;
;Plot the axes
  plot, time_array,emission_array,/NODATA, BACKGROUND=1,COLOR=0,XRANGE=[0,200],YRANGE=[0,max(emission_array)],title=plot_title,xtitle=X_title,ytitle=Y_title,CHARSIZE=1.6,FONT=1,CHARTHICK=2
;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the normalized data
  oplot, time_array, emission_array,COLOR=lineColor, THICK=1
;;;;;;;;;;;;;;;;;;;;;;
;Plot Error
  ERR=std_dev                   ;/Max(emission_array)
  errplot, time_array,emission_array-ERR, emission_array+ERR,COLOR=lineColor



;;;;;;;;;;;;;;;;;
;Option to also plot short
;oplot, time_array, short, Color=2, thick=1
;ERR=short_dev
;errplot, time_array,short-ERR, short+ERR,COLOR=2


;;;;;;;;;;;;;;;;;;;;;;
;Plot Legend
;print the pitch-angle and nt percentage in corner
  legend,[Initial_parameters],outline_color=0,/top_legend,/right_legend,textcolors=0,font=1

  device,/close


END
