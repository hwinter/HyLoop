;+
;NAME: 
;	loopmodel
;PUPROSE:
;	Front end for numerical loop model (loop6.pro). Takes
;	an initial state and propagates forward in time.
;	Results are saved to disk at 1s time intervals.
;CALLING SEQUENCE:
;	loopmodel, g, A, x, heat, interval, [, state=state, lhist=lhist, $
;		T0=T0, outfile=outfile, /src, /fal, /uri, depth=depth]
;INPUT PARAMETERS:
;	interval - amount of time (s) to run the model forward.
;		This gets rounded to the nearest second.
;OPTIONAL KEYWORD INPUTS:
;	lhist - An array of state vectors giving the previous
;		history of the loop. If lhist is specified, then
;		the initial conditions are read from the last
;		entry of lhist and state (if given) is ignored.
;		On output, lhist contains a history of states.
;	state - Initial state structure. Must be supplied if 
;		lhist is not. On output, contains the final state.
;		state.e - internal energy (N volume elements)
;		state.n_e - electron density (N volume elements)
;		state.v - velocity in x direction at the
;		    interstices between the volume 
;		    elements (N-1 elements)
;		state.time - time of specified state.
;	T0 - Temperature at the loop boundaries (chromospheric
;		footpoints). If not specified, it is read
;		from the zeroth volume element of the state vector.
;	outfile - File to store results (lhist, g, A, x, heat). If
;		the display device is set to the z-buffer, then
;		real time graphical output is suppressed, and the
;		present state of the system (state, g, A, x, heat)
;		is output as a save file called outfile+'.snap'.
;	src - optional switch to cut off radiative losses below 
;		T=T0, thus holding the chromospheric temperature
;		above the boundary condition temperature.
;	depth - optional desired chromospheric depth. If this keyword
;		is nonzero, then corrections are applied to try to
;		maintain a chromosphere of a desired depth (add or
;		remove mass at the 1.1*T0 isotherm, which slides
;		the isotherm toward desired depth). If
;		depth <= 1, then the default depth of 1e6 cm is used.
;		If depth is greater than 1, then the value of the
;		keyword is the desired chromospheric depth in cm.
;	safety - timestepping safety factor; see loop6.pro.
;OUTPUTS:
;	lhist - array of state structures, giving the loop history
;		as a function of time.
;	state - final state of the loop.
;HISTORY:
;	1999-Feb-4 written by Charles C. Kankelborg
;	1999-Feb-12 CCK fixed lhist append bug
;	1999-Feb-16 CCK: depth & safety keywords (see loop6.pro)
;	1999-Jun-27 CCK: uri & fal keywords (see loop6.pro radloss)
;	1999-Jun-29 CCK: modified so that when 'z' buffer ia used,
;		graphical output is suppressed and realtime info is
;		sent to a small save file (*.snap). This is very
;		handy for running in batch mode!
;	1999-Aug-18 CCK: fixed crash when depth keyword not set
;	1999-Sep-20 CCK: fixed lhist append off-by-one error
;	1999-Dec-6 CCK: updated from loop5 to loop6.
;-
pro msu_loopmodel, loop, interval, $
                   T0=T0, FILE_PREFIX=FILE_PREFIX, $
                   FILE_EXT=FILE_EXT, src=src, uri=uri, fal=fal, $
                   depth=depth, safety=safety,QUIET=QUIET, $ ;Begin regrid keywords
                   REGRID=REGRID, GRID_SAFETY=GRID_SAFETY, $
                   PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, $
                   MAX_STEP=MAX_STEP, $
                   QUADRATIC=QUADRATIC, LSQUADRATIC=LSQUADRATIC, $
                   SPLINE=SPLINE, SHOWME=SHOWME,$
                   DELTA_T=DELTA_T, DEBUG=DEBUG, $
                   HEAT_FUNCTION=HEAT_FUNCTION, $
                   WINDOW_REGRID=WINDOW_REGRID, $
                   WINDOW_STATE=WINDOW_STATE, $
                   SO=SO, E_H=E_H, $
                   NOVISC=NOVISC, $
                   NO_SAT=NO_SAT,$
                   NT_BEAM=NT_BEAM,$
                   NT_PART_FUNC=NT_PART_FUNC,$ ; PATC section
                   NT_BREMS=NT_BREMS,$
                   NT_DELTA_E=NT_DELTA_E,$
                   NT_DELTA_MOMENTUM=NT_DELTA_MOMENTUM

                   




COMPILE_OPT STRICTARR
;initialize computer time
t_start = systime(1) 
;Initialize System variables if necessary
defsysv, !msul_set, exists=test_set
if test_set le 0 then set_loop_sys_variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check keywords
if size(loop, /TYPE) eq 0 then begin
		print,'Hey, what are the initial conditions?'
		message,'No loop input!'
            goto, end_jump
        endif

if not keyword_set(HEAT_FUNCTION)then HEAT_FUNCTION='get_constant_heat'

;file in which to save results
if not keyword_set(FILE_PREFIX) then FILE_PREFIX ='' 
if not keyword_set(FILE_EXT) then  FILE_EXT='loop'
;timing information
;time interval (s) between saved data
if not keyword_set(DELTA_T) then delta_t = 1.0 

