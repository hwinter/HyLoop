restore,'/Users/winter/programs/PATC/runs/2005_12_1/full_test_2.sav'
set_plot,'x'
;old_beam_str=beam_struct
;beam_struct=old_beam_str
;if size(beam_struct,/type) ne 8 then $
;  restore, '/Users/winter/programs/PATC/runs/2006_AUG_17/loop_hist.sav'
;beam_struct=old_beam_str
scale_factor=1d31
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;1 keV=1.602e-9 ergs
; converts keV to ergs
loop=loop_struct.loop
keV_2_ergs = 1.6022d-9
;s_alt=get_loop_s_alt(loop.s)
;s_alt=s_alt[0:n_elements(s_alt)-2]
;if n_elements(beam_struct) ne n_elements(loop) then $
;  beam_struct=concat_struct(beam_struct[0], beam_struct)
;beam_struct[0].energy_profile[*]=0
;volumes=get_loop_vol(loop[0].x,loop[0].rad*loop[0].rad*!dpi)
;i=0
dt=lhist[1].time-lhist[0].time
for i=0, n_elements(beam_struct) do begin
;Cheat
    e_dep=abs(beam_struct[i].energy_profile*kev_2_ergs) $
          *scale_factor
    half_index=long(n_elements(e_dep)/2)
    e_dep=e_dep/(dt);*volumes)
    plot, loop[i].x,e_dep, psym=10,$
          TITLE='Energy Deposition',$
          YTITLE='ergs cm!E-3!N s!E-1!N',$
          XTITLE='Loop Coordinate [cm]',$
          thick=2, charthick=1.9, charsize=1.9,$
          xrange=[-1d8,8d9],/xstyle;,$
          ;yrange=[0,
          

    legend, 'Time:'+strcompress(string(lhist[i].time,$
                                       format='(d5.3)'), $
                                /remove_all),$
            BOX=0, charthick=1.9, charsize=1.9
    wait,5

ENDFOR


END
