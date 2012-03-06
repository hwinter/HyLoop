;+
;NAME:
;	loop1003
;PURPOSE:
;	Iterate a dynamic loop model from time t to
;	t + delta_t. All units are cgs.
;CALLING SEQUENCE:
;       loop1003, state, g, A, x, heating, delta_t $ 
;		[, /debug,/T0, /safety, /uri,/fal, /spit, /novisc]
;	loop1003, state, g, A, x, heating, delta_t $
;		[, T0=T0, /uri, /fal, /debug, /novisc]
;INPUT PARAMETERS:
;	state - a structure containing initial state
;		information as a function of position:
;		state.e - internal energy (N volume elements)
;		state.n_e - electron density (N volume elements)
;		state.v - velocity in x direction at the
;		    interstices between the volume 
;		    elements (N-1 elements)
;		state.time - time of specified state.
;	g - gravitational acceleration in x direction,
;		as a function of x (N-1 elements)
;	A - cross-sectional area as a function of x
;               (N-1 elements)
;	x - array containing position values for 
;		the boundaries between the volume elements
;		(x has N-1 elements). The intervals
;		should be slowly varying so as to
;		avoid numerical complications.
;	heating - coronal heating rate. Either constant
;		or an array with N-2 elements (volume
;		element grid, missing the ends).
;OPTIONAL KEYWORD INPUTS:
;	compile - if set, all other inputs are ignored and
;		loop7 returns immediately. This is useful for
;		compiling loop7 and its subroutines from an IDL
;		program. Unlike IDL resolve_routine, will not
;		recompile if loop7 is already defined.
;	T0 - boundary temperature (default = 1e4 K)
;	debug - integer values implement various
;		diagnostic options. Read the source.
;	safety - Time stepping safety factor.
;		The time stepping interval dt is derived from
;		the Courant condition, divided by a safety factor
;		(5.0 by default). The purpose of the safety factor
;		is twofold: (1) numerical stability and (2) allow
;		conduction to be more effective than sound over
;		short distances. At the risk of infidelity to physics
;		and possible numerical instability, the safety
;		factor may be reduced (2 is usually OK), bringing
;		about a proportional increase in execution speed.
;	spit -	to use Spitzer Conductivity in Kappa
;KEYWORD SWITCHES:
;OUTPUT:
;	state - after execution, updated state
;		information for time t + delta_t
;		is returned.
;PROCEDURE:
;	Internal energy (e) and electron density (n_e) are modeled
;	in N volume elements along an asymmetric, 1-dimensional
;	coronal loop. Velocity (v) is defined
;	on a staggered grid, occupying the N-1 interstices of the
;	volume elements. The first and last elements of v are:
;		v(0) = v(N-2) = 0 (zero flow).
;	The remaining physical boundary conditions are defined
;	in terms of the temperature and pressure in volume
;	elements 0 and N-1:
;		T(0) = T(N-1) = T0, a constant
;		P(0) = P(1), P(N-1) = P(N-2)
;	Thus, the boundary acts like a solid wall with
;	constant temperature. Actually, there's a small
;	gravity term that is not included in the
;	P equations. For bookkeeping purposes, the
;	internal energy and electron density will satisfy
;	the boundary conditions if:
;		e(0) = e(1), e(N-1) = e(N-2)
;		n_e(0) = e(0) / (3 * kB * T0)
;		n_e(N-1) = e(N-1) / (3* kB * T0)
;	where kB is Boltzmann's constant. The first and last 
;	volume elements exist only for the purpose of imposing 
;	boundary conditions. Since the energy and electron density
;	in these volume elements are outside the v=0 hard wall,
;	and because they vary to maintain the boundary conditions,
;	these boundary elements should not be included for purposes
;	of checking conservation of mass or energy.
;	   First-order differencing is employed on the staggered
;	grid, with advected quantities (internal energy, electron 
;	density) evaluated upstream. Because of the formulation,
;	mass and energy are rigorously conserved under
;	advection. Thermal conduction is done implicitly to
;	maintain numerical stability with reasonable-sized
;	time steps.
;	   Time stepping is done in two phases, 0.6dt and dt,
;	with the finite differences from the former being used
;	to advance the initial state through the latter.
;HISTORY:
;	1999-Dec-6 CCK new version (loop6-->loop6) corrects
;		for interference between the timestepping method
;		and implicit evaluation of the conduction term;
;		loop6 is a drop-in replacement for loop6.
;	1999-Dec-7 CCK debugged.
;	2001-Nov   RAM no more toilet bowl chromosphere. 
;		chromoshere is heated and radiates with a loss funtion
;		user must anticipate and provite appropriate Chrom. depth
;-


