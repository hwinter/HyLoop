;+
; NAME:
;     set_cck_radloss.pro	
;
; PURPOSE:
;	To set the environmental variable that defines the radiatve
;	losses as a function of temperature as set by Kankelborg, C.,
;	and D. Longcope, 
;       Forward modeling of the coronal response to reconnection in an
;       X-ray bright point,  Solar Phys., 190, 59–77, doi:10.1023/A:1005205807984, 1999. 
;       
;------ VAU radiative loss function (1979 ApJ 233:987) ------
;
; CATEGORY:
;	Radiative losses
;       Loop modeling
; CALLING SEQUENCE:
;	set_cck_radloss
;
; INPUTS:
;	None
;
; OPTIONAL INPUTS:
;	None
;	
; KEYWORD SWITCHES:
;	FAL - Values from 1e4 K to 1e5 K based on fig. 2 of E. H. 
;		Avrett in _Mechanisms of Chromospheric and Coronal 
;		Heating_, P. Ulmschneider, E. R. Priest, & R. Rosner 
;		Eds., Springer Verlag (1991), pp.97-99. This is 
;		based on the FAL transition region model, including 
;		corrections for optical depth and ambipolar 
;		diffusion. [An added point at 1e3 K merely 
;		extrapolates the radiative loss to arbitrarily
;		low temperature.]
;	URI - Values above 1e5 K based on recalculation of the
;		Cook et al. (1989 ApJ 338:1176) radiative loss
;		using the Feldman (1992 Phys Scr 46:202-220) coronal
;		abundances.
;	
;
; OUTPUTS:
;	!msul_rad_loss - A [N,2] matrix where !msul_rad_loss[*,0] are
;                        a range of  log temperatures and
;                        !msul_rad_loss[*,1] are the radiation losses
;                        (log(lambda)) for each temperature where
;                        10^log(lambda) is in ergs cm3 s^-1

;
; OPTIONAL OUTPUTS:
;	None
;
; COMMON BLOCKS:
;	None
;
; SIDE EFFECTS:
;	None known
;
; RESTRICTIONS:
;	?
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	set_cck_radloss
;
; MODIFICATION HISTORY:
; 	Written by: CCK originally made the radiative loss curve as a
; 	part of dstate.pro.
;       2009-04-29 HDWII: present form.
;       	
;-

pro set_cck_radloss, URI=URI, FAL=FAL
COMPILE_OPT STRICTARR

;(1) Transition region:
if keyword_set(FAL) then begin
	logT = [3.0d, 4.000, 4.165, 4.380, 4.520, 4.645, 4.905, 5.000]
        logL = [-28d,-23.54d,-22.79,-21.73,-21.36,-21.20,-21.31,-21.38]
endif else begin  ;VAU transition region
	logT = [3.0d, 4.0, 4.19, 4.50, 5.0]
        logL = [-28d, -23.03d, -21.65, -21.90, -21.19]
endelse


;(2) Append the Corona:
if keyword_set(Uri) then begin
	logT = [logT, 5.3d, 5.7, 6.0, 6.3, 6.7, 7.0]
        logL = [logL, -21.39, -20.99, -20.98, -21.64, -22.37, -22.27]
endif else begin  ;VAU corona
	logT = [logT, 5.40d, 5.80, 6.30, 7.50, 8.00]
        logL = [logL, -21.202d, -21.900, -21.939, -22.735,- 22.589]
endelse

defsysv, '!msul_rad_loss', [[logT],[logL]]



END ;Of main
