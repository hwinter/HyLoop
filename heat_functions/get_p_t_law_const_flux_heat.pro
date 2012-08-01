;+
; NAME:
;	get_p_t_law_const_flux_heat
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

function get_p_t_law_const_flux_heat, LOOP, time, dt, $
  nt_beam, nt_brems, PATC_heating_rate, extra_flux, $
  DELTA_MOMENTUM,flux, ne_change, NO_CHROMO=NO_CHROMO


PATC_heating_rate=0d0
extra_flux=0d0
DELTA_MOMENTUM=0d0
n_loops=n_elements(loop)-1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
T=get_loop_temp(loop[n_loops])
P=get_loop_pressure(loop[n_loops])
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine if the parameters have been set via system variables.
;Exponent of the temperature dependance.
DEFSYSV, '!heat_alpha', EXISTS = test1
if test1 ne 1 then  alpha=0 $
  else alpha=!heat_alpha

;Exponent of the pressure/density dependance.
DEFSYSV, '!heat_beta', EXISTS = test2
;Default to no pressure dependence case
if test2 ne 1 then  beta=0 $
  else beta=!heat_beta

;This heating function requires a definition of a constant heat
; flux.
DEFSYSV, '!constant_heat_flux', EXISTS = test3
if test3 ne 1 then begin
    message, 'The heating function get_p_t_law_const_flux_heat.pro ' $
              +'requires the prior definition of the system variable ' $
              +'!constant_heat_flux.'
    stop
endif   else F_alpha=!constant_heat_flux

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
T=get_loop_temp(loop)
P=get_loop_pressure(loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
coronal_cells=get_loop_coronal_cells(loop, count=n_corona)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The power law which is used a couple of timesloop.s_alt[coronal_cells]
power_law=(P[coronal_cells]^beta)*(T[coronal_cells]^alpha)
;Scaling factor
H=F_alpha/int_tabulated(loop.s_alt[coronal_cells],power_law,/DOUBLE)

heat=loop.e_h*0
heat[coronal_cells]=H*(power_law)
if not keyword_set(NO_CHROMO) then $
   heat=add_chromo_heat(loop, heat)

if max(heat) eq 0 then stop


return, heat
END
