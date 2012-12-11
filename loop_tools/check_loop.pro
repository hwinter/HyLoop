function check_loop loop, ERROR_MSG=ERROR_MSG
  
  ERROR_MSG=''
  
  Area_min=min(loop.a)
  Area_max=max(loop.a)

  if Area_min le 0 then begin
     ERROR_MSG=[ERROR_MSG, 'Minimum Loop Area le 0']
  endif

  if Area_max le 0 then begin
     ERROR_MSG=[ERROR_MSG, 'Maximum Loop Area le 0']
  endif

  
  b_min=min(loop.b)

  if b_min le 0 then begin
     ERROR_MSG=[ERROR_MSG, 'Minimum Loop B le 0']
  endif

if n_elements(ERROR_MSG) gt 1 then begin
 pass_fail=-1 
 ERROR_MSG=ERROR_MSG[1:*]
 endif else pass_fail=1

return, pass_fail

END
