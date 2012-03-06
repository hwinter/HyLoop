;get the loop temperature on the volume grid

function msu_get_temp,state

T = state.e/(3*state.n_e*!msul_kB)

return, abs(T)

end
