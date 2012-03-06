;.r nano_gauss_test

;You won't have to do this section because you have a loop structure
; with s defined.
;Length of loop

length=1d9; 10 Megameters
;Constant cross-sectional area.
diameter=1d8
;Number of nano flares
n_flares=200

Fraction_part=0.75
;Guassian FWHM for the nanoflares
nano_fwhm=2d7 ;2d5 meters, 200 km
;Number of s elements
n_s=(500ul)
mk_semi_circular_loop, diameter,length, $
                           T_MAX=1d6, N_DEPTH=20,$
                           TO=1d4,$
                           nosave=1, n_cells=n_s, sigma=2, loop=loop

vols=get_loop_vol(loop, total=total_volume)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
total_flux=1d24; ergs  s-1
total_flux=get_p_t_law_flux(length, 0,1d6)
print, total_flux
heating_rate=(total_flux/length)*total_volume
heating_rate_therm=(1.0-Fraction_part)*heating_rate
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Now make the nanoflares
s_flares=randomu(seed,n_flares)*length

s_flares>=loop.s[loop.n_depth+1]
s_flares<=loop.s[n_s-loop.n_depth]

;s_flare_index=where(abs(s_flares-loop.s_alt) eq min( abs(s_flares-loop.s_alt) ) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

e_h_thermal=get_nfe_gauss_dist(loop, s_flares,heating_rate_therm/n_flares, nano_fwhm )

plot, loop.s, e_h_thermal, xtitle='s [cm]', ytitle='e_h'

print, total(e_h_thermal*vols), total(heating_rate_therm)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




END




