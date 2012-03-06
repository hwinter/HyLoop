function get_nt_beam2, LOOP, dt, current_beam=current_beam,$
  debug=debug


time=LOOP.state.time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Test to see if the System variables are set.
;If not then set them
defsysv, '!current_beam_index',exists=test
if test ne 1 then defsysv, '!current_beam_index',0UL

defsysv, '!inject_beam',exists=test
if test ne 1 then begin
    MESSAGE, 'The function get_nt_beam_1 requires that the injected ' + $
             'beam is placed in the system variable !inject_beam'
    stop
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Test to see if it is time to inject more particles

;Only need to to this if we are not yet at the end of the beam
;  injection time.
if !beam_switch_on_time le 0 then  $
  out_beam=!inject_beam[!current_beam_index].nt_beam else begin  
    

    out_beam=concat_struct(current_beam, $
                           !inject_beam[!current_beam_index].nt_beam)


endelse    
new_index= !current_beam_index +1UL
if new_index gt N_ELEMENTS(!inject_beam)-1ul then $
  !beam_switch_on_time=1d+10 else begin
    !current_beam_index =new_index
    !beam_switch_on_time= !inject_beam[!current_beam_index].time
endelse

return, out_beam

END
