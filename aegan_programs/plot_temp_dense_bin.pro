;Used to generate temp and em movies



set_plot, 'x'
!P.MULTI=[0,2,1]

plot_title=Initial_parameters+' Temperature over Length'
x_title="Length (Megameters)"
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
bins=699
bins=indgen(bins+1)
for t=0, total_seconds do begin
;wdef, 0, 2000,1000

Initial_parameters='pa_4_nt_100_bt_2min'
FILENAME='/Volumes/Herschel/aegan/Data/saved2/'+initial_parameters+'_temps_dens.sav'
restore, filename

plot, length/1e8, temps[t,*]/1e6, BACKGROUND=1, COLOR=0, XRANGE=[0, max(length)/1e8],YRANGE=[0,25],TITLE='Temperature', XTITLE=x_title, YTITLE='Temperature (Megakelvin)', CHARSIZE=3, FONT=1, CHARTHICK=1.5, POSITION=[0.05,0.1,0.45,0.9],psym=0, thick=3
temp_comp=temps[t,1:698:5]
temp_dev_comp=temp_dev[t,1:698:5]
errplot, length[1:698:5]/1e8, (temp_comp-temp_dev_comp)/1e6,(temp_comp+temp_dev_comp)/1e6, color=2
print, 'plotting temps', t
legend,[initial_parameters],outline_color=0, /top_legend, /left_legend, textcolors=0, font=1, charsize=3, charthick=1.5

INITIAL_PARAMETERS='pa_4_nt_75_bt_2min'
FILENAME='/Volumes/Herschel/aegan/Data/saved2/'+initial_parameters+'_temps_dens.sav'
restore, filename

plot, length/1e8, temps[t,*]/1e6, BACKGROUND=1, COLOR=0, XRANGE=[0, max(length)/1e8],YRANGE=[0,25],TITLE='75% Non-Thermal', XTITLE=x_title, YTITLE='Temperature (Megakelvin)', CHARSIZE=3, FONT=1, CHARTHICK=1.5,  POSITION=[0.55,0.1,0.95,0.9],psym=0, thick=3
temp_comp=temps[t,1:698:5]
temp_dev_comp=temp_dev[t,1:698:5]
errplot, length[1:698:5]/1e8, (temp_comp-temp_dev_comp)/1e6,(temp_comp+temp_dev_comp)/1e6, color=2

print, 'plotting temps', t
legend,[initial_parameters],outline_color=0, /top_legend, /left_legend, textcolors=0, font=1, charsize=3, charthick=1.5

;; plot, length/1e8, alog10(density[t,*]), BACKGROUND=1, COLOR=0, XRANGE=[0, max(length)/1e8], YRANGE=[8,9.5],TITLE='Density', XTITLE=x_title, YTITLE='Log (Density)', CHARSIZE=3, FONT=1, CHARTHICK=1.5, POSITION=[0.55,0.1,0.95,0.9],psym=0, thick=3
;; dens_high=alog10(density[t,*]-dens_dev[t,*])
;; dens_low=alog10(density[t,*]+dens_dev[t,*])
;; errplot, length[1:698:5]/1e8, dens_high[1:698:5], dens_low[1:698:5],color=2, width=0.005



legend,["Time="+string(t, '(I04)')],outline_color=0, /top_legend, /right_legend, textcolors=0, font=1, charsize=3, charthick=1.5

print, 'plotting densities',t
;oplot, length[1:698], alog10(density[t,*])      , COLOR=101
;$mkdir '/Volumes/Herschel/aegan/plots/bin_movie/'
image_file='/Volumes/Herschel/aegan/plots2/bin_movie/'+initial_parameters+'_temp_temp_plot_'+string(t, '(I03)')+'.png'
write_png,image_file, tvrd(/TRUE)

endfor ;j

END
