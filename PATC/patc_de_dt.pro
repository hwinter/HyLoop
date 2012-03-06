
function patc_de_dt, t , e_n_vp, dl, dens,m,charge,a,b, $
                     ln_lambda_in=ln_lambda_in,  Coul_out=Coul_out
;print, '::::::::::::::::::::::::::::::::::'
;help,t, e_n_vp[0], dl, dens,m,z,a,b
;See my notes from Jan 18, 2008 for derivation and 
;  Deviation from   Emslie, 1978
v_total=energy2vel(e_n_vp[0])
v_squared=v_total*v_total
A_factor=(4d0*!dpi*dens*v_squared)
;Reduced mass with electrons as the target particles.
mu_e=(m*!shrec_me)/(m+!shrec_me)
zeta_e=((!shrec_qe*charge)/(mu_e*v_squared))^2d0
xi_e=(5d-1)*(zeta_e)*alog(1d0+((dl*dl)/zeta_e))
;Reduced mass with protons as the target particles.
mu_p=(m*!shrec_mp)/(m+!shrec_mp)
zeta_p=(!shrec_qe*charge/(mu_p*v_squared))^2d0
xi_p=(5d-1)*(zeta_p)*alog(1d0+(dl*dl/zeta_p))
Coul_out=[alog(1d0+((dl*dl)/zeta_e)),alog(1d0+(dl*dl/zeta_p)) ]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Random element Number of electron collisions to proton collisions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
de_dt=-A_factor*v_total*(((a*(mu_e*mu_e)/!shrec_me) $
                          *(xi_e)) $
                         +((b*(mu_p*mu_p)/!shrec_mp) $
                           *xi_p))
;help, de_dt
de_dt=de_dt/!shrec_keV_2_ergs  
;help, de_dt

dvp_dt=-(A_factor/m)* $
       ((mu_e*xi_e)+(mu_p*xi_p))

;stop
;print, '::::::::::::::::::::::::::::::::::'
return, [de_dt, dvp_dt]
;stop
end
