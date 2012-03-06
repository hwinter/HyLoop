data_dir=getenv('DATA')
file=data_dir+'/PATC/runs/2006_JUN_19/full_test_2.sav'
;restore, file

E_max=max(beam_struct.e_beam.ke_total)
for i=0L, n_elements(beam_struct)-1L do begin
    NT_beam=beam_struct[i].e_beam
    time=beam_struct[i].time
    in_loop=loop[i]
    particle_display, in_loop,NT_beam,E_min=E_min,E_max=E_max, $
                      WINDOW=WINDOW, $
                      XSIZE=XSIZE, YSIZE=YSIZE, $
                      GIF=GIF, PLOT_TITLE=PLOT_TITLE,$
                      RUN_FOLDER=RUN_FOLDER, CHARSIZE=CHARSIZE ,$
                      CHARTHICK=CHARTHICK,TIME=TIME,$
                      DIVISIONS=DIVISIONS
endfor 




end
