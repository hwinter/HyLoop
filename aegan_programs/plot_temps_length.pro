;Program for plotting temp vs loop length over time in increments of
;10 seconds
;plot_temps_length,length, temps, density, initial_parameters=initial_parameters, total_seconds=total_seconds
pro plot_temps_length,length, temps, density,$
;DENSITY=density,$
  INCREMENT=increment,$
   INITIAL_PARAMETERS=initial_parameters,$
   TOTAL_RUNS=total_runs,$
   TOTAL_SECONDS=total_seconds,$
   TIME_ARRAY=time_array,$
   RUN_FORMAT=run_format,$
   DATA_FOLDER=data_folder,$
   START_RUN=start_run


if size(INITIAL_PARAMETERS,/TYPE) ne 7 then $
   INITIAL_PARAMETERS='pa-4_nt=100'
if size(TOTAL_RUNS,/TYPE) ne 2 then $
   TOTAL_RUNS=65
if size(TOTAL_SECONDS,/TYPE) ne 2 then $
   TOTAL_SECONDS=900
if size(TIME_ARRAY,/N_DIMENSIONS) ne 1 then $
   TIME_ARRAY=indgen(TOTAL_SECONDS+1)
if size(RUN_FORMAT,/TYPE) ne 7 then $   RUN_FORMAT='(I02)'
if size(DATA_FOLDER,/TYPE) ne 7 then $
   DATA_FOLDER='/Volumes/Herschel/aegan/Data/HyLoop/runs/2011_REU_pre_arrival/'
if size(START_RUN,/TYPE) ne 2 then $
   START_RUN=1
if size(INCREMENT, /TYPE) ne 2 then $
   INCREMENT=10


set_plot, 'ps'
!P.MULTI=[0,2,2]

FILENAME='/Volumes/Herschel/aegan/plots/'+initial_parameters+'_temp_plot'+string(increment, '(I02)')+'.ps'



plot_title=Initial_parameters+' Temperature over Length'
x_title="Distance along Loop (cm)"
y_title="Temperature (K)"
t_array=indgen(6)*increment
                                ;if keyword_set(density) then begin
                                ;FILENAME='/Volumes/Herschel/aegan/plots/'+initial_parameters+'_dens_plot.ps'
                                ;plot_title=Initial_parameters+' Density over Length'
                                ;y_title="Logarithmic Density along loop (electrons/cm^-3) "
                                ;endif
device, FILENAME=filename, decomposed=0, /color,/landscape

tvlct, fsc_color(["lawn green", "purple", "red", "blue", 'dark green'],/TRIPLE),100
tvlct, fsc_color(/triple),1
tvlct, fsc_color('black',/triple),0

t=0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;TEMPS
plot, length, temps[0,*], /NODATA, BACKGROUND=1, COLOR=0, XRANGE=[0, max(length)],YRANGE=[0,max(temps)],TITLE='Temperature', XTITLE=x_title, YTITLE='Degrees Kelvin', CHARSIZE=1.4, FONT=1, CHARTHICK=2, POSITION=[0.05,0.55,0.45,0.9]
for j=0, 4 do begin

oplot, length, temps[t, *], COLOR=100+j
print, 'plotting temps', t
t=t+increment
endfor ;temps

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;DENSITIES
plot, length[1:698], alog10(density[0,*]), /NODATA, BACKGROUND=1, COLOR=0, XRANGE=[0, max(length)], YRANGE=[7,9],TITLE='Density', XTITLE=x_title, YTITLE='Logarithmic (electrons/cm^-3)', CHARSIZE=1.4, FONT=1, CHARTHICK=2, POSITION=[0.55,0.55,0.95,0.9]

t=0
for j=0, 4 do begin
print, 'plotting densities',t
oplot, length[1:698], alog10(density[t,*])      , COLOR=100+j

t=t+increment

endfor ;j

legend,['Time='+string(t_array[0]),'Time='+string(t_array[1]),'Time='+string(t_array[2]),'Time='+string(t_array[3]),'Time='+string(t_array[4])],outline_color=0,/top_legend,/right_legend,textcolors=0,font=1,LINESTYLE=[0,0,0,0,0],COLORS=[100,101,102,104,103]

legend,[initial_parameters],outline_color=0, /top_legend, /left_legend, textcolors=0, font=1



;;;;;;;;;;;;;;;;;;;
;;GOES

print, "restoring '/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_GOES_collect.sav'..."
restore, '/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_GOES_collect.sav'

time_array=indgen(total_seconds+1)
goes_title='Simulated GOES Flux and Derivative'
plot, time_array, long, /NODATA, BACKGROUND=1, COLOR=0,  title=goes_title, xtitle='Time (s)', ytitle='Normalized Data', yrange=[0,1], CHARSIZE=1.4, FONT=1, CHARTHICK=2, POSITION=[0.05,0.05,0.95,0.4]
oplot, time_array, long/max(long), COLOR=2
Derived=DERIV(time_array, long)
oplot, time_array, derived/max(derived), COLOR=4
legend, ["GOES Flux","Derivative of GOES Flux"],outline_color=0,/top_legend,/right_legend,textcolors=0,font=1,LINESTYLE=[0,0],COLORS=[2,4]

!P.MULTI=0
device, /close
END
