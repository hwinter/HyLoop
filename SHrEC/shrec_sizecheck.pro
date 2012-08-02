function shrec_sizecheck, loop, E_H=E_H, ERROR_MSG=ERROR_MSG, VERSION=VERSION
  
  version=0.1

  If not keyword_set(E_H) then E_H_in=loop.E_H $
  else  E_H_in=E_H

     
  N_vol_grid=n_elements(loop.state.e)
  
  ERROR_MSG=''
  IF n_elements(loop.state.n_e) ne N_vol_grid   THEN begin
     text='Problem in loop.state.n_e: '
     ERROR_MSG=[ERROR_MSG,text]
  end

  IF n_elements(loop.state.v  ) ne N_vol_grid-1 THEN begin
     text='Problem in loop.state.v'
      ERROR_MSG=[ERROR_MSG,text]
  end
 
  IF n_elements(loop.g        ) ne N_vol_grid-1 THEN begin
      text='Problem in loop.g'
      ERROR_MSG=[ERROR_MSG,text]
  end
 
  IF n_elements(loop.a        ) ne N_vol_grid-1 THEN begin
      text='Problem in loop.a'
      ERROR_MSG=[ERROR_MSG,text]
  end
 
  IF n_elements(loop.s        ) ne N_vol_grid-1 THEN begin
      text='Problem in loop.s'
     ERROR_MSG=[ERROR_MSG,text]
  end
 
  IF (n_elements(E_H_in[*,0]) ne N_vol_grid-2) AND (n_elements(E_H_in) ne 1) THEN begin
      text='Problem in E_h.'
      ERROR_MSG=[ERROR_MSG,text]
  end
 

;IF depth ne 2.00000e+06 THEN print, 'Warning: chromosphere depth may be off."

;check for grid spacings all >0.
  N_surf=n_elements(loop.s)
  dx1=where(loop.s[1:N_surf-1] - loop.s[0:N_surf-2] lt 1e2, nbad)
  IF nbad ge 1 THEN ERROR_MSG=[ERROR_MSG,'wonky grid spacing']

  IF n_elements(ERROR_MSG) gt 1 THEN BEGIN
     FOR iii=1UL, n_elements(ERROR_MSG)-1UL DO print,'ERROR_MSG with '+ERROR_MSG[iii]
     err_stat=-1
                                ; stop
  ENDIF else err_stat=1


  RETURN, err_stat
END

