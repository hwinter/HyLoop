;.r get_xr_test
file=getenv('PATC')+'/patc_test_000010.loop'

restore, file



emiss=get_xr_emiss(loop, nt_brems)

end
