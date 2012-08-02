
function add_loop_chromo_single_cell, loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                                      VERSION=VERSION, STARTNAME=STARTNAME,$
                                      PERCENT_DIFFERENCE=PERCENT_DIFFERENCE,$
                                      MIN_STEP=MIN_STEP,$
                                      SET_SYSV=SET_SYSV, SYSV_NAME=SYSV_NAME,$
                                      _EXTRA=extra_keywords
  
  version=0.1

  n_e0=1d1
  loop.CHROMO_MODEL= 'SINGLE CELL'
  loop= shrec_bcs(loop, N_E0=n_e0)
  loop.n_depth=1
  loop.depth=depth
  defsysv,'!CHROMO_E_H',[[0],[0]]
  
  defsysv, '!N_E0',n_e0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  notes=loop.notes
  notes[0]+= '  . Chromosphere added by add_loop_chromo_single_cell.pro: V'+string(version)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Error check the size of loop elements 
err_state=shrec_sizecheck(LOOP, ERROR=ERR_msg)

if err_state le 0 then begin
   stop
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

return, loop


end
