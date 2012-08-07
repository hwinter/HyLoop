;This is my first plotting of all four of the graphs together. 

pro plot_all_sup, $;GOES, XRT_be_thick, HXR,$

   PLOT_SECS=plot_secs,$
   INITIAL_PARAMETERS=initial_parameters,$
   DATA_FOLDER=data_folder, $
   POSITION=position,$
TITLE=title,$
NO_Y=no_y,$
NO_X=no_X,$
SAVE_FOLDER=save_folder, _extra=extra
  
if size(INITIAL_PARAMETERS,/TYPE) ne 7 then $
   INITIAL_PARAMETERS='pa-4_nt=100'
if size(TOTAL_RUNS,/TYPE) ne 2 then $
   TOTAL_RUNS=65
                                ;if size(TOTAL_SECONDS,/TYPE) ne 2 then $
                                ;  TOTAL_SECONDS=900
if size(PLOT_SECS,/TYPE) ne 2 then $
   PLOT_SECS=900
if size(RUN_FORMAT,/TYPE) ne 7 then $
   RUN_FORMAT='(I02)'
if size(DATA_FOLDER,/TYPE) ne 7 then $
   DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
 if size(SAVE_FOLDER,/TYPE) ne 7 then $
     SAVE_FOLDER='/Volumes/Herschel/aegan/Data/saved/'
if keyword_set(NO_X) then $
x_title=''
if keyword_set(NO_Y) then $
y_title=''


print, 'restoring...'
goes_restore=SAVE_FOLDER+initial_parameters+'_GOES_collect.sav'
restore, goes_restore
print, 'restoring...'
;XRT_restore=SAVE_FOLDER+initial_parameters+'_XRT_be_thick_emission_avg.sav'
;restore, XRT_restore
print, 'restoring...'
HXR_restore=SAVE_FOLDER+initial_parameters+'_hxr_emission.sav'
restore, HXR_restore
print, 'restoring...'
GOES=long
HXR=hxr_array
;XRT_be_thick=xrt_array
time_array=indgen(size(long, /n_elements))

;Set plot characteristics

x_title='Time (s)'
y_title='Normalized Emissions'
;lineColor=4
;x=indgen(totalSeconds)

help, goes
help, long
help, time_array
;Deriv GOES
Derived=DERIV(time_array, GOES)

;;;;;
;Normalize data
norm_GOES=GOES/Max(GOES)
norm_HXR=HXR/Max(hxr)
;norm_XRT_be=XRT_be_thick/Max(XRT_be_thick)
norm_goes_deriv=derived/max(derived)

;Set the colors
GOES_C=2
HXR_C=0
XRT_C=4
DERIV_C=3
if keyword_set(NO_X) then x_title=''
if keyword_set (NO_Y) then y_title=''
;;;;;;;;;;;;;;;;;;;;;;;
;Plot the axes

plot, time_array,goes,/NODATA, BACKGROUND=1,COLOR=0,XRANGE=[0,plot_secs],YRANGE=[0,1],TITLE=title,XTITLE=x_title, YTITLE=y_title, CHARSIZE=2,FONT=1,CHARTHICK=2, THICK=3.5, _extra=extra

;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the normalized data
oplot, time_array, norm_GOES, COLOR=hxr_c,THICK=3.5
oplot, time_array, norm_HXR, Color=xrt_c, thick=3.5
;oplot, time_array, norm_XRT_be, COLOR=xrt_c, thick=1
oplot,time_array, norm_goes_deriv, COLOR=goes_c, THICK=3.5


;;;;;;;;;;;;;;;;;;;;;;
;Plot Legend
;legend,['GOES Long','HXR','XRT Be Thick','GOES Derivative'],outline_color=0,/top_legend,/right_legend,textcolors=0,font=1,LINESTYLE=[0,0,0,0],COLORS=[goes_c, hxr_c, xrt_c, deriv_c]

;device,/close


;set_plot,'x'
END
