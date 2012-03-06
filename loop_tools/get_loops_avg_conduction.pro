function get_loops_avg_conduction, loops, STD_DEV=STD_DEV, VARIANCE=VARIANCE,$
                                 _EXTRA=EXTRA

n_loops=n_elements(loops)

;Q for quantity to make copying and pasting easier.
;Q=loops.e_h
q=shrec_conduction(loops[0].state, loops[0].s,loops[0].A, _EXTRA=EXTRA)
Q=dblarr(n_elements(q), n_loops)
for i=0ul, n_loops-1 do begin
   Q[*,i]=shrec_conduction(loops[i].state, loops[i].s,loops[i].A, _EXTRA=EXTRA)
endfor

mean_Q=total(q, 2)/n_loops
n_elem=n_elements(mean_Q[*,0])
mQ2=rebin(mean_Q,n_elem,  n_loops)

VARIANCE=(1d0/(n_loops-1ul))*$
         total((Q-mQ2)*(Q-mQ2), 2)

STD_DEV=sqrt(VARIANCE)


return, mean_Q

;stop
END
