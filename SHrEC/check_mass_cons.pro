
PRO check_mass_cons, lhist, x, a, n_depth, core_mass, mass, core_vol, vol
;Check for mass conservation in coronal loop
;If mass not conserved, then (I don't know)

 N=n_elements(x)
 dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))
 nne=n_elements(lhist[0].n_e)
 core=indgen(Nne-2*n_depth)+n_depth
 core_vol=total(dv[core])
 vol=total(dv)

 n_time=n_elements(lhist.time)
 mass=fltarr(n_time)
 FOR i=0,n_time-1 DO mass[i]= total(dv*lhist[i].n_e[1:Nne-2]) ;don't include the endpoints
 core_mass=fltarr(n_time)
 FOR i=0,n_time-1 DO core_mass[i]= total(dv[core]*lhist[i].n_e[core])

 IF max(core_mass-core_mass[0])*min(core_mass - core_mass[0]) lt 0 THEN $
	yrange= [min(core_mass), max(core_mass)] - core_mass[0] ELSE $
	yrange= min(core_mass - core_mass[0])*[1.1,-0.2]
 IF n_time gt 1 THEN BEGIN
  plot, [lhist.time], [core_mass - core_mass[0]], linestyle=2, $
	xtitle='time', ytitle='N - N!d0!n Particles Not Conserved', $
	yrange=yrange
  oplot, [lhist.time], [mass - mass[0]], linestyle=0
  legend, ['Total Volume', 'Corona Volume'], lines=[0,2]

  dmdt = mass[0:*] - mass[1:*]
  IF max(abs(dmdt/1e24)) gt 1 THEN BEGIN
   print, 'Mass lost from Total Loop'
   stop
  ENDIF
 ENDIF

RETURN
END

