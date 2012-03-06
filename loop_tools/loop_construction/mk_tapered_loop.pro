;+
; NAME: mk_tapered_loop.pro
;	
;
; PURPOSE: Creates a loop file and linearly tapers the loop radius (holding
; the apex width constant) according to a specified gamma, diameter
; and length where gamma is the ratio of the apex radius to the
; footprint radius. Adjusts loop area and magnetic field strength accordingly.
;	
;
; CATEGORY: Sci-Fi/Horror
;	
;
; CALLING SEQUENCE: loop = lin_taper(gamma, diameter, length)
;	
;
; INPUTS: gamma

;       diameter: [cm] Cross-sectional diameter of loop top. The
;       maximum diameter
;     
;       length: [cm] Length of the main loop, not the strand.  Assumed
;       to be semi-circular through the center.
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;       B_mag: [Gauss] at loop apex
; OUTPUTS:
;  Loop structure containing the tags
;	 state:  Loop History structure $
;       
;        g: [cm s^-2] Parallel acceleration due to gravity
;    
;        A:[cm^2] area of the faces
;        s: [cm] length coordinate.  Face to face of the grid cells 
;        n: [cm^-3] Electron density
;        E_h, 
;        L [cm] New loop length,
;        T_max [[K] Loops maximum temperature
;        orig, 
;	
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS: Tapered loop file.
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
;	Onle input even number of cells for n_cells.
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by: Henry (Trae) Winter
;       Modified by: Chester (Chet) Curme
;-

function mk_tapered_loop,gamma, diameter, length, $
                         T_MAX=T_MAX, $
                         T0=T0,debug=debug, $
                         B_Mag=B_Mag, OUTNAME=OUTNAME, $
                         FILENAME=FILENAME, N_CELLS=N_CELLS,$
                         X_SHIFT=X_SHIFT,Y_SHIFT=Y_SHIFT,$
                         Z_SHIFT=Z_SHIFT, LOOP=LOOP,$
                         SIGMA_FACTOR=SIGMA_FACTOR,$
                         _Extra=Extra

  

loop = 1
compile_opt STRICTARR
Notes=strarr(5)
notes[0]='Tapered loop'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;Do some work with keywords & positional parameters
if size(gamma,/type) eq 0 then gamma_in=1 else gamma_in=gamma

if size(t_max,/type) eq 0 then t_max=1d6
if not keyword_set(X_SHIFT) then X_SHIFT=0d $
else X_SHIFT=double(X_SHIFT)
if not keyword_set(Y_SHIFT)  then Y_SHIFT=0d $
else Y_SHIFT=double(Y_SHIFT)
if not keyword_set(Z_SHIFT)  then Z_SHIFT=0d

if size(diameter,/TYPE) eq 0 then diameter=7d8 ;[cm]
if size(length,/TYPE) eq 0 then length=1d9;[cm]
if size(B_mag,/TYPE) eq 0 then B=100 $
else     B=B_mag                ;[Gauss]
;
if not keyword_set(N_CELLS)  then $
  N_CELLS =long64(300) else $
  N_CELLS =long64(N_CELLS)

;Number of surface grids
n_surf=N_CELLS-1

if not keyword_set(ALPHA) then ALPHA=0d0
if not keyword_set(BETA) then BETA=0d0
;Chromospheric Temperature   
if not keyword_set(T0) then T0=!shrec_T0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the axis for the strand.
;NB For a strand the radius of the loop in the YZ plane (not the
;cross-sectional radius of the strand) is not a constant but a function
;of Z.

;Have to see notes for derivation.
strand_length=!dpi*(length-(Y_SHIFT/(gamma+1)))-(Y_SHIFT/(gamma+1))
;First we do a uniform spacing, than we will spline in on a
;non-uniform grid.
;Make the grid spacings in the function of a Gaussian
theta_steps=mk_gauss_grid( n_cells, 1d0,1d-4, sigma=2 )
;                 SIGMA_FACTOR=SIGMA_FACTOR )

