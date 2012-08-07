; This is a procedure for plotting all six of the final results on one
; page

pro plot_all_temps,PLOT_FOLDER=plot_folder, SAVE_FOLDER=save_folder


if size(PLOT_SECS,/TYPE) ne 2 then $
   PLOT_SECS=200

set_plot, 'ps'

!P.MULTI=[0,3,3]


FILENAME=PLOT_FOLDER+"plot_all_temps.ps"

device, FILENAME=filename, decomposed=0,/color,/landscape

xtitle='Time (s)'
ytitle='Normalized Emission'
;Set the colors
GOES_C=2
HXR_C=0
XRT_C=4
DERIV_C=3

;;ROW 1;;

;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=100'
temp_plot_sup, INITIAL_PARAMETERS='pa-4_nt_100_bt_2min', PLOT_SECS=plot_secs, TITLE="Beamed Particles  100% NT",/NO_X, SAVE_FOLDER=save_folder, /NT

;;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=75'
temp_plot_sup, INITIAL_PARAMETERS='pa-4_nt_75_bt_2min', PLOT_SECS=plot_secs, TITLE="Beamed Particles 75% NT",/NO_X,/NO_Y, SAVE_FOLDER=save_folder

;;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=5-'
temp_plot_sup, INITIAL_PARAMETERS='pa_m4_nt_50_bt_2min', PLOT_SECS=plot_secs, TITLE="Beamed Particles 75% NT",/NO_X,/NO_Y, SAVE_FOLDER=save_folder, /LEGEND


;;;;;;;;;;;;;;;;;;;;;;
;Plot Legend
;legend,['GOES Long','HXR','GOES Derivative'],outline_color=0,/top_legend,/right_legend,textcolors=0,font=1,LINESTYLE=[0,0,0],COLORS=[hxr_c,xrt_c,goes_c], charsize=0.7

;;ROW 2;;

;;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=100'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_100_bt_2min',  TITLE="Random Scattering 100% NT",/NO_X, SAVE_FOLDER=save_folder, /NT

;;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=75'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_75_bt_2min', TITLE="Random Scattering  75% NT", /NO_X,/NO_Y, SAVE_FOLDER=save_folder

;;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=50'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_50_bt_2min', TITLE="Random Scattering 50% NT", /NO_X,/NO_Y, SAVE_FOLDER=save_folder


;;ROW 3;;

;;;;;;;;;;;;;;;;;;;
print, ' pa 4, nt=100'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_100_bt_2min', TITLE="Betatron Scattering 100% NT", SAVE_FOLDER=save_folder, /NT

;;;;;;;;;;;;;;;;;;;
print, ' pa 4, nt=75'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_75_bt_2min', TITLE="Betatron Scattering 75% NT",/NO_Y, SAVE_FOLDER=save_folder

;;;;;;;;;;;;;;;;;;;
print, ' pa 4, nt=50'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_50_bt_2min',  TITLE="Betatron Scattering 50% NT",/NO_Y, SAVE_FOLDER=save_folder



device, /CLOSE
PRINT, "DENSITIES..."
FILENAME=PLOT_FOLDER+"plot_all_dens.ps"

device, FILENAME=filename, decomposed=0,/color,/landscape

;;ROW 1;;

;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=100'
temp_plot_sup, INITIAL_PARAMETERS='pa-4_nt_100_bt_2min', PLOT_SECS=plot_secs, TITLE="Beamed Particles  100% NT",/NO_X, SAVE_FOLDER=save_folder, /DENSE

;;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=75'
temp_plot_sup, INITIAL_PARAMETERS='pa-4_nt_75_bt_2min', PLOT_SECS=plot_secs, TITLE="Beamed Particles 75% NT",/NO_X,/NO_Y, SAVE_FOLDER=save_folder, /DENSE

;;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=50'
temp_plot_sup, INITIAL_PARAMETERS='pa_m4_nt_50_bt_2min', PLOT_SECS=plot_secs, TITLE="Beamed Particles 50% NT",/NO_X,/NO_Y, SAVE_FOLDER=save_folder, /LEGEND, /DENSE


;;;;;;;;;;;;;;;;;;;;;;
;Plot Legend
;legend,['GOES Long','HXR','GOES Derivative'],outline_color=0,/top_legend,/right_legend,textcolors=0,font=1,LINESTYLE=[0,0,0],COLORS=[hxr_c,xrt_c,goes_c], charsize=0.7

;;ROW 2;;

;;;;;;;;;;;;;;;;;;;
print, 'pa 0, nt=100'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_100_bt_2min',  TITLE="Random Scattering 100% NT",/NO_X, SAVE_FOLDER=save_folder, /DENSE

;;;;;;;;;;;;;;;;;;;
print, 'pa 0, nt=75'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_75_bt_2min', TITLE="Random Scattering  75% NT", /NO_X,/NO_Y, SAVE_FOLDER=save_folder, /DENSE

;;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=50'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_50_bt_2min', TITLE="Random Scattering 50% NT", /NO_X,/NO_Y, SAVE_FOLDER=save_folder, /DENSE



;;ROW 3;;

;;;;;;;;;;;;;;;;;;;
print, ' pa 4, nt=100'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_100_bt_2min', TITLE="Betatron Scattering 100% NT", SAVE_FOLDER=save_folder, /DENSE
;;;;;;;;;;;;;;;;;;;
print,' pa 4, nt=75'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_75_bt_2min', TITLE="Betatron Scattering 75% NT",/NO_Y, SAVE_FOLDER=save_folder, /DENSE

;;;;;;;;;;;;;;;;;;;
print,' pa 4, nt=50'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_50_bt_2min',  TITLE="Betatron Scattering 50% NT",/NO_Y, SAVE_FOLDER=save_folder, /DENSE

device, /Close


END
