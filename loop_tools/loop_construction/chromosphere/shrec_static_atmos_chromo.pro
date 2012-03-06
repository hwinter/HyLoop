function shrec_static_atmos_chromo, loop,$
                                    T0=T0, DS2=DS2, IS=IS
;Plane parallel atmosphere model at constant temperature (T0)
;It maintains the 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check and set keywords 
;need to fix the finding of indices so that it works from Z and not z_alt
  if not keyword_set(T0) then T_0=1d4 else T_0=T0
;From Mariska 1987 DOI10.1086/165471"
;  if not keyword_set(P0) then P_0=0.25 else P_0=P0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interpolate the z axis on the volume grid
  z_alt= shrec_get_s_alt(reform(loop.axis[2,*]), /GT0)

  ind=where(loop.s_alt le loop.depth)
  max_ind=max(ind)
  dz=z_alt[ind]-z_alt[max_ind+1]

  p_chromo=loop.P_BC*(exp((-1d0*!shrec_mp*abs(loop.g[ind])*dz)/(!shrec_kB*T_0)))

;Remembering that n_p~n_e and P=nkT
  n_e_add=p_chromo/(2d0*!shrec_kB*T_0)
  loop.state.n_e[ind]=n_e_add
;E=3/2*n*kb*T
  loop.state.e[ind]=3.*n_e_add*!shrec_kB *T_0
  
  ind=where(max(loop.s_alt)-loop.s_alt le loop.depth)

  min_ind=min(ind)
  dz=z_alt[ind]-loop.axis[2,min_ind-1]
  p_chromo=loop.P_BC*(exp((-1d0*!shrec_mp*abs(loop.g[ind])*dz)/(!shrec_kB*T_0)))
;Remembering that n_p~n_e and P=nkT
  n_e_add=p_chromo/(2d0*!shrec_kB*T_0) 
  loop.state.n_e[ind]=n_e_add 
;E=3/2*n*kb*T
  loop.state.e[ind]=3.*n_e_add* !shrec_kB*T_0

  loop=set_loop_bcs(loop, T0=T_0, DS2=DS2, IS=IS)

  return, loop
END
