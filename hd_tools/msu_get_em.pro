function loop_em,s,a,state,DV=DV,T=T

;Volume Emission Measures

;Volume elements
dv=msu_get_volume(s,a)
n_cells= n_elements(state[0].n_e)
;Ignore 1st and last element.  They don't count (no surface fore and
;aft
;if n_elements(state) eq 1 then $
em=dv*(state.n_e[1:(n_cells-2l)])^2d $
;  else begin
;    em=dblarr( n_elements(state),n_elements(dv))
;    for i=0, n_elements(state)-1l do begin
;        em[i,*]=dv*(state[i].n_e[1:(n_cells-2l)])^2d
;    endfor
;endelse


;if keyword_set(T) then begin
;Calculate the temperature array to go with em
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    T = msu_get_temp(state)
    T=T[1:n_cells-2l]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;endif

return,em


END
