pro compress_loop_files, filename, OUT_FILE=OUT_FILE

if not keyword_set(OUT_FILE) then save_file=filename else $
  save_file=OUT_FILE


restore, filename

save ,  ENERGY_CHANGE ,ENERGY_PD, $
        EXTRA_FLUX , E_H, LOOP, MOMENTUM_CHANGE, $
        MOMENTUM_PD, NT_BEAM,NT_BREMS ,PARTICLE_PD,$ 
        PATC_HEATING_RATE, VOLUME_CHANGE ,VOLUME_PD  ,$ 
        /COMPRESS,$
        FILE=save_file


end
