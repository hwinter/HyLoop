;mk_green_field_script
$source ~/.cshrc
;From line_trace2.pro
set_plot,'x'
n_levels=40;Number of levels to contour
B0=100d ;Maximum Magnetic field [Gauss]
Area_0=!dpi*(1d8)^2d ;Footpoint area [cm^2]
;range=
max_height=1.6d9 ;Loop height Fletcher & Martens
T_max=1d*1d6 ;Loop top temperature (Approximate)
;q0=7d-4

;The index of the desired field line changes based on indianness 
;The index of the desired field line changes based on indian-ness 
case !computer of 
    'dawntreader':line_index=1
    'filament':line_index=1
    'mithra':line_index=1
    'fire':line_index=1
    else: line_index=0
endcase

separator_offset=0
outname='green_field.sav'
save_file='gcsm_loop.sav'
chars=1.
chart=1.
bungey_cells=2d2
n_cells=400l                    ;Number of volumes
n_s=n_cells-1l                  ;Number of surfaces
n_depth=20l                     ;Number of surfaces in the Chromosphere
;computer='dawntreader'
;computer='mithra'
rtime=720                   ;Time to allow loop to come to equilibrium
DELTA_T=10                   ;Output timestep
time=0.                         ;The simulation start time
safety=2d                       ; Number that will be divided by
                                ;the C. condition to determine the timestep
note='Green style current sheet initially given RTV scaling'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plotting choices
bgc=255
fgc=0
xs=600
ys=600
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
power=1d24
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine the number of volumes that will be in the corona.
;The final + two are for endpoints that will be replaced by 
;n_depth cells
N_corona=n_cells-(2*n_depth)


so =get_bnh_so(/init);Grab the proper shared object file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the magnetic field given by a Green type reconnection
;Model
bungey_priest_field,B_z,b_y,z,y,f,a=1,B_DRC=0.5,$
                    B0=b0,B_total=B_total,$
                    N_ELEM=bungey_cells
                   
;Make it look like a loop instead of on its side
f2=real_part(transpose(f))
b2=transpose(B_total)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if !d.name eq 'X' then window,0,xs=xs,ys=ys
contour,f2,y,z,nlevels=n_levels,/path_data_coords,$
  path_xy=path_xy,path_info=path_info,$
  path_double=1,closed=0,/ISOTROPIC ,$
        color=fgc,background=bgc
;stop

VALUE_IND=WHERE(path_info.value LT 0)
VALUE_IND2=WHERE(path_info.value gt 0)
LEVELS=[(path_info[VALUE_IND].value), $
        (0D),$
        (path_info[VALUE_IND2].value)]
LEVELS=levels[sort(levels)]
levels=levels[uniq(levels)]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;plot the Separator field line over the the other field lines
;Make a contour map of field lines
contour,f2,y,z,nlevels=n_levels,$
        TITLE="Field Lines for Green's current sheet solution",$
        levels=levels,/ISOTROPIC,color=fgc,background=bgc,$
        chars=chars, chart=chart
;overplot the current sheet
oplot,[0.,0.],[1,-1],thick=2,color=fgc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Choose the separatrix field line
y_ind=where(abs(y-0d) eq min(abs(y-0d)))
z_ind=where(abs(z-(-1.01d)) eq min(abs(z-(-1.01d))))
help,z_ind  

value=f2[y_ind[0],z_ind[0]]
value=0d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Now find the line just below the separatrix
LEVELS=[(path_info[VALUE_IND].value), $
        (path_info[VALUE_IND2].value)]
LEVELS=levels[sort(levels)]
levels=levels[uniq(levels)]

value=levels[where(abs(levels-0) eq $
                   min(abs(levels-0))) $
             -separator_offset]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get the coordinates for the field line with the chosen value
contour,f2,y,z,nlevels=n_levels,$
  /path_data_coords,path_xy=path_xy2,$
  path_info=path_info2,path_double=1,$
  closed=0,levels=value,/ISOTROPIC             ; path_info[1].value

n_lines=n_elements(path_info2)
n_points=path_info2[line_index].n
line_end=path_info2[line_index].offset+n_points-1l
;if line_index+1l ge n_lines-1l then $
;  line_end= n_elements(path_xy2[0,*])-1l $
;  else line_end=path_info2[line_index+1l].offset-1l

;make it red and plot it
loadct,3,/SILENT
for i =0, n_elements(path_xy2[0,*])-1l do begin
;wait,0.01 
 plots, path_xy2[*,$
                 path_info2[line_index].offset: $
                 line_end], color=135,thick=4, $
        /DATA;,chars=chars, chart=chart
;oplot, path_xy2[*,$
;                path_info2[line_index].offset: $
;                line_end],color=135,thick=3


