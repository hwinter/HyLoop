;Heating function for the case where E_H=E_R
function get_er_heat, LOOP, time, dt, nt_beam, nt_brems,$
  PATC_heating_rate, extra_flux, $
  DELTA_MOMENTUM,flux, ne_change
;Constants
;NONE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check the state of global varibles set
;SRC option engages the 'shiny red chromosphere'
;   feature: radiative loss rate at T < T0
;   is set to zero, producing a chromosphere
;   of uniform temperature.
DEFSYSV, '!SRC', EXISTS = test1
if test1 eq 1 then SRC= !SRC
;URI - Values above 1e5 K based on recalculation of the
;    Cook et al. (1989 ApJ 338:1176) radiative loss
;    using the Feldman (1992 Phys Scr 46:202-220) coronal
;    abundances.
DEFSYSV, '!URI', EXISTS = test2;
if test2 eq 1 then URI= !URI
;FAL - Values from 1e4 K to 1e5 K based on fig. 2 of E. H. 
;    Avrett in _Mechanisms of Chromospheric and Coronal 
;    Heating_, P. Ulmschneider, E. R. Priest, & R. Rosner 
;    Eds., Springer Verlag (1991), pp.97-99. This is 
;    based on the FAL transition region model, including 
;    corrections for optical depth and ambipolar 
;    diffusion. [An added point at 1e3 K merely 
;    extrapolates the radiative loss to arbitrarily
;    low temperature.]
DEFSYSV, '!FAL', EXISTS = test3
if test3 eq 1 then FAL= !FAL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;index of last volume gridpoint
is = n_elements(loop.state.e)-1l
T=get_loop_temp(loop[0])
heat=msu_radloss(LOOP.state.n_e[1:is-1],$
                            T[1:is-1],T0=T0,$
                            src=src,uri=uri,fal=fal,$
                            SO=SO )

;stop
return, heat
END
