;get the loop EM on the volume grid

function get_loop_em,loop, T=T, VOL=VOL
;loop=loop[n_elements(loop)-1ul]
	
N=n_elements(loop[0].state.n_e)

vol=get_loop_vol(loop)
EM=alog10(loop.state.n_e[1:N-2])+alog10(loop.state.n_e[1:N-2])+alog10(vol)

;if keyword_set(T) then begin
;Calculate the temperature array to go with em
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    T = get_loop_temp(loop)
    T=T[1:n-2l,*]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;endif

;stop
return, em

end
