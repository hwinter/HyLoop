;get the loop DEM on the volume grid

function get_loop_dem,loop, T=T	

;loop=loop[n_elements(loop)-1ul]
if not keyword_set(T) then T = get_loop_temp(loop)

dT_ds=deriv(loop.s_alt,T)

DEM=loop.state.n_e*loop.state.n_e/abs(dT_ds)

return, dem


end
