function shrec_static_constant_pressure_chromo, loop,$
                                    T0=T0, DS2=DS2, IS=IS
;Constant pressure.  Not constant temperature.  Where does the extra
;mass come from?  Magic!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check and set keywords 
;need to fix the finding of indices so that it works from Z and not z_alt
  if not keyword_set(T0) then T_0=1d4 else T_0=T0
;From Mariska 1987 DOI10.1086/165471"
;  if not keyword_set(P0) then P_0=0.25 else P_0=P0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interpolate the z axis on the volume grid
  z_alt= shrec_get_s_alt(reform(loop.axis[2,*]), /GT0)
  Temperature=get_loop_temp(loop)
  ind=where(loop.s_alt le loop.depth)
  max_ind=max(ind)
  dz=z_alt[ind]-z_alt[max_ind+1]

  p_chromo=loop.P_BC*(dblarr(n_elements(ind))

;Remembering that n_p~n_e and P=nkT
  n_e_add=p_chromo/(2d0*!shrec_kB*Temperature[ind])
  loop.state.n_e[ind]=n_e_add
;E=3/2*n*kb*T
  loop.state.e[ind]=(3./2.) *2.*n_e_add*!shrec_kB *Temperature[ind]
  
  ind=where(max(loop.s_alt)-loop.s_alt le loop.depth)

  p_chromo=loop.P_BC*(dblarr(n_elements(ind))`
;Remembering that n_p~n_e and P=nkT
  n_e_add=p_chromo/(2d0*!shrec_kB*Temperature[ind]) 
  loop.state.n_e[ind]=n_e_add 
;E=3/2*n*kb*T
  loop.state.e[ind]=(3./2.) *2.*n_e_add* !shrec_kB*Temperature[ind]

  loop=set_loop_bcs(loop, T0=T_0, DS2=DS2, IS=IS)

  return, loop
END
