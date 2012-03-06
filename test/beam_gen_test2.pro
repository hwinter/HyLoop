; .r beam_gen_test2.pro

folder=getenv('DATA')+'/PATC/runs/flare_exp_01/'
subfolders=getenv('DATA')+'/PATC/runs/flare_exp_01/'+ $
           'alpha=-4/699_25/'+ $
           ['run_01/','run_02/','run_03/','run_04/','run_05/',$
          'run_06/','run_07/','run_08/','run_09/','run_10/']

dist_alpha=-100

start_time=systime(1)
print, 'Run started at '+systime(/utc)
old_plot_state=!D.NAME
set_plot,'x'
;Total simulation time in seconds
loop_time=15d*60d
delta_time=1d ;[sec]
color_table=39
run_folder=subfolders[0]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Non_thermal particle properties
;Determine the flux of of particles in each energy bin
delta_index=3d
energies=[15d,200d]
;How long will the beam be injected?

beam_time=02d;[sec]
beam_dt=0.1
defsysv, '!PATC_DT',beam_dt
;Total beam energy in ergs
;1d30 is the energy determined by Sui et al. 2005 for 
; the 2002_APR_15 flare
Flare_energy=1d+29

;Number of test particles per beam.
num_test_particles=(1053d0)
FRACTION_PART=.73
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HEAT_FUNCTION='pt_with_patc'
DEFSYSV, '!heat_alpha',3./2.
DEFSYSV, '!heat_beta',0.
DEFSYSV, '!heat_Tmax',1.5d6
flux =get_p_t_law_flux( l, alpha,!heat_Tmax)
DEFSYSV, '!constant_heat_flux',flux

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Give an output filename for the HD code.
FILE_PREFIX=strcompress(run_folder+'patc_test_')
gif_dir=strcompress(run_folder+'gifs/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Path to an IDL save file of a loop magnetic loop
start_file=run_folder+'gcsm_loop.sav';g
safety=5.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Debug=0.
showme=1
quiet=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End of input parameters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the run play nice
spawn,'renice 4 -u winter'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
COMPILE_OPT STRICTARR
;Make some settings to make use of IDL multithreading
;Most of the defaults are ok.
n_cpu=(!CPU.HW_NCPU-1)
n_cpu=2
CPU , TPOOL_NTHREADS=n_cpu
SSW_PACKAGES, /chianti
SSW_PACKAGES, /xray
;Attempt to unlimit the memory usage
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the number of iterations that the code will make.
N_interations=fix(loop_time/delta_time)
restore,start_file
loop.state.time=0.

e_h=loop.e_h
n_loop=n_elements(loop)
s=loop[0].s
volumes=get_loop_vol(loop)
n_vol=n_elements(volumes)
defsysv, '!patc_heat',e_h*0.
;;;;;;;;;;;;;;;;;;;;;;;;;;;e_h;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the loop half length and then overplot the highest point 
;on the loop
if !d.name eq 'X' then window,18
plot,loop[n_loop-1l].axis[1,*],loop[n_loop-1l].axis[2,*]     
junk=where(abs(s-max(s)/2.) eq min(abs(s-max(s)/2.)))
plots,loop[0].axis[1,junk],loop[0].axis[2,junk],psym=4
junk=where( loop[0].axis[2,*] eq max(loop[0].axis[2,*]))
plots,loop[0].axis[1,junk],loop[0].axis[2,junk],psym=5    
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Generate the structure containing the injected beam

;Define the number of iterations you are going to
;   need for your electron beam.
N_beam_iter=long(beam_time/beam_dt)
E_min_max=[min(energies),max(energies)]
;
injected_beam=beam_generator(loop,E_min_max, $
                                    total_energy=Flare_energy, $
                                    SPEC_INDEX=delta_index, $
                                    time=inj_time, delta_t=beam_dt,$
                                    IP='z',n_PART=num_test_particles, $
                                    ALPHA=dist_alpha,$
                                    FRACTION_PART=FRACTION_PART, $
                                    T_PROFILE='Gaussian')
;stop
test=size(injected_beam.nt_beam)
nt_beam=reform(injected_beam.nt_beam, test[1]*test[2])

window,1, title='PA plot'
pa_plot2, nt_beam
window,2, title='Energy plot'
 e_dist_plot, nt_beam
window,3, title='Plot Histo  plot'
mu=cos(nt_beam.PITCH_ANGLE)
plot_histo, mu
help, injected_beam
help, injected_beam.nt_beam



end

