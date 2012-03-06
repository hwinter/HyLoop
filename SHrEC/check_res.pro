FUNCTION check_res, state, dv, n_depth , noisy=noisy
;check mass resivoir in chromosphere
;If not enough mass, stops.
; N=n_elements(x)
; dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))

 nne=n_elements(state.n_e)
 kb=1.38e-16
 t=state.e/(3.*kb*state.n_e)
 id=where(t ge 1.1e4, nt)
 IF nne - nt le 2 THEN stop

 n0=min(id)
 n1=max(id)
 nne=n_elements(state.n_e)
 core=indgen(n1-n0+1)+n0

 mass= dv*state.n_e[1:Nne-2]	;don't include the endpoints
 core_mass= dv[core]*state.n_e[core]
 m1=total(mass)/1.e34
 m_core= total(core_mass)/1.e34

 IF Keyword_set(noisy) THEN BEGIN
  plot, mass/1.e34, xtitle='grid point', ytitle='10!u34!n Particles'
  print, 'Total: ', m1
  print, 'Core:  ', m_core

 ENDIF
 return_me =(m1-m_core)/m1
RETURN, return_me
END
