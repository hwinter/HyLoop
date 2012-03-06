;+
; NAME:
;	mk_semi_circular_loop
;
; PURPOSE:
;	Generate a semi-circular loop then 
;        create a file for input to the evolve hydro codes and PaTC
;
; CATEGORY:
;	Hydrodynamics codes
;       PaTC
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;       diameter: [cm] Cross-sectional diameter of loop. Considered
;       constant for now. 
;     
;       length: [cm] Length of the loop, It's a semi-circular loop so
;       the  radius of that circle will be length/!dpi. 
;
;       B: [Gauss] Considered constant since the loop diameter is
;       constant
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	Q0: Volumetric heating rates
;
; OUTPUTS:
;  Loop structure containing the tags
;	 state:  Loop History structure $
;       
;        g: [cm s^-2] Parallel acceleration due to gravity
;    
;        A:[cm^2] area of the faces
;       
;        s: [cm] length coordinate.  Face to face of the grid cells 
;        n: [cm^-3] Electron density
;        E_h, 
;        L [cm] New loop length,
;        T_max [[K] Loops maximum temperature
;        orig, 
;        n_depth depth of chomospheric penetration
;	
;
; OPTIONAL OUTPUTS:
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
; 	Written by:Rebecca McMullen (RAM) start_loop.pro. 
;                   Heavily modified by Henry (Trae) Winter III (HDWIII)
;
;        10/29/01 - Plan to run w/o toilet bowl chromosphere!
;                   extend last footpoint deep into the chromosphere
;        04/30/02	RAM	fixed discontinuity in dx
;			changed to constant area in chromosphere
;        10/29/01 - Use file 'xbp1_1020.sav', from data at 10:20UT
;        04/17/03 - Stops taken out HDWIII
;        11/28/04 - Stops taken out HDWIII
;        02/08/2006 - Made mk_semi_circular_loop from t_start_loop.pro
;                   -Many undocumented changes.
;        09/07/2007- Changed the T calculation  so that it is originally
;                    calculated on the S grid then an average is taken  to
;                    put in in the volume grid.  This gets rid of a 
;                    Floating illegal operand error.
;Temperature profile on the s grid
	
;-
PRO mk_semi_circular_loop,diameter,length, $
                          T_MAX=T_MAX, N_DEPTH=N_DEPTH,$
                          TO=T0,$
                          B_Mag=B_Mag,Q0=Q0,  NOSAVE=NOSAVE, $
                          outname=outname,N_CELLS=N_CELLS,$
                          X_SHIFT=X_SHIFT,Y_SHIFT=Y_SHIFT,$
                          Z_SHIFT=Z_SHIFT, LOOP=LOOP,$
                          DEPTH=DEPTH,$
                          ADD_CHROMO=ADD_CHROMO,$
                          SIGMA_FACTOR=SIGMA_FACTOR,$
                          PSL=PSL, ALPHA=ALPHA, BETA=BETA,$
                          HEAT_NAME=HEAT_NAME, TEST=TEST, $
                          NO_SAT=NO_SAT,$
                          NOVISC=NOVISC,$
                          CONSTANT_CHROMO=CONSTANT_CHROMO, $
                          SLIDE_CHROMO=SLIDE_CHROMO
version=2.0	
;-
  compile_opt STRICTARR
  Notes=strarr(5)
  notes[0]='Semi circular loop'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Do some work with keywords & positional parameters
  if size(t_max,/type) eq 0 then t_max=1d6
  
  if not keyword_set(Q0) then q0=0.0007 
;;erg/x - number to yield t_max=9e5 K - RAM 10092002

  if not keyword_set(X_SHIFT) then X_SHIFT=0d $
  else X_SHIFT=double(X_SHIFT)
  if not keyword_set(Y_SHIFT)  then Y_SHIFT=0d $
  else Y_SHIFT=double(Y_SHIFT)
  if not keyword_set(Z_SHIFT)  then Z_SHIFT=0d

  if size(diameter,/TYPE) eq 0 then diameter=7d8 ;[cm]
  if size(length,/TYPE) eq 0 then length=1d9     ;[cm]
  if size(B_mag,/TYPE) eq 0 then B=100 $
  else     B=B_mag              ;[Gauss]
;
  if size(n_depth ,/TYPE) eq 0 then n_depth=0

  if not keyword_set(N_CELLS)  then $
     N_CELLS =long64(300) else $
        N_CELLS =long64(N_CELLS)

  IF keyword_set(outname) THEN outname=outname $
  ELSE outname='SC_Loop'+strcompress(q0,/remove_all)

  if not keyword_set(DEPTH) then DEPTH= 0.0
;Number of surface grids
  n_surf=N_CELLS-1

  if not keyword_set(ALPHA) then ALPHA=0d0
  if not keyword_set(BETA) then BETA=0d0
;Chromospheric Temperature   
  if not keyword_set(T0) then T0=!shrec_T0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if !d.name eq 'X' then begin
     window, xs=800, ys=700, /free
     evolve_window=!D.window
   endif  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the axis for a semi-circle coronal s grid
  s=mk_gauss_grid( n_cells, length, DS=DS,$            
                   SIGMA_FACTOR=SIGMA_FACTOR )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the axis for a semicircle
  radius=length/!dpi
  theta =s/radius
  zz = (radius * sin(theta))
  yy = -1d0*radius * cos(theta)
  axis=dblarr(3,n_surf)
  axis[0,*]=DBLARR(n_surf)+X_SHIFT
  axis[1,*]=(yy+Y_SHIFT)
  axis[2,*]=zz+Z_SHIFT+!shrec_h_corona
  z=reform(axis[2,*])
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Dimensionless gravitational acceleration parallel to the loop.
; See Klimchuck,Tanner, & Moore, 2004
;
  g=-1d0*cos(theta)*((!shrec_R_Sun/(!shrec_R_Sun+axis[2,*]))^2d)
;Gravitational acceleration [cm s^2]
  g=g*!shrec_g0
  B=dblarr(n_surf)+B

  RAD=dblarr(n_surf)+(.5d*diameter)
;Calculate areas in cm^2
  a=(rad)^2*!dpi
; Maxwells [Gauss cm^2]
  flux=max(b*a)
;Loop length
  L=max(s)
  s_alt=shrec_get_s_alt(s)
;Volume elements
  dv=shrec_get_volume(s,a)
;stop
;IF n_elements(q0) eq 0 THEN BEGIN
;    IF n_elements(power) eq 0 THEN power=1d24 ;erg/s Cargill & Klimchuck (2004)
;    q0=power/total(dv) ;was 7.e-4 erg/cm^3/s Kankelborg&Longcope, 1999 p.71
;ENDIF ELSE IF n_elements(power) eq 0 THEN  power=q0*total(dv)
  time=0.                       ;start time

  T=dblarr(N_CELLS)
  n_e=dblarr(N_CELLS)
  E=dblarr(N_CELLS)
  v = fltarr(n_surf)
  volumes=shrec_get_volume(s,a)

  case 1 of 
     keyword_set(PSL):begin
        if not keyword_set(alpha) then alpha=0
        if not keyword_set(beta) then beta=0
        if not keyword_set(flux) then $
           flux =get_p_t_law_flux( l, alpha,Tmax)
        P=get_p_t_law_pressure(length, alpha,$
                               TMAX=T_MAX)
        T=get_p_t_law_temp_profile(s_alt, alpha, tmax=t_max)
     end
     else :begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;default to the RTV scaling laws
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;RTV SOLUTION 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Give the coronal portion of the loop a density and temperature 
;  profile based on RTV heating
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;given T_max and L, get P(s), T(s), E(s)
                                ;t_max=1.4e3*(e_h*(L^2.)/(9.8e4))^(2./7.) ;If you have e_h

;Loop is at a constant pressure
        P=((T_max/1.4d3)^3)/L   ;RTV eqn 4.3
        
;Made the following T calculation to get rid of a 
; Floating illegal operand error.
;Temperature profile on the s grid
        T_s = (T_max-T0)*( 4d * s/L $
                        * (1d - (s/L)) )^0.333333d ;CCK empirical
        T_s+=T0


;Convert to the volume grid by taking a simple average.
        T[1:n_cells-2ul]=(T_s[0:n_surf-2ul]+T_s[1:n_surf-1ul])/2d0

;Now make the endcaps take on the value of the last s grid
        T[0]=T_s[0]
        T[n_cells-1ul]=T_s[n_surf-1ul]
;stop
     end
  endcase

;put in footpt cutoff - don't allow temperatures too low.
  T  >= T0      
;n_e=0.5*n=0.5*(P/kt) number density             
  n_e=0.5*(P/(!shrec_kB*T))              
;E=3/2 nkt=3/2 2n_e kt
  E=3./2. *2*n_e* !shrec_kB*T  
  
  e_h=dblarr(n_elements(volumes))
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the state variable and check it
  state={e:double(e), n_e:double(n_e), v:double(v), time:float(time)}
  sizecheck, state,g,A,s, E_h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the loop structure for PaTC
  LOOP=mk_loop_struct(STATE=state,$
                      S_ARRAY=s,B=b,G=g,AXIS=axis,$
                      AREA=A,RAD=rad, $
                      E_H=e_h,T_MAX=t_max,N_DEPTH=n_depth,$
                      NOTES=notes,DEPTH=DEPTH,$
                      start_file=outname+'.sav')
;scaling law if you have t_max
  
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Add on the Chromosphere
  if keyword_set(ADD_CHROMO) then $
     LOOP=add_loop_chromo(loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Skip the equilibrium part
;goto, end_jump
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;If a heating function is not listed use get_p_t_law_heat to make a
;constant heating function
  if not keyword_set(heat_name) then begin
     heat_name_in='get_p_t_law_heat'
     
     
  if keyword_set(PSL) then $
     LOOP.e_h=get_p_t_law_heat( LOOP, $
                                tmax=tmax, $
                                alpha=alpha, $
                                beta=beta, $
                                P_0=p) $
  else LOOP.e_h =LOOP.e_h+( 9.14d-7 * T_max^3.51d * (L/2d)^(-2d) )
     
     DEFSYSV, '!bg_heat', EXISTS = test1

     if test1 ne 1 then begin
        no_bg_heat=1
        DEFSYSV, '!heat_alpha', EXISTS = test2
        if test2 ne 1 then alpha_h=0 else $
           alpha_h=!heat_alpha
        DEFSYSV, '!heat_Tmax', EXISTS = test3
        if test3 ne 1 then Tmax=1d6 else $
           Tmax=!heat_Tmax

        
;Define the energy flux due to thermal heating.
        flux =get_p_t_law_flux(loop.l, alpha_h,Tmax)
        
        e_h=(flux/loop.l)+(0d0*loop.e_h)

        DEFSYSV, '!bg_heat',e_h
     endif


     
     
  endif else $
     heat_name_in=heat_name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  equil_counter=1
  done=0.
  max_v=1d7
;stop
  max_time=1d0*60d0*60d0            ;Time to allow loop to come to equilibrium
  rtime=5d0;*60d0                    ;Output timestep
  DELTA_T=30d0                      ;reporting  timestep
  time=0d0                          ;The simulation start time
  safety=5d0                        ;Number that will be divided by
                                ;  the C. condition to determine the timestep
  grid_safety=10d               ;Number that will be divided by
                                ;  the minimum characterstic scale length to determine
                                ;  the grid sizing

  if keyword_set(test) then goto,end_jump 

  ;stop
  while done le 1 do begin

     n_loop=n_elements(Loop)
     temp_loop=loop[n_loop-1l]
     hyloop ,temp_loop, $
             rtime, $           ;
             T0=1d4,  src=src, uri=uri, fal=fal, $
             safety= safety , $ ;SHOWME=SHOWME, DEBUG=DEBUG   , $
             QUIET=QUIET, HEAT_FUNCTION=heat_name_in,$
             PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, $
             MAX_STEP=MAX_STEP, FILE_EXT='stable', $
             grid_safety= grid_safety,$ ; ,regrid=REGRID , $
             E_H=E_H, FILE_PREFIX=OUTPUT_PREFIX,$
             NOVISC=NOVISC,DEPTH=depth, $
             NO_SAT=NO_SAT,$
             CONSTANT_CHROMO=CONSTANT_CHROMO, $
             SLIDE_CHROMO=SLIDE_CHROMO,$
             CLOCK_TIME=CLOCK_TIME, PLUS_TIME=PLUS_TIME
     
     PLUS_TIME=CLOCK_TIME
     loop=temp_loop
     if !d.name eq 'X' then begin
        wset, evolve_window
        stateplot3, loop, /SCREEN
     endif
;Determine the maximum veloxity
     max_v=max(abs(loop.state.v))
     if max_v le 2d5  then done +=0.333/5 else done =0

     print, 'Min/Max velocity:'
     pmm,abs(loop.state.v)
     
     if equil_counter eq 400 then done=1
     if done le 0 then begin
;Artificially smooth
        for j=0,10 do loop.state.e=smooth(loop.state.e,3)    
;Artificially smooth
        for j=0,10 do loop.state.v=smooth(loop.state.v,5)    
;Artificially kill the velocity
;        loop.state.v=0d0
     endif
     equil_counter +=1
                                ;if loop.state.time gt max_time then done=1
  endwhile

  loop.state.time=0d
end_jump:


  if size(outname,/type)lt 1 then outname=''

  IF keyword_set(nosave) THEN BEGIN
    ; print,'not saving' 
  ENDIF ELSE BEGIN
     print, 'saving file: "'+outname+'.loop"'
     
     save, file=outname+'.loop',loop
     
  ENDELSE

END







