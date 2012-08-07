; This is a procedure for plotting all six of the final results on one
; page

;pro plot_all_temps_hdw,PLOT_FOLDER=plot_folder, SAVE_FOLDER=save_folder
SAVE_FOLDER='/Volumes/Herschel/aegan/Data/saved2/'
PLOT_FOLDER='/Volumes/Herschel/aegan/new_plots/'
if size(PLOT_SECS,/TYPE) ne 2 then $
   PLOT_SECS=200

set_plot, 'ps'

goto, delta_t_jump ;emissions_jump

FILENAME=PLOT_FOLDER+"plot_all_temps_4x3.ps"

device, FILENAME=filename, decomposed=0,/color,/landscape

xtitle='Time (s)'
ytitle='Normalized Emission'
;Set the colors
GOES_C=2
HXR_C=0
XRT_C=4
DERIV_C=3



goto, emissions_jump

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;ROW 1;;
;Beamed
;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=100'
temp_plot_sup, INITIAL_PARAMETERS='pa-4_nt_100_bt_2min', PLOT_SECS=plot_secs, TITLE=" 100% NT Energy",/NO_X,$
               SAVE_FOLDER=save_folder, /NT, gpp=gang_plot_pos(3,4,0,0),/NO_y, /LEGEND
;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=90'
temp_plot_sup, INITIAL_PARAMETERS='pa-4_nt_90_bt_2min', PLOT_SECS=plot_secs, TITLE=" 90% NT Energy",/NO_X,$ 
               SAVE_FOLDER=save_folder, /NT, gpp=gang_plot_pos(3,4,1,0),/NO_Y

;;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=75'
temp_plot_sup, INITIAL_PARAMETERS='pa-4_nt_75_bt_2min', PLOT_SECS=plot_secs, TITLE=" 75% NT Energy",/NO_X,$
               /NO_Y, SAVE_FOLDER=save_folder, gpp=gang_plot_pos(3,4,2,0)

;;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=50'
temp_plot_sup, INITIAL_PARAMETERS='pa_m4_nt_50_bt_2min', PLOT_SECS=plot_secs, TITLE=" 50% NT Energy",/NO_X,$
               /NO_Y, SAVE_FOLDER=save_folder, gpp=gang_plot_pos(3,4,3,0)

axis, yaxis=1, ytitle='Beamed', font=1, CHARSIZE=1.5,CHARthick=1.5, yticks=1, ytickname=['', '']

;;ROW 2;;
;Random
;;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=100'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_100_bt_2min',  /NO_X, SAVE_FOLDER=save_folder, $
               /NT, PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,0,1)

;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=90'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_90_bt_2min', PLOT_SECS=plot_secs, /NO_X, $
               SAVE_FOLDER=save_folder, /NT, gpp=gang_plot_pos(3,4,1,1),/NO_Y


;;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=75'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_75_bt_2min',  /NO_X,/NO_Y, SAVE_FOLDER=save_folder,$
               PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,2,1)


;;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=50'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_50_bt_2min', /NO_X,/NO_Y, $
               SAVE_FOLDER=save_folder, PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,3,1)


axis, yaxis=1, ytitle='Random', font=1, CHARSIZE=1.5,CHARthick=1.5, yticks=1, ytickname=['', '']

;;ROW 3;;
;Betatron
;;;;;;;;;;;;;;;;;;;
print, ' pa 4, nt=100'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_100_bt_2min', SAVE_FOLDER=save_folder, /NT, $
               PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,0,2),/NO_X,/NO_Y

;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=90'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_90_bt_2min', PLOT_SECS=plot_secs, /NO_X,$
               SAVE_FOLDER=save_folder, /NT, gpp=gang_plot_pos(3,4,1,2),/NO_Y

;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
print, ' pa 4, nt=75'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_75_bt_2min', /NO_Y, $
               SAVE_FOLDER=save_folder, PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,2,2)

;;;;;;;;;;;;;;;;;;;
print, ' pa 4, nt=50'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_50_bt_2min',  /NO_Y, SAVE_FOLDER=save_folder,$
               PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,3,2)



axis, yaxis=1, ytitle='Betatron', font=1, CHARSIZE=1.5,CHARthick=1.5, yticks=1, ytickname=['', '']

xyouts,.4,.02,  'Loop Length [Mega Meters]',/normal, font=1, CHARSIZE=1.5,CHARthick=1.5
device, /CLOSE
print, "Printed "+filename
;goto, end_jump 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PRINT, "DENSITIES..."
FILENAME=PLOT_FOLDER+"plot_all_dens_4x3.ps"

device, FILENAME=filename, decomposed=0,/color,/landscape


;;ROW 1;;
;Beamed
;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=100'
temp_plot_sup, INITIAL_PARAMETERS='pa-4_nt_100_bt_2min', PLOT_SECS=plot_secs, TITLE=" 100% NT Energy",/NO_X,$
               SAVE_FOLDER=save_folder, /NT, gpp=gang_plot_pos(3,4,0,0),/NO_y, /LEGEND, /DENS
