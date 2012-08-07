ssw_packages, /xray

.compile reu_2011_pre_mk_pa_4_nt_75_bt_2min.pro
.compile pt_with_patc 
.compile pt_with_patc_gaussian_apex_heating
.compile get_p_t_law_const_flux_heat
resolve_all
save, /ROUTINES , FILE='reu_2011_pre_mk_pa_4_nt_75_bt_2min'+'.sav'
