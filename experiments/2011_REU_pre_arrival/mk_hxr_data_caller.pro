
MIN_PHOTON=1.
MAX_PHOTON=100.;keV
;PHOT_FROM_FILES=PHOT_FROM_FILES,$
FILE_PREFIX='patc'
FILE_EXT='.loop'
data_directory=getenv('DATA')+'/HyLoop/runs/2011_REU_pre_arrival/pa_0_nt=75/'
OUTFILE=data_directory+'hxr_data.sav'
MAX_FILES=5ul
n_iterations=2
ALPHA=0
FRACTION_PART=0.75
BEAM_TIME=2.0
SPEC_INDEX=3
run_dirs=data_directory+'run_'+strcompress(string(indgen(65)+1,FORMAT='(I04)'), /REMOVE_ALL)+'/'

mk_hxr_data, n_iterations, run_dirs, $
                 MIN_PHOTON=MIN_PHOTON, MAX_PHOTON=MAX_PHOTON,$ ;keV
                 PHOT_FROM_FILES=PHOT_FROM_FILES,$
                 FILE_PREFIX=FILE_PREFIX, $
                 FILE_EXT=FILE_EXT,$
                 OUTFILE=OUTFILE, OVERWRITE=OVERWRITE,$
                 MAX_FILES=MAX_FILES,$
                 SPEC_INDEX=SPEC_INDEX, $
                 ALPHA=ALPHA,$
                 FRACTION_PART=FRACTION_PART,$
                 BEAM_TIME=BEAM_TIME

END
