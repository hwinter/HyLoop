 pro particle_display, loop,E_min,E_max, $
   NT_BEAM=NT_beam,$
   WINDOW=WINDOW, $
   XSIZE=XSIZE, YSIZE=YSIZE, $
   GIF=GIF, PLOT_TITLE=PLOT_TITLE,$
   RUN_FOLDER=RUN_FOLDER, CHARSIZE=CHARSIZE ,$
   CHARTHICK=CHARTHICK,
 
;emission_display_script.pro
IF not keyword_set(PLOT_TITLE) then plot_title='Model Loop Sim'
IF not keyword_set(XSIZE) then xsize=600 
IF not keyword_set(YSIZE) then ysize=600 
IF not keyword_set(CHARSIZE) then CHARSIZE=1.5
IF not keyword_set(CHARTHICK) then CHARTHICK=1.5

plot,loop[n_loop-1l].axis[1,*],loop[n_loop-1l].axis[2,*]+loop[n_loop-1l].rad,THICK=3 , $
     TITLE=plot_title,CHARSIZE=1.2,CHARTHICK=1.2 
oplot,loop[n_loop-1l].axis[1,*],loop[n_loop-1l].axis[2,*],linestyle=2    
oplot,loop[n_loop-1l].axis[1,*],loop[n_loop-1l].axis[2,*]-loop[n_loop-1l].rad,linestyle=0,THICK=3 

loadct,color_table,/silent

legend, Ticknames,psym=syms, $
        colors=[reverse(color_factor*(energies)+color_offset),255]$
        ,charsize=1.5,charthick=1.5
legend,['Time= '+string(0d,format='(d8.3)')+' sec'],$
       box=0,/right,charsize=1.5,charthick=1.5
for beam_index=0, n_elements(nt_beam)-1 do begin
    
    position_index=long(where(abs(nt_beam[beam_index].x-loop[n_loop-1l].s) eq $
                              min(abs(nt_beam[beam_index].x-loop[n_loop-1l].s))))
    
    plots,loop[n_loop-1l].AXIS[1,position_index[0]] ,$
          vary[beam_index]*2d0* $
          loop[n_loop-1l].RAD[position_index[0]]+(loop[n_loop-1l].AXIS[2,position_index[0]] $
                                                  -loop[n_loop-1l].RAD[position_index[0]]), $
          psym=8, $
          color=color_factor*(nt_beam[beam_index].ke_total),$
          SYMSIZE=1,THICK=2
    
endfor                          ;


end
