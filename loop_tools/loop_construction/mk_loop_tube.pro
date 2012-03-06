;+
; NAME:
;	mk_loop_tube
;
; PURPOSE:
;	Generate a flat tube of constant cross-section 
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
;	radius: [cm]
;
;       diameter: [cm] Cross-sectional diameter of loop. Considered
;       constand for now. 
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
;        g: [cm s^-2] Parallel acceleration duw to gravity
;    
;        A:[cm^2] area of the fid faces
;       
;        s: [cm] length coordinate.  Face to face of the grid cells 
;        n: [cm^-3] Electron density
;        E_h, 
;        L [cm] New loop length, \
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
;                   Heavily modified by Henry (Trae) Winter II (HDWIII)
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
function mk_loop_tube,diameter,length, $
  T_MAX=T_MAX,N_E=N_E ,$
  N_DEPTH=N_DEPTH,$
  TO=T0,UNIFORM=UNIFORM, $
  B=B,Q0=Q0,  nosave=nosave, $
  outname=outname,N_CELLS=N_CELLS,$
  X_SHIFT=X_SHIFT,Y_SHIFT=Y_SHIFT,$
  Z_SHIFT=Z_SHIFT, LOOP=LOOP,$
  SIGMA_FACTOR=SIGMA_FACTOR

compile_opt STRICTARR
Notes=strarr(5)
notes[0]='Semi circular loop'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Do some work with keywords & positional parameters
if size(t_max,/type) eq 0 then t_max=1d6
if size(N_E,/type) eq 0 then N_E=1D9
	
if not keyword_set(Q0) then q0=0.0007 
;;erg/x - number to yield t_max=9e5 K - RAM 10092002

if not keyword_set(X_SHIFT) then X_SHIFT=0d $
else X_SHIFT=double(X_SHIFT)
if not keyword_set(Y_SHIFT)  then Y_SHIFT=0d $
else Y_SHIFT=double(Y_SHIFT)
if not keyword_set(Z_SHIFT)  then Z_SHIFT=0d

if size(diameter,/TYPE) eq 0 then diameter=7d8 ;[cm]
if size(length,/TYPE) eq 0 then length=1d9;[cm]
if size(B,/TYPE) eq 0 then B=100 ;[Gauss]
;
if size(n_depth ,/TYPE) eq 0 then n_depth=100l

if not keyword_set(N_CELLS)  then $
  N_CELLS =long64(300) else $
  N_CELLS =long64(N_CELLS)

IF keyword_set(outname) THEN outname=outname $
ELSE outname='SC_Loop'+strcompress(q0,/remove_all)

;Number of surface grids
n_surf=N_CELLS-1

if not keyword_set(ALPHA) then ALPHA=0d0
if not keyword_set(BETA) then BETA=0d0
;Chromospheric Temperature   
if not keyword_set(T0) then T0=!shrec_T0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the axis for a semicirclecoronal s grid
if not keyword_set(UNIFORM) then $
  s=mk_gauss_grid( n_cells, length, DS=DS,$            
                   SIGMA_FACTOR=SIGMA_FACTOR ) $
  else s=length*dindgen(n_surf)/(n_surf-1ul)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the axis for a semicircle
;radius=length/!dpi
;theta =s/radius
;zz = (radius * sin(theta))
;yy = -1d0*radius * cos(theta)
zz =dblarr(n_surf)+ 0.5 *diameter
yy=dblarr(n_surf)+ 0.5 *diameter
axis=dblarr(3,n_surf)
axis[0,*]=s+X_SHIFT
axis[1,*]=(yy+Y_SHIFT)
axis[2,*]=zz+Z_SHIFT+!shrec_h_corona
;z=reform(axis[2,*])
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Dimensionless gravitational acceleration parallel to the loop.
; See Klimchuck,Tanner, & Moore, 2004
;
;g=-1d0*cos(theta)*((!shrec_R_Sun/(!shrec_R_Sun+axis[2,*]))^2d)
;Gravitational acceleration [cm s^2]
;g=g*!shrec_g0
g=dblarr(n_surf)
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
time=0.                         ;start time

T=dblarr(N_CELLS)+T_MAX
n_e=dblarr(N_CELLS)+N_E
E=dblarr(N_CELLS)
v = fltarr(n_surf)
volumes=shrec_get_volume(s,a)

E=(3./2.) *2*n_e* !shrec_kB*T            

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
;if keyword_set(PSL) then $
;  LOOP.e_h=get_p_t_law_heat( LOOP, $
;                             tmax=tmax, $
;                             alpha=alpha, $
;                             beta=beta, $
;                             P_0=p) $
;  else 
LOOP.e_h =LOOP.e_h+( 9.14d-7 * T_max^3.51d * (L/2d)^(-2d) )
;scaling law if you have t_max
       
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Add on the Chromosphere
;if keyword_set(ADD_CHROMO) then $
;  LOOP=add_loop_chromo(loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;regrid if desired
;if keyword_set(regrid) then begin
; if !d.name eq 'X' then begin
;     oldwindow=!d.window
;     window,16, title=!computer+'Regrid'
; endif
; regrid_step, loop, /showme
;              
; if !d.name eq 'X' then wset, oldwindow
;endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;junk=check_res( loop.state, dv, n_depth, /noisy)
;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
if size(outname,/type)lt 1 then outname=''

 IF keyword_set(nosave) THEN BEGIN
  print,'not saving' 
 ENDIF ELSE BEGIN
     print, 'saving file: "'+outname+'.loop"'
     
     save, file=outname+'.loop',loop
  
 ENDELSE

return, loop

END







