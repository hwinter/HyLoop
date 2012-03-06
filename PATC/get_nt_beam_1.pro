function get_nt_beam_1, LOOP, dt, $
  CURRENT_BEAM=current_beam,$
  DEBUG=DEBUG

time=LOOP.state.time
if not keyword_set(DEBUG) then debug=0
n_beams=n_elements(!inject_beam)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Print statements for testing
if debug ge 1 then begin
    if !current_beam_index le n_elements(!inject_beam)-1UL then $
      print, 'Beam Time ',!inject_beam[!current_beam_index].time else $
      print, 'Beam Time ', !inject_beam[n_elements(!inject_beam)-1UL].time
    print, 'Loop time ', time
    help, CURRENT_BEAM
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Test to see if the system variables are set.
;If not then set them.
defsysv, '!current_beam_index',exists=test
if test ne 1 then defsysv, '!current_beam_index',0UL

defsysv, '!inject_beam',exists=test
if test ne 1 then begin
    MESSAGE, 'The function get_nt_beam_1 requires that the injected '$
            + 'beam is placed in the system variable !inject_beam'
    stop
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Main case statement.  The following algorithm decides whether to stay,
;  fold, or raise
case 1 of 
;We've run out of beams!
    !current_beam_index gt $
      n_beams-1UL: begin
        if debug ge 1 then $
          print, '!current_beam_index gt  n_elements(!current_beam_index)-1UL case'
        if size(current_beam, /TYPE) ne 8 then $
          out_beam=-1 else out_beam=Current_beam
    end
;The first beam! (If the beam switches on at 0)
    ((size(current_beam, /TYPE) ne 8)  and $
    (!inject_beam[!current_beam_index].time eq 0 )): begin
        if debug ge 1 then $
          print, 'first beam case'
        out_beam=!inject_beam[!current_beam_index].nt_beam  
        !current_beam_index+=1
    end
;Time to switch on another beam.
    (time+dt ge !inject_beam[!current_beam_index].time): begin
        if debug ge 1 then $
          print, 'Beam switch case'
        done=0
        while not done do begin
            
            if size(current_beam, /TYPE) ne 8 then $
              out_beam=!inject_beam[!current_beam_index].nt_beam else $
              out_beam=concat_struct(current_beam, $
                                     !inject_beam[!current_beam_index].nt_beam)
            !current_beam_index = !current_beam_index +1UL
            case 1 of 
                !current_beam_index gt n_beams-1UL : done =1
                !inject_beam[!current_beam_index].time ge time+dt :done =1
                else:
            endcase

            endwhile
    end
;If all else fails, return the input beam, or a -1 if there are no other beams
    else :begin
        if debug ge 1 then $
          print, 'else case'
        if size(current_beam, /TYPE) ne 8 then $
          out_beam=-1 else out_beam=Current_beam
    end
    
endcase



end_jump:
;help, out_beam
;print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
return, out_beam

END

