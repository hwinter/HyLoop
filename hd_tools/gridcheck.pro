FUNCTION gridcheck, state
;check tempreature derivatives over gaps in the grid
;If gaps are too big, plots to screen and returns 0

 t=state.e/state.n_e
 IF max(abs(t[1:*]/t)) gt 5. THEN ok=0 ELSE ok=1 
 IF max(abs(state.e[1:*]/state.e)) gt 5. THEN ok=0
 IF max(abs(state.n_e[1:*]/state.n_e)) gt 5. THEN ok=0

 IF NOT ok THEN BEGIN
;  plot, t[1:*]/t, xtitle='grid #', ytitle='T[i]/T[i-1]'
;  oplot, t/t[1:*]
 ENDIF

RETURN, ok
END
