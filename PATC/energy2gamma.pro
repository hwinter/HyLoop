;+
; NAME:
;	energy2gamma
;
; PURPOSE:
;	Given the energy of a particle, determine the Lorentz gamma
;
; CATEGORY:
;	Particle tools
;
; CALLING SEQUENCE:
;	gamma=energy2gamma(Energy)
;
; INPUTS:
;	Energy:  Particle (assumed to be an electron) energy
;	(assumed to be in keV and assumed to be the kinetic energy) 
;
; OPTIONAL INPUTS:
;	None
;	
; KEYWORD PARAMETERS:
;	 KINETIC:  Tells the program that the energy given was only
;	         the kinetic energy of the particle  (Now the default.) 
;	 MEV: Energy is given in MeVs
;        ERGS: Energy is given in ergs
;        JOULES: Energy is given in joules
;        MASS:  Mass of the particle.  If not given, an electron mass
;                is assumed 
;        KG: Tells the program that we gave the mass in kg instead
;            of g
;        PROTON; Set mass for a proton's mass
;        TOTAL_E: The input was the total energy of the particle
;                   not just the kinetic energy
;
; OUTPUTS:
;	Dimensionless Lorentz gamma
;
; OPTIONAL OUTPUTS:
;	None
;
; COMMON BLOCKS:
;	None
;
; SIDE EFFECTS:
;	None
;
; RESTRICTIONS:
;	Will give you garbage output if the energy is less than the 
;         rest energy
;
; PROCEDURE:
;	Second year physics
;
; EXAMPLE:
;	gamma=energy2gamma(250)
;
; MODIFICATION HISTORY
; 	Written by: Henry (Trae) D. Winter III
;            2006_JULY_18 HDWIII Minor modifications and improvements	
;-


function energy2gamma, Energy, TOTAL_E=TOTAL_E, MEV=MEV, ERGS=ERGS, $
                     JOULES=JOULES,kinetic=kinetic,$
                     MASS=MASS, KG=KG, PROTON=PROTON


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;1 keV=1.602e-9 ergs
; converts keV to ergs
keV_2_ergs = 1.6022d-9
;converts keV to Joules
keV_2_Joules = 1.6022d-16

;Electron mass in grams
e_mass_g=9.1094d-28 
;Proton mass in grams
p_mass_g=1.6726d-24 
;Speed of light in a vacuum [c.g.s.]^2
c_squared=(2.9979d10)^2d

Case 1 of
    keyword_set(JOULES): E=Energy/keV_2_Joules
    keyword_set(MEV): E=Energy*1d-3
    keyword_set(ERGS):E =Energy
    else:E=Energy*keV_2_ergs
endcase

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the mass
case 1 of 
    KEYWORD_SET(PROTON): m=p_mass_g
    (KEYWORD_SET(MASS) AND (KEYWORD_SET(KG) LT 1)):m=MASS
    (KEYWORD_SET(MASS) AND KEYWORD_SET(KG)):m=MASS/1d-3
    else: m=e_mass_g
endcase

;help, e
;help, m
;help, c_squared
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate gamma

     if KEYWORD_SET(TOTAL_E) then gamma=(E/(m*c_squared)) $
        else gamma=(E/(m*c_squared))+1d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return,gamma

END
