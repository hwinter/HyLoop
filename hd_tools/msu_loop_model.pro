;+
;SUBROUTINES:
;     loop1003.pro is default. Will run loop1002.pro with keyword version=1002
;     stateplot.pro, sizecheck.pro, check_rez.pro, get_heat.pro.pro, gridcheck.pro, hd_terms.pro
;INPUT:     infile     = string name of file to import, includes extension
;     time     = sim time (s) to run;  grid = time/delta_t
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
;       ENERGY:  Total energy to dump into the corona [ergs]
;       Q0: Volumetric heating rate [ergs/cm^3/s]
;	S_FORM: Normalized distribution of heat in space
;       T_FORM: Normalized distribution of heat in time 
;       BGHEAT: additional background heating [ergs/cm^3/s] 
;       QUIET:  Supress text output
;
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
;============================================================================================================
PRO msu_loop_model, loop, time, $
                    ENERGY=ENERGY, DELTA_T=DELTA_T, Q0=Q0, $
                    T_FORM=T_FORM, S_FORM=S_FORM,$
                    ATM=ATM, SHOWME=SHOWME, BGHEAT=BGHEAT, $
                    TEST=TEST, NOVISC=NOVISC, VERSION=VERSION,$
                    SO=SO,SPIT=SPIT, URI=URI, FAL=FAL,$
                    OUTPUT_PREFIX=OUTPUT_PREFIX,QUIET=QUIET,$
                    LHIST=LHIST

startit = systime(1)
;Set so that () is for functions and [] is for array indices, rigidly!
compile_opt strictarr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set keywords
IF not keyword_set(VERSION) then VERSION='msu_loop'
IF keyword_set(atm) $
  THEN BEGIN   
;--- Pedestrian Atomic Physics ----
    spit = 1                    ;use spitzer conductivity in Kappa               
    uri = 0                     ;don't use fledman abundances in radiative loss above 1e5K 
                                ;- use VAU corona
    fal=0                       ;don't use avrett TR model from 1e4-1e5K - use VAU transition region
ENDIF ELSE BEGIN                
;--- Kankelborgian Atomic Physics ---
    spit = 0                    ;don't use spitzer conductivity in Kappa 
                                ;- use Fontenla Avrett Loeser tabulated Kappa
    uri = 1                     ;use fledman abundances in radiative loss above 1e5K
    fal=1                       ;use avrett TR model from 1e4-1e5K
ENDELSE

;Name prefix for all output data files
IF not keyword_set(OUTPUT_PREFIX) THEN $ 
  OUTPUT_PREFIX=strcompress(arr2str(bin_date(),$
                            DELIM='_',/NO_DUP),$
                    /REMOVE_ALL)+'_'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;STATE=loop.state
n_loops=n_elements(loop)
n_start=n_loops-1UL
;s=loop[n_start].s
;A=loop[n_start].A
;stop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SET TIMES
IF n_elements(delta_t) eq 0 THEN delta_t=5.0 ;default 1 s time resolution
n_do=fix(float(time)/float(delta_t) +0.5 )
time=fix(n_do*delta_t)          ;reasign interger time to do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;HEAT FUNCTION
hot = msu_get_heat(loop.a,loop.s, n_do, delta_t, n_depth, ENERGY=ENERGY, $
                   Q0=Q0, S_FORM=S_FORM, T_FORM=T_FORM, BGHEAT=BGHEAT)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
N=n_elements(loop[n_start].s)
dv=get_loop_vol(loop[n_start])
state=loop[n_start].state

msu_sizecheck, loop

;HDWIII 04/17/2003
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MAIN LOOP
 FOR i=0ul, n_do-1ul DO BEGIN 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check the grid resolution     
;  IF NOT gridcheck( state) THEN print,'Bad grid.  Suggest regrid3, lhist[0],g,a,x,e_h[0],/nosave'
;No longer needed.  This is now done in the core MSU_Loop program
;  using the regridding program
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;If SHOWME keyword is set then plot terms
  IF keyword_set(showme) THEN IF (i mod showme eq 0 ) AND (i ne 0) THEN BEGIN
    window,0
    stateplot2,loop.s,loop.state,/screen
   ; window,1
    ;msu_hd_terms, loop.state,loop.s,loop.a,loop.g, hot[*,i],/plotit
    
  ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check on the Chromosphere.  If dry, backout!
;  IF NOT keyword_set(test) and i gt 0 THEN BEGIN
;   IF check_res(loop.state, dv, n_depth) le .8 THEN BEGIN
;    i=n_do-1    ;no chromosphere - get out!
;    IF n_elements(note) eq 0 THEN note='Dry Chromosphere' ELSE note=[note, 'Dry Chromosphere']
;   ENDIF
;  ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check to see which version of the loop model the user wants to use.
;Multiple options exist
Case VERSION OF 
    '1002':  $                  ;older version of code, still has dA in K
      loop1002,loop.state, loop.g, loop.A, loop.s, hot[*,i], delta_t,$
               uri=uri,fal=fal,spit=spit,debug=debug,$
               novisc=novisc 
    'msu_loop': msu_loop,loop, hot[*,i], delta_t,$
                         uri=uri,fal=fal,spit=spit,debug=debug, $
                         novisc=novisc,so=so, STATE=STATE
    else: msu_loop,loop, hot[*,i], delta_t,$
                         uri=uri,fal=fal,spit=spit,debug=debug, $
                         novisc=novisc,so=so, STATE=STATE
endcase

    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CONCAT TO LOOP HISTORY
 ; lhist=[lhist,state]
 ; e_h = [[e_h], [hot[*,i]]]
  print,i
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
ENDFOR


endit=systime(1)
if not keyword_set(QUIET) then begin
    print , string(endit -startit)+' Seconds '
    print,'wrote file:"'+savefile+'"'
endif


RETURN
END






