
;Simulate loop equilibria at a variety of temperatures
;Test current version of hd_software
; ssw_batch msu_code_test_2 msu_code_test_batch.txt

;resolve_all
;Profile the performance of codes
Profiler, /SYSTEM
COMPILE_OPT STRICTARR
file='/disk/hl2/data/winter/data1/bp_sim/xbp1_eq_mod_t2.sav'
resolve_routine,['add_loop_chromo',$
                 'mk_loop_struct',$
                 'mk_semi_circular_loop', $
                 'regrid_step', $
                 'regrid_inject', $ $
                 'msu_loop',$
                 'msu_loopmodel2',$
                 'get_loop_n_e_cls',$
                 'get_loop_e_cls',$
                 'get_loop_temp_cls',$
                 'get_loop_b_cls',$
                 'get_loop_v_cls'], $
                /EITHER

set_plot,'z'
patc_dir=getenv('PATC')
;sav_dir= patc_dir+'/test/loop_data/' 
;so =get_bnh_so(!computer,/INIT)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set some parameters
if size(name_prefix,/TYPE) ne 7 then  $
  name_prefix =strcompress(arr2str(bin_date(),$
                                   DELIM='_',/NO_DUP),$
                           /REMOVE_ALL)
name_prefix='temp_junk' 
fname1=name_prefix+ '_test_eq2.sav'
;fname1='/disk/hl2/data/winter/data1/bp_sim/xbp1_eq_mod_t2.sav'
fname2=name_prefix+ '_test_eq2.loop'
time=60.*60.;sec
DELTA_T=1. ;sec
SHOWME=1
ATM=1
OUTPUT_PREFIX='msu_code_test_2'
;VERSION=
ATM=1
GRID_safety=15
N_CELLS=100
n_depth=100
depth=2d6
Length=1d9
max_time=10.*time
diameter=7d8
B=100
Tmax = 1d6
rtime=1d0;*60d0
diameter=7d7
area1=!dpi*(diameter/2d0)^2.
note=''
if strupcase(!d.name) eq 'X' then begin
    window, 5
    window_state=1
    window_regrid=0
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
heat_name='get_p_t_law_heat'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOOP=1
mk_semi_circular_loop, $
  /NOSAVE,$
  outname=outname,N_CELLS=N_CELLS,$
  X_SHIFT=X_SHIFT,Y_SHIFT=Y_SHIFT,$
  Z_SHIFT=Z_SHIFT, LOOP=LOOP,$
  depth=depth, N_DEPTH=N_DEPTH,$
  /ADD_CHROMO

old_loop=loop

;Get the amount of heating [ergs] needed to heat a loop of a certain length
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loopeqt2,  g, A, x,Ttop=Tmax, LENGTH=Length, fname=fname1, $
           rebin=N_CELLS+(2*N_DEPTH), depth=depth, rtime=rtime,$
           safety=1.5,computer=!computer,/LOUD, $
           DELTA_T=DELTA_T;
loop.a[*]=area1 
loop.a[*]=1
RESTORE , fname1
;x_axis=spline(loop.s, loop.axis[0,*],x)
;y_axis=spline(loop.s, loop.axis[1,*],x)
;z_axis=spline(loop.s, loop.axis[2,*],x)

resolve_routine,['msu_loop'], $
                /EITHER, /COMPILE_FULL
;
if strupcase(!d.name) eq 'X' then window,1
X_ALT=msu_get_s_alt(x)
t1=msu_get_temp(lhist[0])
t2=get_loop_temp(loop) 
plot, x_alt,t1 
oplot, loop.s_alt, t2 
if strupcase(!d.name) eq 'X' then window, 5, title=!computer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the axis for a semicircle
;radius=length/!dpi
;theta = (findgen(n_surf)*!dpi / (n_surf-1l))-(!dpi/2)
;yy = radius * sin(theta)
;zz = radius * cos(theta)
;axis=dblarr(3,n_surf)
;axis[0,*]=DBLARR(n_surf)+X_SHIFT
;axis[1,*]=(yy+Y_SHIFT)
;axis[2,*]=zz+Z_SHIFT+h_corona
;z=reform(axis[2,*])
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get the amount of heating [ergs] needed to heat a loop of a certain length
Q0=get_serio_heat( loop.L,Tmax)	
DEFSYSV, '!bg_heat', Q0
;restore,patc_dir+'/test/loop_data/gcsm_loop.sav'
Nloops = n_elements(Tmax)
i=0
STATE_out=1
loop.a[*]=1
old_loop=loop