; wait,.001
endfor
;stop
if !d.name eq 'X' then x2gif,'field_lines.gif'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find the number of points corresponding to the line you are
;interested in
n_points=path_info2[line_index].n
;help,path_xy2[*,path_info2[line_index].offset:n_elements(path_xy2[0,*])-1l]

by=dblarr(n_points)
bz=by
bTOT=bz
B_T=bz
if !d.name eq 'X' then window,2
y_index=lonarr(n_points)
z_index=lonarr(n_points)
y2=dblarr(n_points)
z2=dblarr(n_points)
s=dblarr(n_points) ;Distance along the field line
;plot,y,z,/NODATA,TITLE='Field Line'

for i=0l,n_points-1l do begin
    ypos=reform(path_xy2[0,path_info2[line_index].offset+i])
    zpos=reform(path_xy2[1,path_info2[line_index].offset+i])
    y_index=where(abs(ypos[0]-y) eq min(abs(ypos[0]-y)))
    z_index=where(abs(zpos[0]-z) eq min(abs(zpos[0]-z)))
    if (y_index[0]eq -1) or (z_index[0] eq -1 ) then stop
    by[i]=b_y[y_index,z_index]
    bz[i]=b_z[y_index,z_index]
    B_T[i]=b2[y_index,z_index]
    bTOT[i]=sqrt((by[i]^2d)+(bz[i]^2d))
    plots,y[y_index],z[z_index],psym=4
    y2[i]=y[y_index]
    z2[i]=z[z_index]
   if i ne 0l then $
     s[i]=s[i-1]+sqrt(((y2[i]-y2[i-1l])^2d)+((z2[i]-z2[i-1l])^2d))
endfor

;if !d.name eq 'X' then window,4
;plot,b_t/max(b_t),$
;  TITLE='B Along the loop [Normalized]'
;x2gif,'loop_B.gif'
;window,5
;plot,bTOT,TITLE='FROM script.'  ;*100
;help,btot

if !d.name eq 'X' then window,6
loadct,1,/SILENT
contour,b2,y,z,/CELL_FILL,NLEVELS=60,/ISOTROPIC
loadct,3,/SILENT
 plots, path_xy2[*,$
                 path_info2[line_index].offset: $
                line_end]
contour,b2,y,z,nlevels=10,path_info=path_info3,/ISOTROPIC 
LEVELS=[0D,path_info3.value]
LEVELS=levels[sort(levels)]
levels=levels[uniq(levels)]
 contour,b2,y,z,nlevels=10,$
   c_labels=string(path_info3.value),/OVERPLOT ,$
   LEVELS=LEVELS,/ISOTROPIC ,c_charsize=1
if !d.name eq 'X' then x2gif,'B_map.gif' 

;Interpolate,s in the corona with unifrom grid spacing
s2=s[0]+(s[n_elements(s)-1l]*dindgen(N_corona-1)/(N_corona-2))
print,'S test.  Old min, max S.  New Min Max s'
pmm,s
pmm, s2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interpolate,b_t
b=dblarr(n_corona-1)
help,b
foo =  call_external(so, $            ; The SO
                    'bnh_splint', $  ; The entry name
                    n_points, $   ; # of elements in x, f(x)
                    s, $ ; x
                    b_t, $                    ; f(x)
                    (n_corona-1), $; # elements in thing-to-interpolate
                    s2, $                       ; thing-to-interpolate
                    b, $                ; where the answer goes
                    /d_value, $ 
                    value=[1,0,0,1,0,0], $ 
                    /auto_glue,/cdecl,/ignore_exist) ;, $/ignore_exist,
help,b
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interpolate,y
y_old=path_xy2[0,path_info2[line_index].offset: $
               line_end]
y= dblarr(n_corona-1)  
foo = call_external(so, $            ; The SO
                    'bnh_splint', $  ; The entry name
                    n_points, $   ; # of elements in x, f(x)
                    s, $ ; x
                    y_old, $                  ; f(x)
                    (n_corona-1), $            ; # elements in thing-to-interpolate
                    s2, $                     ; thing-to-interpolate
                    y, $                      ; where the answer goes
                    /d_value, $ 
                    value=[1,0,0,1,0,0], $ 
                    /auto_glue,/cdecl) ;, $/ignore_exist,

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interpolate,z
z_old=path_xy2[1,path_info2[line_index].offset: $
                   line_end]
z= dblarr(n_corona-1)  
foo = call_external(so, $            ; The SO
                    'bnh_splint', $  ; The entry name
                    n_points, $   ; # of elements in x, f(x)
                    s, $ ; x
                    z_old, $                  ; f(x)
                    (n_corona-1), $            ; # elements in thing-to-interpolate
                    s2, $                     ; thing-to-interpolate
                    z, $                      ; where the answer goes
                    /d_value, $ 
                    value=[1,0,0,1,0,0], $ 
                    /auto_glue,/cdecl) ;, $/ignore_exist,
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;stop
;Redefine s 
s=s2

