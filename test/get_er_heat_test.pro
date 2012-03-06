
;Choose a .loop file to restore
file='/Users/winter/Data/PATC/runs/2007_JUN_11e/T=3.0e+06K_L=3.0e+09cm_D=1.0e+07cm_Alpha=0.0_Beta=0.0_00001.loop'

restore, file

;set atomic physics keywords
;SRC option engages the 'shiny red chromosphere'
;   feature: radiative loss rate at T < T0
;   is set to zero, producing a chromosphere
;   of uniform temperature.
DEFSYSV, '!SRC',1
;URI - Values above 1e5 K based on recalculation of the
;    Cook et al. (1989 ApJ 338:1176) radiative loss
;    using the Feldman (1992 Phys Scr 46:202-220) coronal
;    abundances.
DEFSYSV, '!URI',1;
;FAL - Values from 1e4 K to 1e5 K based on fig. 2 of E. H. 
;    Avrett in _Mechanisms of Chromospheric and Coronal 
;    Heating_, P. Ulmschneider, E. R. Priest, & R. Rosner 
;    Eds., Springer Verlag (1991), pp.97-99. This is 
;    based on the FAL transition region model, including 
;    corrections for optical depth and ambipolar 
;    diffusion. [An added point at 1e3 K merely 
;    extrapolates the radiative loss to arbitrarily
;    low temperature.]
DEFSYSV, '!FAL', 1
is = n_elements(loop.state.e)-1l

heat=msu_radloss(LOOP.state.n_e[1:is-1],$
                            T[1:is-1],T0=T0,$
                            src=src,uri=uri,fal=fal,$
                            SO=SO )
E_H=get_er_heat(LOOP, loop.state.time, 5d-5, SO=SO)


plot, loop.s_alt[1:is-1]
;calcu
