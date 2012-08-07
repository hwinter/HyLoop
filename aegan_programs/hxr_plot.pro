;
; NAME: hxr_plot
; 
;
; PURPOSE: This is a procedure for plotting the results of hxr_collect
;          It is executed with the results from hxr_collect as an input
;
; 
;
; CALLING SEQUENCE: hxr_plot, HXR_array, MAD, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds
; 
;
; INPUTS: HXR_array, MAD ->(median absolute deviation) see
;                          get_loops_hxr_collect function
;
; KEYWORD PARAMETERS:
;   General analysis keywords:
;          INITIAL_PARAMETERS=initial_parameters ->No Default, ex. "pa_0_nt=100"
;          TOTAL_SECONDS=total_seconds           **Default: 900
;          PLOT_FOLDER=plot_folder               **Default: '/Volumes/Herschel/aegan/plots/'
; 
; 
;
; OUTPUTS: .ps file of the plot ->filename='/Volumes/Herschel/aegan/plots/'+initial_parameters+'_HXR_plot.ps'
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


 
pro hxr_plot, Emission_array,std_dev, $
              INITIAL_PARAMETERS=initial_parameters,$
              TOTAL_RUNS=total_runs,$
              TOTAL_SECONDS=total_seconds,$
              RUN_FORMAT=run_format,$
              DATA_FOLDER=data_folder,$
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

;Set up the device

  set_plot,'ps'
  filename=PLOT_FOLDER+initial_parameters+'_HXR_plot.ps'
  device,filename=fileName,decomposed=0,/color,/landscape

;Set plot characteristics
  plot_title=initial_parameters+' Hard X-Ray Emission'
  x_title='Time (s)'
  y_title='HXR Emission'
  lineColor=4


  TIME_ARRAY=indgen(total_seconds+1)
 
;;;;;;;;;;;;;;;;;;;;;;;
;Plot the axes
  plot, time_array,Emission_array,/NODATA, BACKGROUND=1,COLOR=0,XRANGE=[0,175],title=plot_title,xtitle=X_title,ytitle=Y_title,CHARSIZE=1.6,FONT=1,CHARTHICK=2
;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the data
  oplot, time_array, Emission_array,COLOR=lineColor, THICK=1

;;;;;;;;;;;;;;;;;;;;;;
;Plot Error
  ERR=std_dev                  
  errplot, time_array,Emission_array-ERR, Emission_array+ERR,COLOR=lineColor

;;;;;;;;;;;;;;;;;;;;;;
;Plot Legend
;print the pitch-angle and nt percentage in corner
  legend,[initial_parameters],outline_color=0,/top_legend,/right_legend,textcolors=0,font=1

  device,/close

END
