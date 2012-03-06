
;hxr_beam_generator_test

file=getenv('DATA')+'/HyLoop/runs/2010_inj_pos/gcsm_loop.sav'
restore, file, /verb
min_max=[5,200.]
elects=1
SPEC_INDEX=3d
DIST_INDEX=2.
alpha=0
TIME=1
DELTA_T=1.
FRACTION_PART=.5
TOTAL_ENERGY=1d30
N_PART=1d5

resolve_routine, 'hxr_beam_generator', /IS_FUNC
inj_beam=hxr_beam_generator(loop,min_max, $
                             TOTAL_ENERGY=TOTAL_ENERGY, DIST_INDEX=DIST_INDEX,$
                             SPEC_INDEX=SPEC_INDEX, N_PART=N_PART,$
                             N_BEAMS=N_BEAMS,IP=IP,T_PROFILE=T_PROFILE,$
                             PROT=PROT,ELECTS=ELECTS,SAVE_FILE=SAVE_FILE, $
                             E_RES=E_RES, TIME=TIME, DELTA_T=DELTA_T,$
                             ALPHA=ALPHA, RAndom=random, FRACTION_PART=FRACTION_PART)

nt_beam=inj_beam[0].nt_beam
for i=1ul, n_elements(inj_beam)-1ul do begin
   nt_beam=[nt_beam, inj_beam[1].nt_beam]

endfor

print, abs((TOTAL_ENERGY*FRACTION_PART)-$
           !shrec_keV_2_ergs*total(nt_beam.ke_total*nt_beam.scale_factor))$
       /(FRACTION_PART*TOTAL_ENERGY)
set_plot, 'x'
window, 0
plot_e_dist, nt_beam, yrange=[1d30, 6d36], /xlog, /ylog
set_plot, 'x'
window, 1

pa_plot3, nt_beam
end
