;test_beam_func
patc_dir=getenv('PATC')
resolve_routine,'get_nt_beam_1',/EITHER
loop_file=patc_dir+'/test/a_2.0_b0_00001.loop'
inj_beam_file= patc_dir+'/test/injected_beam.sav'

restore,loop_file
restore, inj_beam_file

COMPILE_OPT STRICTARR
 print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
 print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
 print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
 print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'

times = (2.5d0)*dindgen(100)/99d
dt=times[1]-times[0]
nt_beam=1
defsysv,'!inject_beam',injected_beam
;If not then set them
defsysv, '!current_beam_index',exists=test
if test ne 1 then $
  defsysv, '!current_beam_index',0UL 


!current_beam_index=0UL
for i=0, n_elements(times)-1UL do begin
    if !current_beam_index le n_elements(!inject_beam)-1UL then $
      print, 'Beam Time ',!inject_beam[!current_beam_index].time else $
      print, 'Beam Time ', !inject_beam[n_elements(!inject_beam)-1UL].time
    
    loop.state.time=times[i]
    print, 'times[i]' , times[i] ,', i',i
   ; help
    nt_beam= get_nt_beam_1(LOOP, dt, current_beam=nt_beam)
    help, nt_beam
 print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'

endfor




END