help,b
print,total(finite((b)))

if n_elements(b) ne total(finite(b)) then stop
a=Area_0*(max(b)/b)

if n_elements(b) ne total(finite(b)) then stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Scale everything to Z
shift_z=-1d*min(z)
z=z+shift_z
shift_y=-1d*min(y)
y=y+shift_y
y=reverse(y)
scale_factor=max_height/max(z)
z=z*scale_factor+h_chromosphere
y=y*scale_factor
axis=dblarr(3,n_corona-1l)
help,axis
axis[0,*]=0d
axis[1,*]=y
axis[2,*]=z
s=s*scale_factor 
;x on the volume element grid (like e, n_e), 
n_s=n_corona-1l
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
s_alt = msu_get_s_alt(s)
;if !d.name eq 'X' then window,1
;plot,axis[1,*],axis[2,*], Title='Loop axis', $
;     XTITLE="Y [cm]",YTITLE='Z [cm]',$
;     /ISOTROPIC

theta = (indgen(N_CORONA)*!dpi / (N_CORONA-1l))-(!dpi/2)
sine_theta=-1d*smooth(deriv(z)/deriv(s),10,/EDGE)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Dimensionless gravitational acceleration parallel to the loop.
; See Klimchuck,Tanner, & Moore, 2004
;Theta is defined differently from my notes so the sine is more
;appropriate than the cosine
;g=sin(theta)*((R_Sun/(R_Sun+axis[2,*]))^2d)
g=sine_theta*((R_Sun/(R_Sun+axis[2,*]))^2d)

;Gravitational acceleration [cm s^2]
g=reform(g)*g0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
L=max(s) ;Loop half length
x=s
;dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))

;******* RTV SOLUTION ******************
;given T_max and L, get P(x), T(x), E(x)
 ;t_max=1.4e3*(e_h*(L^2.)/(9.8e4))^(2./7.) ;If you have e_h
heat = 9.14d-7 * T_max^3.51d * (L/2d)^(-2d) ;scaling law if you have t_max
q0=heat
P=((T_max/1.4d3)^3)/L                       ;RTV eqn 4.3
T = T_max * ( 4d * s_alt/(L) * (1d - s_alt/(L)) )^0.333333d ;CCK empirical
T = T > 1d4                     ;put in footpt cutoff - don't allow temperatures too low.
n_e=0.5*(P/(kb*T))              ;n_e=0.5*n=0.5*(P/kt) number density
E=3./2. *2*n_e* Kb*T            ;E=3/2 nkt=3/2 2n_e kt

;N = n_elements(e)
v = fltarr(n_corona-1)
volumes=msu_get_volume(s,a)
;e_h=power/volumes
e_h=dblarr(n_elements(volumes))+heat
;stop
;***************** add on chromosphere ************
;UPDATE 10/29/01 - run w/o toilet bowl chromosphere!
;extend last footpoint deep into the chromosphere
;keep grid refined in TR
x=s
x=x-x[0]                        ;get rid of leading space	04/30/02	RAM

;make a gravitationally stratified atmosphere
 ne_addon=reverse(dindgen(n_depth)* $
                  10^(alog10(n_e[0])+2d)/$
                  (n_depth-1) + n_e[0] +n_e[0]-n_e[1])

 x_addon=alog(ne_addon-n_e[0])*kb*t[0]/(0.5*mp*g[0]) 
 x_addon=x_addon-x_addon[0]
 depth=max(x_addon)
 if depth gt h_chromosphere then begin
     x_addon=x_addon*(h_chromosphere/depth)
     depth=max(x_addon)
 end

 if NOT (x_addon[0] eq 0 and depth ne 0 ) THEN stop
 xstep=x[1]-x[0]
 x=[x_addon, depth+xstep+ x, 2*(depth+xstep)+max(x)- reverse(x_addon)]
 n_e= [ne_addon, n_e, reverse(ne_addon)]
n_e=n_e >1d1

;print,n_e
;assume constant t in the chromosphere
 E_addon=3./2. *2*ne_addon* Kb*T0	;E=3/2 nkt=3/2 2n_e kt
 e=[e_addon, e, reverse(e_addon)]

