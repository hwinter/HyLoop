function get_loop_ds, loop, DERIV=DERIV
if not keyword_set( DERIV ) then begin
;figure out grid size
    N = n_elements(loop.state.e)
    ds = loop.s[1:N-2] - loop.s[0:N-3]
    
endif else $
  ds=deriv(loop.s)

return, ds

end
