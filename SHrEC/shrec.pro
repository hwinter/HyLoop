;+
;NAME:
;	shrec.pro
;PATC taken out
;Viscosity
;Saturated Cond. flux
;
;PURPOSE:
;	Iterate a dynamic loop model from time t to
;	t + delta_t. All units are cgs.
;CALLING SEQUENCE:
;	shrec_loop, state, g, A, s, heating, delta_t $
;		[, T0=T0, /src, /uri, /fal, /debug, depth=depth]
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
;	s - array containing position values for 
;		the boundaries between the volume elements
;		(s has N-1 elements). The intervals
;		should be slowly varying so as to
;		avoid numerical complications.
;	heating - coronal heating rate. Either constant
;		or an array with N-2 elements (volume
;		element grid, missing the ends).
;OPTIONAL KEYWORD INPUTS:
;	T0 - boundary temperature (default = 1e4 K)
;	debug - integer values implement various
;		diagnostic options. Read the source.
;	depth - optional desired chromospheric depth. If this keyword
;		is nonzero, then corrections are applied to try to
;		maintain a chromosphere of a desired depth (add or
;		remove mass at the 1.1*T0 isotherm, which slides
;		the isotherm toward desired depth). If
;		depth <= 1, then the default depth of 1e6 cm is used.
;		If depth is greater than 1, then the value of the
;		keyword is the desired chromospheric depth in cm.
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
;KEYWORD SWITCHES:
;	SRC - if set, engages the 'shiny red chromosphere'
;		feature: radiative loss rate at T < T0
;		is set to zero, producing a chromosphere
;		of uniform temperature.
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
;       2007-APR-20 HDW Converted to msu_loop.pro
;           Enforced proper (), [] syntax. (Again! That's what 
;           happens when you revert to a previous version.  <sigh>)
;           Made DEBUG a passable keyword, which made sense.
;       2007-APR-24 HDW
;
;       2010-APR-21 Converted to SHrEC
;-


