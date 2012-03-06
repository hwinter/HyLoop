;pro 
;
;beam_gen_test
set_plot,'x'
SSW_PACKAGES, /chianti
patc_dir=getenv('PATC')
data_dir=getenv('DATA')
!path=!path+':'+EXPAND_PATH('+'+patc_dir) 
start_time=systime(0)
;Total simulation time in seconds
loop_time=10d*60d
;Total beam energy in ergs
;1d30 is the energy determined by Sui et al. 2005 for 
; the 2002_APR_15 flare
Flare_energy=1d+30
total_energy=Flare_energy
time_step=.1 ;[sec]
delta_time=time_step
color_table=39
plot_title='Model Loop Sim'
run_folder=strcompress(data_dir+'/PATC/runs/2006_DEC_09_01/')
alpha=0
beta=1d
num_test_particles=(1d2)
beam_name='initial_nt_beam.sav'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Cheat
particle_shift=0l
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Give an output filename for the HD code. .sav will be added
outname=strcompress(run_folder+'hd_out.sav')

gif_dir=strcompress(run_folder+'gifs/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Background heating 
;q0=0.007                    ;erg/s/cm^3
;Now get from file
sm_width=10
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Non_thermal particle properties
;Determine the flux of of particles in each energy bin
delta_index=3d
spec_index=delta_index
e_min_max=[20d0,185d0]
e_res=5d0
n_bins=long(float((max(e_min_max)-min(e_min_max))/e_res))
energies=double(fix((min(e_min_max))+(dindgen(n_bins)/(n_bins-1l))*float(max(e_min_max)-min(e_min_max))))

;energies=[20d,25d,30d,35d,40d,45d,50d,$
;          55d0,60d,65d0,70d0,75d0,80d0,$
;          85d,90d0,95d0,100d,105d0,]
;energies=[20d,50d]

n_part=num_test_particles
beam_time=02d;[sec]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Path to an IDL save file of a loop magnetic loop
;start_file=patc_dir+'loop_data/exp_b_scl.start'
start_file=run_folder+'gcsm_loop.sav'
;start_file=dialog_pickfile()
;loop_file=patc_dir+'loop_data/exp_b_scl.sav'
save_file=run_folder+'/full_test_2.sav'

so =get_bnh_so(!computer,/init);Grab the proper shared object file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Define the number of iterations you are going to
;   need for your electron beam.
N_beam_iter=long(beam_time/time_step)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;f=A(E/E_0)^(-delta)
E_0=min(energies)
percent=double((energies/E_0)^(-delta_index)) 
percent=percent/total(percent)
number_n_E_bin=long(percent*num_test_particles)
number_n_E_bin>=10l
num_test_particles=total(number_n_E_bin)
color_lower_bound=(110)
syms=[4, intarr(n_elements(energies))+8]
color_factor=(255-color_lower_bound)/(max(energies)-min(energies))
color_offset=255-(color_factor)

 Ticknames=[string(energies, format='(I2.2)')+' keV']
Ticknames=reverse(Ticknames)
 Ticknames=[Ticknames,'Thermal']

syms=reverse(syms)
circle_sym,  THICK=2, /FILL

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
k_boltz_ergs=1.3807d-16
kb=k_boltz_ergs
;Boltzmann's constant in Joules/[K]
k_boltz_joules=1.3807d-23 
;Electron mass in grams
e_mass_g=9.1094d-28 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;We defined a total energy for a flare.  The next two lines define a
;scale factor so that we acheive that energy.
energy_per_beam=total(energies*number_n_E_bin)*keV_2_ergs
scale_factor=Flare_energy/(energy_per_beam*N_beam_iter)
;scale_factor=2.78d26/energy_per_beam
;Define the number of iterations that the code will make.
N_interations=fix(loop_time/time_step)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;print,'N_beam_iter:', string(N_beam_iter)


restore,start_file
e_h[*]=min(e_h)
help, e_h
pmm,e_h
n_loop=n_elements(loop)
bgheat=e_h
x=loop[0].s

N_beam_iter=long(beam_time/time_step)

injected_beam=beam_generator2(loop,E_min_max, TOTAL_ENERGY=TOTAL_ENERGY, $
                             SPEC_INDEX=SPEC_INDEX, N_PART=N_PART,$
                             N_BEAMS=N_beam_iter, IP='z',$ ;T_PROFILE=T_PROFILE,$
                             /ELECTS, $
                             E_RES=E_RES, TIME=beam_time,$
                            ALPHA=ALPHA, BETA=BETA,/unif, grr=1)


print, 'total_energy=', $
       total(injected_beam.nt_beam.ke_total $
             *injected_beam.nt_beam.scale_factor)*kev_2_ergs

nt_beam=injected_beam[0].nt_beam

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End section to calculate Energy in each E_bin
window,1
plot, nt_beam.ke_total,nt_beam.scale_factor, title='BG2'

window,19
plot_histo, cos(injected_beam.nt_beam.pitch_angle), delta=.1
window,20
print, 'total_energy=', $
       total(injected_beam.nt_beam.ke_total $
             *injected_beam.nt_beam.scale_factor)*kev_2_ergs

particle_display, loop,nt_beam
save, injected_beam,file=run_folder+beam_name
print, 'Saved file ',run_folder+beam_name

end