if not keyword_set(T0) then T0 = loop.state.e[0]/(3*loop.state.n_e[0]*!msul_kB)
if not keyword_set(REGRID) then REGRID=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
old_loop=loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
num_iterations = long(interval+0.5)  ;round to nearest second

i1 = long(n_elements(old_loop)) ;where are we starting?
loop=old_loop[i1-1]

for i=i1, i1+num_iterations-1l do begin
    case  REGRID of
      1: regrid_step,loop, SHOWME=SHOWME, GRID_SAFETY=GRID_SAFETY, $
                  MAX_STEP=MAX_STEP,PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, $
                  ENERGY_PD=ENERGY_PD, PARTICLE_PD=PARTICLE_PD, $
                  MOMENTUM_PD=MOMENTUM_PD, VOLUME_PD=VOLUME_PD, $
                  ENERGY_CHANGE=ENERGY_CHANGE, $
                  MOMENTUM_CHANGE=MOMENTUM_CHANGE, $
                  VOLUME_CHANGE=VOLUME_CHANGE ,$
                  WINDOW=WINDOW_REGRID 
      2: regrid_step2,loop, SHOWME=SHOWME, GRID_SAFETY=GRID_SAFETY, $
                  MAX_STEP=MAX_STEP,PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, $
                  ENERGY_PD=ENERGY_PD, PARTICLE_PD=PARTICLE_PD, $
                  MOMENTUM_PD=MOMENTUM_PD, VOLUME_PD=VOLUME_PD, $
                  ENERGY_CHANGE=ENERGY_CHANGE, $
                  MOMENTUM_CHANGE=MOMENTUM_CHANGE, $
                  VOLUME_CHANGE=VOLUME_CHANGE ,$
                  WINDOW=WINDOW_REGRID 
      else: begin
        MAX_STEP=0
        ENERGY_PD=0
        PARTICLE_PD=0
        MOMENTUM_PD=0
        VOLUME_PD=0
        ENERGY_CHANGE=0 
        MOMENTUM_CHANGE=0
        VOLUME_CHANGE=0
        
    end
endcase

;Get the grid spacing
    N = n_elements(loop.state.e) ;figure out grid size
    ds = loop.s[1:N-2] - loop.s[0:N-3]
   
    if not keyword_set(QUIET) then Print, 'Number of volume grids: ',N
;Evolve the loop state in time 
    msu_loop, loop, delta_t, T0=T0, $
              src=src, fal=fal, uri=uri,$
              depth=depth, safety=safety, $
              DEBUG=DEBUG, HEAT_FUNCTION=HEAT_FUNCTION, $
              SO=SO, E_H=E_H,$
              NOVISC=NOVISC, $
              NO_SAT=NO_SAT,$
              NT_BEAM=NT_BEAM,NT_PART_FUNC=NT_PART_FUNC,$
              NT_BREMS=NT_BREMS,$
              NT_DELTA_E=NT_DELTA_E,$
              NT_DELTA_MOMENTUM=NT_DELTA_MOMENTUM
    
                   
  
	
;Save a snapshot of the present state.
    save, loop, ENERGY_PD, PARTICLE_PD, $
          MOMENTUM_PD, VOLUME_PD, $
          ENERGY_CHANGE, $
          MOMENTUM_CHANGE, $
          VOLUME_CHANGE,$
          E_H,$
          NT_BEAM,NT_PART_FUNC,$
          NT_BREMS,$
          NT_DELTA_E,$
          NT_DELTA_MOMENTUM,$
          filename=strcompress(FILE_PREFIX $
          +string(loop.state.time,FORMAT='(I05)') $
          +'.'+FILE_EXT,/REMOVE_ALL)

    if keyword_set(SHOWME) then $
      stateplot2, loop.s, loop.state, /screen, WINDOW=WINDOW_STATE 
;stop
    if not keyword_set(QUIET) then begin
        print,'Computer: ', strupcase(!computer)
        print,'Computer Time: ', systime()
        print,'Model time: '+strcompress(string(loop.state.time),/REMOVE_ALL)+ $
              's    Real time: '+strcompress(string(systime(1)-t_start),/REMOVE_ALL),'s'
        print,'Min/Max V:  '+strcompress(string(min(loop.state.v)/1d5),/REMOVE_ALL)+ $
              '/'+strcompress(string(max(loop.state.v)/1d5),/REMOVE_ALL)+'[km/s]'
        print, 'T_max: '+strcompress(string(loop.t_max),/REMOVE_ALL)
        print,'grid spacing runs from ',min(ds)/100.0,' m  to ',max(ds)/100000.0,' km.'
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        n_cells=n_elements(loop.state.n_e)
        print, 'Flux: '+strcompress($
                                    string(int_tabulated(loop.s_alt[1:n_cells-2],loop.e_h)),$
                                           /REMOVE_ALL)+' erg cm^-2 sec^-1'
        if not keyword_set(depth) then $
          print,'keyword DEPTH = OFF' Else $           
          print,'keyword DEPTH =',depth             

        if  keyword_set(NOVISC) then $
          print,'Viscosity model  = OFF' Else $
          print,'Viscosity model = ON'
        
        print,'########################################################################'
    endif
    
endfor

help, nt_beam
end_jump:
t_end= systime(1) ;get computer time
run_time=t_end-t_start
end
