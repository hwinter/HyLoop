;get the loop coordinate on the volume grid

function shrec_get_s_alt,s, GT0=GT0
N_s=n_elements(s)	
s_alt = [2*s[0]-s[1],(s[0:N_s-2]+s[1:N_s-1])/2.0,2*s[N_s-1]-s[N_s-2]]

IF KEYWORD_SET(GT_0) THEN s_alt =s_alt > 0d

return, s_alt

end
