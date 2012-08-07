;
; NAME: plot_all_no_err
; 
;
; PURPOSE: This procedure restores data to plot normalized GOES, XRT be thick,
;          HXR and GOES derivative data on the same plot without error bars
;
; 
;
; CALLING SEQUENCE: plot_all_no_err, INITIAL_PARAMETERS=initial_parameters, total_seconds=total_seconds, plot_secs=200
;
; INPUTS: 
;
; KEYWORD PARAMETERS:
;   Specific Keywords:    
;          PLOT_SECS=How many seconds of data the plot will represent
;                    (setting the x axis)
;   General analysis keywords:
;          INITIAL_PARAMETERS=initial_parameters ->No Default, ex. "pa_0_nt=100"
;          TOTAL_SECONDS=total_seconds           **Default: 900
;          PLOT_FOLDER=plot_folder               **Default: '/Volumes/Herschel/aegan/plots/'
;          SAVE_FOLDER=save_folder               **'/Volumes/Herschel/aegan/Data/saved/'
; 
; 
;
; OUTPUTS: .ps file of the plot ->filename='/Volumes/Herschel/aegan/plots/'+initial_parameters+'_total_plot_'+string(plot_secs,'(I03)')+'_new.ps';
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


pro plot_all_no_err, $          ;GOES, XRT_be_thick, HXR,$
   title=title, $
   PLOT_SECS=plot_secs,$
   INITIAL_PARAMETERS=initial_parameters,$
   TOTAL_RUNS=total_runs,$
   TOTAL_SECONDS=total_seconds,$
   RUN_FORMAT=run_format,$
   DATA_FOLDER=data_folder,$
   PLOT_FOLDER=plot_folder, $
   SAVE_FOLDER=save_folder, gpp=gpp, _extra=extra, $
   legend=legend,$
   NO_Y=no_y,$
   NO_X=no_X
  

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
     SAVE_FOLDER='/Volumes/Herschel/aegan/Data/saved2/'

;Set up device
;Restore all of the data
  goes_restore=SAVE_FOLDER+initial_parameters+'_GOES_collect.sav'
  restore, goes_restore, verb=1
  print, 'restoring '+goes_restore
  ;; XRT_restore=SAVE_FOLDER+initial_parameters+'_XRT_be_thick_emission_avg.sav'
  ;; restore, XRT_restore
  print, 'restoring...'
  HXR_restore=SAVE_FOLDER+initial_parameters+'_hxr_emission.sav'
  restore, HXR_restore, /verb
  print, 'restoring '+HXR_restore
  GOES=long
  HXR=hxr_array
 ;; XRT_be_thick=xrt_array

;Set plot characteristics
  plot_title=Initial_parameters
  x_title='Time (s)'
  y_title='Normalized Emissions'


  time_array=indgen(n_elements(Goes))
                                ;help, goes
                                ;help, long
                                ;help, time_array
help, time_array
help, goes
;Deriv GOES
;stop
Derived=DERIV(time_array, GOES)

;;;;;
;Normalize data
  norm_GOES=GOES/Max(GOES)
  norm_HXR=HXR/Max(hxr)
 ;; norm_XRT_be=XRT_be_thick/Max(XRT_be_thick)
  norm_goes_deriv=derived/max(derived)

;Set the colors
  color=['Red','Blue', 'Orange', 'black']

if keyword_set(no_x) then X_title=''
if keyword_set(no_y) then y_title=''
if keyword_set(legend) then goto, legend_jump
;;;;;;;;;;;;;;;;;;;;;;;
;Plot the axes
  plot, time_array,goes,/NODATA, BACKGROUND=1,COLOR=0,XRANGE=[40,120],YRANGE=[0,1],title=title,xtitle=X_title,ytitle=Y_title,CHARSIZE=.9,FONT=1,CHARTHICK=2,$
       xticks =2, xtickv=[50,100, 150] ,_extra=gpp
;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the normalized data
  oplot, time_array, norm_GOES, COLOR=fsc_color(color[0]),THICK=4
  oplot, time_array, norm_HXR, Color=fsc_color(color[1]), thick=4
 ;; oplot, time_array, norm_XRT_be, COLOR=xrt_c, thick=1
  oplot, time_array, norm_goes_deriv, COLOR=fsc_color(color[3]), THICK=4


;;;;;;;;;;;;;;;;;;;;;;
legend_jump:
;Plot Legend
if keyword_set(legend) then $
   legend,['GOES Long','HXR','GOES Deriv.'],outline_color=0,/top_legend,/right_legend,textcolors=0,font=1,LINESTYLE=[0,0,0],$
          box=3, COLORS=[fsc_color(color[0]),fsc_color(color[1]),fsc_color(color[3])], thick=[4,4,4] ; set_plot,'x'
END
