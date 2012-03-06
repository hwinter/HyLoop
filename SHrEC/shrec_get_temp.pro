;get the loop temperature on the volume grid

function shrec_get_temp,state

T = state.e/(3*state.n_e*!shrec_kB)

return, abs(T)

end
