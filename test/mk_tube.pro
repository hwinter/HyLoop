;A script to make a tube of constant cross-section,
; temperature and density to be used for testing puposes.

B0=100d ; Magnetic field [Gauss]
rad=1d8; [cm]
;range=
length=1d9
T_max=1d*1d6 ;Loop top temperature (Approximate)
n_e=9d10
save_file='loop_data/loop_tube.loop'
note='tube of constant radius ['+strcompress(string(rad),/remove_all)+' cm] ' $
     +'temperature ['+strcompress(string(T_max),/remove_all)+' K] ' $
     + 'and density ['+strcompress(string(n_e),/remove_all)+' cm!E-3!N]' 
n_cells=400l                    ;Number of volumes
n_s=n_cells-1l                  ;Number of surfaces
n_depth=20l                     ;Number of surfaces in the Chromosphere
depth=1d6
time=0
x_shift=0d
y_shift=1d9
z_shift=1d9
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plotting choices
bgc=255
fgc=0
xs=600
ys=600
chars=1.
chart=1.
if !d.name ne 'Z' then DEVICE, SET_FONT='Times', /TT_FONT  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
Mega_meter2cm=1d8
cm2Mega_meter=1d-8
;Solar surface gravity acceleration[cm s^-2]
g0 =2.74d4
;Solar radius [cm]
R_Sun=6.96d10
h_chromosphere=2d8
;Height of the Corona above the photosphere[cm]
h_corona=2d8
;Boltzmann constant (erg/K)
kB = 1.38d-16      
;proton mass (g)
mp = 1.67d-24     
;Chromospheric Temperature   
T0=1.d4                        
!except=2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Acceleration due to gravity is zero everywhere
g=dblarr(n_s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
s=length*dindgen(n_s)/(n_s-1l)
L=max(s) ;
x=s
A=(!dpi*(rad)^2d)+dblarr(n_s) ; area [cm^2]
;******* RTV SOLUTION ******************
;given T_max and L, get P(x), T(x), E(x)
 ;t_max=1.4e3*(e_h*(L^2.)/(9.8e4))^(2./7.) ;If you have e_h
heat = 9.14d-7 * T_max^3.51d * (L/2d)^(-2d) ;scaling law if you have t_max
q0=heat
P=((T_max/1.4d3)^3)/L                       ;RTV eqn 4.3
T =dblarr(n_cells)+T_max        ;Constant T
n_e=dblarr(n_cells)+n_e         ;n_e=0.5*n=0.5*(P/kt) number density
E=3./2. *2*n_e* Kb*T            ;E=3/2 nkt=3/2 2n_e kt
v=dblarr(n_s)
b=B0+dblarr(n_s)
rad=rad+dblarr(n_s)
volumes=msu_get_volume(s,a)
e_h=dblarr(n_elements(volumes))+heat
axis=dblarr(3,n_s)
axis[0,*]=s+x_shift
axis[1,*]=y_shift
axis[2,*]=z_shift

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lhist={e:double(e), n_e:double(n_e), v:double(v), time:double(time)}
help,lhist,/str
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sizecheck, lhist,g,A,s, E_h
LOOP=mk_loop_struct(lhist,s,b,g,axis, A,rad, $
                    e_h,t_max, n_depth, note,DEPTH=DEPTH,$
                    start_file=save_file)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sizecheck, loop[0].state,loop[0].g,loop[0].a,loop[0].s,loop[0].E_h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end_jump:
print,'Saving file: ', save_file
save,g, A, s, rad, lhist, E_h,axis,b,loop,q0, heat,e_h,file=save_file
END

