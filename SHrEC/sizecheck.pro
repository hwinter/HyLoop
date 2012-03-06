PRO sizecheck, state, g,a,s,E_h		;, depth
 N=n_elements(state.e)
trouble=' '
 IF n_elements(state.n_e) ne N   THEN  trouble=[trouble,'state.n_e']
 IF n_elements(state.v  ) ne N-1 THEN  trouble=[trouble,'state.v']
 IF n_elements(g        ) ne N-1 THEN  trouble=[trouble,'g']
 IF n_elements(a        ) ne N-1 THEN  trouble=[trouble,'a']
 IF n_elements(s        ) ne N-1 THEN  trouble=[trouble,'s']
 IF (n_elements(E_h[*,0]) ne N-2) AND (n_elements(E_h) ne 1) THEN  trouble=[trouble,'E_h']

;IF depth ne 2.00000e+06 THEN print, 'Warning: chromosphere depth may be off."

;check for grid spacings all >0.
ns=n_elements(s)
dx1=where(s[1:ns-1] - s[0:ns-2] lt 1e2, nbad)
IF nbad ge 1 THEN trouble=[trouble,'wonky grid spacing']

 IF n_elements(trouble) gt 1 THEN BEGIN
  FOR i=1UL, n_elements(trouble)-1UL DO print,'trouble with '+trouble[i]
 ; stop
 ENDIF

RETURN
END

