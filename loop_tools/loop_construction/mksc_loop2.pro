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
;	 lhist:  Loop History structure $
;       
;        g: [cm s^-2] Parallel acceleration duw to gravity
;    
;        A:[cm^2] area of the fid faces
;       
;        x: [cm] length coordinate.  Face to face of the grid cells 
;        n: [cm^-3] Electron density
;        E_h, 
;        L [cm] New loop half-length, \
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
	
;-
PRO mk_sc_loop2,diameter,length, B, lhist, $
                          axis, rad, g,A,x, E_h, L, $
                          T_max, orig, n_depth,$
                          Q0=Q0, power=power, nosave=nosave,$
                          outname=outname,N_CELLS=N_CELLS,$
                          X_SHIFT=X_SHIFT,Y_SHIFT=Y_SHIFT,$
                          Z_SHIFT=Z_SHIFT

	
if keyword_set(Q0) ne 1 then q0=0.0007 
;;erg/x - number to yield t_max=9e5 K - RAM 10092002
if keyword_set(X_SHIFT) ne 1 then X_SHIFT=0d $
else X_SHIFT=double(X_SHIFT)
if keyword_set(Y_SHIFT) ne 1 then Y_SHIFT=0d $
else Y_SHIFT=double(Y_SHIFT)
if keyword_set(Z_SHIFT) ne 1 then Z_SHIFT=0d $
else Z_SHIFT=double(Z_SHIFT)



;diameter=7d8
;length=14d9
;B=10
;power=1d24
;q0=0.0007
;X_SHIFT=0d;.5d*length
;Y_SHIFT=0d;5d*length
;Z_SHIFT=0d;3d*1d8


if keyword_set(N_CELLS) ne 1 then $
  N_CELLS =long64(200) else $
  N_CELLS =long64(N_CELLS)

IF keyword_set(outname) THEN outname=outname $
ELSE outname='./loop_save'+strcompress(power,/remove_all)+'.sav'
radius=length/!dpi
theta = (indgen(N_CELLS)*!dpi / (N_CELLS-1))-(!dpi/2)
yy = radius * sin(theta)
zz = radius * cos(theta)
axis=dblarr(3,N_CELLS)
axis[0,*]=DBLARR(N_CELLS)+X_SHIFT
axis[1,*]=reverse(yy+Y_SHIFT)
axis[2,*]=zz+Z_SHIFT

B=DINDGEN(N_CELLS)+B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
Mega_meter2cm=1d8
cm2Mega_meter=1d-8
;Solar surface gravity acceleration[cm s^-2]
g0 =(2.74d4)
;Solar radius [cm]
R_Sun=6.96d10
;Height of the Corona above the photosphere[cm]
h_corona=R_Sun+2d8
;Boltzmann constant (erg/K)
kB = 1.38e-16      
;proton mass (g)
mp = 1.67e-24                                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


RAD=dblarr(N_CELLS)+(.5d*diameter)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Dimensionless gravitational acceleration parallel to the loop.
; See Klimchuck,Tanner, & Moore, 2004
g=(R_Sun/(h_corona+axis[2,*]))*sin(theta)
;AXIS            FLOAT     = Array[3, 200]	;cm
;B               FLOAT     = Array[200]		;Gauss
;RAD             FLOAT     = Array[200]		;cross-sec radius cm
;L               FLOAT     = Array[1, 200]	;cm
;G               FLOAT     = Array[1, 200]	;dimless

;Calculate areas in cm^2
a=(rad)^2*!dpi
; Maxwells [Gauss cm^2]
flux=max(b*a)
;Coordiante of grid faces[cm]
x=(indgen(N_CELLS)*!dpi / (N_CELLS-1))*radius ;
 

;pmm,x
;stop

;Loop Half-length
L=max(x)/2.
;Gravitational acceleration [cm s^2]
g=reform(g)*g0
;Says it all
N=n_elements(x)
;Volume elements?
dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))


IF n_elements(q0) eq 0 THEN BEGIN
    IF n_elements(power) eq 0 THEN power=1d24 ;erg/s Cargill & Klimchuck (2004)
    q0=power/total(dv) ;was 7.e-4 erg/cm^3/s Kankelborg&Longcope, 1999 p.71
ENDIF ELSE IF n_elements(power) eq 0 THEN  power=q0*total(dv)


e_h=q0                          ;heat energy
time=0.                         ;start time

