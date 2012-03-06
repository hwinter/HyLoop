function get_loops_avg_v, loops, $
  STD_DEV=STD_DEV, VARIANCE=VARIANCE, SOUND=SOUND, MACH=MACH

n_loops=n_elements(loops)

;Q for quantity to make copying and pasting easier.
Q=loops.state.v

if keyword_set(SOUND) or keyword_set(MACH) then begin
    cs=GET_LOOP_CS(loops,S_grid=1)
    q=q/cs
endif

mean_Q=total(q, 2)/n_loops

n_elem=n_elements(mean_Q[*,0])
mQ2=rebin(mean_Q,n_elem,  n_loops)

VARIANCE=(1d0/(n_loops-1ul))*$
         total((Q-mQ2)*(Q-mQ2), 2)

STD_DEV=sqrt(VARIANCE)


return, mean_Q


END
