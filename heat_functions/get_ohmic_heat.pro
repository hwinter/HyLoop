;+
; NAME:
;	get_ohmic_heat
;
; PURPOSE:
;	Calculate a heating rate based on Martens' power law heating functions,
;        E_h=H*(T^alpha)*(P^beta), where the constant of proportionality, H,
;        is not based on Martens (2007) but on the amount of energy deposited
;        in a loop based upon Serio's scaling laws (Serio, et al.1981)
;
; CATEGORY:
;      Heat_function	
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
; 	Written by:HDWII
;-

function get_ohmic_heat, LOOP, time, dt, $
  J=J, ETA_0=ETA_0

COMPILE_OPT  STRICTARR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n_loops=n_elements(loop)-1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;From Choudhuri, p. 265
if not keyword_set(ETA_0) then eta_0=7.3d-9
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine if the parameters have been set via system variables.
;[statamp cm^-2]. Should be either n_cells-2 or a scalar.
DEFSYSV, 'Current_density', EXISTS = test1
;Default to the Joule heating case
if test1 eq 1 then j =!Current_density  $
else begin
    if not keyword_set(j) then $
      j=7.1d6
endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n_cells=n_elements(loop[n_loops].state.n_e)

T=get_loop_temp(loop[n_loops])
c_log=get_loop_coulomb_log( loop,T=T)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Heating rate to scale to.
H=eta_0*c_log*j*j

heat=H*(T[1:n_cells-2]^(-1.5d0))

;stop
return, heat
END