;------ VAU radiative loss function (1979 ApJ 233:987) ------
;KEYWORD SWITCHES:
;	FAL - Values from 1e4 K to 1e5 K based on fig. 2 of E. H. 
;		Avrett in _Mechanisms of Chromospheric and Coronal 
;		Heating_, P. Ulmschneider, E. R. Priest, & R. Rosner 
;		Eds., Springer Verlag (1991), pp.97-99. This is 
;		based on the FAL transition region model, including 
;		corrections for optical depth and ambipolar 
;		diffusion. [An added point at 1e3 K merely 
;		extrapolates the radiative loss to arbitrarily
;		low temperature.]
;	URI - Values above 1e5 K based on recalculation of the
;		Cook et al. (1989 ApJ 338:1176) radiative loss
;		using the Feldman (1992 Phys Scr 46:202-220) coronal
;		abundances.
;	DISP - Ignore n_e and T inputs, and plot a graph of the
;		radiative loss function. If DISP is set but not
;		one, then OPLOT procedure is used, and minus the
;		value of DISP is used for the psym keyword.
;	04/2002 - RAM ramp to zero rloss at 9500K
function radloss, n_e, T, uri=uri, fal=fal, disp=disp
;print,'R ' & if uri then print,'URI' ELSE print, 'noURI' & if fal then print,'FAL' 
;(1) Transition region:
 if keyword_set(FAL) then begin
	logT = [3.0d, 4.000, 4.165, 4.380, 4.520, 4.645, 4.905, 5.000]
        logL = [-28d,-23.54d,-22.79,-21.73,-21.36,-21.20,-21.31,-21.38]
 endif else begin  ;VAU transition region
	logT = [3.0d, 4.0, 4.19, 4.50, 5.0]
        logL = [-28d, -23.03d, -21.65, -21.90, -21.19]
 endelse


;(2) Append the Corona:
 if keyword_set(Uri) then begin
	logT = [logT, 5.3d, 5.7, 6.0, 6.3, 6.7, 7.0]
        logL = [logL, -21.39, -20.99, -20.98, -21.64, -22.37, -22.27]
 endif else begin  ;VAU corona
	logT = [logT, 5.40d, 5.80, 6.30, 7.50, 8.00]
        logL = [logL, -21.202d, -21.900, -21.939, -22.735,- 22.589]
 endelse

;DISP option
if keyword_set(disp) then begin

	if disp eq 1 then begin
        	plot, logT, logL, psym=-1, xtitle = '!6log T', $
		ytitle = '!6Radiative loss, log !7K!6(T)', xrange=[4,7],$
		symsize=!P.symsize ;IDL !P.symsize doesn't work.
	endif else begin
;        	oplot, logT, logL, psym=-disp, symsize=!P.symsize
        	oplot, logT, logL, linestyle=disp, symsize=!P.symsize
        endelse
	return, 0
endif

Tmax = max(10^logT)
Tmin = min(10^logT)

;old, inefficient way
Lambda = 10^interpolate(logL, findex(logT, alog10(T)))

;new, zippy way
 n_tabulated = n_elements(logT)
 logtemp = alog10(double(T >Tmin <Tmax))
	;new interpolator crashes when logtemp is out of range!
 n_logtemp = n_elements(logtemp)
 logLambda = make_array(n_logtemp, /double)
