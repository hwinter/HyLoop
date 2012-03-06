;+
;NAME:
;	LOOPEQ
;PURPOSE:
;	Produce an equilibrium loop solution and save it
;	to a file for future reference. 
;CALLING SEQUENCE:
;	loopeq, [g, A, x, heat=heat, Ttop=Ttop, fname='myfile.sav', $
;		L=L, /rebin, rtime=rtime, depth=depth]
;EXAMPLES:
;	loopeq, Ttop = 1e6, L=2e9
;	;Creates an equilibrium solution with the given length
;	;and temperature (Note: Ttop will only be approximate).
;	loopeq, x, A, heat=2e-3, /rebin
;	;Rebins x, A to a bilogarithmic scale and runs the model to
;	;equilibrium using the given heating rate. Since g is not
;	;specified, a semicircular loop in a plane perpendicular to
;	;the photosphere is assumed.
;INPUT PARAMETERS:
;	x - N-element coordinate grid along loop (cm).
;	g - N-element array of gravitational force in 
;		the +x direction as a function of x.
;		If not specified, 0 is used. If a scalar
;		is given, then this is taken to be the
;		maximum (footpoint) value, and a cosine
;		is used for the intermediate values.
;	A - N-element array of cross-sectional area (cm2)
;		as a function of x. If not supplied, then
;		constant, unit cross-section will be assumed.
;OPTIONAL KEYWORD INPUTS:
;       heat - heating rate, erg cm-3 s-1. May be
;               a scalar or a 1D array with N-1
;               elements, corresponding to the volumes
;               between the x axis grid. In the latter
;               case, x must be supplied.
;	Ttop - maximum loop temperature; may be specified in 
;		lieu of heat. If both are specified, then
;		Ttop takes precedence.
;	L - loop length. Required if x is not specified,
;		but ignored if x is specified.
;	rebin - if nonzero, then rebin the x axis to a
;		bilogarithmic grid. If rebin=1, then the
;		same number of gridpoints as the original
;		x are used. If greater than 1, then the
;		number of gridpoints is set equal to the
;		value of rebin.
;	fname - name of idl save file, which will contain
;		g, A, x, heating, and the equilibrium state.
;		Default is 'loopeq.sav'.
;	rtime - time (s) allowed to relax the model. This
;		will be rounded to a long integer. Default
;		value is 1800.
;	depth - just like for loopmodel, but default is 1.
;	safety - just like for loopmodel, but default is 2.0.
;PROCEDURE:
;	Initial conditions are constructed using an isothermal
;	corona derived from the RTV scaling law, with a
;	constant-pressure 1e4 K chromosphere containing 
;	a similar amount of mass as the corona. The LOOPMODEL
;	procedure is used to bring the system to equilibrium,
;	and the results (g, A, x, heat, lhist) are written
;	to an IDL save file by LOOPMODEL.
;HISTORY:
;	1999-Feb-5  begun by C. Kankelborg
;	1999-Feb-13 CCK: bilogarithmic grid spacing,
;		estimate init conditions based on scaling laws
;	1999-Jun-27 CCK: added /fal, /uri options as standard
;	1999-Jul-1  CCK: simplified by using a call to loopmodel
;	1999-Jul-2  CCK: finally implemented rebinning for g, A
;	1999-Sep-20 CCK: fixed off-by-one errors when x is specified
;	1999-Sep-21 CCK: added safety keyword
;	1999-Sep-22 CCK: fixed an off-by-2 error introduced Sep 20
;	1999-Sep-22 CCK: min dx now a function of N (used to be 50m)
;-
pro loopeqt, g, A, x, computer=computer, heat=heat, Ttop=Ttop, fname=fname, L=L, $
             rebin=rebin, rtime=rtime, depth=depth, safety=safety,$
             T0=T0,STATE=STATE

;constants
kB = 1.38e-16 ;Boltzmann constant (erg/K)
mp = 1.67e-24 ;proton mass (g)
gamma = 5.0/3.0 ;ratio of specific heats, Cp/Cv
gs = 2.74e4 ;solar surface gravity

if not keyword_set(T0) then T0 = 1d4 ;loop base temperature (fixed)
if not keyword_set(computer) then computer='filament'
if n_elements(depth) eq 0 then depth = 1
if n_elements(fname) eq 0 then fname = 'loopeq.sav'
if n_elements(rtime) eq 0 then rtime = 1800 ;default 1/2 hour
if not keyword_set(L) then L=max(x)
rtime = long(rtime)

