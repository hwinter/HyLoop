function get_loop_cond_cts, loop, MIN=MIN
;Taken from the dissertation of Henry (Trae) Winter III page 40/
;Get the charateristic timescale of conduction along the loop.
T=get_loop_temp(loop)
ds=get_loop_ds(loop)


tau_cond=(4.14D-10)*loop.state.n_e*ds*ds/(T^(5.0/2.0))


if keyword_set(min) then tau_cond=min(tau_cond)

return, tau_cond

END