; foo = call_external('bnh_splint2.so', $ ; The SO
 ;                 'bnh_splint2', $      ; The entry name
 ;                  n_tabulated, $      ; # of elements in x, f(x)
 ;                  logT, $             ; x
 ;                  logL, $             ; f(x)
 ;                  n_logtemp, $        ; # elements in thing-to-interpolate
 ;                  logtemp, $          ; thing-to-interpolate
 ;                  logLambda , $            ; where the answer goes
;		   /d_value, $ 
;		    value=[1,0,0,1,0,0], $ 
;	           /auto_glue,$
;                   COMPILE_DIR='.')
; Lambda = 10^logLambda

;(3) Chromosphere = linear ramp for 9500 < T < 1e4
 intercept=10^logL[1]	;where logt=4.0
 here=where(t le 1e4, n_here)
 IF n_here gt 0 THEN BEGIN
  ramp=(t[here] - 9500.)*(intercept)/500. 
  lambda[here]=ramp >0.
 ENDIF

;plot, t, lambda, xrange=[0,1.2e4]
;oplot, 10^logt, 10^logL, psym=4
;oplot, t[here], ramp, psym=-2
;stop


 result = n_e*n_e * Lambda

return, result
end


;------ Thermal conductivity ---------------------------------
;Based on Spitzer (1e-6 * T^(5/2)), with corrections inferred
;from Fontenla, Avrett & Loeser (1990 ApJ 355:700)
;1999-Jul-15 CCK added DISP keyword similar to radloss function
;KEYWORDS 
;	spit 	- uses Spitzer 1e-6 * T^(5/2)*(1.)  that is, sets correction=1.
;	disp 	- makes some plots of conductivity options
function kappa, T, disp=disp, spit=spit
;print, 'kappa ' & IF spit then print,'spit' ELSE print,'FAL'
;first tabulated point is a dummy point, in case T < 1e4.
 logc = [2d, 2.00d, 1.12, 0.69, 0.22, 0.13, 0.10, 0.08, 0.00, 0.00, 0.00]
 logT = [3d, 4.00d, 4.18, 4.30, 4.60, 4.78, 4.90, 5.00, 6.00, 7.00, 8.00]
 Tmin = 10^min(logT)
 Tmax = 10^max(logT)

;DISP option
if keyword_set(disp) then begin
	plot, logT, 2.5*logT+logC-6, psym=-1, xtitle = '!6log T', $
		ytitle = '!6Thermal conductivity, log [!7j!6T!U5/2!N]', $
		xrange=[4,5], yrange=[4,7], symsize=!P.symsize
		;Note that !P.symsize doesn't work unless it's
		;hooked in manually as above!
	oplot, logT, 2.5*logT-6, psym=-4, symsize=!P.symsize, $
		linestyle=2
	;oplot, logt, 2.5*logt+dblarr(11)-6
	legend, ['New heat flux model','Spitzer (1962)'],$
		psym=[-1,-4],linestyle=[0,2],$
		symsize=[!P.symsize,!P.symsize], box=0
	return, 0
endif

 IF keyword_set(spit) THEN correction = 1. ELSE BEGIN
;interpolate correction table onto T
correction = 10^interpolate(logc, findex(logT, alog10(T)))

;new, zippy way ;
  n_tabulated = n_elements(logT)
  logtemp = alog10(double(T >Tmin <Tmax))
	;new interpolator crashes if logtemp is out of range!
  n_logtemp = n_elements(logtemp)
  logcorr = make_array(n_logtemp, /double)
;  foo = call_external('bnh_splint2.so', $ ; The SO
;                  'bnh_splint2.c', $      ; The entry name
;                   n_tabulated, $      ; # of elements in x, f(x)
;                   logT, $             ; x
;                   logc, $             ; f(x)
;                   n_logtemp, $        ; # elements in thing-to-interpolate
;                   logtemp, $          ; thing-to-interpolate
;                   logcorr, $           ; where the answer goes
;		   /d_value, $ 
;		    value=[1,0,0,1,0,0], $ 
;	           /auto_glue,$
;                   COMPILE_DIR='.')

  correction = 10^logcorr
 ENDELSE

