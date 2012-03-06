;+
; NAME:
;	
;
; PURPOSE:
;	
;
; CATEGORY:
;	
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	
;
; OPTIONAL OUTPUTS:
;	
;
; COMMON BLOCKS:
;	
;
; SIDE EFFECTS:
;	
;
; RESTRICTIONS:
;	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by:	
;-

FUNCTION gridcheck, state, NOISY=NOISY
;check tempreature derivatives over gaps in the grid
;If gaps are too big, plots to screen and returns 0

 t=state.e/state.n_e
 IF max(abs(t[1:*]/t)) gt 5. THEN ok=0 ELSE ok=1
 IF max(abs(state.e[1:*]/state.e)) gt 5. THEN ok=0
 IF max(abs(state.n_e[1:*]/state.n_e)) gt 5. THEN ok=0

 ;IF NOT ok THEN BEGIN
  ;plot, t[1:*]/t, xtitle='grid #', ytitle='T[i]/T[i-1]'
  ;oplot, t/t[1:*]
 ;ENDIF

RETURN, ok
END

FUNCTION check_res, state, dv, n_depth , noisy=noisy
;check mass resivoir in chromosphere
;If not enough mass, stops.
; N=n_elements(x)
; dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))

 nne=n_elements(state.n_e)
 kb=1.38e-16
 t=state.e/(3.*kb*state.n_e)
 id=where(t ge 1.1e4, nt)
 IF nne - nt le 2 THEN stop

 n0=min(id)
 n1=max(id)
 nne=n_elements(state.n_e)
 core=indgen(n1-n0+1)+n0

 mass= dv*state.n_e[1:Nne-2]    ;don't include the endpoints
 core_mass= dv[core]*state.n_e[core]
 m1=total(mass)/1.e34
 m_core= total(core_mass)/1.e34

 IF Keyword_set(noisy) THEN BEGIN
  plot, mass/1.e34, xtitle='grid point', ytitle='10!u34!n Particles'
  print, 'Total: ', m1
  print, 'Core:  ', m_core

 ENDIF
 return_me =(m1-m_core)/m1
RETURN, return_me
END

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
  ;plot, [lhist.time], [core_mass - core_mass[0]], linestyle=2, $
   ; xtitle='time', ytitle='N - N!d0!n Particles Not Conserved', $
   ; yrange=yrange
  ;oplot, [lhist.time], [mass - mass[0]], linestyle=0
  ;legend, ['Total Volume', 'Corona Volume'], lines=[0,2]

  dmdt = mass[0:*] - mass[1:*]
  IF max(abs(dmdt/1e24)) gt 1 THEN BEGIN
   print, 'Mass lost from Total Loop'
   stop
  ENDIF
 ENDIF

RETURN
END


FUNCTION get_heat, a, x, n_do, delta_t, n_depth, energy=energy, q0=q0, $
    s_form=s_form, t_form=t_form, bgheat=bgheat
;Generate heat function for input to loopmodel
;OPTIONAL KEYWORDS:
;   bgheat
;   t_form
;   s_form
;   energy
;   q0

 space_size=n_elements(x)
 time_size =n_do
 dv=0.5*(a(0:space_size-2) +a(1:space_size-1)) * (x(1:space_size-1) - x(0:space_size-2))

;DEFINE SPACE AND TIME HEATING STRUCTURE
 IF n_elements(s_form) eq 0 THEN s_form=fltarr(space_size-1)+1.
 IF n_elements(t_form) eq 0 THEN  t_form=fltarr(time_size )+1.
 hot=s_form # t_form

