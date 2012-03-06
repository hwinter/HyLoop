;Estimated heating [erg cm^-3 s^-1] needed to give a 
; loop of a certain length [L [cm]], a certain Tmax[K]

function get_serio_heat, L,Tmax	

;Estimated using scaling laws from Serio et al. 1981 ApJ 243:288
heat = 9.14d-7 * Tmax^3.51d * (L/2d)^(-2d) ;scaling law

return, heat

end
