;+
; NAME:
;      add_constant_t_apex_pressure_chromo	
;
; PURPOSE:
;	Create a chromospheric model that has a pressure at
;	it's apex of 10^11 cm^-3, and a constant temperature
;	based on T0. A hydrostatic atmosphere is assumed to calculate
;	the density profile of the chromosphere.  The maximum density
;	allowed is 10^11 cm^-3.  The chromosphere is then added to the
;	base of the loop, with the areas matching.
;
; CATEGORY:
;	HyLoop, chromosphere, 
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
;       T0: Chromospheric temperature in Kelvin.  If not set the
;       program will look for the system variable !shrec_T0.  If that
;       is not set, the T0 is set to 1d4 [K].
;	N_DEPTH: The number of volume cells to be added.  The number
;	of surface cells added will be N_DEPTH-1.
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
; 	Written by:	Henry "Trae" D. Winter III, July 3, 2012.


function add_constant_t_apex_pressure_chromo, loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
   VERSION=VERSION, STARTNAME=STARTNAME,$
   PERCENT_DIFFERENCE=PERCENT_DIFFERENCE,$
   MIN_STEP=MIN_STEP,$
   SET_SYSV=SET_SYSV, SYSV_NAME=SYSV_NAME

  Version=1.0  	
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Let's set some keywords!
;Chromospheric Temperature  [K]
  if not keyword_set(T0) then begin
     defsysv,"!shrec_T0", EXISTS=Test 
     if test gt 0 then T0=!shrec_T0 $
     else T0=1d4
  endif


;Depth into the chromosphere  [cm]
  if not keyword_set(DEPTH) then DEPTH=2d8; If not defined, use the whole chromosphere.

;Number of cells for the hydrostatic atmosphere chromosphere.
  if not keyword_set(N_DEPTH) then N_DEPTH=100
  if not keyword_set(PERCENT_DIFFERENCE) then PERCENT_DIFFERENCE=1d-1

;Smallest step size we are going to take
  if not keyword_set(MIN_STEP) then MIN_STEP=5d4 ;500 meters or ~five football fields.
;
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if size(loop,/TYPE) ne 8 then $
     message, 'Argument for add_loop_chromo() must be a loop structure.'
;At least 3 points for the chromosphere
  n_depth>=3

  N_DEPTH_s=N_DEPTH-1ul

  loop.n_depth=N_DEPTH
  loop.depth=DEPTH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHROMO_MODEL='T0 APEX P0'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get values for the corona.
  n_e_corona=loop.state.n_e
  n_corona_surf=n_elements(loop.s)
  T_corona=get_loop_temp(loop)
;Density at the Chromspheric apex.
  ne_Ch_apex=2d11
;Maximum Chromspheric Density.
  ne_Ch_max=1d15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  old_s=loop.s+DEPTH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine step size based on exponential scaling
;Use a root finder to get an expontially decaying step size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P_Ch_apex=2*ne_Ch_apex*!shrec_kb*T0
recompute_N_DEPTH:
  ds=get_loop_ds(loop)
  ds_first=ds[0]
;Compute the percent difference of the last two coronal cells.
;This will provide the basis of for the size of the next step
;percent_difference=abs(ds[1]-ds[0])/ds_first

  A_0=ds_first*(1d0-percent_difference)
;If the number of cells is too small you can never 
; make it to depth while maintaining the percent
; difference of the the first step.
  if A_0*(N_DEPTH_s) le depth then begin
     N_DEPTH_s=long(depth/A_0)+10l
     N_DEPTH=N_DEPTH_s+1l
     print,'***************************'
     print,'add_loop_chromo.pro warning!'
     print,'Not enough cells to maintain a smooth distribution.'
     print,'Changing the number of cells to '+$
           strcompress(string(N_DEPTH), /REMOVE_ALL)+'.'
     print,'***************************'
  endif

  ind_array=dindgen(N_DEPTH_s)
;We are going to use a simple Newton Raphson method.
;The expression is simple, so we shouldn't fall into
; any of the traps that can accompany NR.

;Initial guess at the constant.
  C1=.5

  pd_b=1d5
  jj=0ul
  repeat begin
     if finite(c1) lt 1 then stop
     d_step2= (A_0)*exp(-C1*ind_array/N_DEPTH_s)
     d_step2>= MIN_STEP
    
     
     y_n=total(d_step2)-(depth)
     y_prime_n=total((-ind_array/Max(ind_array))*d_step2)
            
     pd_b=ABS((total(d_step2)-(depth))/(depth))
     
     if y_prime_n eq 0 then y_prime_n=1d-15
     C1_new=C1-(y_n/y_prime_n)  ;
;Hope it never gets to the following point!
     if c1_new lt 0 then c1 =C1+(y_n/y_prime_n)   else c1 =c1_new
                                ;print, 'y_prime_n',y_prime_n,(y_n/y_prime_n)
     if finite(c1) lt 1 then stop

     help, pd_b
     help, d_step2
     help, c1
     print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
  endrep until  pd_b LT 1D-10

  d_step2=d_step2*(depth/total(d_step2))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  d_step1=reverse(d_step2)
  s1=[0, total(d_step1[0:N_DEPTH_s-2], /CUMULATIVE)]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  n_ds=n_elements(ds)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Axis goes straight down
