;spec_test1
    delta_index=3d
    energies=[15d,200d]
;How long will the beam be injected?

    beam_time=02d               ;[sec]
    beam_dt=0.1
;Total beam energy in ergs
;1d30 is the energy determined by Sui et al. 2005 for 
; the 2002_APR_15 flare
    Flare_energy=1d+29
dist_alpha=-4
;Number of test particles per beam.
    num_test_particles=(530d0)
    inj_time=2.
    FRACTION_PART=1.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;p
    start_file='gcsm_loop.sav' ;g
    restore,start_file
    loop.state.time=0.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delta_index=[2,3,4,5,6]


;delta_index=[3]
    N_beam_iter=long(beam_time/beam_dt)
    E_min_max=[min(energies),max(energies)]
;

for i=0, n_elements(delta_index)-1ul do begin

    injected_beam=beam_generator(loop,E_min_max, $
                                 total_energy=Flare_energy, $
                                 SPEC_INDEX=delta_index[i], $
                                 time=inj_time, delta_t=beam_dt,$
                                 IP='z',n_PART=num_test_particles, $
                                 ALPHA=dist_alpha,$
                                 FRACTION_PART=FRACTION_PART, $
                                 T_PROFILE='Gaussian')
    nt_beam=injected_beam[0].nt_beam
    for j=1ul, n_elements(injected_beam) -1ul do begin
        nt_beam=concat_struct(nt_beam, injected_beam[j].nt_beam)
    endfor

    e_dist_plot, nt_beam, SPEC=INDEX, $
                 energy_array=energy_array, n_array=n_array, $
                   INDEX_IN= delta_index[i],$
                 ps =  'spec'+strcompress(string(i), /remove_all)+'.ps' $
                                ,/XLOG,/YLOG            ;, PS='junk.ps'
    print,     delta_index[i], INDEX

endfor
;stop
end