return, (1.0e-6)*T^(2.5)*correction	;units: erg/(K cm s)
end

;----- Boundary Conditions (same each time applied) -------------------
function bcs, state,g, T0

common loopmodel, dx1, dx2, A1, ix

;Constants
kB = 1.38e-16 ;Boltzmann constant (erg/K)
me = 9.11e-28 ;electron mass (g)
mp = 1.67e-24 ;proton mass (g)
gamma = 5.0/3.0 ;ratio of specific heats, C_P/C_V

	;calculate rho (mass density) on v grid
	rho = mp * (state.n_e[0:ix-1] + state.n_e[1:ix])/2.0
state.v(0) = 0.0 ;no flow
state.v(ix-1) = 0.0 ;no flow
state.e(0) = state.e(1) - $
	1.5*rho(0)*g(0)*dx2(0) ;zero force
state.e(ix) = state.e(ix-1) + $
	1.5*rho(ix-1)*g(ix-1)*dx2(ix-1) ;zero force
state.n_e(0) = state.e(0)/(3.0*kB*T0) ;constant temperature
state.n_e(ix) = state.e(ix)/(3.0*kB*T0) ;const. temperature

return, state
end

;----- Eulerian time stepper (result is change in state variable) -----
function dstate, state, T, g, A, x, heating, dt, T0,mu, $
	 debug, safety, uri, fal, spit

common loopmodel, dx1, dx2, A1, ix

;Constants
kB = 1.38e-16 ;Boltzmann constant (erg/K)
me = 9.11e-28 ;electron mass (g)
mp = 1.67e-24 ;proton mass (g)
gamma = 5.0/3.0 ;ratio of specific heats, C_P/C_V

;useful thermodynamic quantities (e/n_e grid)
P = (2.0/3.0)*state.e
T2 = (T[0:ix-1] + T[1:ix])/2.0	;temperature interpolated to the v grid

state = bcs( state, g, T0)	;boundary conditions

;calculate rho (mass density) on v grid
rho = mp * (state.n_e[0:ix-1] + state.n_e[1:ix])/2.0

;Upwind differencing stuff
vpos = float(state.v gt 0.0)
vneg = not vpos

	
;***** Continuity equation (n_e) *****
;Scheme rigorously conserves mass.
mass_flux = A * vpos * state.v * state.n_e[0:ix-1] + $
            A * vneg * state.v * state.n_e[1:ix]
dn_e = - (dt/A1)* $
	( mass_flux(1:ix-1) - mass_flux(0:ix-2) )/dx1

;***** Internal energy (e) equation *****
;Note: Advection uses a conservative form.
;Advection and work:
e_flux = A * vpos * state.v * state.e[0:ix-1] + $
              A * vneg * state.v * state.e[1:ix]
advect_work = -(dt/(A1*dx1)) * $
      ( e_flux(1:ix-1) - e_flux(0:ix-2) ) $ ;advection
   -(dt*P[1:ix-1]/(A1*dx1)) * $
      (A[1:ix-1]*state.v[1:ix-1] - A[0:ix-2]*state.v[0:ix-2]);work

;Thermal conduction (implicit differencing)
;Given an inhomogeneous matrix equation
;	M T' = 3 ne kB T
;where T is the initial temperature, T' is final temperature,
;ne is electron density, kB is Boltzmann's constant, and M 
;is a tridiagonal matrix, invert for T'.

K2 = kappa(T2, spit=spit) ;calculate thermal conductivity
temp1 =A[0:ix-2] *K2[0:ix-2] *dt / $
  	( dx2(0:ix-2)*dx1*0.5*(A[0:ix-2] +A[1:ix-1]) )
