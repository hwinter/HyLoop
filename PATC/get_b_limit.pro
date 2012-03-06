function get_b_limit, E, PROTON=PROTON

psi_min=1d-4
psi_min_test=psi_min
for i=0ul, 1000ul do begin
    test=1d0 eq cos(psi_min_test)
    if test eq 1 then begin
        psi_min_test=psi_min_test+psi_min_test*.1
        psi_min=psi_min_test
    endif

    if test eq 0 then psi_min_test=psi_min_test-psi_min_test*.2
    
 ;   print, psi_min, test
endfor
if size(E, /TYPE) eq 0 then E=15d0

v=energy2vel(E)

m_test=!shrec_me

if keyword_set(PROTON) then m_target= !shrec_mp $
  else m_target=!shrec_me

mu_rm=(m_test*m_target)/(m_test+m_target)

b_limit=(2d0*!shrec_qe*!shrec_qe)/(mu_rm*v*v*psi_min)


return, b_limit


end
