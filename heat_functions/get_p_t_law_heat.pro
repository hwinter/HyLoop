;+
; NAME:
;	get_p_t_law_heat
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

function get_p_t_law_heat, LOOP, time, dt, $
                           dummy1,dummy2, dummy3,dummy4,$
                           dummy5,dummy6,dummy7,$
                           ALPHA_in=ALPHA_in, BETA_in=BETA_in, $
                           P_0_in=P_0_in, TMAX_in=TMAX_in

n_loops=n_elements(loop)-1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
T=get_loop_temp(loop[n_loops])
P=get_loop_pressure(loop[n_loops])
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine if the parameters have been set via system variables.
;Exponent of the temperature dependance.
DEFSYSV, '!heat_alpha', EXISTS = test1
;Default to the Joule heating case
if test1 eq 1 then alpha=!heat_alpha  $
else begin
    if not keyword_set(alpha_in) then $
      alpha=-3d/2d else alpha=alpha_in
endelse

;Exponent of the pressure/density dependance.
DEFSYSV, '!heat_beta', EXISTS = test2
;Default to no pressure dependence case
if test2 eq 1 then  beta=!heat_beta $
else begin
    if not keyword_set(beta_in) then  $
      beta=0 else  beta=beta_in
endelse
;Test to see if the user has defined a constant 
;  pressure to be used in calculating the heat scaling.
DEFSYSV, '!heat_P_0', EXISTS = test2a
;Default to the average pressure.
if test2a eq 1 then  P_0=!heat_P_0 $
else begin
    if not keyword_set(P_0_in) then $
      P_0=mean(p) else P_0=P_0_in
endelse
;Radiative losses power law exponent.
DEFSYSV, '!rad_law_gamma', EXISTS = test3
;Default to rad_law_gamma=0.5
;  a la Martens et al,2000
if test3 ne 1 then  rad_law_gamma=0.5d $
  else rad_law_gamma=!rad_law_gamma

;Radiative losses constant of proportionality.
DEFSYSV, '!rad_chi_0', EXISTS = test4
;Default to rad_chi_0=1d12.41
;  a la Martens et al,2000
if test4 ne 1 then rad_chi_0=10^12.41 $
  else rad_chi_0=!rad_chi_0

;What do you want Tmax to be?
DEFSYSV, '!heat_Tmax', EXISTS = test5
if test5 eq 1 then Tmax=!heat_Tmax $
  else begin
    if not keyword_set(TMAX_in) Then $
      tmax=loop.t_max else Tmax=TMAX_in
    endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n_cells=n_elements(loop[n_loops].state.n_e)
;volumes =get_loop_vol(loop[n_loops])
;power=total(heat_rate*volumes)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Heating rate to scale to.
H=((P_0^(-beta+2d0))*rad_chi_0*(alpha+3.5d0))$
  /((Tmax^(rad_law_gamma+alpha+2d0))*(-rad_law_gamma+1.5d0))

heat=H*(P[1:n_cells-2]^beta)*(T[1:n_cells-2]^alpha)

;stop
return, heat
END