temp2 =A[1:ix-1] *K2[1:ix-1] *dt / $ 
  	( dx2(1:ix-1)*dx1*0.5*(A[0:ix-2] +A[1:ix-1]) )
;temp1 = K2[0:ix-2] *dt / ( dx2(0:ix-2)*dx1 )
;temp2 = K2[1:ix-1] *dt / ( dx2(1:ix-1)*dx1 )

sub = [0.0, -temp1, 0.0]
	;sub-diagonal elements of M
main = 3.0*state.n_e*kB + [0.0, temp1 + temp2, 0.0]
	;main diagonal elements of M
super = [0.0, -temp2, 0.0]
	;super-diagonal elements of M
rhs = 3 * state.n_e * kB * T
	;right-hand side of the inhomogeneous equation

Tprime = trisol(sub,main,super,rhs)

conduction = 3*state.n_e*kB*(Tprime - T) ;used to use state.e instead of T,
	;but timestepping causee T and state.e to be out of sync!

radiative_loss= - radloss(state.n_e[1:ix-1],T[1:ix-1], $
	uri=uri,fal=fal)*dt 

;viscous energy loss - mu is imported
 temp1 = 2.*(A[1:ix-1]*state.v[1:ix-1] - A[0:ix-2]*state.v[0:ix-2]) / $
	(dx1[0:ix-2]*(A[1:ix-1] + A[0:ix-2]))
 visc0 = dt * mu[0:ix] * [0., (temp1)^2, 0.]	;d^2 v heats the plasma
;ENDELSE

;Round up all terms 
de = conduction[1:ix-1] + advect_work   $
	+ radiative_loss $
	+ heating*dt $
	+ visc0		;viscousity


;***** Momentum equation (v) *****
div_v = (state.v[1:ix-1] - state.v[0:ix-2])/dx1
dv =    - (dt/rho) * (P[1:ix] - P[0:ix-1])/dx2 $ ;grad P
	- dt * state.v * $
	  ( vpos * [0.0, div_v] + $
	    vneg * [div_v, 0.0] ) $ ;advection
	+ (dt*g) ;gravity

return, {e:[0.0,de,0.0], n_e:[0.0,dn_e,0.0], v:dv}
;This is almost a state structure, just lacks the time tag
end


;-------- Begin Main Program ---------------------------------

pro loop1003, state, g, A, x, heating, delta_t, debug=debug, $
	T0=T0, safety=safety, uri=uri,fal=fal, spit=spit, novisc=novisc

if not keyword_set(T0) then T0 = 1e4 ;default boundary temperature

if not keyword_set(safety) then safety = 5.0

common loopmodel, dx1, dx2, A1, ix

;Constants
kB = 1.38d-16 ;Boltzmann constant (erg/K)
me = 9.11d-28 ;electron mass (g)
mp = 1.67d-24 ;proton mass (g)
gamma = 5.0/3.0 ;ratio of specific heats, C_P/C_V
kappa0 = 1e-6 ;Spitzer thermal conductivity coefficient

delta_t = float(delta_t)

state0=state ;useful temporary variable
ix = n_elements(state.e)-1 ;index of last gridpoint

;calculate grid spacing
dx1 = x(1:ix-1)-x(0:ix-2)
	;valid indices run from 0 to ix-2 (volume grid, missing ends)
dx2 = [dx1[0],(dx1[0:ix-3] + dx1[1:ix-2])/2.0, dx1[ix-2]]
	;dx1 interpolated onto the v grid, ends extrapolated.
A1 = (A(0:ix-2) + A(1:ix-1))/2.0
	;A interpolated onto the e/n_e grid (missing ends)