;******* RTV SOLUTION ******************
;given e_h and L, get P(x), T(x), E(x)
t_max=1.4e3*(e_h*(L^2.)/(9.8e4))^(2./7.)
P=((T_max/1.4E3)^3)/L		;RTV eqn 4.3
T = T_max * ( 4d * x/(2d*L) * (1d - x/(2d*L)) )^0.333333 ;CCK empirical
T = T > 1e4  ;put in footpt cutoff - don't allow temperatures too low.
n_e=0.5*(P/(kb*T))              ;n_e=0.5*n=0.5*(P/kt) number density
E=3./2. *2*n_e* Kb*T            ;E=3/2 nkt=3/2 2n_e kt

;define this on the grid points
orig={x:x, b:b, g:g, e:e, n_e:n_e, e_h:e_h, axis:axis, t:t, dv:dv, a:a}

;adjust array sizes for input to loop?.pro
N = n_elements(x)
x = 0.5*( x(0:N-2) + x(1:N-1) )
N = n_elements(b)
b = 0.5*( b(0:N-2) + b(1:N-1) )
N = n_elements(g)
g = 0.5*( g(0:N-2) + g(1:N-1) )
N = n_elements(a)
a = 0.5*( a(0:N-2) + a(1:N-1) )

N = n_elements(e)
v = fltarr(N-1)
e_h0=fltarr(N-2)+e_h

;***************** add on chromosphere ************
;UPDATE 10/29/01 - run w/o toilet bowl chromosphere!
;extend last footpoint deep into the chromosphere
;keep grid refined in TR

 x=x-x[0]	;get rid of leading space	04/30/02	RAM
 n_depth=101


;make a gravitationally stratified atmosphere
 T0=1.e4
;Don't Understand this
;Adding on a chromosphere
 ne_addon=reverse(findgen(n_depth)*10^(alog10(n_e[0])+2)/(n_depth-1) + n_e[0] +n_e[0]-n_e[1])

 x_addon=alog(ne_addon-n_e[0])*kb*t[0]/(0.5*mp*g[0]) 
 x_addon=x_addon-x_addon[0]
 depth=max(x_addon)
 if NOT (x_addon[0] eq 0 and depth ne 0 ) THEN stop
 xstep=x[1]-x[0]
 x=[x_addon, depth+xstep+ x, 2*(depth+xstep)+max(x)- reverse(x_addon)]
 n_e= [ne_addon, n_e, reverse(ne_addon)]

IF 0 THEN BEGIN ;OLD WAY TO DO IT
 IF keyword_set(newfile) THEN x_addon= 1-exp(-findgen(n_depth)/(10.*n_depth)) ELSE $
 	x_addon= 1-exp(-findgen(n_depth)/(0.25*n_depth))
 scale=(x[1]-x[0])/(x_addon[n_depth-1]-x_addon[n_depth-2])
 x_addon=x_addon*scale
 dd=max(x_addon) 
 dx=x_addon[n_depth-1]-x_addon[n_depth-2]
 x = [x_addon, dd+dx+x, 2*dd+2*dx+max(x)-reverse(x_addon)]

;make a gravitationally stratified atmosphere
 T0=1.e4
 ne_addon=n_e[0]*exp(0.5*mp*g[0]*(x_addon-dd)/(kb*T0))	;p=p0 exp{-.5mgz/kT} note: g<0
 n_e=[ne_addon, n_e, reverse(ne_addon)]
 print, 'Chromosphere Depth: '+string((dd-x_addon[0])*g[0]/(-2.74e4)  )+'(cm)'
ENDIF
;assume constant t in the chromosphere
 E_addon=3./2. *2*ne_addon* Kb*T0	;E=3/2 nkt=3/2 2n_e kt
   e=[e_addon, e, reverse(e_addon)]

