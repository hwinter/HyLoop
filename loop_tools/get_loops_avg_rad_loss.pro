function get_loops_avg_rad_loss, loops, STD_DEV=STD_DEV, VARIANCE=VARIANCE,$
                                 _EXTRA=EXTRA

n_loops=n_elements(loops)

;Q for quantity to make copying and pasting easier.

t=get_loop_temp(loops)
Q=shrec_radloss(loops.state.n_e, T, _EXTRA=EXTRA)


mean_Q=total(q, 2)/n_loops
n_elem=n_elements(mean_Q[*,0])
mQ2=rebin(mean_Q,n_elem,  n_loops)

VARIANCE=(1d0/(n_loops-1ul))*$
         total((Q-mQ2)*(Q-mQ2), 2)

STD_DEV=sqrt(VARIANCE)


return, mean_Q

;stop
END
