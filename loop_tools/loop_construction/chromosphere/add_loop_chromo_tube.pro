;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function get_exponential_steps, ds_first, N_DEPTH, depth, $
                                percent_difference, N_DEPTH_s

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine step size based on exponential scaling
;Use a root finder to get an expontially decaying step size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
recompute_N_DEPTH:
;Compute the percent difference of the last two coronal cells.
;This will provide the basis of for the size of the next step
;percent_difference=abs(ds[1]-ds[0])/ds_first

A_0=ds_first*(1d0-percent_difference)
;If the number of cells is too small you can never 
; make it to depth while maintaining the percent
; difference of the the first step.

if A_0*(N_DEPTH_s) le depth then begin
    N_DEPTH_s=long(depth/A_0)+10l
    N_DEPTH_a=N_DEPTH_s+1l
    print,'***************************'
    print,'add_loop_chromo.pro warning!'
    print,'Not enough cells to maintain a smooth distribution.'
    print,'Changing the number of cells to '+$
          strcompress(string(N_DEPTH_a), /REMOVE_ALL)+'.'
    print,'***************************'
    if N_DEPTH_a gt N_DEPTH then begin
        N_DEPTH=N_DEPTH_a
        goto, recompute_N_DEPTH
    endif else N_DEPTH=N_DEPTH_a
endif

ind_array=dindgen(N_DEPTH_s)
;We are going to use a simple Newton Raphson method.
;The expression is simple so we shouldn't fall into
; any of the traps that can accompany NR.

;Initial guess at the constant.
C1=.5

pd_b=1d5
jj=0ul
repeat begin
    if finite(c1) lt 1 then stop
    d_step1= (A_0)*exp(-C1*ind_array/N_DEPTH_s)
    ;plot, d_step1
    
    y_n=total(d_step1)-(DEPTH)
    y_prime_n=total((-ind_array/Max(ind_array))*d_step1)
    ;y_prime_n=total(-d_step1)
    
    pd_b=ABS((total(d_step1)-(DEPTH))/(DEPTH))
    ;PRINT,'PD_B, C1, total(d_step1)/(DEPTH)', PD_B, C1, total(d_step1)/(DEPTH);;
    if y_prime_n eq 0 then y_prime_n=1d-15
    C1_new=C1-(y_n/y_prime_n)       ;
;Hope it never gets to the following point!
    if c1_new lt 0 then c1 =C1+(y_n/y_prime_n)   else c1 =c1_new
                                ;print, 'y_prime_n',y_prime_n,(y_n/y_prime_n)
    if finite(c1) lt 1 then stop

    help, pd_b
    help, d_step1
    help, c1
    print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
endrep until  pd_b LT 1D-4

return , d_step1

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function get_constant_steps, ds_first, N_DEPTH, depth, n_depth_S

  if ds_first*3. gt depth then depth=ds_first*3.

  n_depth=ulong(depth/ds_first)
  n_depth_S=n_depth-1
  steps=ds_first*(dblarr(n_depth_S)+1)

  steps[n_depth_S-1]=depth-total(steps[n_depth_S-2], /CUMULATIVE)

  steps_total=total(steps) 
  if steps_total ne depth then begin
    steps=(steps/steps_total)*depth
  endif

  return, steps



end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function get_increasing_steps, ds_first, N_DEPTH, depth, n_depth_S,$
                               percent_difference

  if ds_first*3. gt depth then depth=ds_first*3.
  steps=ds_first

  done=0
  iii=1
  while not done do begin
     steps=[steps, iii*percent_difference*ds_first]
     steps_total=total(steps)
     case 1 of
        steps_total gt depth : begin
           ;steps[iii]=depth-total(steps[0:iii-1])
           done=1
        end
        steps_total gt depth : done =1

        else:
     
     endcase
     iii++
  endwhile
  

  steps_total=total(steps) 
  if steps_total ne depth then begin
     steps=(steps/steps_total)*depth
  endif

  n_depth_S=n_elements(steps)
  N_DEPTH=n_depth_S+1
  
  return, steps
  end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function add_loop_chromo_tube, loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                               VERSION=VERSION, STARTNAME=STARTNAME,$
                               PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, CHROMO_NAME=CHROMO_NAME
  Version=1.0
  ne_mult=1
  CHROMO_NAME='Tube Increasing' 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Let's set some keywords!
;Chromospheric Temperature  [K]
  if not keyword_set(T0) then T0=!shrec_T0

