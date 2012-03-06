
;Get the volumes for the grids, except for the first and last one
;[cm^3]
function get_loop_vol,loop, TOTAL=TOTAL	
;loop=loop[n_elements(loop)-1ul]	

N=n_elements(loop[0].s)

vol=0.5*(loop.a[0:N-2] +loop.a[1:N-1]) * (loop.s[1:N-1] - loop.s[0:N-2])

TOTAL=total(vol,1)

return,vol

end
