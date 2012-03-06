function get_constant_heat, LOOP, time, dt, nt_beam, nt_brems,$
  PATC_heating_rate, extra_flux, $
  DELTA_MOMENTUM,flux, ne_change


DEFSYSV, '!bg_heat', EXISTS = test1

if test1 ne 1 then heat=0.0041809093d $
  else heat=!bg_heat

heat=heat+dblarr(n_elements(get_loop_vol(loop)))

return, heat
END
