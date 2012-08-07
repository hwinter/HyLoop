;Used to generate temp and em movies



FILENAME='/Volumes/Herschel/aegan/Data/saved2/'+initial_parameters+'_temps_dens.sav'
restore, filename

set_plot, 'x'
!P.MULTI=[0,2,1]

plot_title=Initial_parameters+' Temperature over Length'
x_title="Distance along Loop (cm)"
y_title="Temperature (K)"

                                ;if keyword_set(density) then begin
                                ;FILENAME='/Volumes/Herschel/aegan/plots/'+initial_parameters+'_dens_plot.ps'
                                ;plot_title=Initial_parameters+' Density over Length'
                                ;y_title="Logarithmic Density along loop (electrons/cm^-3) "
                                ;endif


tvlct, fsc_color(["lawn green", "purple", "red", "blue", 'dark green'],/TRIPLE),100
tvlct, fsc_color(/triple),1
tvlct, fsc_color('black',/triple),0

;total_seconds=size(temps, /n_elements)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;TEMPS

for t=0, total_seconds do begin
;wdef, 0, 2000,1000

plot, length, temps[t,*], BACKGROUND=1, COLOR=0, XRANGE=[0, max(length)],YRANGE=[0,2e7],TITLE='Temperature', XTITLE=x_title, YTITLE='Degrees Kelvin', CHARSIZE=3, FONT=1, CHARTHICK=1.5, POSITION=[0.05,0.1,0.45,0.9]

;oplot, length, temps[t, *], COLOR=100
print, 'plotting temps', t
legend,[initial_parameters],outline_color=0, /top_legend, /left_legend, textcolors=0, font=1, charsize=3, charthick=1.5




plot, length[1:698], alog10(density[t,*]), BACKGROUND=1, COLOR=0, XRANGE=[0, max(length)], YRANGE=[8,9.5],TITLE='Density', XTITLE=x_title, YTITLE='Log Density', CHARSIZE=3, FONT=1, CHARTHICK=1.5, POSITION=[0.55,0.1,0.95,0.9]



legend,["Time="+string(t, '(I04)')],outline_color=0, /top_legend, /left_legend, textcolors=0, font=1, charsize=3, charthick=1.5

print, 'plotting densities',t
;oplot, length[1:698], alog10(density[t,*])      , COLOR=101

image_file='/Volumes/Herschel/aegan/plots/temp_movie/'+initial_parameters+'_temp_dens_plot_'+string(t, '(I03)')+'.png'
write_png,image_file, tvrd(/TRUE)

endfor ;j

END


