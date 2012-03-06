function get_nt_beam, LOOP, dt, current_beam

time=LOOP.state.time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Test to see if the System variables are set.
;If not then set them
defsysv, '!current_beam_index',exists=test
if test ne 1 then defsysv, '!current_beam_index',0UL

defsysv, '!inject_beam',exists=test
if test ne 1 then begin
    MESSAGE, 'The function get_nt_beam_1 requires that the injected '$
             'beam is placed in the system variable !inject_beam'
    stop
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Test to see if it is time to inject more particles

;Only need to to this if we are not yet at the end of the beam
;  injection time.
if ((size(current_beam, /TYPE) eq 0)  and $
    (!inject_beam[!current_beam_index].time eq 0 )) then $
  out_beam=!inject_beam[!current_beam_index].nt_beam

if !current_beam_index lt n_elements(!inject_beam)-2UL then begin
   
        if time+dt ge !inject_beam[!current_beam_index+1ul].time then begin
        
            !current_beam_index = !current_beam_index +1UL
            if size(current_beam, /TYPE) eq 0 then $
              out_beam=!inject_beam[!current_beam_index].nt_beam else $
              out_beam=concat_struct(current_beam, $
                                     !inject_beam[!current_beam_index].nt_beam)
            

        endif
    endif
defsysv, '!beam_switch_on_time', 
    
return, out_beam

END
