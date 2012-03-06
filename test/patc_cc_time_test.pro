;.r patc_cc_energy_test10

;A test of PATC's ability to perform the 
; proper calculation of the energy loss of a particle.
;Same as 4 but as a function of timestep instead of energy
;Test new C++ PaTC code.
set_shrec_sys_variables
TITLE=''
eps_name='energy_test_10.eps'
EPS_time_name='energy_test_9_time.eps'
start_time=systime(1)
print, 'Run started at '+systime(/utc)
;patc_version1='patc'
patc_version1='patc'
patc_version2='patc_cc'
old_pmulti=!p.multi
;!p.multi=[0,1,3]
old_plot_state=!D.NAME
set_plot,'z'
patc_dir=getenv('DATA')+'/PATC/runs/test/'
eps_name=patc_dir+eps_name
EPS_time_name=patc_dir+EPS_time_name
!path=!path+':'+EXPAND_PATH('+'+patc_dir) 
;Total simulation time in seconds
loop_time=10d;10d*60d
delta_time=.1;1d ;[sec]
color_table=39
run_folder=strcompress('./')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Non_thermal particle properties
;Determine the flux of of particles in each energy bin
;How long will the beam be injected?
beam_time=delta_time;[sec]
;Total beam energy in ergs
Flare_energy=1d+10
num_test_particles=[1., 5.];,1e3, 1e4, 1e5, 1e6] 
delta_index=3
energy=50.
energy=[20., 50, 75, 100]
;energy[*]=100
scale_factor=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Loop Properties
diameter=1d8
length=5d9
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Have to fix this
;Some functions and proc's change their parameter input unexpectedly.
dt=delta_time
inj_time=beam_time

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For debugging
;!except=2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
times=-1
for h=0, n_elements(num_test_particles)-1 do begin
   
   n_energies=n_elements(energy)
   percent_diff=dblarr(n_energies, 1d6)-1d0
   for i=0, 0 do begin
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
      NT_BEAM=REPLICATE( NT_BEAM,num_test_particles[h] )
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
    etest=1d
    de1=1
    de2=1
    e_array=1
  ;  while sim_time le loop_time do begin
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

        DELTA_TIME=DT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        resolve_routine,patc_version1
        time_a=systime(1)
        call_procedure, patc_version1, $
                        nt_beam,loop[n_loop-1l],DELTA_TIME, DELTA_E=DELTA_E,$
                        DELTA_MOMENTUM=DELTA_MOMENTUM ;,NT_BREMS=NT_BREMS
        t1=systime(1)-time_a
        print, patc_version1+' took '+string(t1[n_elements(t1)-1])+' to complete a cycle.'  
        DELTA_TIME=dt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Whatever energy change the particles' had the plasma had to have an
;equal yet opposite delta E
        nt_beam1=nt_beam
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        nt_beam=nt_old
        resolve_routine,patc_version2
        time_a=systime(1)
        call_procedure, patc_version2, $
                        nt_beam,loop[n_loop-1l],DELTA_TIME, DELTA_E=DELTA_E,$
                        DELTA_MOMENTUM=DELTA_MOMENTUM ;,NT_BREMS=NT_BREMS
        t2=systime(1)-time_a
        print, patc_version2+' took '+string(t2[n_elements(t2)-1])+' to complete a cycle.'  

        print, t1[n_elements(t1)-1]/t2[n_elements(t1)-1]
        DELTA_TIME=dt
        times=[times, t1/t2]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Whatever energy change the particles' had the plasma had to have an
;equal yet opposite delta E
          nt_beam2=nt_beam
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;All the particles have been thermalized.  Skip some steps   
        junk1=where(nt_beam1.state eq 'NT')
        junk2=where(nt_beam2.state eq 'NT')
        
        if ((junk1[0] eq -1) and (junk2[0]eq -1))  then begin
            goto, endloop
        endif else  begin
           if junk1[0] ne -1 then $
            nt_old=nt_beam1[junk1] else $
               nt_old=nt_beam2[junk2]
        endelse
        DELTA_TIME=DT
;    patc_new,nt_beam,loop,DELTA_TIME
;        m_form=-1d*DELTA_MOMENTUM
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
        print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
        
;nt_flux=get_nt_flux(loop,nt_beam,$
;                     time_step=delta_time,PLOT=1)
     endfor
        skip_patc:

    ;endwhile
    
endloop:
    
;pmm,etest2

    print, 'Run ended at '+systime(/utc)
    print, 'This run took '+string(systime(1)-start_time)+' seconds to complete.'

 endfor



times=times[1:*]


plot,num_test_particles, times, thick = 2, charsize = 1.5, color = fsc_color('black'), $
      back = fsc_color('white'), /xlog, xrange = [1e1, 1e8], /ynozero, yrange = [0, 2], $
      xtitle = 'Array size', ytitle = 'Speedup fraction', title=TITLE, /nodata
oplot ,num_test_particles, times, color = fsc_color('red'), thick = 2

;oplot_horiz, 1, /log, color = fsc_color('black')

legend, thick = 2, color = [ fsc_color('red')], $
        ['pp3/pp4'], linestyle = 0, $
        textcolors=[fsC_color('black')]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset the IDL multithreading state to the default
    CPU ,/RESET

end
