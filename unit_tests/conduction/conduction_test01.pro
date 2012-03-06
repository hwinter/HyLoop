;.r conduction_test.pro
;
eps_name='conduction_test_01.eps'
start_time=systime(1)
print, 'Run started at '+systime(/utc)
old_pmulti=!p.multi
;!p.multi=[0,1,3]
old_plot_state=!D.NAME
set_plot,'z'
patc_dir=getenv('DATA')+'/PATC/runs/test/'
eps_name=patc_dir+eps_name
!path=!path+':'+EXPAND_PATH('+'+patc_dir) 
;Total simulation time in seconds
loop_time=10d;10d*60d
delta_time=.001;1d ;[sec]
color_table=39
run_folder=strcompress('./')
t_min=1d6
t_max=5d6
n_t_steps=1000ul
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Loop Properties
diameter=1d8
length=1d9
N_E=1d9
UNIFORM=1 
B=10
nosave=1
N_CELLS=200
LOOP=1
dist_alpha=0
FRACTION_PART=1.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End of input parameters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
$unlimit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make an array of temperatures
temps=t_min+((t_max-t_min)*dindgen(n_t_steps)/(n_t_steps-1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a loop tube
loop=mk_loop_tube(diameter,length, $
  T_MAX=1d5,N_E=N_E ,$
  N_DEPTH=N_DEPTH,$
  TO=T0,UNIFORM=UNIFORM, $
  B=B,Q0=Q0,  nosave=nosave, $
  outname=outname,N_CELLS=N_CELLS,$
  X_SHIFT=X_SHIFT,Y_SHIFT=Y_SHIFT,$
  Z_SHIFT=Z_SHIFT, $
  SIGMA_FACTOR=SIGMA_FACTOR)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



annotation=''
length=loop.s_alt[1]-loop.s_alt[0]
loop.state.e[*]=t2e(t_min)
gradient=dblarr(n_t_steps)

c1=gradient
c2=gradient
annotation=['With Sat. Flux', 'No Sat. Flux']
for i=0,n_t_steps-1 do begin
    loop.state.e[1]=t2e(Temps[i])
    c=MSU_conduction(loop.state, loop.s,spit=1)
    c1[i]=abs(c[1])
    c=MSU_conduction(loop.state, loop.s,NO_SAT=1,spit=1)
    c2[i]=abs(c[1])
    
    gradient[i]=(Temps[i]-T_min)/length
endfor

xy0=reform([[[gradient]],[[c1]]])
xy1=reform([[[gradient]],[[c2]]])

ymax=max([c1, c2]);*1.1
yrange=[min([c1,c2]),ymax]

hdw_pretty_plot2, xy0,xy1, $
                  label=annotation, right=1, box=0,$
                  YTICKFORMAT=format, TITLE='Conduction',$
                  XTITLE='!9'+STRING("321B")+'!3T [K cm!e-1!n] ',$
                  YTITLE='Flux erg cm!e-2!n s!E-1N',$
                  charsize=1.5, charthick=1.5,$
                  yrange=yrange, lthick=1.8,EPS=EPS_name 
print, annotation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Clean up
set_plot,old_plot_state
!p.multi=old_pmulti
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset the IDL multithreading state to the default
    CPU ,/RESET

end
