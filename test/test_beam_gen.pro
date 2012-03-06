
patc_dir=getenv('DATA')
patc_dir=patc_dir+'/PATC/'


file=patc_dir+'/runs/2006_JUN_23/full_test_2.sav'
restore, file
RESOLVE_ROUTINE,'beam_generator',/IS_FUNCTION

Beam_Energy=1d30
n_PART=1d5
E_min_max=[25,200]
beam=beam_generator(loop,E_min_max, total_energy=Beam_Energy, $
                    SPEC_INDEX=3, time=2, delta_t=.5,$
                    IP='z',n_PART=n_PART)


print, 'Energy Test: '+string( Beam_Energy/$
                               (total(beam.nt_beam.ke_total*$
                                    beam.nt_beam.scale_factor )))

print, 'PA Test: '+string(Where(finite(beam.nt_beam.pitch_angle) ne 1))

window,0

fdf=flux_dist_func( beam[0].nt_beam, loop[0],energies, v)
plot, energies, fdf, XTITLE='',$
      YTITLE='N cm!E-2!n s!E-1!N',$
      TITLE='Flux Distribution Function', $
      /YLOG, /XLOG

for i=1ul, n_elements(beam)-1ul do begin
    symbol = i mod 4
    fdf=flux_dist_func( beam[i].nt_beam, loop[0],energies, v)
    oplot, energies, fdf, psym=symbol
    
    
endfor


END