;04/30/02 - RAM - keep chromosphere area constant.
 a_addon=fltarr(n_depth) + a[0]	;*exp(-1.*(x_addon-dd-x[0])/sqrt(a[0])
    a=[a_addon, a, reverse(a_addon)]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;add on for the Axes HDWIII 02/09/2006 
;Assume that the x and y remain fixed, and z goes negative 
axis_x_addon=dblarr(n_depth)+axis[0,0]
axis_y_addon1=dblarr(n_depth)+axis[1,0]
axis_y_addon2=dblarr(n_depth)+axis[1,N_CELLS-1]
new_axis=dblarr(3,(N_CELLS+2l*n_depth)-1l)
help,x,new_axis
new_axis[0,*]=[axis_x_addon,reform(axis[0,1:n_elements(axis[0,*])-1l]),$
               axis_x_addon]
new_axis[1,*]=[axis_y_addon1,reform(axis[1,1:n_elements(axis[0,*])-1l]),$
               axis_y_addon2]

z0=reform(axis[2,0])
zn=reform(axis[2,N_CELLS-1])
new_axis[2,*]=[z0[0]-reverse(x_addon),$
               reform(axis[2,1:n_elements(axis[2,*])-1l]),zn[0]-x_addon]
;stop
axis=new_axis
;constant velocity, gravity and heating
  c0=fltarr(n_depth)+1
    v=[c0*v(0), v, c0*v(n_elements(v)-1)]
    g=[c0*g(0), g, c0*g(n_elements(g)-1)]
    e_h=[c0*0.+q0, e_h0, c0*0+q0]

;************* finish, check, save, exit ***********
  lhist={e:double(e), n_e:double(n_e), v:double(v), time:float(time)}

 sizecheck, lhist,g,A,x, E_h
;Don't know what this stop was for.  Asked Becca about it 
;04/01/2003
;stop
 regrid4, lhist,g,a,x,e_h,/showme,/nosave
 sizecheck, lhist,g,A,x, E_h
 N=n_elements(x)
 dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))
 junk=check_res( lhist, dv, n_depth, /noisy)
 
 rad=dblarr(n)+rad[0]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the loop structure for PaTC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;t3d, axis,matrix=axis,rotate=[5,0,0]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;


N = n_elements(lhist.v)
n_x=n_elements(x)
d_x=x[n_x-1]-x[n_x-2]
;n_x=10000L
old_surf=[x, x[n_x-1]+d_x]

 x_alt = [2*x[0]-x[1],(x[0:N-3]+x[1:N-2])/2.0,2*x[N-2]-x[N-3]]
;Good grief! I had to work with this part for awhile!
;new_x=x_alt
;Extrapolate a new magnetic field 
new_x=(dindgen(n_x)/(n_x-1))*max(x)
d_x=new_x[1]-new_x[0]
x_surf=[new_x, new_x[n_x-1]+d_x]

;x defined in the volumes
x_alt = [2*new_x[0]-new_x[1],$
         (new_x[0:N_x-3]+new_x[1:N_x-2])/2.0,$
         2*new_x[N_x-2]-new_x[N_x-3]]

b2=spline(orig.x,orig.b,new_x)
orig_n_x=n_elements(orig.x);Extrapolate a new axis in cm
f_x=(dindgen(orig_n_x)/(orig_n_x-1))*max(x)

rad2=dblarr(n_x)
rad2=spline(f_x,rad,new_x)
new_axis=dblarr(3,n_x)
new_x_axis=dblarr(n_x)
new_y=dblarr(n_x)
new_z=dblarr(n_x)
new_x_axis=spline(f_x,orig.axis[0,*],new_x)
new_y=reverse(spline(f_x,orig.axis[1,*],new_x))
new_z=spline(f_x,orig.axis[2,*],new_x)

new_axis[0,*]=new_x_axis*1d+8
new_axis[1,*]=new_y*1d+8
new_axis[2,*]=new_z*1d+8

;l=dblarr(n_x)
;l=spline(f_x,l,new_x)

A=spline(x,A,new_x)
g=spline(x,g,new_x)
e_h=spline(x[0:n_elements(x)-2],e_h,new_x[0:n_x-2]) 
lHist.e=spline(old_surf,lHist.e,x_surf)
lHist.n_e=spline(old_surf,lHist.n_e,x_surf)
lHist.v=spline(x,lHist.v,new_x)
x=new_x
loop_x=loop.l*1d+8
loop={l:l, $
     x:x, $                    ;Convert to cm
     x_alt:  x_alt,$
     axis:new_axis,$
     e:lhist.e ,$
     n_e:lhist.n_e,$
     v:lhist.v,$
     b:b2,$
     g:g,$
     rad:rad2,$
     t_max:t_max,$
     note:note,$
     start_file:start_file,$
     T:lhist.e/(3.0*lhist.n_e*kB)}



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 IF keyword_set(nosave) THEN BEGIN
  print,'not saving' 
 ENDIF ELSE BEGIN
 print, 'saving file: "'+outname+'"'
  save, file=outname, lhist, g,A,x, E_h, L, T_max, orig, n_depth,$
    axis,b,rad, note

 ENDELSE
;RETURN
END







