
function tau_de,E ,$
                E_FINAL=E_FINAL,t=t , dens=dens,m=m,charge=charge
  if not keyword_set(m) then m=!shrec_me
  if not keyword_set(charge) then charge=!shrec_qe 
  if not keyword_set(dens) then dens=1d9
  if not keyword_set(t) then t=1d6
  if not keyword_set(E_FINAL) then E_FINAL=exp(-1d0)*E ;1-exp(-1)
;See my notes from Jan 18, 2008 for derivation and 
;  Deviation from   Emslie, 1978
  v_total=energy2vel(E)
  v_squared=v_total*v_total
  A_factor=(4d0*!dpi*dens*v_squared)
  a=1.
  b=1.
;debye_length
  dl=6.9010323*((T)/ $
                (dens))^0.5d
;help, dl, m,c,a,b
  de_dt=patc_de_dt(t , [e,v_total], dl, dens,m,charge,a,b)
  de_dt=(de_dt[0])
;help, de_dt
  tau=abs((E_final-E)/de_dt)
;stop
  return,tau                    ; [de_dt, dvp_dt]
end
