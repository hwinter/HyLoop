function get_loop_rtv_pressure, loop


;Based on RTV 1978 eq. 4.3
l_half=loop.l/2.0

max_T=max(get_loop_temp(loop))
pressure=((max_T/1400.)^3.0)*(1.0/l_half)


return, pressure

end
