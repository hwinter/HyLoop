function stablize_loop, old_loop,T0=T0,  src=src, uri=uri, fal=fal, $
                        safety= safety , $ ;SHOWME=SHOWME, DEBUG=DEBUG   , $
                        QUIET=QUIET, HEAT_FUNCTION=HEAT_FUNCTION,$
                        PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, $
                        MAX_STEP=MAX_STEP, FILE_EXT=FILE_EXT, $
                        grid_safety= grid_safety,$ ; ,regrid=REGRID , $
                        E_H=E_H, FILE_PREFIX=FILE_PREFIX,$
                        NOVISC=NOVISC, T_MAX=T_MAX , CLEANUP=CLEANUP,DELTA_T=DELTA_T;,DEPTH=depth

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set keywords

  If not keyword_set(HEAT_FUNCTION) then begin
     heat_function_in='get_p_t_law_const_flux_heat'
     flux=get_p_t_law_flux(old_loop.l, 0.0,T_MAX)
     defsysv, '!constant_heat_flux', flux
  endif else heat_function_in=HEAT_FUNCTION

  if size(FILE_PREFIX, /TYPE) ne 7 then OUTPUT_PREFIX='stable_' $
  else OUTPUT_PREFIX=FILE_PREFIX

  if not keyword_set(DELTA_T) then DELTA_T=30d0                  ;reporting  timestep
  
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  equil_counter=1
  done=0
  max_v=1d7

  max_time=105d0*60d0*60d0      ;Time to allow loop to come to equilibrium
  rtime=10d0*60d0               ;Output timestep
  DELTA_T=30d0                  ;reporting  timestep

  SHOWME=1
  NO_SAT=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;stop
  old_loop=old_loop[0]
  while done le 0 do begin

     hyloop ,old_loop, $
             rtime, DELTA_T=DELTA_T, $ ;
             T0=T0,  src=src, uri=uri, fal=fal, $
             safety= safety , SHOWME=SHOWME, DEBUG=DEBUG   , $
             QUIET=QUIET, HEAT_FUNCTION=heat_function_in,$
             PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, $
             MAX_STEP=MAX_STEP, FILE_EXT=OUTPUT_FILE_EXT, $
             grid_safety= grid_safety,$ ; ,regrid=REGRID , $
             E_H=E_H, FILE_PREFIX=OUTPUT_PREFIX,$
             NOVISC=1, NO_SAT=NO_SAT ; , depth=2d6, slide_CHROMO=1, $
     
     n_loop=n_elements(old_loop)
     old_loop=old_loop[n_loop-1l]
;Determine the maximum veloxity
     max_v=max(abs(old_loop.state.v))
     if max_v le 2d5  then done =1 else done =0

     print, 'Min/Max velocity:'
     pmm,abs(old_loop.state.v)
     
     if equil_counter eq 400 then done=1
     if done le 0 then begin
     endif
     equil_counter +=1
     if old_loop.state.time gt max_time then done=1
  endwhile

  old_loop.state.time=0d

  if keyword_set(CleanUp) then $
     spawn, 'rm '+FILE_PREFIX+'*'+OUTPUT_FILE_EXT

  return, old_loop

END