theta=!dpi*theta_steps
R_of_theta=Length-($
                 Y_SHIFT*($
                        (1.0+(gamma*sin(theta))/(gamma+1) )$
                  )) 
zz =  R_of_theta* sin(theta)
yy = -R_of_theta*cos(theta)
xx = X_SHIFT*gamma*(zz/max(zz))

s=theta*R_of_theta

;Make the grid spacings 
;s=mk_gauss_grid( n_cells, strand_length, DS=DS,$            
;                 SIGMA_FACTOR=SIGMA_FACTOR )

;Map the X, Y, & Z components of the strand axis to the new grid.
;x=spline(s_old, xx,s,0.01)
;y=spline(s_old, yy,s, 0.01)
;z=spline(s_old, zz,s, 0.01)
x=xx
y=yy
z=zz

axis=dblarr(3,n_surf)
axis[0,*]=x
axis[1,*]=y
axis[2,*]=z+Z_SHIFT+!shrec_h_corona
z=reform(axis[2,*])
;stop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Dimensionless gravitational acceleration parallel to the loop.
; See Klimchuck,Tanner, & Moore, 2004
;
g=-1d0*cos(theta)*((!shrec_R_Sun/(!shrec_R_Sun+axis[2,*]))^2d)
;Gravitational acceleration [cm s^2]
g=g*!shrec_g0
r_apex=(.5d*diameter)
r_foot = r_apex/gamma_in
;
A_0=(r_apex)^2*!dpi
; Maxwells [Gauss cm^2]
flux=b*A_0
rad=dblarr(n_surf)

; Linearly taper radius (this could be more elegant)
if ((n_surf mod 2) eq 0) then begin
   for i=0, n_surf/2-1 do begin
      rad[i] = r_foot + ((r_apex - r_foot)/s[n_surf/2-1])*s[i]
      rad[i+n_surf/2] = r_apex - ((r_apex - r_foot)/s[n_surf/2-1])*(s[i+n_surf/2]-s[n_surf/2])
   endfor
endif else begin
   for i=0, n_surf/2 do begin
      rad[i] = r_foot + ((r_apex - r_foot)/s[n_surf/2])*s[i]
      rad[i+n_surf/2] = r_apex - ((r_apex - r_foot)/s[n_surf/2])*(s[i+n_surf/2]-s[n_surf/2])
   endfor
endelse

;Calculate areas in cm^2

; Adjust area
a=(rad)^2*!dpi


; Adjust magnetic field strength B to conserve flux.
b = flux/a
;Strand length
L=max(s)
s_alt=shrec_get_s_alt(s)
;Volume elements
dv=shrec_get_volume(s,a)

time=0.                         ;start time

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
        P=get_p_t_law_pressure(l, alpha,$
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
        T_s = T_max * ( 4d * s/L $
                        * (1d - (s/L)) )^0.333333d ;CCK empirical


;Convert to the volume grid by taking a simple average.
        T[1:n_cells-2ul]=(T_s[0:n_surf-2ul]+T_s[1:n_surf-1ul])/2d0

;Now make the endcaps take on the value of the last s grid
        T[0]=T_s[0]
        T[n_cells-1ul]=T_s[n_surf-1ul]

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
                    E_H=e_h,T_MAX=t_max,$
                    NOTES=notes)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Artificially smooth
for j=0,10 do loop.state.e=smooth(loop.state.e,3)
for j=0,10 do loop.state.n_e=smooth(loop.state.n_e,3)   
for j=0,50 do loop.a=smooth(loop.a,3) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Let the loop come to hydrodynamic equilibrium if desired.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Case 1 of
   keyword_set(outname) :  Begin
      print, 'saving file: "'+outname
      save, file=outname,loop
   end
   keyword_set(FILENAME) :  Begin
      print, 'saving file: "'+FILENAME
      save, file=FILENAME,loop
   end
   else:
endcase


return, loop

END