done = 0
start_tim = state.time
n_int = 0L ;number of dt intervals
now=0d
while not done do begin
    ;print,'LOOP1003 Working!'
	;calculate dt, the largest allowable time step
	T = state.e/(3*state.n_e*kB)
	cs = sqrt(2.0*gamma*kB*T/mp) ;sound speed
 	cs_sm = (cs(0:ix-1) + cs(1:ix))/2.0
	dt = min( dx1/(cs_sm + abs(state.v(0:ix-1))) )/safety
		;Courant condition for advection and acoustic waves,
		;with a safety factor for stability.
	if ((now + dt) ge delta_t) then begin ;almost done!
	;(05/13/02) RAM problem with roundoff error in double(dt) crashes
	;if ((state.time -start_tim) + dt ge delta_t) then begin 
		dt = delta_t - now
		done = 1 ;This will be the last iteration.
	endif
	IF keyword_set(novisc) THEN BEGIN
		mu = fltarr(ix+1)
		visc=0. 
	ENDIF ELSE BEGIN
	;calculate mu only once because T will not get updated
 		coul_log=20d	;coulomb log (dimensionless)
 		qe = 4.8d-10	;electron charge (statcoulombs= g^1/2 cm^3/2 /s)
 	  	mu = ( sqrt((kb*T)^5. *mp) *0.96*3d )/( coul_log*4d*sqrt(!pi)*qe^4. )	;g/(cm s)
		;Plasma Formulary, p.38 - careful of floating point underflow here

	;implict viscousity term in momentum equation
	;calculate only once for all dt
 		ne2=0.5*(state.n_e[0:ix-1] + state.n_e[1:ix])
 		temp2 = mu[2:ix-1] * dt /(dx2[1:ix-2]*dx1[1:ix-2]*A[1:ix-2])
 		temp1 = mu[1:ix-2] * dt /(dx2[1:ix-2]*dx1[0:ix-3]*A[1:ix-2])
 		sub = [0.0, -temp1*A[2:ix-1], 0.0]
			;sub-diagonal elements of M
 		main = mp*ne2 + [0.0, A[1:ix-2]*(temp1 + temp2), 0.0]
			;main diagonal elements of M
 		super = [0.0, -temp2*A[0:ix-3], 0.0]
			;super-diagonal elements of M
		rhs = state.v * mp * ne2
			;right-hand side of the inhomogeneous equation
			;M v' = v
 		vprime = trisol(sub,main,super,rhs)
 		visc = vprime - state.v
	ENDELSE

	;------ Do the time stepping here ------
	IF NOT finite(dt) THEN STOP	;check for NaNs
	dt0 = 0.6 * dt ;a bit more than 1/2 timestep for stability

	ds0 = dstate(state, T, g, A, x, heating, dt0, T0,mu, $
        	debug, safety, uri, fal, spit)

	state0.e = ( state.e + ds0.e ) > 0.0
	state0.n_e = ( state.n_e + ds0.n_e ) > 1.0e2
	state0.v = state.v + ds0.v + visc * 0.6
	;state0.time = state.time + dt0

	;We feed the original temperature, T, to dstate. Thus,
	;implicit timestep for conduction does not use the 0.6*dt
	;timestep scheme.

	ds = dstate(state0, T, g, A, x, heating, dt, T0,mu, $
        	 debug,  safety, uri, fal, spit)

	state.e = ( state.e + ds.e ) > 0.0
	state.n_e = ( state.n_e + ds.n_e ) > 1.0e2
	state.v = state.v + ds.v + visc
	now = now + dt
	;state.time = state.time + dt

	n_int = n_int + 1

	;Level 2 debug
	if keyword_set(debug) then begin
	if debug ge 2 then begin
		plot,state.e,xrange=[80,150],yrange=[0,3]
		;oplot,alog10(state.e/(3*state.n_e*kB)),psym=3
		xyouts,1,1,'time = '+string(now),/device ;string(state.time),/device
		wait,1
	endif
	endif
	
endwhile
	state=bcs( state, g, T0)	;boundary conditions

state.time=state.time+now

if keyword_set(debug) then begin
	print,'Model time (s): ',state.time,' Number of intervals: ',n_int
	print,'Total number of electrons:',total(state.n_e[1:ix-1]*A1*dx1)
	;message,'execution halted for debugging....'
endif

end
