;Compute the over (under if less than one) pressure of a loop based on
;the RTV 1978 scaling laws.

function get_loop_overpressure, loop
  compile_opt STRICTARR
  rtv_pressure=get_loop_rtv_pressure(loop)
  
  pressure=get_loop_pressure(loop)

  max_z=where(loop.axis[2,*] eq max(loop.axis[2,*]))

  overpressure=pressure[max_z[0]]/rtv_pressure

  return, overpressure

END ;of main