;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=90'
temp_plot_sup, INITIAL_PARAMETERS='pa-4_nt_90_bt_2min', PLOT_SECS=plot_secs, TITLE=" 90% NT Energy",/NO_X,$ 
               SAVE_FOLDER=save_folder, /NT, gpp=gang_plot_pos(3,4,1,0),/NO_Y, /DENS

;;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=75'
temp_plot_sup, INITIAL_PARAMETERS='pa-4_nt_75_bt_2min', PLOT_SECS=plot_secs, TITLE=" 75% NT Energy",/NO_X,$
               /NO_Y, SAVE_FOLDER=save_folder, gpp=gang_plot_pos(3,4,2,0), /DENS

;;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=50'
temp_plot_sup, INITIAL_PARAMETERS='pa_m4_nt_50_bt_2min', PLOT_SECS=plot_secs, TITLE=" 50% NT Energy",/NO_X,$
               /NO_Y, SAVE_FOLDER=save_folder, gpp=gang_plot_pos(3,4,3,0), /DENS

axis, yaxis=1, ytitle='Beamed', font=1, CHARSIZE=1.5,CHARthick=1.5, yticks=1, ytickname=['', '']

;;ROW 2;;
;Random
;;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=100'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_100_bt_2min',  /NO_X, SAVE_FOLDER=save_folder, $
               /NT, PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,0,1), /DENS

;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=90'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_90_bt_2min', PLOT_SECS=plot_secs, /NO_X, $
               SAVE_FOLDER=save_folder, /NT, gpp=gang_plot_pos(3,4,1,1),/NO_Y, /DENS


;;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=75'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_75_bt_2min',  /NO_X,/NO_Y, SAVE_FOLDER=save_folder,$
               PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,2,1), /DENS


;;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=50'
temp_plot_sup, INITIAL_PARAMETERS='pa_0_nt_50_bt_2min', /NO_X,/NO_Y, $
               SAVE_FOLDER=save_folder, PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,3,1), /DENS


axis, yaxis=1, ytitle='Random', font=1, CHARSIZE=1.5,CHARthick=1.5, yticks=1, ytickname=['', '']

;;ROW 3;;
;Betatron
;;;;;;;;;;;;;;;;;;;
print, ' pa 4, nt=100'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_100_bt_2min', SAVE_FOLDER=save_folder, /NT, $
               PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,0,2),/NO_X,/NO_Y, /DENS

;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=90'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_90_bt_2min', PLOT_SECS=plot_secs, /NO_X,$
               SAVE_FOLDER=save_folder, /NT, gpp=gang_plot_pos(3,4,1,2),/NO_Y, /DENS

;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
print, ' pa 4, nt=75'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_75_bt_2min', /NO_Y, $
               SAVE_FOLDER=save_folder, PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,2,2), /DENS

;;;;;;;;;;;;;;;;;;;
print, ' pa 4, nt=50'
temp_plot_sup, INITIAL_PARAMETERS='pa_4_nt_50_bt_2min',  /NO_Y, SAVE_FOLDER=save_folder,$
               PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,3,2), /DENS



axis, yaxis=1, ytitle='Betatron', font=1, CHARSIZE=1.5,CHARthick=1.5, yticks=1, ytickname=['', '']

xyouts,.4,.02,  'Loop Length [Mega Meters]',/normal, font=1, CHARSIZE=1.5,CHARthick=1.5
device, /CLOSE
print, "Printed "+filename


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
emissions_jump:
PRINT, "emissions..."
FILENAME=PLOT_FOLDER+"plot_all_emiss_4x3.ps"
device, FILENAME=filename, decomposed=0,/color,/landscape


;;ROW 1;;
;Beamed
;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=100'
plot_all_no_err, INITIAL_PARAMETERS='pa-4_nt_100_bt_2min', PLOT_SECS=plot_secs, TITLE=" 100% NT Energy",/NO_X,$
               SAVE_FOLDER=save_folder, /NT, gpp=gang_plot_pos(3,4,0,0),/NO_y,  /DENS
;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=90'
plot_all_no_err, INITIAL_PARAMETERS='pa-4_nt_90_bt_2min', PLOT_SECS=plot_secs, TITLE=" 90% NT Energy",/NO_X,$ 
               SAVE_FOLDER=save_folder, /NT, gpp=gang_plot_pos(3,4,1,0),/NO_Y, /DENS

;;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=75'
plot_all_no_err, INITIAL_PARAMETERS='pa-4_nt_75_bt_2min', PLOT_SECS=plot_secs, TITLE=" 75% NT Energy",/NO_X,$
               /NO_Y, SAVE_FOLDER=save_folder, gpp=gang_plot_pos(3,4,2,0), /DENS

