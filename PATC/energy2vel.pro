;+
; NAME:
;	energy2vel
;
; PURPOSE:
;	Calculate an electron's or particle's speed based on 
;         its kinetic energy.  Relativistic effects are taken
;         into account for gamma =>1.2 
;
; CATEGORY:
;	Particle tools
;
; CALLING SEQUENCE
;	v=energy2vel(20)
;
; INPUTS:
;	Kinetic energy assumed to be in keV (see keywords)
;
; OPTIONAL INPUTS:
;	None
;	
; KEYWORD PARAMETERS:
;	PROTONS: Tells the program that the particles are protons
;       MASS:    the mass of the arbitrary particle
;       MEV:     Input units were in MeV instead of keV
;       ERGS:    Input units were in ergs instead of keV
;       JOULES:  Input units were in Joules instead of keV 
;       TOTAL_E: The input was the total energy of the particle
;                   not just the kinetic energy
;	
; OUTPUTS:
;	Speed in [cm/s]
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
;	None
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	 speed=energy2vel(510.984024555,total_e=1)
;
; MODIFICATION HISTORY:
; 	Written by: Henry (Trae) D. Winter III
;            2006_JULY_18 HDWIII Minor modifications and improvements	
;-


function energy2vel,energy,PROTONS=PROTONS,MASS=MASS, $
                    MEV=MEV, ERGS=ERGS, $
                    JOULES=JOULES, TOTAL_E=TOTAL_E
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;1 keV=1.602e-9 ergs
; converts keV to ergs
keV_2_ergs = 1.6022d-9
;Electron mass in grams
e_mass_g=9.1094d-28 
;Proton mass in grams
p_mass_g=1.6726d-24 
;Speed of light [cm/s]
c=(2.9979d10)
;Speed of light squared [cm/s]^2
c_2=c*c


Case 1 of
    keyword_set(PROTONS):  mass=p_mass_g
    keyword_set(MASS):  mass=MASS
    else: mass=e_mass_g
endcase

Case 1 of
    keyword_set(JOULES): begin
        E=Energy/keV_2_Joules
        E=Energy*keV_2_ergs
        end
    keyword_set(MEV):begin
        E=Energy*1d-3
        E=Energy*keV_2_ergs
        end
    keyword_set(ERGS):E=Energy
    else:E=Energy*keV_2_ergs
endcase

rest_energy=mass*c_2
gamma=energy2gamma(E,MASS=mass,/ERGS, TOTAL_E=TOTAL_E)

;if gamma le 1.2 then begin
;   
;    if keyword_set(TOTAL_E) then  v_total=sqrt((2*(energy-rest_energy))/mass) $ 
;    else v_total=sqrt((2*energy)/mass)
;endif else begin
    if keyword_set(TOTAL_E) then v_total=c*((1d)-(((E-rest_energy)/ $
                                                  (rest_energy)+1d)^(-2d)))^(.5d) $
    else   v_total=c*((1d)-((E/(rest_energy)+1d)^(-2d)))^(.5d)
;endelse
return, v_total
end
