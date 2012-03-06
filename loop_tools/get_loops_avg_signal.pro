;Working
function get_loops_avg_signal,$
  loops,nt_brems_array, STD_DEV=STD_DEV, VARIANCE=VARIANCE
E_RANGE=[3.,6.]
n_loops=n_elements(loops)


signal= get_xr_emiss(loops[0],nt_brems_array[*,0], $
                             E_RANGE=E_RANGE,NT_ONLY=1)

signal=total(signal,2)
;Too sloppy
for i=1ul, n_loops-1ul do begin
    temp=get_xr_emiss(loops[i],nt_brems_array[*,i], $
                             E_RANGE=E_RANGE,NT_ONLY=1)
    
    temp=total(temp,2)
    signal=[[signal],[temp]]
endfor
;Q for quantity to make copying and pasting easier.
Q=signal

mean_Q=total(q, 2)/n_loops

n_elem=n_elements(mean_Q[*,0])
mQ2=rebin(mean_Q,n_elem,  n_loops)

VARIANCE=(1d0/(n_loops-1ul))*$
         total((Q-mQ2)*(Q-mQ2), 2)

STD_DEV=sqrt(VARIANCE)


return, mean_Q


END
