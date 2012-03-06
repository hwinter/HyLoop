function test_loop_grid, loop ,$
  GRID_SAFETY=GRID_SAFETY,$
  S_GRID=S_GRID, VOL_GRID=VOL_GRID,$
  SMOOTH=SMOOTH, NO_ENDS=NO_ENDS,$
  MIN_CLS=MIN_CLS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Keywords
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define Characteristic length scales
 MIN_CLS=get_loop_min_cls(loop, $
                          GRID_SAFETY=GRID_SAFETY,$
                          S_GRID=S_GRID, VOL_GRID=VOL_GRID,$
                          SMOOTH=SMOOTH, NO_ENDS=NO_ENDS)
                                ;figure out grid size
 N = n_elements(loop.state.e)
 ds = loop.s[1:N-2] - loop.s[0:N-3]
 violotions_temp=where(ds gt min_cls, violations_count)
 n_violations=Total(violations_array)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

return, n_violations
end_jump:
end;OF MAIN
restore, dialog
