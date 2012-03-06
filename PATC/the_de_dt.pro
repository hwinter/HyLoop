



function patc_de_dt, t , e_n_vp, dl, dens,m,c
;See my notes from Jan 18, 2008 for derivation and 
;  Deviation from   Emslie, 1978
v_total=energy2vel(e_n_vp[0])
v_squared=v_total*v_total
A_factor=(4d0*!dpi*dens*v_squared)
a=1
b=1
;Reduced mass with electrons as the target particles.
        mu_e=(m*!shrec_me)/(m+!shrec_me)
        zeta_e=!shrec_qe*c/(mu_e*v_squared)
        xi_e=mu_e*zeta_e*zeta_e*alog(dl/zeta_e)
;Reduced mass with protons as the target particles.
        mu_p=(m*!shrec_mp)/(m+!shrec_mp)
        zeta_p=!shrec_qe*c/(mu_p*v_squared)
        xi_p=mu_p*zeta_p*zeta_p*alog(dl/zeta_p)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Random element Number of electron collisions to proton collisions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        de_dt=-A_factor*v_total*(((a*mu_e/!shrec_me) $
                                  *xi_e) $
                                 +((b*mu_p/!shrec_mp) $
                                   *xi_p))/!shrec_keV_2_ergs  

        dvp_dt=-(A_factor/m)* $
               (xi_e+xi_p)
return, [de_dt, dvp_dt]
end
