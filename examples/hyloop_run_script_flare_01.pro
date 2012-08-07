; .r hyloop_run_script_flare_01
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define a main folder for the experiment
;folder=getenv('DATA')+'//runs/test/'
cd, cur=folder
folder=folder+'/'
;Define a sub-folder for this particular run.
RUN_FOLDERS='run_00001/'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Total simulation time in seconds
loop_time=15d*60d
;Reporting timestep.
delta_time=1d                   ;[sec]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Number of surface elements in the main loop.
N_CELLS=700
;Number of surface elements in the 'chromosphere".
N_DEPTH=25
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Non_thermal particle properties
;NT energy spectral index.
delta_index=3d ;Very hard energy spectrum here.
;Min and max of the NT energy distribution.
energies=[15d,200d]
;How long will the beam be injected?
beam_time=02d                   ;[sec]
;Time bin for injecting NT sub-beams
beam_dt=0.1
defsysv, '!PATC_DT',beam_dt
;Total beam energy in ergs
;1d30 is the energy determined by Sui et al. 2005 for 
; the 2002_APR_15 flare
Flare_energy=1d+30
;Number of test particles per sub-beam.
num_test_particles=(1500d0)
;Exponent used to determine the pitch-angle distribution.
dist_alpha=-4.    
;Fraction of the flare energy to go into non-thermal particles
FRACTION_PART=1.0
;Time profile as defined in ???
T_PROFILE='Gaussian'
;NT particle injection point as defined in ???
IP='z'

;min and max photon energies for bremmstrahlung radiation
MIN_PHOTON=1                    ;keV
MAX_PHOTON=100                  ;keV
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Loop Properties
;Intitial maximum loop temperature 
Tmax=1.5d+6 
;Minimum loop area.  Footpoint area.
loop_min_area=!dpi*(1.0d+8)*(1.0d+8);From Fletcher & Martens
;Loop height
max_height=1.6d9 ;Loop height Fletcher & Martens
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;User defined safety factor. HD  timestep=courant dt/safety
safety=5.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Setings for the heat function.  
HEAT_FUNCTION='pt_with_patc'
;This heat function requires the setting of the following system variables
DEFSYSV, '!heat_alpha',3./2.
DEFSYSV, '!heat_beta',0.
DEFSYSV, '!heat_Tmax',Tmax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calling a fuction that defines the loop str
loop=mk_green_field_loop(N_CELLS=N_CELLS,$
                         N_depth=N_depth,max_height=max_height,$
                         Area_0=loop_min_area)
;Remove the files generated while the loop came to equilibrium.
;    spawn, 'rm *.stable'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determining the energy flux neccessary to heat a semicircular loop of
;constant cross-section based on the Pressure (P), Temperature (T)
;power laws of Martens (2010)
flux =get_p_t_law_flux(loop.l,!heat_alpha ,!heat_Tmax)
DEFSYSV, '!constant_heat_flux',flux
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Give an output filename prefix for the code. The code will append a
;number based on the simulation time in se
FILE_PREFIX='patc_test_'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Extra settings for HyLoop
Debug=1.0
showme=1
quiet=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End of input parameters.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Generate subfolders
subfolders=folder + $
           RUN_FOLDERS
;make sure the main folder and subfolders exist.
spawn, 'mkdir '+folder
for index=0ul, n_elements(subfolders) -1ul do begin
    spawn, 'mkdir '+subfolders[index]
endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print, 'Run started at '+systime(/utc)
;Make sure that the X libraries are NOT used so that the code
;won't die if in background mode.
old_plot_state=!D.NAME
set_plot,'z'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make some settings to make use of IDL multithreading
;Most of the defaults are ok.
n_cpu=(!CPU.HW_NCPU-1)
n_cpu>=1
CPU , TPOOL_NTHREADS=n_cpu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Necessary ba
SSW_PACKAGES, /chianti
SSW_PACKAGES, /xray
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Attempt to unlimit the memory usage
$unlimit
COMPILE_OPT STRICTARR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


loop_old=loop
for index=0ul, n_elements(subfolders) -1ul do begin
   loop=loop_old
   
   FULL_FILE_PREFIX=subfolders[index]+'/'+FILE_PREFIX
   cd , subfolders[index]
   
   spawn, 'rm p*1.loop'
   spawn, 'rm p*2.loop'
   spawn, 'rm p*3.loop'
   spawn, 'rm p*4.loop'
   spawn, 'rm p*5.loop'
   spawn, 'rm p*6.loop'
   spawn, 'rm p*7.loop'
   spawn, 'rm p*8.loop'
   spawn, 'rm p*9.loop'
   spawn, 'rm p*.loop'
   
   start_time=systime(1)
  
   run_folder=strcompress('./')
   
   gif_dir=strcompress(run_folder+'gifs/')
;Some functions and proc's change their parameter input unexpectedly.
   dt=delta_time
   inj_time=beam_time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For debugging
