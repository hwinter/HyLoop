function get_chromo_mass_flux, loop

mass_flux=loop.state.n_e[loop.n_depth]*loop.state.v[loop.n_depth]

return, mass_flux
END
