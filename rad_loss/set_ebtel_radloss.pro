;+
; NAME:
;     set_ebtel_radloss.pro	
;
; PURPOSE:
;	To set the environmental variable that defines the radiatve
;	losses as a function of temperature as used by the EBTEL code
;	circa 2009.  As provided by James Klimchuk.
;
; CATEGORY:
;	Radiative losses
;       Loop modeling
; CALLING SEQUENCE:
;	set_ebtel_radloss
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
;	!msul_rad_loss - A [2,N] matrix where !msul_rad_loss[0,*] are
;                        a range of  log temperatures and
;                        !msul_rad_loss[1,*] are the radiation losses
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
;	set_ebtel_radloss
;
; MODIFICATION HISTORY:
; 	Written by:  2009-04-29 HDWII: Interpreted from an email by
; 	James Klimchuk.
;       	
;-

pro set_ebtel_radloss, RTV=RTV
COMPILE_OPT STRICTARR

;DEFINE TEMPERATURE ARRAY
N=50.
temp_array=10^( 4.0+4.0*(dindgen(N)/(N-1.0)))
rad_loss_array=temp_array

;At some point I should vectorize the next step.
for i=0ul, N-1 do begin
   tt=temp_array[i]
   tt2=tt
; Radiation function temperature breaks
   
   if not keyword_set(rtv) then begin
;    Raymond-Klimchuk loss function
      kt0 = 1.e4
      kt1 = 9.3325e4
      kt2 = 4.67735e5
      kt3 = 1.51356e6
      kt4 = 3.54813e6
      kt5 = 7.94328e6
      kt6 = 4.28048e7
      
   endif else begin
;    RTV loss function
      kt0 = 10.^4.3
      kt1 = 10.^4.6
      kt2 = 10.^4.9
      kt3 = 10.^5.4
      kt4 = 10.^5.75
      kt5 = 10.^6.3
   endelse


; Radiation

   if not keyword_set(rtv) then begin
;       Raymond-Klimchuk loss function
      if (tt gt kt6) then rad = 1.96e-27*sqrt(tt) else $
         if (tt gt kt5) then rad = 5.4883e-16/tt else $
            if (tt gt kt4) then rad = 3.4629e-25*(tt^(0.3333333)) else $
               if (tt gt kt3) then rad = 3.5300e-13/(tt^(1.5)) else $
                  if (tt gt kt2) then rad = 1.8957e-22 else $
                     if (tt gt kt1) then rad = 8.8669e-17/tt else $
                        if (tt gt kt0) then rad = 1.0909e-31*tt*tt $
                        else                rad =1.0909e-31*tt*tt
      
   endif else begin
;       RTV loss function
      if (tt gt kt5) then rad = 10^(-17.73)/tt^(.666) else $
         if (tt gt kt4) then rad = 10.^(-21.94) else $
            if (tt gt kt3) then rad = 10.^(-10.4)/(tt*tt) else $
               if (tt gt kt2) then rad = 10.^(-21.2) else $
                  if (tt gt kt1) then rad = (1d-31)*(tt*tt) else $
                     if (tt gt kt0) then rad = 10^(-21.85) $
                     else                rad =10^(-21.85)
   endelse
   rad_loss_array[i]=rad
   
endfor

defsysv, '!msul_rad_loss', [[alog10(temp_array)],[alog10(rad_loss_array)]]



END ;Of main
