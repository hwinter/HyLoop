;.r patc_time_test_01

;A test of PATC's ability to perform the 
; proper calculation of the energy loss of a particle.
;Same as 4 but as a function of timestep instead of energy
TITLE='PATC Time test ,Statndard Multi-threading'; No Multi-threading'

EPS_time_name='patc_time_test_01.eps'
start_time=systime(1)
print, 'Run started at '+systime(/utc)
;patc_version1='patc'
patc_version1='patc_for_loop'
;patc_version2='patc'
patc_version2='patc_matrix'
old_pmulti=!p.multi
;!p.multi=[0,1,3]
old_plot_state=!D.NAME
set_plot,'z'
patc_dir=getenv('DATA')+'/PATC/runs/test/'

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
;How long will the beam be beam?
injected_time=delta_time;[sec]
;Total beam energy in ergs
Flare_energy=1d+10
num_test_particles=[10., 50,100.,500,1e3,5d3, 1e4]
;num_test_particles=[10.,100.,1e3, 1e4, 1d5]
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
beam_time=dt
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
;n_cpu=10
;CPU ,TPOOL_MAX_ELTS = 1d7 ,TPOOL_MIN_ELTS = 1d7,$
;     TPOOL_NTHREADS=n_cpu
CPU, /reset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Generate the structure containing the injected beam

;Define the number of iterations you are going to
;   need for your electron beam.
;N_beam_iter=long(beam_time/delta_time)
N_beam_iter=1
E_min_max=[15,200]
;
times=-1
t1_array=-1
t2_array=-1
version1_report=0
version2_report=0
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
;stop
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
        Profiler
        profiler, /System
        time_a=systime(1)
        call_procedure, patc_version1, $
                        nt_beam,loop[n_loop-1l],DELTA_TIME, DELTA_E=DELTA_E,$
                        DELTA_MOMENTUM=DELTA_MOMENTUM ;,NT_BREMS=NT_BREMS
        t1=systime(1)-time_a
        t1_array=[t1_array, t1]
        print, patc_version1+' took '+string(t1[n_elements(t1)-1])+' to complete a cycle.'  
        
        profiler, /REPORT,FILE='version1_report'+$
                  strcompress(string(num_test_particles[h],FORMAT='(I07)'),/REMOVE)+$
                              '.txt' ; DATA=version1_report_temp
        
        profiler, /RESET
       ; if size(version1_report, /TYPE) ne 8 then $
        ;   version1_report=version1_report_temp else $
        ;      version1_report=[version1_report, version1_report_temp]

        DELTA_TIME=dt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Whatever energy change the particles' had the plasma had to have an
;equal yet opposite delta E
        nt_beam1=nt_beam
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        nt_beam=nt_old
        resolve_routine,patc_version2
        Profiler
        profiler, /System
        time_a=systime(1)
        call_procedure, patc_version2, $
                        nt_beam,loop[n_loop-1l],DELTA_TIME, DELTA_E=DELTA_E,$
                        DELTA_MOMENTUM=DELTA_MOMENTUM ;,NT_BREMS=NT_BREMS
        t2=systime(1)-time_a
        t2_array=[t2_array, t2]
        print, patc_version2+' took '+string(t2[n_elements(t2)-1])+' to complete a cycle.'
        
        profiler, /REPORT,FILE='version2_report'+$
                  strcompress(string(num_test_particles[h],FORMAT='(I07)'),/REMOVE)+$
                              '.txt' ; DATA=version1_report_temp
        profiler, /RESET
  ;      if size(version2_report, /TYPE) ne 8 then $
  ;         version2_report=version2_report_temp else $
  ;            version2_report=[version2_report, version2_report_temp]

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
    
        skip_patc:

    ;endwhile
    
endloop:
    
;pmm,etest2

    print, 'Run ended at '+systime(/utc)
    print, 'This run took '+string(systime(1)-start_time)+' seconds to complete.'

 endfor
endfor

t1_array=t1_array[1:*]
t2_array=t2_array[1:*]

times=times[1:*]
set_plot, 'x'
window, /free

plot,num_test_particles, times, thick = 2, charsize = 1.5, color = fsc_color('black'), $
      back = fsc_color('white'), /xlog, /ynozero, $
      xtitle = 'Array size', ytitle = 'Speedup fraction', title=TITLE, /nodata, $
     xrange=[min(num_test_particles), max(num_test_particles)*10], $
     yrange=[0.9*min(times), 1.1*max(times)]
oplot, num_test_particles, times , color = fsc_color('red'), thick = 3
oplot,  num_test_particles, times , color = fsc_color('red'),psym=4, symsize=2.5

;oplot_horiz, 1, /log, color = fsc_color('black')

legend, color = [ fsc_color('red')], $
        [patc_version1+'/'+patc_version2], linestyle = 0, $
        textcolors=[fsC_color('black')], thick=3
xyouts,num_test_particles, times+.1, string(t1_array) +' sec', color=fsc_color('green')
xyouts,num_test_particles, times-.1, string(t2_array)+' sec', color=fsc_color('blue')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset the IDL multithreading state to the default
    CPU ,/RESET

end
