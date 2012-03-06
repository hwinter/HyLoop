;.r test_regrid_fit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Loop Keywords
Tmax=3d6;K
Length=3d9 ;[cm],30 Mega meters
diameter =1d8 ;[cm]
depth=1d6
N_CELLS=500ul
n_depth=50ul
TO=1d4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Alpha=2.5d0
Beta=0.0d0
;This is proscribed in the next program.
heat_name='get_p_t_law_const_flux_heat'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mk_semi_circular_loop,diameter,length, $
  T_MAX=T_MAX, N_DEPTH=N_DEPTH,$
  TO=T0,$
  B_Mag=B_Mag,Q0=Q0,  nosave=nosave, $
  outname=outname,N_CELLS=N_CELLS,$
  X_SHIFT=X_SHIFT,Y_SHIFT=Y_SHIFT,$
  Z_SHIFT=Z_SHIFT, LOOP=LOOP,$
  DEPTH=DEPTH,$
  ADD_CHROMO=ADD_CHROMO,$
  SIGMA_FACTOR=SIGMA_FACTOR,$
  PSL=PSL, ALPHA=ALPHA, BETA=BETA



help, loop


end





