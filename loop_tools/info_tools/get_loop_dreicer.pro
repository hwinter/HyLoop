;+
; NAME:
;	get_loop_sptizer_conductivity
;
; PURPOSE:
;	Calculate the Spitzer Harm electrical conductivity, in ESU, along a loop structure
;
; CATEGORY:
;	HyLoop
;
; CALLING SEQUENCE:
;	sigma=get_loop_spitzer_conductivity(loop)
;
; INPUTS:
;	Loop structure
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	Spitzer Harm electrical conductivity, in ESU
;
; OPTIONAL OUTPUTS:
;	Temperature along the loop (T)
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
; Using the equation for the Spitzer Harm resistivity as show in eq
; 13.27 of The Physics of Fluids and Plasmas, Choudhuri(1998)	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by:Henry "Trae" D. Winter III 2011-09-13

function get_loop_dreicer, loop, T=T

  Version=1.0	
;-

;Boltzmann's constant in ergs/[K]
  k_boltz_ergs=1.3807d-16

;Charge on an electron in statcoulombs
  e=4.8032d-10

  coulomb_log=get_loop_coulomb_log(loop, T=T)
  
  debye_length=((k_boltz_ergs*T)/ $
                (4d*!dpi*e^2d))^0.5d
  E_Dreicer=!shrec_qe*coulomb_log/(Debye_length*Debye_length)
  
  return, E_Dreicer
end
