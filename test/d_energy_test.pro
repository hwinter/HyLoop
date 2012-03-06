;A test of PATC's ability to perform the 
; proper calculation of the energy loss of a particle.
start_time=systime(1)
print, 'Run started at '+systime(/utc)
patc_version='patc_cc'
old_pmulti=!p.multi
;!p.multi=[0,1,3]
old_plot_state=!D.NAME
set_plot,'x'
patc_dir=getenv('DATA')
patc_dir=patc_dir+'/PATC/'
!path=!path+':'+EXPAND_PATH('+'+patc_dir) 
;Total simulation time in seconds
loop_time=1d;10d*60d
delta_time=.001;1d ;[sec]
color_table=39
run_folder=strcompress('./')
minimum_e=94
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
resolve_routine,patc_version
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Non_thermal particle properties
;Determine the flux of of particles in each energy bin
delta_index=0d
energies=[100d]
;How long will the beam be injected?
beam_time=delta_time;[sec]
;Total beam energy in ergs
;1d30 is the energy determined by Sui et al. 2005 for 
; the 2002_APR_15 flare
Flare_energy=1d+30
num_test_particles=(5)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Give an output filename for the HD code.
outname=strcompress(run_folder+'hd_out.sav')
gif_dir=strcompress(run_folder+'gifs/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Path to an IDL save file of a loop magnetic loop
;start_file=patc_dir+'loop_data/exp_b_scl.start'
start_file='~/programs/HyLoop/test/loop_data/loop_tube.loop'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Smoothing width
sm_width=10
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End of input parameters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SSW_PACKAGES, /chianti
SSW_PACKAGES, /xray
$unlimit
;Grab the proper shared object file for bnh_splint
so =get_bnh_so()
print, 'so='+so
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
restore,start_file
lhist=lhist[n_elements(lhist)-1ul]
e_h=e_h[*,0]
n_loop=n_elements(loop)
s=loop[0].s

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
E_min_max=[min(energies),max(energies)]
;
nt_beam=mk_nt_p_struct(loop[n_loop-1l].s,$
                      loop[n_loop-1l].axis[2,*], $
                       loop[n_loop-1l].B,$
                       N_Part=num_test_particles,$ ;
                       IP=0,$
                       E_0=energies[0], $
                       /ELECTS,$
                       PITCH_ANGLE=acos(1))
nt_beam[*].PITCH_ANGLE=acos(1)
if !d.name eq 'X' then window, 0
particle_display, loop,NT_beam,e_min=minimum_e, e_max=max(energies),$
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


DELTA_E=dblarr(n_elements(loop[n_loop-1ul].s)-1ul)
momentum_profile=dblarr(n_elements(loop[n_loop-1ul].s))
DELTA_MOMENTUM=dblarr(n_elements(loop[n_loop-1ul].s))
;


beam_struct={time:sim_time, nt_beam:nt_beam,$
             energy_profile:DELTA_E,$ 
             momentum_profile:DELTA_MOMENTUM}
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

    DELTA_MOMENTUM=dblarr(n_elements(loop[n_loop-1ul].s))
    DELTA_E=dblarr(n_elements(loop[n_loop-1ul].s))
    junk=where(nt_beam.state eq 'NT')
                                ;print,'junk',junk
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;All the particles have been thermalized.  Skip some steps   
    if junk[0] eq -1 then begin
        help,junk
        goto, skip_patc
    endif
    
    DELTA_E=dblarr(n_elements(loop[n_loop-1ul].s)-1ul)
    momentum_profile=dblarr(n_elements(loop[n_loop-1ul].s))
    DELTA_MOMENTUM=dblarr(n_elements(loop[n_loop-1ul].s))
;

    NT_BREMS=1
    ;stop
    
 ;   particle_display, loop,NT_beam,e_min=minimum_e, e_max=max(energies),$
 ;        /XY
    time_a=systime(1)
    call_procedure, patc_version, nt_beam,loop[n_loop-1l],DELTA_TIME, DELTA_E=DELTA_E,$
          DELTA_MOMENTUM=DELTA_MOMENTUM,NT_BREMS=NT_BREMS
    print, 'PATC took '+string(systime(1)-time_a)+' to complete a cycle.'
    ;save,nt_brems, file=run_folder+string(n_sim_iter,format='(I05)')+'.nt_brems'
    delvarx,nt_brems
    skip_patc:
        temp_beam_struct={time:sim_time, nt_beam:nt_beam,$
                          energy_profile:DELTA_E,$ 
                          momentum_profile:DELTA_MOMENTUM}
        beam_struct=concat_struct(beam_struct,temp_beam_struct)

        m_form=-1d*DELTA_MOMENTUM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Whatever energy change the particles' had the plasma had to have an
;equal yet opposite delta E

        energy_profile=abs(-1d*DELTA_E*keV_2_ergs)

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
if sm_width gt 0 then begin
        for jc=0,3 do   s_form=abs(smooth(s_form, sm_width))
        for jc=0,3 do   m_form=abs(smooth(m_form, sm_width))
    endif
        lhist[n_elements(lhist)-1].v=(lhist[n_elements(lhist)-1].v) $
          +(m_form/(lhist[n_elements(lhist)-1].n_e*volumes))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
no_energy:
;stop
        s_form=s_form+e_h
        help,s_form
        PMM,S_FORM
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
;        if beam_counter lt N_beam_iter  then begin
;            nt_beam=concat_struct(temporary(nt_beam),$
;                          injected_beam_struct[beam_counter].nt_beam)
;        endif

T_plasma=get_loop_temp(loop[0])
debye_length=((k_boltz_ergs*T_plasma)/ $
              (4d*!dpi*e^2d))^0.5d
b_crit=(e^2d)/(2d*nt_beam.ke_total*keV_2_ergs ) 
ln_lambda=(alog(debye_length[nt_beam.position_index]/b_crit))

;Analytic delta_e
de1=[de1,$
   (((-2d)*(!dpi)*(ln_lambda)*$
     (e^4d))/(nt_beam.KE_total*kev_2_ergs)) $
   *((e_mass_g/p_mass_g)+1d)$
   *(loop.state.N_e[nt_beam.position_index]) $
   *energy2vel(nt_beam.KE_total)*delta_time $
   *(1d/kev_2_ergs)]

de2=[de2,nt_beam.KE_total-beam_struct[n_sim_iter-2ul].nt_beam.KE_total]


etest=[etest,mean(abs((de1-de2)/de1))]
print,'Min/Max cos(Pitch Angle)'
pmm, cos(NT_beam.pitch_angle)

print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
if !d.name eq 'X' then window, 0
particle_display, loop,NT_beam,e_min=minimum_e, e_max=max(energies),$
                  /XY,C_BAR_POS=[0.35,0.8,0.7,0.85]
if !d.name eq 'X' then window,4
plot,BEAM_STRUCT.time, de1, psym=5,XTITLE='Time'
oplot, BEAM_STRUCT.time, de2, psym=6
if !d.name eq 'X' then window, 2
plot_histo, NT_beam.pitch_angle
if !d.name eq 'X' then window, 1
;nt_flux=get_nt_flux(loop,nt_beam,$
;                     time_step=delta_time,PLOT=1)
endwhile

endloop:
print, 'etest=',string(etest)
print, 'max nt_brems.N_photons',max(nt_brems.N_photons)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;test for the entire tube instead of one step.
b_crit=(e^2d)/(2d*BEAM_STRUCT[0].nt_beam.ke_total*keV_2_ergs )
de1=(((-2d)*(!dpi)*(ln_lambda)* $
     (e^4d))/(BEAM_STRUCT[0].nt_beam.KE_total*kev_2_ergs)) $
     *((e_mass_g/p_mass_g)+1d)$
     *(loop.state.N_e[nt_beam.position_index]) $
     *energy2vel(BEAM_STRUCT[0].nt_beam.KE_total) $
     *(sim_time-2*delta_time) $
     *(1d/kev_2_ergs)

etest2=mean(abs((de1-(BEAM_STRUCT[n_elements(BEAM_STRUCT)-2ul].nt_beam.KE_total $
       -BEAM_STRUCT[0].nt_beam.KE_total))/de1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset the IDL multithreading state to the default
CPU ,/RESET
;window,4
;plot,BEAM_STRUCT.time, etest, psym=5,XTITLE='Time'
pmm,etest2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Clean up
set_plot,old_plot_state
!p.multi=old_pmulti
print, 'Run ended at '+systime(/utc)
print, 'This run took '+string(systime(1)-start_time)+' seconds to complete.'


end
