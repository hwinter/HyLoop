;
; NAME: xrt_plot_curves
; 
;
; PURPOSE: This is a procedure for generating .ps plots for xrt lightcurve data

;
; 
;
; CALLING SEQUENCE: xrt_plot_curves, xrt_array, xrt_dev, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds
; 
;
; INPUTS: XRT_array, xrt_dev-> see xrt_avg_maps function
;
; KEYWORD PARAMETERS:
;   General analysis keywords:
;          INITIAL_PARAMETERS=initial_parameters ->No Default, ex. "pa_0_nt=100"
;          TOTAL_SECONDS=total_seconds           **Default: 900
;          PLOT_FOLDER=plot_folder               **Default: '/Volumes/Herschel/aegan/plots/'
;
; 
; 
;
; OUTPUTS: .ps file of the plot ->filename=PLOT_FOLDER+initial_parameters+'_XRT_be_thick_plot.ps'
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

pro xrt_plot_curves, emission_array, std_dev, $
                     INITIAL_PARAMETERS=initial_parameters,$
                     TOTAL_RUNS=total_runs,$
                     TOTAL_SECONDS=total_seconds,$
                     RUN_FORMAT=run_format,$
                     DATA_FOLDER=data_folder, $
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


;Set Device 
  set_plot,'ps'
  FILENAME=PLOT_FOLDER+initial_parameters+'_XRT_be_thick_plot.ps'
  device,FILENAME=FILENAME,DECOMPOSED=0,/COLOR,/LANDSCAPE

;Set plot characteristics
  plot_title=initial_parameters+' XRT Thick Beryllium Filter Light Curve'
  x_title='Time (s)'
  y_title='XRT Emission'
  lineColor=4
  time_array=indgen(total_Seconds+1)


;;;;;;;;;;;;;;;;;;;;;;;
;Plot the axes
  plot, time_array,Emission_array,/NODATA, BACKGROUND=1,COLOR=0,XRANGE=[0,total_seconds],title=plot_title,xtitle=X_title,ytitle=Y_title,CHARSIZE=1.6,FONT=1,CHARTHICK=2

;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the normalized data
  oplot, time_array, Emission_array,COLOR=lineColor, THICK=1

;;;;;;;;;;;;;;;;;;;;;;
;Plot Error
  ERR=std_dev
  errplot, time_array,Emission_array-ERR, Emission_array+ERR,COLOR=lineColor

;;;;;;;;;;;;;;;;;;;;;;
;Plot Legend
;print the pitch-angle and nt percentage in corner
  legend,[Initial_parameters],outline_color=0,/top_legend,/right_legend,textcolors=0,font=1

  device,/close





  set_plot,'x'
END