;RESCALE TO energy (erg) OR TO q0 (erg/cm^3/s), USE VOLUME OF CORONA
 IF n_elements(q0) eq 1 THEN hot1=hot*q0 ELSE BEGIN
  IF n_elements(ENERGY) gt 0 THEN BEGIN
   corona=indgen(space_size-1)
   IF n_elements(n_depth) eq 2 THEN corona=corona[n_depth[0]+1:space_size-n_depth[1]-1] $
    ELSE corona=corona[n_depth+1:space_size-n_depth-1]
   scl= ENERGY/( delta_t * total((dv[corona]#(fltarr(n_do)+1.))* hot[corona, *] ))
   hot1=hot*scl
   E_corona=total( (hot1[corona, *]) *( dv[corona]#(fltarr(n_do)+1.))*delta_t )
   print,'Total Corona Energy: ',E_corona
   IF abs( ENERGY- E_corona) ge 0.1*ENERGY THEN BEGIN
    print,'Heat funciton is BOGUS!'
    STOP
   ENDIF
  ENDIF ELSE BEGIN  ;if energy & q0 both undefined, don't renormalize
   hot1=hot
   print,'Energy & q0 unspecified. Run with user-defined heat function.'
  ENDELSE
 ENDELSE

;BACKGROUND HEATING
 IF n_elements(bgheat) eq 1 THEN bgheat=bgheat*(fltarr(space_size-1)+1.)
 IF n_elements(bgheat) ne space_size-1 AND n_elements(bgheat) ne 0 THEN BEGIN
  print, 'User-defined background is wrong size.  Need '+string(fix(space_size-1))+' elements.'
  STOP
 ENDIF
 IF n_elements(bgheat) eq space_size-1 THEN BEGIN
  hot1 = hot1 + bgheat#(fltarr(time_size )+1.)
  print,'User-defined background incorperated.'
 ENDIF

;check output size
 IF n_elements(hot1[*,0]) ne space_size-1 THEN BEGIN
  print, 'space resolution is off'
 ;danger !!!!
 ;stop
 ENDIF
 IF n_elements(hot1[0,*]) ne time_size THEN BEGIN
  print, 'time resolution is off'
 ;danger !!!!
 ;stop
 ENDIF

 print, 'min/max of heat function: (erg/s/cm^3)', min(hot1),'/', max(hot1)
RETURN, hot1    ;variable is returned
END

;============================================================================================================
PRO PATC_evolve_hd_loop  , infile, time, dt, $
    ENERGY=ENERGY, outfile=outfile, q0=q0, $
    t_form=t_form, s_form=s_form, atm=atm, showme=showme, bgheat=bgheat, $
    test=test, novisc=novisc, version=version, computer=computer
;+
;SUBROUTINES:
;     loop1003.pro is default. Will run loop1002.pro with keyword version=1002
;     stateplot.pro, sizecheck.pro, check_rez.pro, get_heat.pro.pro, gridcheck.pro, hd_terms.pro
;INPUT:     infile     = string name of file to import, includes extension
;     time     = sim time (s) to run;  grid = time/delta_t
;     dt   = time step to return. Default is 5s.
;OPTIONAL IN:   energy    = ammount of extera ergs to dump in time 'time'
;     q0   = (erg/s/cm^3) heat input for grid, except photospere
;     outfile  = name of file to save, includes extension
;     t_form   = heating function in time, (erg/s/cm^3).  Must have time/delta_t elements
;     s_form   = heating function in space, (erg/s/cm^3).  Must have N-1 elements
;     atm  = sets uri=0, fal=0, spit=1 in loop1001 and subroutines.  Atomic Physics
;     showme   = plots onscreen while running.  Slower.
;     bgheat   = background volumentric heating added to e_h post-normalization.
;     test = keeps from checking mass res in Chromosphere
;     novisc   = Runs without analytical viscosity.
;     version = If set to '1002' will use loop1002.pro instead of loop1003.pro
;     computer= Options: "mithra" or "earth", earth is default.  Moves to directory with
;          apopriately compiles c subroutines. Must run on Solaris.
;SAMPLE CALL:
;     evolve10, '../klimchuk/NRLtest1.sav',1000, q0=2.e-6, /showme, /atm
;     evolve10, path+'xbp1_start.save', 1000., 5., outfile=path+'xbp1_10000.sav', q0=7e-4, showme=1
;
;PURPOSE:   run charles' loop codes for n_do=time/delta_t steps.
;     user specific heating funcitons, normalized to energy optional input
;     uses initial conditions of last element of 'infile'
;HISTORY:
;
;   ??    assume major changes in save files - that they include
;      depth, n_depth, ...
;   8/01  Change to heating footpoints
;   9/01  change from variable heat to variable power mode
;   11/07 Fixed a problem with energy normalization when running with delta_t ne 1.
;   1/8/02    changed heat function radically.
;   02/02 add t_form or s_form as optional input keywords, passed to get_heat.pro
;   02/02 add keyword 'atm' to use standard (non-kankelborgian) atomic physics
;     changed input/output filenames.  Updates all around.
;   10/02 Added "computer" keyword, to take advantage of new Solaris "Earth"
;-
 startit = systime(1)

 IF keyword_set(version) then version=version ELSE version=0
 IF keyword_set(atm) $
 THEN BEGIN     ;--- Pedestrian Atomic Physics ----
    spit = 1   ;use spitzer conductivity in Kappa
    uri = 0       ;don't use fledman abundances in radiative loss above 1e5K - use VAU corona
    fal=0   ;don't use avrett TR model from 1e4-1e5K - use VAU transition region
 ENDIF ELSE BEGIN   ;--- Kankelborgian Atomic Physics ---
    spit = 0   ;don't use spitzer conductivity in Kappa - use Fontenla Avrett Loeser tabulated Kappa
    uri = 1       ;use fledman abundances in radiative loss above 1e5K
    fal=1   ;use avrett TR model from 1e4-1e5K
 ENDELSE

;INPUT/OUTPUT
;changed the save file path
;HDWIII 04/17/2003
 inname=strmid(infile, 0, strpos(infile,'.',/reverse_search))
 IF keyword_set(outfile) THEN savefile=outfile ELSE $
    savefile='/disk/data1/winter/bp_sim/data/'+inname+'_'+strcompress(fix(time),/remove_all)+'.sav'
 print, 'will save file: ', savefile
 restore, infile       ;infile must have right format
 n_start=n_elements(lhist) -1

;SET TIMES
 IF n_elements(delta_t) eq 0 THEN delta_t=5.0   ;default 5 s time resolution
 IF n_elements(dt) ne 0 THEN delta_t=dt     ;grandfather in old notation
 n_do=fix(float(time)/float(delta_t) +0.5 )
 time=fix(n_do*delta_t)          ;reasign interger time to do

;HEAT FUNCTION
 hot = get_heat(a,x, n_do, delta_t, n_depth, energy=energy, q0=q0, s_form=s_form, t_form=t_form, bgheat=bgheat)
 ;window, 0
 ;window,1
 ;shade_surf, [[e_h],[hot]]

 N=n_elements(x)
 dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))

 sizecheck, lhist(n_start), g,a,x,E_h
 state=lhist(n_start)
;Changed directories to new paths
 IF n_elements(computer) ne 0 THEN IF strupcase(computer) eq "MITHRA" THEN cd,'/disk/data1/winter/bp_sim/charles/' $
    ELSE cd,'/disk/data1/winter/bp_sim/charles/earth/', current=curr_id    $;move to run c subroutines
    ELSE cd,'/disk/data1/winter/bp_sim/charles/earth/', current=curr_id    ;move to run c subroutines
;Added the curr_id parameter to make the program more general
;HDWIII 04/17/2003
 FOR i=0, n_do-1 DO BEGIN      ;MAIN LOOP
  IF NOT gridcheck( state) THEN print,'Bad grid.  Suggest regrid3, lhist[0],g,a,x,e_h[0],/nosave'
  IF keyword_set(showme) THEN IF (i mod showme eq 0 ) AND (i ne 0) THEN BEGIN
    wset,0
    stateplot,x,state,/screen
    wset,1
    hd_terms, state, x,a,g,e_h[*,i],/plotit
    wset,0
  ENDIF
  IF NOT keyword_set(test) and i gt 0 THEN BEGIN
   IF check_res(state, dv, n_depth) le .8 THEN BEGIN
    i=n_do-1    ;no chromosphere - get out!
    IF n_elements(note) eq 0 THEN note='Dry Chromosphere' ELSE note=[note, 'Dry Chromosphere']
   ENDIF
  ENDIF
;  IF version eq 1002 THEN $ ;older version of code, still has dA in K
;    loop1002,state, g, A, x, hot[*,i], delta_t,uri=uri, $
;           fal=fal,spit=spit,debug=debug, novisc=novisc $
;   ELSE loop1003,state, g, A, x, hot[*,i], delta_t,uri=uri, $
;            fal=fal,spit=spit,debug=debug, novisc=novisc

patc_loop,state, g, A, x, hot[*,i], delta_t,uri=uri, $
            fal=fal,spit=spit,debug=debug, novisc=novisc

;CONCAT TO LOOP HISTORY
  lhist=[lhist,state]
  e_h = [[e_h], [hot[*,i]]]
  print,i
  IF (i mod 100 eq 0) AND (i ne 0) THEN $
    ;Changed the next line to reflect new ownership
    ;HDWIII 04/17/2003
    save, file='/disk/data1/winter/bp_sim/test/midway_test.sav', lhist,g,A,x, E_h, delta_t, orig, n_depth, note
 ENDFOR

 endit=systime(1)
 IF n_elements(note) eq 0 THEN note=string(endit -startit)+'Seconds ' $
    ELSE note=[note, string(endit -startit)+'Seconds ']
 cd,'/disk/data1/winter/bp_sim/'
 save, file=savefile, lhist, g, A, x, E_h, delta_t, orig, n_depth, note
 print,'wrote file:"'+savefile+'"'

RETURN
END






