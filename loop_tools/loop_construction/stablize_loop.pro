function stablize_loop, old_loop,T0=T0,  src=src, uri=uri, fal=fal, $
                        safety= safety , $ ;SHOWME=SHOWME, DEBUG=DEBUG   , $
                        QUIET=QUIET, HEAT_FUNCTION=HEAT_FUNCTION,$
                        PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, $
                        MAX_STEP=MAX_STEP, FILE_EXT=FILE_EXT, $
                        grid_safety= grid_safety,$ ; ,regrid=REGRID , $
                        E_H=E_H, FILE_PREFIX=OUTPUT_PREFIX,$
                        NOVISC=NOVISC, T_MAX=T_MAX ;,DEPTH=depth

loop=old_loop



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Start equilibrium section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
equil_counter=1
done=0
max_v=1d7

max_time=105d0*60d0*60d0          ;Time to allow loop to come to equilibrium
rtime=10d0*60d0                      ;Output timestep
DELTA_T=30d0                     ;reporting  timestep

If not keyword_set(HEAT_FUNCTION) then begin
   heat_function_in='get_p_t_law_const_flux_heat'
   flux=get_p_t_law_flux(loop.l, 0.0,T_MAX)
   defsysv, '!constant_heat_flux', flux
endif else heat_function_in=HEAT_FUNCTION

SHOWME=1
NO_SAT=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;stop
while done le 0 do begin

    n_loop=n_elements(Loop)
    temp_loop=loop[n_loop-1l]
    hyloop ,temp_loop, $
                    rtime, DELTA_T=DELTA_T, $ ;
                    T0=T0,  src=src, uri=uri, fal=fal, $
                    safety= safety , SHOWME=SHOWME, DEBUG=DEBUG   , $
                    QUIET=QUIET, HEAT_FUNCTION=heat_function,$
                    PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, $
                    MAX_STEP=MAX_STEP, FILE_EXT='stable', $
                    grid_safety= grid_safety,$; ,regrid=REGRID , $
                    E_H=E_H, FILE_PREFIX=OUTPUT_PREFIX,$
                    NOVISC=1, NO_SAT=NO_SAT; , depth=2d6, slide_CHROMO=1, $
            no_sat=1
    
    loop=temp_loop
;Determine the maximum veloxity
    max_v=max(abs(loop.state.v))
    if max_v le 2d5  then done =1 else done =0

        print, 'Min/Max velocity:'
        pmm,abs(loop.state.v)
        
        if equil_counter eq 400 then done=1
        if done le 0 then begin
;Artificially smooth
;            for j=0,10 do loop.state.e=smooth(loop.state.e,3)
;Artificially smooth the velocity
;            for j=0,10 do loop.state.v=smooth(loop.state.v,3) 
        endif
        equil_counter +=1
    if loop.state.time gt max_time then done=1
endwhile

loop.state.time=0d



return, loop

END