;Depth into the chromosphere  [cm]
  if not keyword_set(DEPTH) then DEPTH=2500*1d5

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
;Add on chromosphere 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Left
  old_s=loop.s+depth

  ds=get_loop_ds(loop)
  ds_first=ds[0]

                                ;d_step1= get_exponential_steps( ds_first,N_DEPTH, depth, $
                                ;                                percent_difference, n_depth_S)
                                ;d_step1=d_step1*(depth/total(d_step1))
  
                                ;d_step1=get_constant_steps( ds_first, N_DEPTH, depth, n_depth_S)
  d_step1=get_increasing_steps( ds_first, N_DEPTH, depth, n_depth_S,$
                                percent_difference)
  d_step1=reverse(d_step1)
  n_depth_old=N_DEPTH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Right
  n_ds=n_elements(ds)
  ds_last=ds[n_ds-1]
                                ;d_step2=get_exponential_steps( ds_last,N_DEPTH, depth, $
                                ;                       percent_difference, n_depth_S)
                                ;d_step2=d_step2*(depth/total(d_step2))
  
                                ;d_step2=get_constant_steps( ds_last, N_DEPTH, depth, n_depth_S)
  d_step2=get_increasing_steps( ds_last, N_DEPTH, depth, n_depth_S,$
                                percent_difference)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  depth_counter=0
  depth_done =0 

  if n_depth_old eq N_DEPTH then depth_done=1
  while not depth_done do begin
     
                                ; d_step1= get_exponential_steps( ds_last,N_DEPTH, depth, $
                                ;                                 percent_difference, n_depth_S)
                                ;d_step1=d_step1*(depth/total(d_step1))
                                ;d_step1=get_constant_steps( ds_first, N_DEPTH, depth, n_depth_S)
     d_step1=get_increasing_steps( ds_first, N_DEPTH, depth, n_depth_S,$
                                   percent_difference)
     d_step1=reverse(d_step1)
     n_depth_old=N_DEPTH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Right
     n_ds=n_elements(ds)
     ds_last=ds[n_ds-1]
                                ;d_step2=get_exponential_steps( ds_last,N_DEPTH, depth, $
                                ;                       percent_difference, n_depth_S)
                                ;d_step2=d_step2*(depth/total(d_step2))
                                ;d_step2=get_constant_steps( ds_last, N_DEPTH, depth, n_depth_S)
     d_step2=get_increasing_steps( ds_last, N_DEPTH, depth, n_depth_S,$
                                   percent_difference)
     depth_counter++
     if depth_counter gt 10 then depth_done=1
     if n_depth_old eq N_DEPTH then depth_done=1
  endwhile

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


  new_s=[0, total(d_step1[0:N_DEPTH_s-2], /CUMULATIVE), $
         old_s,$
         depth+max(loop.s)+total(d_step2, /cumulative)]
  
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
  z_add_alt=shrec_get_s_alt(z_add2)
  dz=z_add_alt-loop.axis[2,n_corona_surf-1]
  p_chromo2=P[1]*(exp((-1d0*!shrec_mp*abs(g_add2)*dz)/(!shrec_kB*T0)))

;Remembering that n_p~n_e and P=nkT
  n_e_add1=p_chromo1/(2d0*!shrec_kB*T0)
  n_e_add1*=ne_mult
;E=3/2*n*kb*T
  E_add1=(3./2.) *2.*n_e_add1*!shrec_kB *T0     
  E_add2=(3./2.) *2.*reverse(n_e_add1)* !shrec_kB*T0  
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

  end_index=fix(N_DEPTH_s*1.1)
  end_index>=N_DEPTH_s+6
  for iii=0, 30 do a[0:end_index]=smooth(a[0:end_index],3) 
  n_a=n_elements(a)
  for iii=0, 30 do a[n_a-end_index:n_a-1]=smooth(a[n_a-end_index:n_a-1],3)   

  rad=[dblarr(N_DEPTH_s)+loop.rad[0],$
       loop.rad,$
       dblarr(N_DEPTH_s)+loop.rad[n_corona_surf-1]]


  b=[dblarr(N_DEPTH_s)+(loop.b[0]*dblarr(N_DEPTH_s)+loop.A[0]),$
     loop.b,$
     loop.b[n_corona_surf-1]*dblarr(N_DEPTH_s)+loop.rad[n_corona_surf-1]]

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
;plot, s_alt_old, t1
;oplot, new_LOOP.s_alt[n_depth-1:n_elements(new_LOOP.s_alt)-n_depth],$
;       t2[n_depth-1:n_elements(new_LOOP.s_alt)-n_depth]
;for j=1, 10 do begin
;    g=smooth(g,10,/edge)
;endfor



;stop

  print, 'Add_loop_chromo All Done'
  return, new_loop

END                             ; Of main
