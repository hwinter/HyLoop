function get_loop_mass_flux, loop

n_vols=n_elements(loop.state.n_e)
density_on_v_grid=(loop.state.n_e[0:n_vols-2]+loop.state.n_e[1:n_vols-1])/2.

mass_flux=(!shrec_mp+!shrec_me)*density_on_v_grid*loop.state.v




return , mass_flux

END
