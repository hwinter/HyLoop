;.r conduction test.pro
;A test of PATC's ability to perform the 
; proper calculation of the energy loss of a particle.
;Same as 4 but as a function of timestep instead of energy

eps_name='energy_test_04.eps'
start_time=systime(1)
print, 'Run started at '+systime(/utc)
patc_version='patc'
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
resolve_routine,patc_version
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Non_thermal particle properties
;Determine the flux of of particles in each energy bin
;How long will the beam be injected?
beam_time=delta_time;[sec]
;Total beam energy in ergs
Flare_energy=1d+10
num_test_particles=(1d0)
delta_index=3
energy=[20., 50, 75, 100]
energy=50.

scale_factor=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Loop Properties
diameter=1d8
length=1d9
T_MAX=1d6
N_E=1d9
UNIFORM=1 
B=10
nosave=1
N_CELLS=200
LOOP=1
dist_alpha=0
FRACTION_PART=1.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Smoothing width
sm_width=10
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Give an output filename for the HD code.
outname=strcompress(run_folder+'hd_out.sav')
gif_dir=strcompress(run_folder+'gifs/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Path to an IDL save file of a loop magnetic loop
;start_file=patc_dir+'loop_data/exp_b_scl.start'

loop=mk_loop_tube(diameter,length, $
  T_MAX=T_MAX,N_E=N_E ,$
  N_DEPTH=N_DEPTH,$
  TO=T0,UNIFORM=UNIFORM, $
  B=B,Q0=Q0,  nosave=nosave, $
  outname=outname,N_CELLS=N_CELLS,$
  X_SHIFT=X_SHIFT,Y_SHIFT=Y_SHIFT,$
  Z_SHIFT=Z_SHIFT, $
  SIGMA_FACTOR=SIGMA_FACTOR)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End of input parameters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SSW_PACKAGES, /chianti;, /quiet
SSW_PACKAGES, /xray;, /quiet
$unlimit
print, patc_version
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Have to fix this
;Some functions and proc's change their parameter input unexpectedly.
dt=delta_time
inj_time=beam_time

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For debugging
;!except=2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;1 keV=1.602e-9 ergs
; converts keV to ergs
keV_2_ergs = 1.602d-9
;converts ergs to keV
egs_2_kev=1d/(keV_2_ergs)
;Boltzmann's constant in ergs/[K]
k_boltz_ergs=1.3807d-16
;Charge on an electron in statcoulombs
e=4.8032d-10
;Electron mass in grams
e_mass_g=9.1094d-28 
;Proton mass in grams
p_mass_g=1.6726d-24 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the number of iterations that the code will make.
N_interations=fix(loop_time/delta_time)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make some settings to make use of IDL multithreading
;Most of the defaults are ok.
n_cpu=(!CPU.HW_NCPU)-1
n_cpu>=1

CPU ,TPOOL_MAX_ELTS = 1d6 ,TPOOL_MIN_ELTS = 5d3,$
     TPOOL_NTHREADS=n_cpu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Generate the structure containing the injected beam

;Define the number of iterations you are going to
;   need for your electron beam.
;N_beam_iter=long(beam_time/delta_time)
N_beam_iter=1
E_min_max=[15,200]
;


n_energies=n_elements(energy)
percent_diff=dblarr(n_energies, 1d6)-1d0
for i=0, n_energies-1 do begin
    NT_BEAM = { $
               KE_TOTAL: double(energy[i]), $
               MASS:DOUBLE(9.1094000e-28), $
               PITCH_ANGLE:DOUBLE (acos(0.1)),$
               X :douBle(loop.s[50]), $
               CHARGE:DOUBLE(4.8032000e-10), $
               ALIVE_TIME:DOUBLE(0.0000000), $
               STATE:    'NT', $
               MAG_MOMENT:DOUBLE(0.0000000), $
               SCALE_FACTOR:DOUBLE(1), $   
               POSITION_INDEX: ULONG(0)  , $   
               DESCRIPTION:STRArR(11)   , $   
               VERSION:FLOAT(2.00 )  $   
              }
;stop
;nt_beam.x=0
    NT_BEAM=REPLICATE( NT_BEAM,num_test_particles )
    if !d.name eq 'X' then begin
        window, 0
        particle_display, loop,NT_beam,e_min=10, e_max=max(energy[i]),$
                          /XY
        window, 1
        nt_flux=get_nt_flux(loop,nt_beam,$
                            PLOT=1)
    endif
;restore, '/Users/winter/Data/PATC/runs/2006_DEC_07c/injected_beam.sav'
;nt_beam=injected_beam[0].nt_beam
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Have to fix this
;Some functions and proc's change their parameter input unexpectedly.
    dt=delta_time
    inj_time=beam_time
;We are at the beginning of the run so start out some counters at 0
    beam_step=0
    beam_on_time=0
    sim_time=0
    counter=0
    beam_counter=0
    sim_time=0d
    beam_on_time=0d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Main loop
;This loop spans the whole loop simulation time.
;Electron Beam injection
;Loop cooling post beam injection.
;Electron thermalization. etc.  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Keep the loop going until time's up
;stop
    n_sim_iter=1ul
    time=0
;
    etest=1d
    de1=1
    de2=1
    e_array=1
    while sim_time le loop_time do begin
        junk=where(nt_beam.state eq 'NT')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;All the particles have been thermalized.  Skip some steps   
        
        if junk[0] eq -1 then begin
            goto, endloop
        endif else nt_beam=nt_beam[junk]
        
        print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
        print,'iteration #:',n_sim_iter
        print, "N_elements Beam:",n_elements(nt_beam)
        print, "Time Step: ",delta_time
        print, "Current simulation time:",sim_time
        print, 'Computer: ',!computer
        print, 'Minimum/Maximum Beam Energy [keV]', $
               min(nt_beam.ke_total),'/', max(nt_beam.ke_total)
        n_loop=n_elements(loop)

                                ;print,'junk',junk
  
        
        nt_old=NT_beam
        if !d.name eq 'X' then begin
            particle_display, loop,NT_beam,e_min=10, e_max=max(energy[i]),$
                              /XY
        endif
        DELTA_TIME=DT
        time_a=systime(1)
        call_procedure, patc_version, $
                        nt_beam,loop[n_loop-1l],DELTA_TIME, DELTA_E=DELTA_E,$
                        DELTA_MOMENTUM=DELTA_MOMENTUM ;,NT_BREMS=NT_BREMS
        print, 'PATC took '+string(systime(1)-time_a)+' to complete a cycle.'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;All the particles have been thermalized.  Skip some steps   
        junk=where(nt_beam.state eq 'NT')
        if junk[0] eq -1 then begin
            goto, endloop
        endif else  begin
            nt_beam=nt_beam[junk]
            nt_old=nt_old[junk]
        endelse
  
        junk=where(nt_beam.ke_total gt 10.)
        if junk[0] eq -1 then begin
            goto, endloop
        endif else  begin
            nt_beam=nt_beam[junk]
            nt_old=nt_old[junk]
        endelse

 

        DELTA_TIME=DT
;    patc_new,nt_beam,loop,DELTA_TIME
;        m_form=-1d*DELTA_MOMENTUM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Whatever energy change the particles' had the plasma had to have an
;equal yet opposite delta E
        delta_e1=(NT_beam.ke_total-nt_old.ke_total) ;*keV_2_ergs
        de2=[de2,$
             (avg(delta_e1))]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
no_energy:
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       
;Set counters forward
        n_sim_iter=temporary(n_sim_iter)+1ul
        beam_on_time=beam_on_time+delta_time        
        beam_counter+=1ul
        
        sim_time=sim_time+delta_time
        loop.state.time=sim_time
;        if beam_counter lt N_beam_iter  then begin
;            nt_beam=concat_struct(temporary(nt_beam),$
;                          injected_beam_struct[beam_counter].nt_beam)
;        endif
        
        T_plasma=get_loop_temp(loop[0])
;Different than Choudhuri and Benz but about the same as 
;  The NRL plasma formulary
        debye_length=6.9010323*((T_plasma)/ $
                                (loop.state.n_e[0]))^0.5d
        
        b_crit=(e^2d)/(nt_old.ke_total*keV_2_ergs ) 
        ln_lambda=(alog(1d0+(debye_length/b_crit)))
        
        v_total=energy2vel(nt_old.ke_total)
        v_squared=v_total*v_total
        A_factor=(4d0*!dpi*loop.state.n_e[0]$
                  *v_squared)
        mu_e=(nt_old[*].mass*!msul_me)/(nt_old[*].mass+!msul_me)
        zeta_e=!msul_qe*nt_old[*].charge/(mu_e*v_squared)
        xi_e=mu_e*zeta_e*zeta_e*alog(debye_length/zeta_e)
        
;Analytic delta_e
        C=2d0*!dpi*(e^4.)*ln_lambda[0]
        anal_de=((-C*loop.state.n_E[0]*energy2vel(nt_old.ke_total))$
                 /(nt_old.ke_total*keV_2_ergs))*delta_time
        
        anal_de=-A_factor*v_total*delta_time*(((mu_e/!msul_me) $
                                               *xi_e) )
        etest_temp=avg((anal_de-delta_e1)/anal_de)
        if n_elements(anal_de) gt 1 then $
          avg_de1=moment(anal_de/kev_2_ergs) else $
          avg_de1=anal_de/kev_2_ergs
        de1=[de1,$
             avg_de1[0]]
        e_array=[  e_array,avg(abs((delta_e1-anal_de)/anal_de))]
        print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
        if !d.name eq 'X' then begin
            window, 0
            particle_display, loop,NT_beam,e_min=10, e_max=max(energy[i]),$
                              /XY,C_BAR_POS=[0.35,0.8,0.7,0.85]
            window, 2
            pa_plot2, NT_beam
            window, 1
;nt_flux=get_nt_flux(loop,nt_beam,$
;                     time_step=delta_time,PLOT=1)
        endif
        skip_patc:
    endwhile
    
endloop:
;window,4
;plot,BEAM_STRUCT.time, etest, psym=5,XTITLE='Time'
    de1=de1[1:n_elements(de1)-2]
    
    de2=de2[1:n_elements(de2)-2]
    
    etest=((de1-de2)/de1)
    pmm, etest
    percent_diff[i,0:n_elements(etest)-1]=etest
;pmm,etest2

    print, 'Run ended at '+systime(/utc)
    print, 'This run took '+string(systime(1)-start_time)+' seconds to complete.'

endfor
n_array=lindgen(n_elements(etest))+1



n_b_max=1d36
ymax=-1
for i=0, n_energies-1 do begin
    junk=where(percent_diff[i,*] ne -1, count)
    n_b_max<=count
    ymax>=max(percent_diff[i,*])
endfor
n_b_max=500
new_p=dblarr(n_energies, n_b_max)
new_p=percent_diff[*, 0:n_b_max-1ul]
percent_diff=new_p

n_steps=lindgen(n_b_max)+1
n_steps=transpose(rebin(n_steps,n_b_max, n_energies))
annotation=['']
format='(e10.1)'

for i=0, n_energies-1 do begin
    mean=moment(percent_diff[i,*]);, sdev=percent_diff_std)
    annotation=[annotation,$
                'KE='+string(energy[i], format=format)+' keV,'+ $
                ' Avg % Diff.='+string(mean[0], format=format)]
    
endfor

annotation=annotation[1:*]
xy0=reform([[[n_steps[0,*]]],[[percent_diff[0,*]]]])
xy1=reform([[[n_steps[1,*]]],[[percent_diff[1,*]]]])
xy2=reform([[[n_steps[2,*]]],[[percent_diff[2,*]]]])
xy3=reform([[[n_steps[3,*]]],[[percent_diff[3,*]]]])
help, xy0, xy1


;yrange=[0,ymax]

hdw_pretty_plot2, xy0, xy1, xy2, xy3, $
                  label=annotation, right=1, box=0,$
                  YTICKFORMAT=format, TITLE='Energy Test',$
                  XTITLE='N Timesteps',YTITLE='Avg % Diff.',$
                  EPS=EPS_name, charsize=1, charthick=1,$
                  lthick=2.
print, annotation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Clean up
set_plot,old_plot_state
!p.multi=old_pmulti
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset the IDL multithreading state to the default
    CPU ,/RESET

end
