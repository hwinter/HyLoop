function get_loops_avg_p, loops, STD_DEV=STD_DEV, VARIANCE=VARIANCE

n_loops=n_elements(loops)

;Q for quantity to make copying and pasting easier.
Q=get_loop_pressure(loops)

mean_Q=total(q, 2)/n_loops

n_elem=n_elements(mean_Q[*,0])
mQ2=rebin(mean_Q,n_elem,  n_loops)

VARIANCE=(1d0/(n_loops-1ul))*$
         total((Q-mQ2)*(Q-mQ2), 2)

STD_DEV=sqrt(VARIANCE)


return, mean_Q


END