;if strupcase(!d.name) eq 'X' then begin
;    window,15
;    regrid_step, loop, /showme, GRID_safety=GRID_safety
;    window,0
;endif else regrid_step, loop,  GRID_safety=GRID_safety

;regrid_inject, loop, /showme, grid_safety=10
done=0
counter=0
;stop
while not done do begin
    
    regrid_step, loop, /showme, grid_safety=80,$
                 PERCENT_DIFFERENCE=1d7,$
                 WINDOW=WINDOW_REGRID
    current_time=time*counter
    s_form=loop[0].e_h;
    temp_loop=loop[n_elements(loop)-1]
;    LHIST=temp_loop.state
;    msu_loop_model, loop, time, $
;                    DELTA_T=DELTA_T,  S_FORM=S_FORM,$
;                    ATM=ATM, SHOWME=SHOWME, $
;                    TEST=TEST, NOVISC=NOVISC, VERSION=VERSION,$
;                    SO=SO,SPIT=SPIT, URI=URI, FAL=FAL,$
;                    OUTPUT_PREFIX=OUTPUT_PREFIX,QUIET=QUIET,$
;                    LHIST=LHIST
;    msu_evolve_loop2, temp_loop.g,temp_loop.a,temp_loop.s,$
;                      time, e_h, $
;                       s_form=s_form, atm=atm, $
;                      /showme, $
;                      test=test, novisc=novisc, computer=!computer,$
;                      lhist=lhist
;    HELP, old_LOOP, /STR
;    HELP,  TEMP_LOOP, /STR

;    loopmodelt2, temp_loop.g, temp_loop.A,temp_loop.s, $
;                 temp_loop.e_h,time, lhist=temp_loop.state, $
;                 T0=1d4,  src=1,$ ; uri=uri, fal=fal, $
;                 safety=5,DELTA_T=DELTA_T, $ ;SO=SO,
;                 /LOUD;, $
;                 depth=loop[n_elements(loop)-1].depth
;    loopmodelt2,g, A,x, $
;                 e_h,time, lhist=lhist, $
;                 T0=1d4,  src=1,$ ; uri=uri, fal=fal, $
;                 safety=5,DELTA_T=DELTA_T, $ ;SO=SO,
;                 /LOUD;, $
  ;               depth=loop[n_elements(loop)-1].depth
;   loopmodelt, temp_loop.g, temp_loop.A,temp_loop.s, $
;               temp_loop.e_h,time, lhist=temp_loop.state, $
;                T0=1d4,  src=1,$ ; uri=uri, fal=fal, $
;                                ;depth=loop[n_elements(loop)-1].depth, $
;                safety=5,DELTA_T=DELTA_T

;   msu_loopmodel , temp_loop.g, temp_loop.A,temp_loop.s, $
;                temp_loop.e_h,time, lhist=temp_loop.state, $;
;                T0=1d4,  src=1,$ ; uri=uri, fal=fal, $
;                safety=5  
    msu_loopmodel2 ,temp_loop, $
                    temp_loop.e_h,time, $ ;
                    T0=1d4,  src=1,$      ; uri=uri, fal=fal, $
                    safety=15  , /SHOWME, /DEBUG   , $
                    HEAT_FUNCTION=heat_name,$
                    PERCENT_DIFFERENCE=1d7,$
                    grid_safety=40  ,/regrid , $
                    WINDOW_STATE=window_state, WINDOW_REGRID=window_regrid 
;SO=SO,
  ;                              ;depth=loop[n_elements(loop)-1].depth, $
             
 ;   restore, 'foo.sav'
 ;   temp_loop.state=lhist[n_elements(lhist)-1]
 ;   loop=[loop, temp_loop]
 max_v=max(abs(loop.state.v))
 counter+=1 
    case 1 of 
        counter eq 500: done=1
        max_v le 1e+5: done=1
        current_time ge max_time: done=1
        else: 
    endcase
    

    Profiler, /SYSTEM, /REPORT
endwhile

save, loop, FILE=fname2

PROFILER , DATA=profiler_data, OUTPUT=profiler_report, /REPORT, /SYSTEM

;Clear out the profiler's memory
Profiler, /RESET

end
