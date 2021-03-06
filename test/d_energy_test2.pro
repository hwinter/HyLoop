;.r d_energy_test2
;A test of PATC's ability to perform the 
; proper calculation of the energy loss of a particle.
start_time=systime(1)
print, 'Run started at '+systime(/utc)
patc_version='patc'
old_pmulti=!p.multi
;!p.multi=[0,1,3]
old_plot_state=!D.NAME
set_plot,'x'
patc_dir=getenv('DATA')
patc_dir=getenv('DATA')+'/PATC/test/'
!path=!path+':'+EXPAND_PATH('+'+patc_dir) 
;Total simulation time in seconds
loop_time=60d;10d*60d
delta_time=.01;1d ;[sec]
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
energy=20.
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

NT_BEAM = { $
           KE_TOTAL: double(energy), $
           MASS:DOUBLE(9.1094000e-28), $
           PITCH_ANGLE:DOUBLE (acos(1)),$
           X :douBle(loop.s[5]), $
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
if !d.name eq 'X' then window, 0
particle_display, loop,NT_beam,e_min=10, e_max=max(energy),$
        /XY
if !d.name eq 'X' then window, 1
;nt_flux=get_nt_flux(loop,nt_beam,$
;                     PLOT=1)
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

e_deposited=0
;
etest=1d
de1=1
de2=1


while sim_time le loop_time do begin
    junk=where(nt_beam.state eq 'NT')
    if junk[0] eq -1 then goto, endloop

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
 
    junk=where(nt_beam.state eq 'NT')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;All the particles have been thermalized.  Skip some steps   
    if junk[0] eq -1 then begin
        help,junk
        goto, skip_patc
    endif
    
    nt_old=NT_beam
    particle_display, loop,NT_beam,e_min=10, e_max=max(energy),$
         /XY
    time_a=systime(1)
    call_procedure, patc_version, nt_beam,loop[n_loop-1l],DELTA_TIME, DELTA_E=DELTA_E,$
          DELTA_MOMENTUM=DELTA_MOMENTUM;,NT_BREMS=NT_BREMS
    print, 'PATC took '+string(systime(1)-time_a)+' to complete a cycle.'
    skip_patc:
    pmm, delta_e

    e_deposited=total(DELTA_E)+e_deposited
;    patc_new,nt_beam,loop,DELTA_TIME
;        m_form=-1d*DELTA_MOMENTUM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Whatever energy change the particles' had the plasma had to have an
;equal yet opposite delta E

        energy_profile=abs(-1d*DELTA_E*keV_2_ergs)
        de2=[de2,$
             avg(NT_beam.ke_total-nt_old.ke_total)*keV_2_ergs]
        print,'Total Energy', total(energy_profile), ' ergs'
        energy_profile=energy_profile/(delta_time)

        print,'Total Power', total(energy_profile), ' ergs s^-1'
       
        if total(energy_profile) le 0d then begin
            print, 'No collision case'
            energy_profile=dblarr(n_elements(loop[n_loop-1l].s)-1ul)
            s_form=dblarr(n_elements(s)-1ul)
            m_form=0d
            goto, no_energy
        endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate volumes of each bit
        volumes= get_loop_vol(loop[n_loop-1l])
        n_vol=n_elements(volumes)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Put the energy and momentum where it goes for MSULoop
        s_form=energy_profile/volumes
;if sm_width gt 0 then begin
;        for jc=0,3 do   s_form=abs(smooth(s_form, sm_width))
;        for jc=0,3 do   m_form=abs(smooth(m_form, sm_width))
;    endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
no_energy:
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Save all of the software's hard work    
;   
;        save,beam_struct,loop, s_form,$
;             file=run_folder+string(n_sim_iter,format='(I05)')+'.loop'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
                                (loop.state.n_e))^0.5d

        b_crit=(e^2d)/(nt_beam.ke_total*keV_2_ergs ) 
        ln_lambda=(1d0+alog(debye_length[nt_beam.position_index]/b_crit))
        
;Analytic delta_e


        C=2d0*!dpi*(e^4.)*ln_lambda[0]
        de1=[de1,$
             avg(-C*loop.state.n_E[0]*$
                 energy2vel(nt_beam.ke_total)$
                 *delta_time/(nt_beam.ke_total*keV_2_ergs))]


etest=[etest,mean(abs((de1-de2)/de1))]
print,'Min/Max cos(Pitch Angle)'
pmm, cos(NT_beam.pitch_angle)

print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
if !d.name eq 'X' then window, 0
particle_display, loop,NT_beam,e_min=10, e_max=max(energy),$
                  /XY,C_BAR_POS=[0.35,0.8,0.7,0.85]
if !d.name eq 'X' then window,4
;plot,BEAM_STRUCT.time, de1, psym=5,XTITLE='Time'
;oplot, BEAM_STRUCT.time, de2, psym=6
if !d.name eq 'X' then window, 2
pa_plot2, NT_beam
if !d.name eq 'X' then window, 1
;nt_flux=get_nt_flux(loop,nt_beam,$
;                     time_step=delta_time,PLOT=1)
endwhile

endloop:
;print, 'max nt_brems.N_photons',max(nt_brems.N_photons)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;test for the entire tube instead of one step.
;b_crit=(e^2d)/(2d*BEAM_STRUCT[0].nt_beam.ke_total*keV_2_ergs )
;de1=(((-2d)*(!dpi)*(ln_lambda)* $
;     (e^4d))/(BEAM_STRUCT[0].nt_beam.KE_total*kev_2_ergs)) $
;     *((e_mass_g/p_mass_g)+1d)$
;     *(loop.state.N_e[nt_beam.position_index]) $
;     *energy2vel(BEAM_STRUCT[0].nt_beam.KE_total) $
;     *(sim_time-2*delta_time) $
;     *(1d/kev_2_ergs)

;etest2=mean(abs((de1-(BEAM_STRUCT[n_elements(BEAM_STRUCT)-2ul].nt_beam.KE_total $
;       -BEAM_STRUCT[0].nt_beam.KE_total))/de1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset the IDL multithreading state to the default
CPU ,/RESET
;window,4
;plot,BEAM_STRUCT.time, etest, psym=5,XTITLE='Time'
de1=de1[1:n_elements(de1)-1]

de2=de2[1:n_elements(de2)-1]

etest=etest[1:n_elements(etest)-1]

print, 'etest=',string(etest)

;pmm,etest2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Clean up
set_plot,old_plot_state
!p.multi=old_pmulti
print, 'Run ended at '+systime(/utc)
print, 'This run took '+string(systime(1)-start_time)+' seconds to complete.'


e_ergs=energy/!msul_keV_2_ergs
C=2d0*!dpi*(e^4.)*ln_lambda[0]
dt=((e_ergs-(15./!msul_keV_2_ergs))*energy )$
   /(loop.state.n_e[0]*energy2vel(energy)*C)
print, dt

dt2=(2D0)*e_ergs*e_ergs/$
    ((energy2vel(energy))*loop.state.n_e[0]*3D0*C)

print, dt2
end
