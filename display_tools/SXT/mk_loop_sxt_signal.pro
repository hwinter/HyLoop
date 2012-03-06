;Use only one loop at a time

function mk_loop_xrt_signal,loop, nt_brems, $
  FILTER_INDEX=FILTER_INDEX,$
  Al_mesh=Al_mesh,$
  Al_poly=Al_poly,$
  C_poly=C_poly,$
  Ti_poly=Ti_poly,$
  Be_thin=Be_thin,$
  Be_med=Be_med,$
  Al_med=Al_med,$
  Al_thick=Al_thick,$
  Be_thick=Be_thick,$
  Al_p_Al_m=Al_p_Al_m,$
  Al_p_Ti_p=Al_p_Ti_p,$
  Al_p_Al_t=Al_p_Al_t,$
  Al_p_Be_t=Al_p_Be_t,$
  C_p_Ti_p=C_p_Ti_p,$
  C_p_Al_t=C_p_Al_t,$
  specfile=specfile, $
  UNITS=UNITS, $
  SPEC_RESP=SPEC_RESP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UNITS='DN cm^2 s^-1 pix^-1'

if not keyword_set(FILTER_INDEX) then begin
    case 1 of
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;Al_poly is the default
        keyword_set(Al_poly) : filter_index=1    
        keyword_set(Al_mesh) : filter_index=0
        keyword_set(C_poly) :  filter_index=2
        keyword_set(Ti_poly) : filter_index=3
        keyword_set(Be_thin) : filter_index=4
        keyword_set(Be_med) :  filter_index=5
        keyword_set(Al_med) :  filter_index=6
        keyword_set(Al_thick) : filter_index=7
        keyword_set(Be_thick) : filter_index=8
        keyword_set(Al_p_Al_m): filter_index=9
        keyword_set(Al_p_Ti_p): filter_index=10
        keyword_set(Al_p_Al_t): filter_index=11
        keyword_set(Al_p_Be_t): filter_index=12
        keyword_set(C_p_Ti_p): filter_index=13
        keyword_set(C_p_Al_t): filter_index=14
    else:filter_index=1
endcase
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set(EMISS) then goto, wave_resp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loop_size=size(loop)
n_loops=loop_size[1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;Get the volume emission measure [cm^3] and temperatures {log K]
em=get_loop_em(loop,VOL=vol, t=loop_temp)

signal=dblarr(n_elements(em[*,0]))
CASE 1 OF 
    NOT keyword_set(SPEC_RESP) :begin
   
;Get the xrt temperature response function
        defsysv, '!xrt_tresp', exists=test
        if test lt 1 then $
          defsysv, '!xrt_tresp',CALC_XRT_TEMP_RESP( specfile=specfile)
        
        
        loop_index=sort(loop_temp,/L64)
        
        resp_index=where(!xrt_tresp[filter_index].TEMP gt 0, $
                         resp_i_count)
        
        signal[loop_index]=em[loop_index]* $
                           (spline(!xrt_tresp[filter_index].TEMP[resp_index],$
                                   !xrt_tresp[filter_index].TEMP_RESP[resp_index], $
                                   loop_temp[loop_index]))
    ;stop
        
        signal=abs(signal)
        bad_index=where(loop_temp lt min(!xrt_tresp[1].TEMP[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
        
        help, bad_index
        
        bad_index=where(loop_temp gt max(!xrt_tresp[1].TEMP[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
        
    end
    else:begin
        
        signal=emiss*
        
        
    end
endcase


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end_jump:
return, signal

end
