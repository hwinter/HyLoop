

;+
; NAME:
;	set_loop_bcs.pro
;
; PURPOSE:
;	Impose boundary conditions on a loop
;
; CATEGORY:
;	
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	
;
; OPTIONAL OUTPUTS:
;	
;
; COMMON BLOCKS:
;	
;
; SIDE EFFECTS:
;	
;
; RESTRICTIONS:
;	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by:	HDWIII 2010-Sep-03.  Based on programs written by 
;                             Charles Kankelborg and Rebecca McMullen
;-


;----- Boundary Conditions (same each time applied)
;      -------------------
function set_loop_bcs,  loop, T0=T0, DS2=DS2, IS=IS

  COMPILE_OPT STRICTARR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Test and set keyword switches
  if not keyword_set(T0) then T_0=1d4 else T_0=T0

;index of last volume gridpoint
  if not keyword_set(is) then is_in = n_elements(loop.state.e)-1l $
  else is_in=is

  if not keyword_set(DS2) then begin
;valid indices run from 0 to is-2 (volume grid), missing ends
     ds1 = temp_loop.s[1:is-1]-temp_loop.s[0:is-2]
;ds1 interpolated onto the s grid, ends extrapolated.
     ds_2 = [ds1[0],(ds1[0:is-3] + ds1[1:is-2])/2.0, ds1[is-2]]
  endif else ds_2=DS2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;calculate rho (mass density) on v grid
  rho = !shrec_mp* (loop.state.n_e[0:is_in-1] + loop.state.n_e[1:is_in])/2.0

;no flow
  loop.state.v[0] = 0.0
  loop.state.v[is_in-1] = 0.0  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;zero force:  P0=P1
  loop.state.e[0] = loop.state.e[1] - $
                    1.5*rho[0]*loop.g[0]*ds_2[0]
  loop.state.e[is_in] = loop.state.e[is_in-1] + $
                        1.5*rho[is_in-1]*loop.g[is-1]*ds_2[is_in-1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;constant temperature
  loop.state.n_e[0] = loop.state.e[0]/(3.0*!shrec_kB*T_0) 
  loop.state.n_e[is_in] = loop.state.e[is_in]/(3.0*!shrec_kB*T_0)


  return, loop
end
