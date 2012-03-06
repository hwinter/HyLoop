function get_b_crit, E

if size(E, /TYPE) eq 0 then E=15d0

b_crit=(!shrec_qe*!shrec_qe)/(E*!shrec_KEV_2_ERGS)


return, b_crit


end