;------ VAU radiative loss function (1979 ApJ 233:987) ------
;KEYWORD PARAMETERS:
;	T0 - minimum temperature threshold used with /src option.
;KEYWORD SWITCHES:
;	SRC - if set, engages the 'shiny red chromosphere'
;		feature: radiative loss rate at T < T0
;		is set to zero, producing a chromosphere
;		of uniform temperature.
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
;
;Chromospheric Models
;    'SLIDING CHROMOSPHERE'
;    'CONSTANT CHROMOSPHERE'      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Begin Main Program ---------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro shrec, loop, delta_t, debug=debug, $
           T0=T0, src=src, depth=depth, safety=safety,$
           uri=uri,fal=fal, OUT_LOOP=OUT_LOOP, $
           HEAT_FUNCTION=HEAT_FUNCTION,$
           SO=SO, E_H=E_H,$
           NT_BEAM=NT_BEAM,NT_PART_FUNC=NT_PART_FUNC,$
           NT_BREMS=NT_BREMS,$
           NT_DELTA_E=NT_DELTA_E,$
           NT_DELTA_MOMENTUM=NT_DELTA_MOMENTUM,$ 
           PATC_heating_rate=PATC_heating_rate,$
           extra_flux=extra_flux, $
           NOVISC=NOVISC ,$
           NO_SAT=NO_SAT,$
           N_E_CHANGE=N_E_CHANGE , DT_COND_MIN=DT_COND_MIN, $
           CHROMO_MODEL=CHROMO_MODEL
           
  
   ;        CONSTANT_CHROMO=CONSTANT_CHROMO, $
   ;        SLIDE_CHROMO=SLIDE_CHROMO

  

  common loopmodel, ds1, ds2, A1, is

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check keyword switches

  if not keyword_set(T0) then T0 = 1e4 ;default boundary temperature
  if not keyword_set(HEAT_FUNCTION) then HEAT_FUNCTION='get_constant_heat'
  if not keyword_set(safety) then safety = 5.0
  if not keyword_set(DEBUG) then DEBUG=0

  if keyword_set(depth) then begin
     if (depth le 1 and depth ne 0) then depth = 1e6
  endif

  delta_t = double(delta_t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get some loop properties that won't change during the run.
;Only operate on the last loop element
  temp_loop=loop[n_elements(loop)-1]

  loops=temp_loop
;useful temporary variable
  state0=temp_loop.state 
;index of last volume gridpoint
  is = n_elements(temp_loop.state.e)-1l 
;Get the volumes of each grid element
  volumes=get_loop_vol(temp_loop)
  n_vol=n_elements(volumes)
  n_e_change_in=dblarr(n_vol)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;calculate grid spacing
;valid indices run from 0 to is-2 (volume grid), missing ends
  ds1 = temp_loop.s[1:is-1]-temp_loop.s[0:is-2]
;ds1 interpolated onto the s grid, ends extrapolated.
  ds2 = [ds1[0],(ds1[0:is-3] + ds1[1:is-2])/2.0, ds1[is-2]]

;A interpolated onto the e/n_e grid (missing ends)
  A1 = (temp_loop.A[0:is-2] + temp_loop.A[1:is-1])/2.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set done switch
  done = 0
;Set the time
  start_tim =temp_loop.state.time
;number of dt intervals
  n_int = 0UL
  patc_ticker=0d
;Debug ticker
  debug_ticker=0d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Begin time step loop
  while not done do begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For debugging
;!except=2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    temp_loop=regrid_spline(temp_loop)
;Calculate dt, the largest allowable time step
     T = get_loop_temp(temp_loop)
;Compute sound speed
     cs = get_loop_sound_speed(temp_loop, T=T)
;Interpolate sound speed to surface grid
     cs_sm = (cs[0:is-1] + cs[1:is])/2.0
;Courant condition for advection and acoustic waves,
                                ;with a safety factor for stability.
     dt_cfl = abs(min( ds1/(cs_sm + abs(temp_loop.state.v[0:is-1])) )/safety)
     dt_cfl<=0.10*delta_t
     dt_cfl>=1d-15
                                ;dt_cfl>=1d-6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Add a conduction component so that the timestep isn't too far off
     dt_cond=(4.14d-10)*temp_loop.state.n_e[1:is-1] $
             *ds1*ds1/((T[1:is-1])^2.5)
     dt_cond>=1d-2

     dt = abs(min([dt_cfl, dt_cond]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Some information to print off when debugging, or just curious
                                ;if debug gt 0 then $
     if size(avg_courant,/TYPE) eq 0 then avg_courant=dt $
     else avg_courant=[avg_courant,dt]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;If something goes wrong and dt hits a non-finite value print
;  an error message and stop.
     if finite(dt) lt 1 then begin
        print, 'Non-finite dt detected in shrec_loop.'
        help, dt
        help, min(dt_cfl)
        help,dt_cond
        cause_of_death= 'Non-finite dt detected in shrec_loop.'
        save, /all, file='shrec_loop_gasp01.sav'
        stop
     endif

;If something goes wrong and dt goes to zero  print
;  an error message and stop.
     if dt le 0d0 then begin
        print, 'A negative or zero dt detected in shrec_loop.pro.'
        help, dt
        help, dt_cfl
        help,min(dt_cond)
        cause_of_death= 'A negative or zero dt detected in shrec_loop.pro.'
        save, /all, file='shrec_loop_gasp02.sav'
        stop
                                ;dt=
     endif
;dt>=10d-6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check to see if this is the last step
     if ((temp_loop.state.time-start_tim) + dt ge delta_t) then begin 
;almost done!
        dt = delta_t - (temp_loop.state.time - start_tim)
        if dt eq 0 then dt=1d-5
        done = 1                ;This will be the last iteration.
     endif else begin
;Kill some roundoff error here 2008/APR/1 HDWIII
        temp=dt+delta_t
        dt=temp-delta_t
     endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Heating function section 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Insert the heating input from a user defined 
;   function
     n_e_change=0d0
     heating=call_function(HEAT_FUNCTION,temp_LOOP,$
                           temp_loop.state.time, dt, $,
                           nt_beam, nt_brems, PATC_heating_rate, extra_flux, $
                           DELTA_MOMENTUM,flux, n_e_change)
     if n_elements(n_e_change) gt 1 then begin
        n_e_change=[0,n_e_change,0]
        n_e_change_in+=n_e_change
     endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     dv_patc=0                  ;DELTA_MOMENTUM/(temp_loop.state.n_e(1:is-1)*!shrec_mp)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;coulomb log (dimensionless)
;From Choudhuri p. 265
;coulomb_log=alog((1.5d0)*(1d0/!shrec_charge_z)*(1d0/(!shrec_qe^2d0))* $
;            ((!shrec_kB^3d0)*(T^3d0)*(1d0/!dpi)*$
;             (1d0/state.n_e))^5d-1)
     index1=where(T le 4.2d5)
     index2=where(T gt 4.2d5)
     coulomb_log=dblarr(n_elements(T))
;Approximation from Benz
     if index1[0] ne -1 then $
        coulomb_log[index1]=1.24d4 $
                            *(T[index1]^1.5d0) $
                            *(loop.state.n_e[index1]^(-0.5d0))
     
     if index2[0] ne -1 then $
        coulomb_log[index2]=8.0d6*(T[index2])*(loop.state.n_e[index2]^(-0.5d0))
     
     coulomb_log=alog(coulomb_log)
;Set a threshold  that the coulomb log cannot go below.
     coulomb_log>=14.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Viscosity section
;this section was taken directly from the work of McMullen 2002.   
     IF keyword_set(novisc) THEN BEGIN
        mu = dblarr(is+1)
        visc=0.d
     ENDIF ELSE BEGIN 
;HDW 2007_OCT_15 Moved the calculation of mu, and the dissipation of ; 
; v into shrec_dstate3.  For large gradients in flow, the procedure was not 
; conserving energy.  
;calculate mu only once because T will not get updated

;Plasma Formulary, p.38 - careful of floating point underflow here
;Plasma formulary uses different units but 
; this should be fine as long as the right kb is used.      
        mu = ( sqrt((!shrec_kB*T)^5. *!shrec_mp) $
               *0.96*3d )/( coulomb_log*4d*sqrt(!dpi)*!shrec_qe^4. ) ;g/(cm s)
        
;implict viscousity term in momentum equation.
;Density on the surface grid.
        ne2=0.5d0*(loop.state.n_e[0:is-1] +loop.state.n_e[1:is])
;I hate the way IDL handles math errors.  underflows
        JUNK=where(ne2 lt 0d0)
        if junk[0] ne -1 then ne2[junk]=abs(ne2[junk])

        temp2 = mu[2:is-1] * dt /(ds2[1:is-2]*ds1[1:is-2]*loop.A[1:is-2])
        temp1 = mu[1:is-2] * dt /(ds2[1:is-2]*ds1[0:is-3]*loop.A[1:is-2])
;sub-diagonal elements of M
        sub = [0.0, -temp1*loop.A[2:is-1], 0.0]
;main diagonal elements of M
        main = !shrec_mp*ne2 + [0.0,loop.A[1:is-2]*(temp1 + temp2), 0.0]
;super-diagonal elements of M
        super = [0.0, -temp2*loop.A[0:is-3], 0.0]
;right-hand side of the inhomogeneous equation
        rhs = loop.state.v * !shrec_mp * ne2
;M v' = v
        vprime = trisol(sub,main,super,rhs,/DOUBLE)
        visc = vprime - loop.state.v
     Endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Time stepping section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;------ Do the time stepping here ------
;a bit more than 1/2 timestep for stability
     dt0 = 0.6 * dt              
;.    
     ds0 = shrec_dstate3(temp_loop.state, T, temp_loop.g, temp_loop.A,$
                         temp_loop.s, heating, dt0, T0, $
                         src, depth, safety, uri, fal, DEBUG=DEBUG,$
                         NOVISC=NOVISC,$
                         NO_SAT=NO_SAT, mu=mu, $
                         Coulomb_log=Coulomb_log, $
                         CHROMO_MODEL=CHROMO_MODEL,$
                         LOOP=LOOP)
     
;Put back in the >0.0 ala loop1003.pro  2008/APR/1 HDWIII
     state0.e = (temp_loop.state.e + ds0.e) > 1d-6
;Put back in the > 1.0e2 ala loop1003.pro  2008/APR/1 HDWIII
;+n_e_change
     state0.n_e = (temp_loop.state.n_e + ds0.n_e  )> 1.0d2
;Here is where the viscosity gets added 
     state0.v = temp_loop.state.v + ds0.v+ visc * 0.6 ;$
                                ; +dv_patc*dt0
     state0.time = temp_loop.state.time + dt0
        tloop=temp_loop
        tloop.state=state0
        tloop=shrec_bcs(tloop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Maintain a chromosphere of constant depth, (depth) at a constant
;temperature (T0) based on the equation of state E=3/2NKT, or for our
;case rewritten as n_e=state.e/(3kT0)
     if  strupcase(loop.CHROMO_MODEL)  eq 'CONSTANT CHROMOSPHERE' then  begin
        tloop=shrec_static_atmos_chromo(tloop, T0=T0, DS2=DS2, IS=IS)
        state0=tloop.state
        delvarx, tloop
        endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;We feed the original temperature, T, to shrec_dstate3. Thus,
;implicit timestep for conduction does not use the 0.6*dt
;timestep scheme.
     ds = shrec_dstate3(state0, T, temp_loop.g, temp_loop.A,$
                        temp_loop.s, heating, dt, T0, $
                        src,  depth, safety, uri, fal, DEBUG=DEBUG,$
                        NOVISC=NOVISC,$
                        NO_SAT=NO_SAT, mu=mu, $
                        Coulomb_log=Coulomb_log, $
                        CHROMO_MODEL=CHROMO_MODEL,$
                        LOOP=LOOP)
     
;Put back in the >0.0 ala loop1003.pro  2008/APR/1   
     temp_loop.state.e =(temp_loop.state.e + ds.e )> 1d-6
;Put back in the > 1.0e2 ala loop1003.pro  2008/APR/1
     temp_loop.state.n_e = (temp_loop.state.n_e + ds.n_e)> 1d2
;Here is where the viscosity gets added 
     temp_loop.state.v = temp_loop.state.v + ds.v+ visc ;$
                                ;  +dv_patc*dt0
     temp_loop.state.time = temp_loop.state.time + dt
     n_int = n_int + 1ul
     temp_loop.e_h=heating
     temp_loop.t_max=max(get_loop_temp(temp_loop))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the boundary conditions.
     temp_loop=shrec_bcs(temp_loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     case strupcase(loop.CHROMO_MODEL) of  
;Maintain a chromosphere of constant depth, (depth) at a constant
;temperature (T0) based on the equation of state E=3/2NKT, or for our
;case rewritten as n_e=state.e/(3kT0)
     'CONSTANT CHROMOSPHERE' :  temp_loop=shrec_static_atmos_chromo(temp_loop, T0=T0, DS2=DS2, IS=IS)
     else:
  endcase
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     loops=[loops, temp_loop]
     nn= n_elements(loops) 
     if nn gt 10 then loops=loops[nn-10:*]
                                ; temp_loop.state=state
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make an array to store the 
;information on the volumetric heating rate 
     if size(e_h_array,/TYPE) eq 0 then e_h_array=heating $
     else e_h_array=e_h_array+(heating) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
     Case 1 of
;Level 2 debug
        (debug le 0 ):          ;Do nothing

        ((debug le 1 ) and (debug gt 0)):begin
           if debug_ticker ge 50 then begin
              save, /all, file='shrec_loop.debug.sav'
              debug_ticker=0
           endif else debug_ticker++
        end

        debug gt 1 : begin
           if debug_ticker ge 50 then begin
              save, /all, file='shrec_loop.debug.sav'
              debug_ticker=0
           endif else debug_ticker++
           if strupcase(!d.name) eq 'X' then begin 
              window,0
              stateplot3, temp_loop, /screen, WINDOW=WINDOW_STATE
              
              plot,temp_loop.s_alt[1:n_elements(temp_loop.s_alt)-2],heating, $
                   TITLE="Heating" 
              plot,loop.s_alt[1:n_elements(loop.s_alt)-2], E_H_array, $
                   TITLE="Heating"
              
              if size(nt_beam,/TYPE) EQ 8 then begin
                 particle_display, temp_loop,NT_beam,E_min=20,E_max=200, $
                                   WINDOW=4 
                 
              endif
           endif
           
           xyouts,1,1,'time = '+string(temp_loop.state.time),/device
                                ; wait,1
        end
        else:
     endcase
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                                ;print, 'time=', temp_loop.state.time   
  endwhile
  
                                ;  save, loops, file='shrec_loop_out.sav'
  
  n_e_change=n_e_change_in
;End of time stepper loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the boundary conditions.
  temp_loop=shrec_bcs(temp_loop)
;Send back the average volumetric heating rate
  temp_loop.e_h=(e_h_array/double(n_int))
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if debug gt 0 then begin
     print,'Model time (s): ',temp_loop.state.time,' Number of intervals: ',n_int
     print,'Total number of electrons:',total(temp_loop.state.n_e[1:is-1]*A1*ds1)
     print, 'Avg Courant dt: '+STRCOMPRESS(mean(avg_courant,/DOUBLE),/REMOVE_ALL)

     case strupcase(loop.CHROMO_MODEL) of  
        'STRATIFIED ATMOSPHERE':  print, 'SHrEC: Stratified Atmosphere Chromosphere Set'
        'CONSTANT CHROMOSPHERE' : print, 'SHrEC: Constant Chromosphere Set'
        'SLIDING CHROMOSPHERE': print, 'SHrEC: Sliding Chromosphere Set'
        'SINGLE CELL':  print, 'SHrEC: Single Chromsphere Cell Set' 
        else:  print, 'SHrEC: Single Chromsphere Cell Set <default>' 
     endcase
  endif

  E_H=temp_loop.e_h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Need to reinstate later
;temp_loop.notes[3]='Avg Courant dt: '+STRCOMPRESS(mean(avg_courant,/DOUBLE),/REMOVE_ALL)

  if not  keyword_set(OUT_LOOP) then loop=(temp_loop) $
  else OUT_LOOP=(temp_loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

END                             ;OF MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
