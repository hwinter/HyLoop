;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-Eulerian time stepper (result is change in state variable)
;      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function shrec_dstate3, state, T, g, A, s, heating, dt, T0, $
                        src, depth, safety, uri, fal, $
                        DEBUG=DEBUG,$
                        SO=SO, $
                        NO_SAT=NO_SAT,$
                        NOVISC=NOVISC, mu=mu, $
                        Coulomb_log=Coulomb_log, $
                                ;CONDUCTION=CONDUCTION, $
                        DN_E=DN_E, $
                        E_FLUX=E_FLUX, $
                        ADVECT_WORK=ADVECT_WORK, $
                        CONDUCTION=CONDUCTION, $
                        RADIATIVE_LOSS=RADIATIVE_LOSS,$
                        DE=DE, DIV_V=DIV_V, DV=DV,$
                        VISC0=VISC0, K2=K2,$
                        MFP=MFP,$
                        L_T=L_T, $
                        CONSTANT_CHROMO=CONSTANT_CHROMO, $
                        SLIDE_CHROMO=SLIDE_CHROMO
  
  
  common loopmodel, ds1, ds2, A1, is
;ds1: valid indices run from 0 to is-2 (volume grid), missing ends
;ds2:ds1 interpolated onto the s grid, ends extrapolated
;A1: Area interpolated on the volume grid.
;is; index of last volume gridpoint

;Force proper (), [] syntax
  COMPILE_OPT STRICTARR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Test and set keyword switches. 
  if not keyword_set(DEBUG) then DEBUG=0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;useful thermodynamic quantities (e/n_e grid)
  P = (2.0/3.0)*state.e
;temperature interpolated to the surface grid
  T2 = (T[0:is-1] + T[1:is])/2.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;calculate rho (mass density) on surface grid
  rho = !shrec_mp * (state.n_e[0:is-1] + state.n_e[1:is])/2.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;set boundary conditions
  state=shrec_bcs(state, g, T0, ds2, is)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Upwind differencing stuff
  vpos = float(state.v gt 0.0)
  vneg = not vpos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;***** Continuity equation (n_e) *****
;Scheme rigorously conserves mass.
  mass_flux = A * vpos * state.v * state.n_e[0:is-1] + $
              A * vneg * state.v * state.n_e[1:is]
  dn_e = - (dt/A1)* $
         (mass_flux[1:is-1] - mass_flux[0:is-2])/ds1
  dn_e = [0.0,dn_e,0.0]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;***** Internal energy equation (e) *****
;Note: Advection uses a conservative form.
;Advection and work:
  e_flux = A * vpos * state.v * state.e[0:is-1] + $
           A * vneg * state.v * state.e[1:is]

  advect_work = -(dt/(A1*ds1)) * $
                ( e_flux[1:is-1] - e_flux[0:is-2] ) $ ;advection
                -(dt*P[1:is-1]/(A1*ds1)) * $
                ((A[1:is-1]*state.v[1:is-1]) -( A[0:is-2]*state.v[0:is-2])) ;work
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
  conduction = SHREC_conduction(state, s, a, $
                                SO=SO, $ ;Pass the SO for C codes if desired
                                IS=is, $
                                DT=dt, $
                                DS1=ds1, $
                                DS2=ds2, $
                                TEMP=TEMP,$
                                S_GRID_TEMP=S_GRID_TEMP,$
                                SPIT=SPIT,$
                                NO_SAT=NO_SAT,$
                                A1=A1,$
                                coulomb_log=coulomb_log,$
                                K2=K2,$
                                MFP=MFP,$
                                L_T=L_T)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate volumetric radiative losses
  radiative_loss=-shrec_radloss(state.n_e[1:is-1],T[1:is-1],T0=T0,$
                                src=src,uri=uri,fal=fal)*dt 	

;viscous energy loss Mu is passed in
;temp1 = 2.d0*(A[1:is-1ul]*state.v[1:is-1ul] $
;              - A[0:is-2ul]*state.v[0:is-2ul]) / $
;        (ds1[0:is-2ul]*(A[1:is-1ul] + A[0:is-2ul]));

;visc0 = dt * mu[0:is] * [0d, (temp1)^2d0, 0d0] 
;d^2 v heats the plasma
;visc0 = dt * mu[1:is-1ul] * (temp1)^2d0 
  
;Round up all terms
  de = conduction[1:is-1] $
       + advect_work   $
       + radiative_loss $
       + heating*dt             ;$
                                ; + visc0
                                ; ;viscousity
  de=[0.0,de,0.0]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;***** Momentum equation (v) *****
  div_v = (state.v[1:is-1] - state.v[0:is-2])/ds1
  dv =    - (dt/rho) * (P[1:is] - P[0:is-1])/ds2 $ ;grad P
          - dt * state.v * $
          ( vpos * [0.0, div_v] + $
            vneg * [div_v, 0.0] ) $ ;advection
          + (dt*g)                  ; $;gravity
                                ;      + visc;Viscous term
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sliding Chromospheric/TR model based on McMullen 2001     
case 1 of     
   keyword_set(SLIDE_CHROMO): begin
;s on the volume element grid (like e, n_e)
        s_alt = [2*s[0]-s[1],(s[0:is-2]+s[1:is-1])/2.0,2*s[is-1]-s[is-2]]
;Length of the loop                                
        L = s[is-1] + s[0]         
;find location of transition region at bottom of each loop leg.
        ss = where(T ge 1.1*T0)
        n_ss = n_elements(ss)
        i0 = ss[0]>1 & i1 = ss[n_ss-1]<(is-3)
;     
        strength = (1.0/safety)*((depth - s_alt[i0])/depth)^3 $
                < 1.0/safety > (-1.0/safety) ;clamp density loss
;Relevant density scale
        nscale = 0.5*min(state.n_e[0:i0]) 
;Add density to the isotherm closest to the origin.
        dn_e[i0] = dn_e[i0] + nscale*strength
;Clamp density loss    
        strength = (1.0/safety)*((depth - (L - s_alt[i1]))/depth)^3 $
                   < 1.0/safety > (-1.0/safety) 
;New relevant density scale
        nscale = 0.5*min(state.n_e[i1:is])     
;Add density to the isotherm closest to the end.
        dn_e[i1] = dn_e[i1] + nscale*strength
     end
     else:
  endcase
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;stop
  return, {e:de, n_e:dn_e, v:dv}
;This is almost a state structure, just lacks the time tag
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
END ;Of MAIN
