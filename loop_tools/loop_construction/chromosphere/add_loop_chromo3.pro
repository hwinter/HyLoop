;Constant spacing through the chromosphere

function add_loop_chromo3, loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
  VERSION=VERSION, STARTNAME=STARTNAME,$
  PERCENT_DIFFERENCE=PERCENT_DIFFERENCE
Version=1.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Let's set some keywords!
;Chromospheric Temperature  [K]
if not keyword_set(T0) then T0=!shrec_T0

;Depth into the chromosphere  [cm]
if not keyword_set(DEPTH) then DEPTH=2d6

;Number of cells for the chromosphere.
if not keyword_set(N_DEPTH) then N_DEPTH=100
if not keyword_set(PERCENT_DIFFERENCE) then PERCENT_DIFFERENCE=1d-1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if size(loop,/TYPE) ne 8 then $
  message, 'Argument for add_loop_chromo() must be a loop structure.'
;

n_depth>=3

N_DEPTH_s=N_DEPTH-1ul
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get values for the corona.
n_e_corona=loop.state.n_e
n_corona_surf=n_elements(loop.s)
T_corona=get_loop_temp(loop)
;Pressure at the loop endpoints
P=2d0*!shrec_kB*[n_e_corona[0]*T_corona[0],$
          n_e_corona[n_corona_surf-1]*T_corona[n_corona_surf-1]]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get the coronal step_size

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Add on chromosphere 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

old_s=loop.s+depth
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
d_step=depth/N_DEPTH_s
steps=total(d_step*(dindgen(N_DEPTH_s)+1),/CUMULATIVE)
s1=steps-d_step

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Axis goes straight down
z_add1=reverse(loop.axis[2,0]-steps)

z_add2=loop.axis[2,n_corona_surf-1]-steps
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
new_s=[s1, $
       old_s,$
       depth+max(loop.s)+steps]

new_s=new_s-new_s[0]
s_alt=shrec_get_s_alt(new_s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Gravity
;print, 'At gravity'
g_add1=-!shrec_g0*((!shrec_R_Sun/(!shrec_R_Sun+z_add1))^2d)
g_add2=!shrec_g0*((!shrec_R_Sun/(!shrec_R_Sun+z_add2))^2d)

;Calculate the gas pressure of a stratified atmosphere
; from the corona down
z_add_alt=shrec_get_s_alt(z_add1)
dz=z_add_alt-loop.axis[2,0]
p_chromo1=P[0]*(exp((-1d0*!shrec_mp*abs(g_add1)*dz)/(!shrec_kB*T0)))
area_chromo1=loop.A[0] $
             *1d0/(exp((-1d0*!shrec_mp*abs(g_add1)*dz)/(!shrec_kB*T0)))



z_add_alt=shrec_get_s_alt(z_add2)
dz=z_add_alt-loop.axis[2,n_corona_surf-1]
p_chromo2=P[1]*(exp((-1d0*!shrec_mp*abs(g_add2)*dz)/(!shrec_kB*T0)))
area_chromo2=loop.A[n_corona_surf-1] $
             *1d0/(exp((-1d0*!shrec_mp*abs(g_add2)*dz)/(!shrec_kB*T0)))

;Remembering that n_p~n_e and P=nkT
n_e_add1=p_chromo1/(2d0*!shrec_kB*T0)
n_e_add2=p_chromo2/(2d0*!shrec_kB*T0)
;E=3/2*n*kb*T
E_add1=(3./2.) *2.*n_e_add1*!shrec_kB *T0     
E_add2=(3./2.) *2.*n_e_add2* !shrec_kB*T0  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Summing up
s=new_s

e=[E_add1, $
   loop.state.e, $
   reverse(E_add1)]



for jj=0, 100ul do e=smooth(e,3)

n_e=[n_e_add1, $
     loop.state.n_e, $
    reverse(n_e_add1)]

g=  [g_add1,$
     loop.g,$
    g_add2]

v=[dblarr(N_DEPTH_s),$
   loop.state.v, $
   dblarr(N_DEPTH_s)]

;Remember no endcaps
e_h=[dblarr(N_DEPTH_s)+loop.e_h[0],$
    loop.e_h,$
     dblarr(N_DEPTH_s)+loop.e_h[n_corona_surf-2]]

A=[dblarr(N_DEPTH_s)+loop.A[0],$
   loop.A,$
   dblarr(N_DEPTH_s)+loop.A[n_corona_surf-1]]

;A=[area_chromo1,$
;   loop.A,$
;   area_chromo2]

rad=[dblarr(N_DEPTH_s)+loop.rad[0],$
   loop.rad,$
   dblarr(N_DEPTH_s)+loop.rad[n_corona_surf-1]]


b=[dblarr(N_DEPTH_s)+(loop.b[0]*loop.A[0]/area_chromo1),$
   loop.b,$
   dblarr(N_DEPTH_s)+ $
   (loop.b[n_corona_surf-1]*loop.A[n_corona_surf-1]/area_chromo2)]

new_n=n_elements(e)-1ul

n_e_ends=max([n_e[0], n_e[new_n-1ul]])
  
E_ends=(3./2.) *2.*n_e_ends* !shrec_kB*T0  

n_e[0]=n_e_ends
n_e[new_n]=n_e_ends
for jj=0ul, 1000ul do n_e=smooth(n_e,3)
e[0]=E_ends
e[new_n]=E_ends
state={e:double(e), n_e:double(n_e), $
       v:double(v), time:double(loop.state.time)}

notes=loop.notes
notes[0]+= '  . Chromosphere added by add_loop_chromo :'+string(version)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the loop structure for PaTC
new_LOOP=mk_loop_struct(STATE=state,$
                        S_ARRAY=s,$
                        B=b,G=g,$
                        AXIS=axis, $
                        AREA=A,$
                        RAD=rad, $
                        E_H= e_h,$
                        T_MAX=t_max, $
                        N_DEPTH=n_depth, $
                        NOTES=noteS,$
                        DEPTH=DEPTH,$
                        TIME=loop.state.TIME,$
                        start_file=loop.start_file)
;stop
t1=get_loop_temp(loop)
s_alt_old=get_loop_s_alt(loop)
t2=get_loop_temp(new_LOOP)


for jj=0ul, 100ul do loop.state.n_e=smooth(loop.state.n_e,3)


;stop

print, 'Add_loop_chromo All Done'
return, new_loop

END; Of main
