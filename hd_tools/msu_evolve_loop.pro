
;+
;SUBROUTINES: 	
;		loop1003.pro is default. Will run loop1002.pro with keyword version=1002
;		stateplot.pro, sizecheck.pro, check_rez.pro, get_heat.pro.pro, gridcheck.pro, hd_terms.pro
;              
;INPUT:		infile 	= string name of file to import, includes extension
;		time 	= sim time (s) to run;  grid = time/delta_t
;		dt	= time step to return. Default is 5s.
;OPTIONAL IN:	energy 	= ammount of extera ergs to dump in time 'time'
;		q0	= (erg/s/cm^3) heat input for grid, except photospere
;		outfile	= name of file to save, includes extension
;		t_form	= heating function in time, (erg/s/cm^3).  Must have time/delta_t elements
;		s_form	= heating function in space, (erg/s/cm^3).  Must have N-1 elements
;		atm	= sets uri=0, fal=0, spit=1 in loop1001 and subroutines.  Atomic Physics
;		showme	= plots onscreen while running.  Slower. 
;		bgheat	= background volumentric heating added to e_h post-normalization.
;		test	= keeps from checking mass res in Chromosphere 
;		novisc	= Runs without analytical viscosity.
;		version = If set to '1002' will use loop1002.pro instead of loop1003.pro
;		
;SAMPLE CALL: 	
;		evolve10, '../klimchuk/NRLtest1.sav',1000, q0=2.e-6, /showme, /atm
;		evolve10, path+'xbp1_start.save', 1000., 5., outfile=path+'xbp1_10000.sav', q0=7e-4, showme=1
;
;PURPOSE:	run charles' loop codes for n_do=time/delta_t steps.
;		user specific heating funcitons, normalized to energy optional input 
;		uses initial conditions of last element of 'infile'
;HISTORY:
;	
;	??	assume major changes in save files - that they include
;			depth, n_depth, ...
;	8/01	Change to heating footpoints 
;	9/01	change from variable heat to variable power mode
;	11/07	Fixed a problem with energy normalization when running with delta_t ne 1.
;	1/8/02	changed heat function radically.  
;	02/02	add t_form or s_form as optional input keywords, passed to get_heat.pro
;	02/02	add keyword 'atm' to use standard (non-kankelborgian) atomic physics
;		changed input/output filenames.  Updates all around.
;	10/02	Added "computer" keyword, to take advantage of new Solaris "Earth"
;-
;============================================================================================================

PRO msu_evolve_loop, g,a,x, time, dt,e_h, n_depth, $
                 ENERGY=ENERGY, outfile=outfile, q0=q0, $
                 t_form=t_form, s_form=s_form, atm=atm, $
                 showme=showme, bgheat=bgheat, $
                 test=test, novisc=novisc, version=version, computer=computer,$
                 lhist=lhist,so=so
 
if !d.name eq 'X' then window,0
 startit = systime(1)

 IF keyword_set(version) then version=version ELSE version=0
;Set the atomic physics parameters
 IF keyword_set(atm) $
 THEN BEGIN		;--- Pedestrian Atomic Physics ----
	spit = 1	;use spitzer conductivity in Kappa
	uri = 0		;don't use fledman abundances in radiative loss above 1e5K - use VAU corona
	fal=0		;don't use avrett TR model from 1e4-1e5K - use VAU transition region
 ENDIF ELSE BEGIN	;--- Kankelborgian Atomic Physics ---
	spit = 0	;don't use spitzer conductivity in Kappa - use Fontenla Avrett Loeser tabulated Kappa
	uri = 1		;use fledman abundances in radiative loss above 1e5K
	fal=1		;use avrett TR model from 1e4-1e5K
 ENDELSE

;INPUT/OUTPUT
; inname=strmid(infile, 0, strpos(infile,'.',/reverse_search))
 IF keyword_set(outfile) THEN savefile=outfile ELSE $
	savefile=strcompress(fix(time),/remove_all)+'.sav'
 print, 'will save file: ', savefile
 ;restore, infile		;infile must have right format
 n_start=n_elements(lhist) -1

;SET TIMES
 IF n_elements(delta_t) eq 0 THEN delta_t=5.0	;default 5 s time resolution
 IF n_elements(dt) ne 0 THEN delta_t=dt 	;grandfather in old notation
 n_do=fix(float(time)/float(delta_t) +0.5 )
 time=fix(n_do*delta_t)				;reasign interger time to do

;HEAT FUNCTION
 hot = get_heat(a,x, n_do, delta_t, n_depth, energy=energy, q0=q0, s_form=s_form, t_form=t_form, bgheat=bgheat)
; N=n_elements(x)
; dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))
 dv=msu_get_volume(x,a)
 ;sizecheck, lhist(n_start), g,a,x,E_h
 state=lhist(n_start)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BEGIN MAIN LOOP
 FOR i=0, n_do-1 DO BEGIN
;Check grid spacing
  ;   IF NOT gridcheck(state) THEN begin
                                ;print,'Bad grid.  Suggest regrid3, lhist[0],g,a,x,e_h[0],/nosave'
   ;      print,'regridding'
    ;     regrid6, state,g,a,x,hot[*,i],/nosave
     ;endif
;Plot the curret loop state if showme is set.
     IF keyword_set(showme) THEN IF (i mod showme eq 0 ) AND (i ne 0) THEN BEGIN
         if !d.name eq 'X' then wset,0
         if !d.name eq 'X' then stateplot,x,state,/screen 
                                ;window,1
	;hd_terms, state, x,a,g,e_h[*,i],/plotit
        
     ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;If not a test run, then check the chromosphere.
    IF NOT keyword_set(test) and i gt 0 THEN BEGIN
        IF check_res(state, dv, n_depth) le .8 THEN BEGIN
            i=n_do-1            ;no chromosphere - get out!
            IF n_elements(note) eq 0 THEN note='Dry Chromosphere' ELSE note=[note, 'Dry Chromosphere']
        ENDIF
    ENDIF
    
    
    IF version eq 1002 THEN $	;older version of code, still has dA in K
      loop1002,state, g, A, x, hot[*,i], delta_t,uri=uri,fal=fal,spit=spit,debug=debug, novisc=novisc $
      ELSE	loop1003t2,state, g, A, x, hot[*,i], delta_t,uri=uri,fal=fal,spit=spit,$
                           debug=debug, novisc=novisc,so=so
    
;CONCAT TO LOOP HISTORY
    lhist=[lhist,state]
    e_h = [[e_h], [hot[*,i]]]
ENDFOR
;End main loop.

endit=systime(1)
IF n_elements(note) eq 0 THEN note=string(endit -startit)+'Seconds ' $
	ELSE note=[note, string(endit -startit)+'Seconds ']

save, file=savefile, lhist, g, A, x, E_h, delta_t, orig, n_depth, note
print,'wrote file:"'+savefile+'"'

RETURN
END






