function get_db_spec , wave, $
  SPEC_FOLDER=SPEC_FOLDER

if not keyword_set(SPEC_FOLDER) then $
  spec_folder=Getenv('DATA')+ $
              '/spectral_dbase/mazzotta_etal/sun_coronal/'

restore, spec_folder+ 'spec_files_index.sav'

defsysv, '!xrt_spec_resp', exists=test
if test lt 1 then $
  defsysv, '!xrt_spec_resp',CALC_XRT_SPEC_RESP()








END ;Of main