;!except=2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the number of iterations that the code will make.
   N_interations=fix(loop_time/delta_time)
   
   e_h=loop.e_h
   n_loop=n_elements(loop)
   s=loop[0].s
   volumes=get_loop_vol(loop)
   n_vol=n_elements(volumes)
   defsysv, '!patc_heat',e_h*0.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the loop half length and then overplot the highest point 
;on the loop
   if !d.name eq 'X' then window,18
   plot,loop[n_loop-1l].axis[1,*],loop[n_loop-1l].axis[2,*]     
   junk=where(abs(s-max(s)/2.) eq min(abs(s-max(s)/2.)))
   plots,loop[0].axis[1,junk],loop[0].axis[2,junk],psym=4
   junk=where( loop[0].axis[2,*] eq max(loop[0].axis[2,*]))
   plots,loop[0].axis[1,junk],loop[0].axis[2,junk],psym=5    
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Generate the structure containing the injected beam

;Define the number of iterations you are going to
;   need for your electron beam.
   N_beam_iter=long(beam_time/beam_dt)
   E_min_max=[min(energies),max(energies)]
;
   ip_in=ip
   injected_beam=beam_generator(loop,E_min_max, $
                                total_energy=Flare_energy, $
                                SPEC_INDEX=delta_index, $
                                time=inj_time, delta_t=beam_dt,$
                                IP=ip_in,n_PART=num_test_particles, $
                                ALPHA=dist_alpha,$
                                FRACTION_PART=FRACTION_PART, $
                                T_PROFILE='Gaussian')
;stop
   defsysv,'!next_beam_time',injected_beam[0].time
;Put this beam into a system variable.
   defsysv, '!injected_beam',injected_beam
   defsysv, '!beam_index', 0ul
   defsysv, '!patc_next', 0d0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Have to fix this
;Some functions and proc's change their parameter input unexpectedly.
    dt=delta_time
    inj_time=beam_time

;print, finite(injected_beam_struct.nt_beam.pitch_angle)
;pmm, injected_beam_struct.nt_beam.ke_total
    save, injected_beam, file='initial_nt_beam.sav'
;stop
;NEED TO THINK ABOUT THIS IMPLEMENTATION LATER
    counter=0
    sim_time=0d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Main loop
;This loop spans the whole loop simulation time.
;Electron Beam injection
;Loop cooling post beam injection.
;Electron thermalization. etc.  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Keep the loop going until time's up
    n_sim_iter=1ul
    nt_beam=injected_beam[0].nt_beam
    beam_counter=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a pre-flare file
    loop.state.time=0.
    ph_energies=MIN_PHOTON+dindgen(MAX_PHOTON-MIN_PHOTON+1d)
    n_ph_e_array=n_elements(ph_energies)
    n_photons=dblarr(n_ph_e_array)
    nt_brems={ph_energies:ph_energies,$
              n_photons:n_photons}
    nt_brems=replicate(nt_brems,n_vol )
    save, nt_beam, loop,nt_brems, file='patc_test_000000.loop'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
    hyloop, loop,loop_time  ,  $
                    T0=T0, FILE_PREFIX=FULL_FILE_PREFIX,$
                    FILE_EXT=FILE_EXT, src=src, uri=uri, fal=fal, $
                    depth=depth, safety=safety,QUIET=QUIET, $
;Begin regrid keywords
                    REGRID=REGRID, GRID_SAFETY=GRID_SAFETY, $
                    PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, $
                    MAX_STEP=MAX_STEP, $
                    QUADRATIC=QUADRATIC, LSQUADRATIC=LSQUADRATIC, $
                    SPLINE=SPLINE, SHOWME=SHOWME,$
                    DELTA_T=DELTA_Time, DEBUG=DEBUG, $
                    HEAT_FUNCTION=HEAT_FUNCTION, $
                    WINDOW_REGRID=WINDOW_REGRID, $
                    WINDOW_STATE=WINDOW_STATE, $
                    SO=SO, E_H=E_H, $
                    novisc=1,$
                    NT_BEAM=NT_BEAM,$
                    NT_PART_FUNC=NT_PART_FUNC,$ ; PATC section
                    NT_BREMS=NT_BREMS,$
                    NT_DELTA_E=NT_DELTA_E,$
                    NT_DELTA_MOMENTUM=NT_DELTA_MOMENTUM ,$
                    PATC_heating_rate=PATC_heating_rate,$
                    extra_flux=extra_flux
    
    print, 'This run took '+string(systime(1)-start_time)+' to complete.'
    
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make some maps 

;This reflects bad planning!
parts=strsplit(folder, '/', /EXTRACT)
n_parts=n_elements(parts)
EXPERIMENT_DIR='/'

for bpi=0ul, n_parts-3 do begin
    EXPERIMENT_DIR=EXPERIMENT_DIR+parts[bpi]+'/'
endfor


ALPHA_FOLDERS=parts[n_parts-2]+'/'
GRID_FOLDERS=parts[n_parts-1]+'/'
;End bad planning cleanup!

flare_exp_05_mk_all_maps,EXPERIMENT_DIR,ALPHA_FOLDERS,GRID_FOLDERS,$
  RUN_FOLDERS


exit
end

