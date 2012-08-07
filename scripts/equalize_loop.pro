;
plot_state=!D.Name
set_plot,'Z'
patc_dir=getenv('PATC')
restore, patc_dir+'/test/loop_data/gcsm_loop.sav'
save_file= patc_dir+'/scripts/gcsm_loop.sav'
min_v=1e+3
max_time=5d0*60d0*60d0          ;Time to allow loop to come to equilibrium
rtime=60d0                      ;Output timestep
DELTA_T=10d0                     ;reporting  timestep
time=0d0                        ;The simulation start time
safety=5d0                      ;Number that will be divided by
                                ;  the C. condition to determine the timestep
grid_safety=3d                  ;Number that will be divided by
                                ;  the minimum characterstic scale length to determine
                                ;  the grid sizing
note='Green style current sheet initially given RTV scaling'
plot_state=!D.Name
set_plot,'Z'
old_except=!except
!except=2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
Mega_meter2cm=1d8
cm2Mega_meter=1d-8
;Solar surface gravity acceleration[cm s^-2]
g0 =2.74d4
;Solar radius [cm]
R_Sun=6.96d10
d_chrom=2d8
depth=d_chrom*.7
;Height of the Corona above the photosphere[cm]
h_corona=2d8
;Boltzmann constant (erg/K)
kB = 1.38d-16      
;proton mass (g)
mp = 1.67d-24     
;Chromospheric Temperature   
T0=1.d4 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;stop
equil_counter=1
done=0
regrid_step, loop,/NOSAVE;,/SHOWME

max_v=1d7
while not done do begin
    n_loop=n_elements(loop)   
    state=loop[n_loop-1l].state
    g=loop[n_loop-1l].g
    a=loop[n_loop-1l].a
    s=loop[n_loop-1l].s
    e_h=loop[n_loop-1l].e_h[*,0]
    n_depth=loop[n_loop-1l].n_depth
;print, equil_counter;
;    msu_evolve_loop2, g,a,s, rtime,  DELTA_T,e_h, n_depth, $
;                    outfile=outfile, q0=q0, $
;                    /showme,  $ ;q0=q0,
;                    computer=!computer,$
;                    lhist=state;,so=so ;,/novisc
    loopmodelt2, g, A, s, q0, rtime, T0=1e4, $
                 /fal, /uri,lhist=state,$
                 safety=5,$;safety,$
                 so=so,/src,  DELTA_T=DELTA_T  ,$
                 OUTFILE='foo.sav';,depth=depth

    n_state=n_elements(state)             
    state[n_state-1].e=abs(state[n_state-1].e)
    state[n_state-1].n_e=abs(state[n_state-1].n_e)
    temp_loop=loop[n_loop-1l]
    temp_loop.state=state[n_elements(state)-1l]
    temp_loop.time=state[n_elements(state)-1l].time
    loop=temp_loop
    
    if !d.name eq 'X' then window,18,TITLE='Before Regrid'
     stateplot2,LOOP.s, LOOP.state,/SCREEN
    if !d.name eq 'X' then x2gif,'snap.gif'
    if !d.name eq 'Z' then z2gif,'snap.gif'

   ; if !d.name eq 'X' then wset,regrid_window
    regrid_step, loop,/NOSAVE;,/SHOWME
    ;if !d.name eq 'X' then window,19,TITLE='After Regrid'
    ;stateplot,LOOP.s, LOOP.state,/SCREEN
;Determine the maximum veloxity
    max_v=max(abs(loop.state.v))
    if max_v le min_v then done =1
;Artificially smooth
    ;for j=0,5 do state.v[*]=smooth(state.v,10)      
    ;for j=0,5 do e = smooth(e,7)
;Artificially kill the velocity
    ;state.v[*]=0

    pmm,abs(loop.state.v)
    ;if equil_counter eq 400 then done=1
    equil_counter +=1
    if loop.state.time gt max_time then done=1
endwhile


end_jump:
e_h=e_h[*,0]
print,'Saving file: ', save_file
save,g, A, s, rad, state, E_h,axis,b,loop,q0, heat,e_h,file=save_file



;reset the except state             
!except=old_except
set_plot, plot_state
END

