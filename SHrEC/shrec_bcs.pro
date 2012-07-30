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
;                  HDWIII 2012-07-29: Changed the boundary conditions
;                  so that a constant n_e is kept on the bottom of the
;                  chromosphere.  This is either a) set by the user
;                  via keyword b) set via a system variable or c) set
;                  to a default value of 1d11
;-


;----- Boundary Conditions (same each time applied) -------------------
function shrec_bcs, state,g, T0, ds2, is, N_E0=N_E0
  COMPILE_OPT STRICTARR

  if not keyword_set(N_E0) then begin
     defsysv, '!N_E0',exists=test
     if test le 0 then N_E0_in=1d11 else N_E0_in=!N_E0
  endif else N_E0_in=N_E0

;Set the BC density
  state.n_e[0] =N_E0_in; state.e[0]/(3.0*!shrec_kB*T0) ;constant temperature
  state.n_e[is] = N_E0_in; state.e[is]/(3.0*!shrec_kB*T0) ;const. temperature
;Set the BC velocities
  state.v[0] = 0.0              ;no flow
  state.v[is-1] = 0.0           ;no flow



;Set the no conduction BCs (Not sure about this
;formulation.)
  state.e[1] = state.e[0]
  state.e[is-1] = state.e[is]
;Old
;  state.e[0] = state.e[1] - $
;               1.5*rho[0]*g[0]*ds2[0] ;zero force
;  state.e[is] = state.e[is-1] + $
;                1.5*rho[is-1]*g[is-1]*ds2[is-1] ;zero force


  return, state
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
