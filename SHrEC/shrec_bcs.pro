;+
; NAME:
;	shrec_bcs.pro
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
; 	Written by:	HDWIII 2007-APR-20.  Based on programs written by 
;                             Charles Kankelborg and Rebecca McMullen
;-


;----- Boundary Conditions (same each time applied) -------------------
function shrec_bcs, state,g, T0, ds2, is
COMPILE_OPT STRICTARR

;calculate rho (mass density) on v grid
rho = !shrec_mp* (state.n_e[0:is-1] + state.n_e[1:is])/2.0

state.v[0] = 0.0 ;no flow
state.v[is-1] = 0.0 ;no flow

state.e[0] = state.e[1] - $
	1.5*rho[0]*g[0]*ds2[0] ;zero force
state.e[is] = state.e[is-1] + $
	1.5*rho[is-1]*g[is-1]*ds2[is-1] ;zero force

state.n_e[0] = state.e[0]/(3.0*!shrec_kB*T0) ;constant temperature
state.n_e[is] = state.e[is]/(3.0*!shrec_kB*T0) ;const. temperature

return, state
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
