;get the loop temperature on the volume grid

function get_loop_temp,loop

T = loop.state.e/(3*loop.state.n_e*!shrec_kB)

return, abs(T)

end
