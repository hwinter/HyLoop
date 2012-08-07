

pro temp_plot_sup, $
   PLOT_SECS=plot_secs,$
   INITIAL_PARAMETERS=initial_parameters,$
   TOTAL_RUNS=total_runs,$
   TOTAL_SECONDS=total_seconds,$
   RUN_FORMAT=run_format,$
   DATA_FOLDER=data_folder,$
   PLOT_FOLDER=plot_folder, $
   TITLE=title,$
   NO_Y=no_y,$
   NO_X=no_X,$
   SAVE_FOLDER=save_folder,$
   LEGEND=legend,$
   DENSE=dense,$
NT=NT, gpp=gpp

help, extra
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



  FILENAME=SAVE_FOLDER+initial_parameters+'_temps_dens.sav'
  restore, FILENAME



;plot_title=Initial_parameters+' Temperature over Length'
  x_title="Distance along Loop (cm)"
  y_title="Mega Kelvin"
  yrange=[0,33]
  if keyword_set(DENSE) then begin
print, "keyword is set"
     temps=alog10(density)
   y_title="Log (Density)"
    yrange=[8,9.5]
  endif


  if keyword_set(NO_X) then $
     x_title=''
  if keyword_set(NO_Y) then $
     y_title=''

  tvlct, fsc_color(["lawn green", "purple", "red", "blue", 'dark green'],/TRIPLE),100
  tvlct, fsc_color(/triple),1
  tvlct, fsc_color('black',/triple),0


colors=fsc_color(["lawn green", "purple", "red", "blue", 'dark green'])
if not keyword_set(DENSE) then begin
;if keyword_set(NT) then yrange=[0,6e6]

  plot, length/1d8, temps[0,*]/1d6, /NODATA, BACKGROUND=1, COLOR=0, XRANGE=[0, max(length)/1d8],YRANGE=yrange,  $
        CHARSIZE=1.5, FONT=1, CHARTHICK=1.5, YTITLE=y_title, /ystyle,xticks=1,/xstyle,xtickv=[37., 75], $
        thick=3.5, _extra=gpp, title=title; XTITLE=x_title, YTITLE=y_title, title=title

  increment=20
  start_t=20
  t=start_t
  for j=0, 4 do begin

     oplot, length/1d8, temps[t, *]/1d6, COLOR=colors[j]
    ; print, 'plotting temps', t


     t=t+increment


  endfor                        ;temps
endif else begin

;if keyword_set(NT) then yrange=[0,6e6]

   plot, length/1d8, temps[0,*], /NODATA, BACKGROUND=1, COLOR=0, XRANGE=[0, max(length)/1d8],YRANGE=yrange,  $
        CHARSIZE=1.5, FONT=1, CHARTHICK=1.5, YTITLE=y_title, /ystyle,xticks=1,/xstyle,xtickv=[37., 75], $
        thick=3.5, _extra=gpp, title=title; XTITLE=x_title, YTITLE=y_title, title=title

  increment=20
  start_t=20
  t=start_t
  for j=0, 4 do begin

     oplot, length/1d8, temps[t, *], COLOR=colors[j]
    ; print, 'plotting temps', t


     t=t+increment


  endfor                        ;temps
endelse


  if keyword_set(Legend) then $
     legend,['Time='+string(start_t,'(I02)'),'Time='+string(start_t+increment,'(I02)'),$
             'Time='+string(start_t+2*increment, '(I02)'),$
             'Time='+string(start_t+3*increment, '(I02)'),$
             'Time='+string(start_t+4*increment, '(I03)')],$
            outline_color=0,/top_legend,/right_legend,textcolors=0,font=1,LINESTYLE=[0,0,0,0,0],COLORS=colors, charsize=0.7

END