;Need to change the z_axis part at some time.  z_add1 & 
;  reverse(z_add2) are slightly different in symmetric cases.
;  (third decimal place)
  z_add1=reverse(loop.axis[2,0]-(total(d_step1,/CUMULATIVE)))

  z_add2=loop.axis[2,n_corona_surf-1]-(total(d_step2,/CUMULATIVE))
  z=[z_add1, $
     reform(loop.axis[2,*]),$
     z_add2]

  y_add1=loop.axis[1,0]+dblarr(n_depth_s)
  y_add2=loop.axis[1,n_corona_surf-1]+dblarr(n_depth_s)
  y=[y_add1, $
     reform(loop.axis[1,*]),$
     y_add2]

  x_add1=loop.axis[0,0]+dblarr(n_depth_s)
  x_add2=loop.axis[0,n_corona_surf-1]+dblarr(n_depth_s)
  x=[x_add1, $
     reform(loop.axis[0,*]),$
     x_add2]

  axis=dblarr(3,n_elements(x))
  axis[0,*]=x
  axis[1,*]=y
  axis[2,*]=z


  new_s=[s1, $
         old_s,$
         depth+max(loop.s)+total(d_step2, /cumulative)]

  new_s=new_s-new_s[0]
  s_alt=shrec_get_s_alt(new_s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Gravity
;print, 'At gravity'
  g_add1=-!shrec_g0*((!shrec_R_Sun/(!shrec_R_Sun+z_add1))^2d)
  g_add2=!shrec_g0*((!shrec_R_Sun/(!shrec_R_Sun+z_add2))^2d)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the gas pressure of a stratified atmosphere
; from the corona down
;"Right" side"
  z_add_alt=shrec_get_s_alt(z_add2)
  dz=z_add_alt-loop.axis[2,n_corona_surf-1]
  p_chromo1=P_Ch_apex*(exp((-1d0*!shrec_mp*abs(g_add2)*dz)/(!shrec_kB*T0)))

;Remembering that n_p~n_e and P=nkT
  n_e_add=p_chromo1/(2d0*!shrec_kB*T0)
;E=3/2*n*kb*T
  E_add=(3./2.) *2.*n_e_add*!shrec_kB *T0     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Summing up
  s=new_s

  e=[reverse(E_add), $
     loop.state.e, $
     E_add]


  n_e0=reverse(n_e_add)
  n_e=[n_e0, $
       loop.state.n_e, $
       n_e_add]
  n_e0=n_e0[0]
;Set the boundary condition for the density
  defsysv, '!N_E0',n_e0
;Value of the chromospheric density at the base.
  n_e<=10d15 
  n_e<=ne_Ch_max
  g=  [g_add1,$
       loop.g,$
       g_add2]

  v=[dblarr(N_DEPTH_s),$
     loop.state.v, $
     dblarr(N_DEPTH_s)]
  A=[dblarr(N_DEPTH_s)+loop.A[0],$
     loop.A,$
     dblarr(N_DEPTH_s)+loop.A[n_corona_surf-1]]

  rad=[dblarr(N_DEPTH_s)+loop.rad[0],$
       loop.rad,$
       dblarr(N_DEPTH_s)+loop.rad[n_corona_surf-1]]


  b=[dblarr(N_DEPTH_s)+(loop.b[0]),$
     loop.b,$ $
     loop.b[n_corona_surf-1]+dblarr(N_DEPTH_s)]

;  for jj=0, 10ul do e=smooth(e,3)
;  for jj=0ul, 10ul do n_e=smooth(n_e,3)

  e_h1=n_e_add[1:*]*0
  e_h=[e_h1,$ 
       loop.e_h[0],loop.e_h,loop.e_h[n_elements(loop.e_h)-1],$
       e_h1]

  state={e:double(e), n_e:double(n_e), $
         v:double(v), time:double(loop.state.time)}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  notes=loop.notes
  notes[0]+= '  . Chromosphere added by add_constant_t_apex_pressure_chromo: V'+string(version)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the loop structure for PaTC
  n_depth=n_elements(n_e_add)
  new_LOOP=mk_loop_struct(STATE=state,$
                          S_ARRAY=s,$
                          B=b,G=g,$
                          AXIS=axis, $
                          AREA=A,$
                          RAD=rad, $
                          E_H= e_h,$
                          T_MAX=t_max, $
                          N_DEPTH=n_depth,$
                          P_0=P_0,$
                          P_BC=P_BC,$
                          CHROMO_MODEL=CHROMO_MODEL,$
                          NOTES=notes,$
                          DEPTH=DEPTH,$
                          TIME=loop.state.TIME,$
                          start_file=loop.start_file)

;Remember no endcaps
  e_h=add_chromo_heat( new_LOOP,/SET_SYSV,$
                       /UPDATE_LOOP)
  new_LOOP= shrec_bcs(new_LOOP)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Error check the size of loop elements 
err_state=shrec_sizecheck(new_LOOP, ERROR=ERR_msg)

if err_state le 0 then begin
   stop
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print, 'add_constant_t_apex_pressure_chromo All Done'
;stop
  return, new_loop

END                             ; Of main
