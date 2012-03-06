;get the loop coordinate on the volume grid

function get_loop_s_alt,loop, GT0=GT0,NO_BOUNDARY=NO_BOUNDARY
n_loops=n_elements(loop)
N_s=n_elements(loop[n_loops-1ul].s)	
s=loop[n_loops-1ul].s
s_alt = [2*s[0]-s[1],(s[0:N_s-2]+s[1:N_s-1])/2.0,2*s[N_s-1]-s[N_s-2]]

IF KEYWORD_SET(GT_0) THEN s_alt =s_alt > 0d
if keyword_set(NO_BOUNDARY) then s_alt =s_alt[1:N_s]


return, s_alt

end
