;Something screwy happens at t=2.4s and t=9.6s
   ;note 9.6 = 4*(2.4)

pro test_cc_heat_function

sim_time = 10.;sec
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
; Make loop
;; diameter = 2.2e8 ;cm
;; length = 1e9 ;cm
;; Tmax=1.5d+6 
;; N_CELLS=400 
;; loop=mk_tapered_loop(diameter, length, 1.3,t_max=Tmax,
;; n_cells=n_cells)
restore, "/data/dvdata/ccurme/Project_Programs/traesoft/PATC/test_loop.loop"
   ;note N_CELLS = 400 for saved loop
vols = get_loop_vol(loop)

; Prepare beam_generator input variables
delta_index=3d
defsysv, '!SPEC_INDEX', delta_index
energies=[10d,50d]
E_min_max=[min(energies),max(energies)]
defsysv, '!E_min_max', E_min_max
flux = get_p_t_law_flux(loop.l, 0, loop.t_max)
heating_rate = (flux/loop.l)*total(vols)
defsysv, '!heating_rate', heating_rate
Flare_energy = heating_rate*sim_time
num_test_particles = (20d0)
defsysv, '!n_part', num_test_particles
defsysv, '!n_nano', 20d0
dist_alpha = 0.
defsysv, '!dist_alpha', dist_alpha
defsysv, '!FRACTION_PART', 0.50
;defsysv, '!injected_beam', injected_beam
defsysv, '!beam_index', 0ul
defsysv, '!next_beam_time', 0d0
e_h = loop.e_h
defsysv, '!e_h', e_h
defsysv, '!PATC_DT', 0.2
nano_fwhm=2d7
defsysv, '!nano_fwhm',nano_fwhm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Step through heating function

movie_directory = "/data/dvdata/ccurme/Project_Programs/Default/" $
                  + "movies/nano_histo/"

pwr_out = !heating_rate*!FRACTION_PART
pwr_in = cc_heat_function2(loop,0.0,beam_dt, nt_beam, nt_brems, $
                          PATC_heating_rate, extra_flux, DELTA_MOMENTUM, $
                          flux, n_e_change, TEST=1)

pwr_in = transpose(pwr_in) # vols
diff_array = 100*((pwr_in - pwr_out)/pwr_out)
index = 0
last_beam = nt_beam

!next_beam_time += !PATC_dt
;nt_beam.state = "TL"

;histo movie part
;; name = movie_directory + "beam000000"
;; set_plot, "ps"
;; device, /COLOR, FILENAME=name + ".ps"
;; plot_histo, nt_beam.x, XTITLE="s (cm)", YTITLE="Number particles injected", $
;;             TITLE="Dotted lines demarcate particles/nanoflare"
;; for q=1,4 do oplot, [0, max(loop.s)],[q*!n_part,q*!n_part], COLOR=1, LINE=1
;; legend, ["Time: 0.000000s"], /RIGHT
;; device, /CLOSE
;; spawn, "convert " + name + ".ps " + name + ".gif"
;; spawn, "rm " + name + ".ps"

nt_beam = 0.

for t=0.1, sim_time, 0.1 do begin

   pwr_in = cc_heat_function2(loop,t,beam_dt, nt_beam, nt_brems, $
                          PATC_heating_rate, extra_flux, DELTA_MOMENTUM, $
                          flux, n_e_change, TEST=1)

   pwr_in = transpose(pwr_in) # vols
   if pwr_in eq 0 then begin
      diff_array =[diff_array, 0]
      nt_beam = last_beam
   endif else begin
      ;nt_beam.state = "TL"
      diff_array = [diff_array, 100*((pwr_in - pwr_out)/pwr_out)]
      index = [index, 10*t]
      !next_beam_time += !PATC_dt
      last_beam = nt_beam
   endelse

;histo movie part
;;    if 10*t lt 10 then begin
;;       name = movie_directory + "beam00000" + strcompress(string(10*t), /REMOVE_ALL)
;;    endif else if 10*t lt 100 then begin
;;       name = movie_directory + "beam0000" + strcompress(string(10*t), /REMOVE_ALL)
;;    endif else if 10*t lt 1000 then begin
;;       name = movie_directory + "beam000" + strcompress(string(10*t), /REMOVE_ALL)
;;    endif else begin
;;       name = movie_directory + "beam00" + strcompress(string(10*t), /REMOVE_ALL)
;;    endelse

;;    set_plot, "ps"
;;    device, /COLOR, FILENAME=name + ".ps"
;;    plot_histo, nt_beam.x, XTITLE="s (cm)", YTITLE="Number particles injected", $
;;             TITLE="Dotted lines demarcate particles/nanoflare"
;;    for q=1,4 do oplot, [0, max(loop.s)],[q*!n_part,q*!n_part], COLOR=1, LINE=1
;;    legend, ["Time:" +strcompress(string(t)) + "s"], /RIGHT
;;    device, /CLOSE
;;    spawn, "convert " + name + ".ps " + name + ".gif"
;;    spawn, "rm " + name + ".ps"
   
   nt_beam = 0.

endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Beams are going off as expected + illustrate that pwr_in = pwr_out
set_plot, "x"
t_axis = dindgen(sim_time/0.1)*0.1
wset, 0
plot, t_axis, diff_array, XTITLE="Simulation Time (s)", YTITLE="% Difference", $
   TITLE="dt:"+strcompress(string(!PATC_DT)), /NODATA
oplot, t_axis, diff_array, PSYM=4, COLOR=3
oplot, t_axis[index], diff_array[index], PSYM=4, COLOR=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Histogram of particles vs. s
;; filelist = file_search(movie_directory, "beam*.gif")
;; image2movie, filelist, movie_name="beam_histo.gif", /gif, $
;;              outdir="/data/dvdata/ccurme/Project_Programs/Default/movies"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
jump1:
END