;******** loop geometry *********
if n_elements(rebin) eq 0 then rebin=0 ;rebin can be evaluated now!
if (rebin ne 0) or (n_elements(x) eq 0) then begin
	if rebin gt 1 then N = long(rebin) else begin
        	N = n_elements(x) + 1 ;CCK 1999 Sep 20
                if N eq 0 then begin
                	N = 512 ;default grid size
                endif
        endelse
        if n_elements(L) ne 1 then L=max(x)
	N = (N/2)*2 ;volume grid size, must be an even number!
	
        ;Save old x grid, if it exists.
        if n_elements(x) gt 1 then xold = x
        
        ;Generate new x grid
        d = 50.0d*100 *100/N ;minimum grid spacing, 50m*100/N
        ;given N and d, what is eps?
	eps = 0.1 ;fractional growth rate in grid spacing (first guess)
        for j = 1, 10 do begin ;iterate to get eps correct
        	eps = (eps*L/(2*d))^(2.0d/(N-2.0d)) - 1.0
                ;this converges fast!
        endfor
	base = (1+eps)^((N-2)/2)
	x1 = 0.5*L*base^(findgen((N-2)/2)/double((N-1)/2)-1.0)
	x = [x1, L/2.0, L - reverse(x1)]
endif
if n_elements(N) eq 0 then N=n_elements(x) + 1 ;CCK 1999 Sep 22 (+, not -)
	;handles case when g,a,x specified; CCK 1999 Sep 20
dx = x[1:N-2] - x[0:N-3]
print,'grid spacing runs from ',min(dx)/100.0,' m  to ',max(dx)/100000.0,' km.'

x_alt = [2*x[0]-x[1], (x[0:N-3]+x[1:N-2])/2.0, 2*x[N-2]-x[N-3]]
;x on the volume element grid (like e, n_e)
        
if n_elements(A) eq 0 then begin
	A=make_array(N-1, value=1.0d) 
        ;default uniform, unit cross-section
endif else begin
	if rebin ne 0 then begin
        	if n_elements(xold) ne n_elements(A) then $
                	message,'x and A are of unequal size!'
		;interpolate tabulated A(xold) onto new grid
        	A = interpol(A, xold, x_alt)
        endif
endelse

if n_elements(g) eq 0 then begin
	g = -gs * cos(3.1415927d * x/max(x))
        ;default vertical semicircle
endif else begin
	if rebin ne 0 then begin
        	if n_elements(xold) ne n_elements(g) then $
                	message,'x an g are of unequal size!'
		;interpolate tabulated g(xold) onto new grid
        	g = interpol(g, xold, x_alt)
        endif
endelse
;********* end of loop geometry **********

;timing information
;;delta_t = 1.0 ;time interval (s) between saved data
;;num_iterations = long(rtime/delta_t) ;number of delta_t runs to perform

;*** initial values ***
;Estimated using scaling laws from Serio et al. 1981 ApJ 243:288
if keyword_set(Ttop) then begin
	heat = 9.14d-7 * Ttop^3.51d * (L/2d)^(-2d)  ;scaling law
endif else begin
	Ttop = 52.6d * (L/2d)^0.569d * heat^0.285d ;scaling law
endelse
ntop = 1.33e6 * Ttop^2/(L/2) ;scaling law

T = make_array(N, value=T0)
;depth = 1e6 ;initial chromospheric depth (cm)
corona = where((x_alt gt depth) and (x_alt lt L-depth))
T(corona) = Ttop*(4*(x_alt(corona)-depth)/(L-2*depth) * $
	(1-(x_alt(corona)-depth)/(L-2*depth)))^.33

state = {e:dblarr(N), n_e:dblarr(N), v:dblarr(N-1), time:0.0d}
state.n_e = ntop * Ttop/T ;isobaric approximation
state.e = 3*state.n_e * kB * T ;apply initial temperature

;smooth initial conditions to prevent numerical misbehavior
for j = 1, 5 do begin
	state.e = smooth(state.e,3)
        	;We're at constant pressure, so this shouldn't do anything.
	state.n_e=smooth(state.n_e,3)
endfor

;*********************** run the model
if not keyword_set(safety) then safety=2.0

so =get_bnh_so(computer)
loopmodelt, g, A, x, heat, rtime, state=state, T0=1e4, $
            outfile=fname, /src, /fal, /uri,$
            depth=depth, safety=safety,$
            so=so,LHIST=LHIST
        

end
