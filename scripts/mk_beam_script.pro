
;2006_JUl_19.pro
;computer='dawntreader'
;computer='mithra'
computer='filament'
patc_dir=getenv('PATC')

;Total simulation time in seconds
loop_time=10d*60d
time_step=.5d ;[sec]
run_folder=strcompress(patc_dir+'runs/2006_AUG_17/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Give an output filename for the HD code. .sav will be added
outname=strcompress(run_folder+'hd_out.sav')
gif_dir=strcompress(run_folder+'gifs/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Path to an IDL save file of a loop magnetic loop
;start_file=patc_dir+'loop_data/exp_b_scl.start'
start_file=run_folder+'gcsm_loop.sav'
save_file=run_folder+'/loop_hist.sav'
particle_name='part_file'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Smoothing width for energy inputs to MSUloop
sm_width=10
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Non_thermal particle properties
E_min_max=[20d,22d]
N_PART =(1d4)
beam_time=02d;[sec]
;Define the rsolution of the energy bins
E_RES=1d
;Define the injection point. 'z' for loop apex or enter the index of a 
;  volume cell.
IP='z'
;Set to 1 if it is an electron beam. If something different, see keywords.
ELECTS=1
;Save file for an unperturbed beam.
SAVE_FILE_IB='original_beam.sav'
;Spectral index of the power law defining electron flux
SPEC_INDEX=3
;Total beam energy in ergs
;1d30 is the energy determined by Sui et al. 2005 for 
; the 2002_APR_15 flare
Flare_energy=1d+30
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Now that the variables are set, let's start the show!
set_plot,'z'
SSW_PACKAGES, /chianti
ssw_packages,/xray
patc_dir=getenv('PATC')
start_time=systime(0)
!path=!path+':'+EXPAND_PATH('+'+patc_dir) 
so =get_bnh_so(computer);Grab the proper shared object file
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
kb=k_boltz_ergs
;Boltzmann's constant in Joules/[K]
k_boltz_joules=1.3807d-23 
;Electron mass in grams
e_mass_g=9.1094d-28 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
restore,start_file

n_loop=n_elements(loop)
bgheat=e_h 
x=loop[0].s

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a series of electron beams
;Define the number of iterations you are going to
;   need for your electron beam.
N_beam_iter=long(beam_time/time_step)

injected_beam=beam_generator(loop,E_min_max, TOTAL_ENERGY=TOTAL_ENERGY, $
  SPEC_INDEX=SPEC_INDEX, N_PART=N_PART,$
   Z=Z, IP=IP,T_PROFILE=1,$
  PROT=PROT,ELECTS=ELECTS, $
  E_RES=E_RES, time=0.5)




end
