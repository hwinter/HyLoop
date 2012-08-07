  set_shrec_sys_variables

  index=66

  RUN_FOLDERS ='run_'+$
               string(index,format='(I4.4)')+$
               '/' 
  folder=getenv('DATA')+'/HyLoop/runs/2011_REU_pre_arrival/pa_0_nt_100_bt_2min/'

  spawn, 'mkdir '+folder
  subfolders=folder + $
             RUN_FOLDERS
  N_CELLS=700
  N_DEPTH=25

;Number of test particles per beam.
  num_test_particles=(100d0)
     
  spawn, 'mkdir '+subfolders


  print, 'Run started at '+systime(/utc)
  old_plot_state=!D.NAME
  set_plot,'z'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the run play nice
  username=getenv('DATA')
  if username eq '' then username='hwinter'
  spawn,'renice 4 -u '+username

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Should be in the IDL startup file
host=strsplit(strlowcase(getenv('HOST')),'.',/EXTRACT)
HOST=HOST[0]
defsysv,'!COMPUTER',HOST[0],1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  COMPILE_OPT STRICTARR
;Make some settings to make use of IDL multithreading
;Most of the defaults are ok.
  n_cpu=(!CPU.HW_NCPU-1)
  n_cpu>=1
  CPU , TPOOL_NTHREADS=n_cpu
  SSW_PACKAGES, /chianti
  SSW_PACKAGES, /xray
  
;Attempt to unlimit the memory usage. (Only works on some systems.)
  $unlimit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

     for index=0ul, n_elements(subfolders) -1ul do begin

     dist_alpha=0.
     cd , subfolders[index]

     start_time=systime(1)
     
;Total simulation time in seconds
     loop_time=15d*60d
     delta_time=1d              ;[sec]
     color_table=39
     run_folder=strcompress('./')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Non_thermal particle properties
;Determine the flux of of particles in each energy bin
;Very hard energy spectrum here.
     delta_index=3d
     energies=[15d,200d]
;How long will the beam be injected?

     beam_time=02d*60              ;[sec]
     beam_dt=0.1
     defsysv, '!PATC_DT',beam_dt
;Total beam energy in ergs
;1d30 is the energy determined by Sui et al. 2005 for 
; the 2002_APR_15 flare
     Flare_energy=1d+30

     FRACTION_PART=1.00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermal loop plasma properties
;Intitial loop temperature maximum
     Tmax=1.5d+6 
;Minimum loop area.  Footpoint area
     loop_min_area=!dpi*(1.0d+8)*(1.0d+8)
;Loop height
     max_height=1.6d9           ;Loop height Fletcher & Martens
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     safety=5.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

     HEAT_FUNCTION='pt_with_patc'
     DEFSYSV, '!heat_alpha',3./2.
     DEFSYSV, '!heat_beta',0.
     DEFSYSV, '!heat_Tmax',Tmax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

     loop=mk_green_field_loop(N_CELLS=N_CELLS,$
                              N_depth=N_depth,max_height=max_height,$
                              Area_0=loop_min_area)
     spawn, 'rm *.stable'

     flux =get_p_t_law_flux(loop.l,!heat_alpha ,!heat_Tmax)
     DEFSYSV, '!constant_heat_flux',flux
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     loop.state.time=0.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Give an output filename for the HD code.
     FILE_PREFIX=strcompress(run_folder+'patc_test_')
     gif_dir=strcompress(run_folder+'gifs/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     Debug=0.
     showme=1
     quiet=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End of input parameters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
     
     e_h=loop.e_h
     n_loop=n_elements(loop)
     s=loop[0].s
     volumes=get_loop_vol(loop)
     n_vol=n_elements(volumes)
     defsysv, '!patc_heat',e_h*0.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;
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
     MIN_PHOTON=1               ;keV
     MAX_PHOTON=100             ;keV
     
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
                     T0=T0, FILE_PREFIX=FILE_PREFIX, $
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

