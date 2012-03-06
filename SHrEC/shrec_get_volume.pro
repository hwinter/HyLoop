
;Get the volumes for the grids, except for the first and last one
;[cm^3]
function shrec_get_volume,s,a, TOTAL=TOTAL	

N=n_elements(s)

vol=0.5*(a[0:N-2] +a[1:N-1]) * (s[1:N-1] - s[0:N-2])

TOTAL=total(vol)

return,vol

end
