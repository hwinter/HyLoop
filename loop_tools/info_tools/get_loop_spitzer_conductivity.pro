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

function get_loop_spitzer_conductivity, loop, T=T

Version=1.0	
;-

  coulomb_log=get_loop_coulomb_log(loop, T=T)
  
  sigma=(1.0/(7.3d-9))*(T^(3/2))*(1.0/coulomb_log)
  
  return, sigma
end