;;;;;;;;;;;;;;;;;;;
print, ' pa -4, nt=50'
plot_all_no_err, INITIAL_PARAMETERS='pa_m4_nt_50_bt_2min', PLOT_SECS=plot_secs, TITLE=" 50% NT Energy",/NO_X,$
               /NO_Y, SAVE_FOLDER=save_folder, gpp=gang_plot_pos(3,4,3,0), /DENS

axis, yaxis=1, ytitle='Beamed', font=1, CHARSIZE=1.5,CHARthick=1.5, yticks=1, ytickname=['', '']

;;ROW 2;;
;Random
;;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=100'
plot_all_no_err, INITIAL_PARAMETERS='pa_0_nt_100_bt_2min',  /NO_X, SAVE_FOLDER=save_folder, $
               /NT, PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,0,1), /DENS

;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=90'
plot_all_no_err, INITIAL_PARAMETERS='pa_0_nt_90_bt_2min', PLOT_SECS=plot_secs, /NO_X, $
               SAVE_FOLDER=save_folder, /NT, gpp=gang_plot_pos(3,4,1,1),/NO_Y, /DENS


;;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=75'
plot_all_no_err, INITIAL_PARAMETERS='pa_0_nt_75_bt_2min',  /NO_X,/NO_Y, SAVE_FOLDER=save_folder,$
               PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,2,1), /DENS


;;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=50'
plot_all_no_err, INITIAL_PARAMETERS='pa_0_nt_50_bt_2min', /NO_X,/NO_Y, $
               SAVE_FOLDER=save_folder, PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,3,1), /DENS


axis, yaxis=1, ytitle='Random', font=1, CHARSIZE=1.5,CHARthick=1.5, yticks=1, ytickname=['', '']

;;ROW 3;;
;Betatron
;;;;;;;;;;;;;;;;;;;
print, ' pa 4, nt=100'
plot_all_no_err, INITIAL_PARAMETERS='pa_4_nt_100_bt_2min', SAVE_FOLDER=save_folder, /NT, $
               PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,0,2),/NO_X,/NO_Y, /DENS

;;;;;;;;;;;;;;;;;;
print, ' pa 0, nt=90'
plot_all_no_err, INITIAL_PARAMETERS='pa_4_nt_90_bt_2min', PLOT_SECS=plot_secs, /NO_X,$
               SAVE_FOLDER=save_folder, /NT, gpp=gang_plot_pos(3,4,1,2),/NO_Y, /DENS

;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
print, ' pa 4, nt=75'
plot_all_no_err, INITIAL_PARAMETERS='pa_4_nt_75_bt_2min', /NO_Y,  /NO_X,$
               SAVE_FOLDER=save_folder, PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,2,2), /DENS

;;;;;;;;;;;;;;;;;;;
print, ' pa 4, nt=50'
plot_all_no_err, INITIAL_PARAMETERS='pa_4_nt_50_bt_2min',  /NO_Y, /NO_X, SAVE_FOLDER=save_folder,$
               PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,3,2), /DENS



axis, yaxis=1, ytitle='Betatron', font=1, CHARSIZE=1.5,CHARthick=1.5, yticks=1, ytickname=['', '']

xyouts,.45,.02,  'Time [seconds]',/normal, font=1, CHARSIZE=1.5,CHARthick=1.5
device, /CLOSE

print, "Printed "+filename


PRINT, "emissions..."
FILENAME=PLOT_FOLDER+"legend.ps"
device, FILENAME=filename, decomposed=0,/color,/landscape
plot_all_no_err, INITIAL_PARAMETERS='pa_4_nt_50_bt_2min',  /NO_Y, /NO_X, SAVE_FOLDER=save_folder,$
               PLOT_SECS=plot_secs, gpp=gang_plot_pos(3,4,3,2), /DENS, /legen
print, "Printed "+filename

device, /close


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delta_t_jump:
INITIAL_PARAMETERS=['pa-4_nt_100_bt_2min', 'pa_0_nt_100_bt_2min','pa_4_nt_100_bt_2min', $
                    'pa-4_nt_90_bt_2min','pa_0_nt_90_bt_2min', 'pa_4_nt_90_bt_2min', $
                    'pa-4_nt_75_bt_2min','pa_0_nt_75_bt_2min', 'pa_4_nt_75_bt_2min',$
                    'pa-4_nt_50_bt_2min','pa_0_nt_50_bt_2min', 'pa_4_nt_50_bt_2min']

for i=0, n_elements(INITIAL_PARAMETERS)-1 do begin
   print, INITIAL_PARAMETERS[i]
   delta_t, $
      INITIAL_PARAMETERS= INITIAL_PARAMETERS[i],$
       SAVE_FOLDER='/Volumes/Herschel/aegan/Data/saved2/',$
      TOTAL_SECONDS=total_seconds, $
      PERCENT=0.01
   

endfor







end_jump:





END