;04/30/02 - RAM - keep chromosphere area constant.
 a_addon=fltarr(n_depth) + a[0]	;*exp(-1.*(x_addon-dd-x[0])/sqrt(a[0])
    a=[a_addon, a, reverse(a_addon)]

rad=sqrt(a/!dpi)
;constant velocity, gravity,b, and heating
c0=fltarr(n_depth)+1
v=[c0*v(0), v, c0*v(n_elements(v)-1l)]
;g=[c0*g(0), g, c0*g(n_elements(g)-1l)]
e_h=[c0*q0, e_h, c0*q0]
b=[c0*b[0], b, c0*b[n_elements(b)-1l]]
g_addon=g0*reform((R_Sun/(R_Sun+x_addon))^2d)
g=[-1d*g_addon, g,g_addon ]
s=x
s_alt=msu_get_s_alt(x,/GT0)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;add on for the Axes HDWIII 02/09/2006 
;Assume that the x and y remain fixed, and z goes negative 
axis_x_addon=dblarr(n_depth)+axis[0,0]
axis_y_addon1=dblarr(n_depth)+axis[1,0]
axis_y_addon2=dblarr(n_depth)+axis[1,N_s-1l]
new_axis=dblarr(3,(N_s+2l*n_depth))


help,s,new_axis
new_axis[0,*]=[axis_x_addon,reform(axis[0,0:n_elements(axis[0,*])-1l]),$
               axis_x_addon]
new_axis[1,*]=[axis_y_addon1,reform(axis[1,0:n_elements(axis[0,*])-1l]),$
               axis_y_addon2]
new_axis[1,*]=reverse(new_axis[1,*])
z0=reform(axis[2,0])
zn=reform(axis[2,N_S-1l])
;new_axis[2,*]=[z0[0]-reverse(s_addon),$
;               reform(axis[2,0:n_elements(axis[2,*])-1l]),zn[0]-s_addon]
new_axis[2,*]=[(x_addon),$
               reform(axis[2,*]),reverse(x_addon)]
axis=new_axis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;smooth initial conditions to prevent numerical misbehavior
for j = 1, 10 do begin
    e = smooth(e,3)
                                ;We're at constant pressure, so this shouldn't do anything.
    n_e=smooth(n_e,3)
    ;a=smooth(a,3)
    g=smooth(g,3,/edge)
    ;e_h=smooth(e_h,3)
endfor

;for j=1, 10 do begin
;    g=smooth(g,10,/edge)
;endfor


;a[*]=area_0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lhist={e:double(e), n_e:double(n_e), v:double(v), time:double(time)}
help,lhist,/str
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sizecheck, lhist,g,A,s, E_h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;regrid4, lhist,g,a,s,e_h,/showme,/nosave
;goto, end_jump

equil_counter=1
done=0
max_v=1d7
;stop
if !d.name eq 'X' then window,7,xs=xs,ys=ys
plot, s_alt[1l:n_elements(s_alt)-2l],e_h,$
      TITLE='Heating Profile',XTITLE='s [cm]', $
      YTITLE='[ergs cm!E-3!N s!E-1!N]'
while not done do begin
    ;print, equil_counter
;    msu_evolve_loop, g,a,s, rtime,  DELTA_T,e_h, n_depth, $
;                    outfile=outfile, q0=q0, $
;                    /showme, computer=!computer, $
;                    lhist=lhist,so=so;,/novisc;

    loopmodelt2, g, A, s, q0, rtime, T0=1e4, $
                 /fal, /uri,lhist=lhist,$
                 safety=safety,$
                 /src, depth=depth,$
                 OUTFILE=OUTNAME, DELTA_T=DELTA_T
    max_v=max(lhist.v)
    if max_v le 1d3 then done =1
;depth=depth*.5d,
    lhist=lhist[n_elements(lhist)-1l]
    ;for j=0,5 do lhist.v[*]=smooth(lhist.v,10)
       
   ; for j=0,5 do e = smooth(e,7)
   ; lhist.v[*]=0
    pmm,lhist.v
    lhist.time=0d
    if equil_counter eq 5 then done=1
    equil_counter +=1
    
    ;done=1
endwhile
;Calculate the temperature 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
T = lhist.e/(3.0*lhist.n_e*kB)
t_max=max(T)
sizecheck, lhist[0],g,A,s, E_h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;junk=check_res( lhist, dv, n_depth, /noisy)

;a=a/max(a)
;stop
loopeqt, g, A, x, computer=!computer, Ttop=T_max, fname='test.sav', $
	 rtime=rtime, safety=safety, T0=T0;, depth=depth,rebin=rebin,

LOOP=mk_loop_struct(lhist,s,b,g,axis, A,rad, $
                    e_h,t_max, n_depth, note,DEPTH=DEPTH,$
                    start_file='gcsm_loop.sav')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sizecheck, loop[0].state,loop[0].g,loop[0].a,loop[0].s,loop[0].E_h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end_jump:
e_h=e_h[*,0]
print,'Saving file: ', save_file
save,g, A, s, rad, lhist, E_h,axis,b,loop,q0, heat,e_h,file=save_file
END

