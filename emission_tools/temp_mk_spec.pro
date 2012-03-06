file='/home/hwinter/Data/PATC/runs/2009_Solar_C_prop/microflare/run_00003/patc_test_0000002.0000.loop'
restore,file, /verb
;temp_mk_spec
em=get_loop_em(loop, t=t)
edensity=loop[0].state.n_e[1:n_elements(loop[0].state.n_e)-2]
;stop

wave=kev2ang(nt_brems[0].PH_ENERGIES)
wmin=min(wave)
wmax=max(wave)
wavestep=.1
thermal_spectra=dblarr(n_elements(nt_brems[0].n_photons))
abund_name='/proj/DataCenter/ssw/packages/chianti/dbase/abundance/sun_coronal.abund'


;strcompress(abund_name,/remove_all)
ioneq_name='/proj/DataCenter/ssw/packages/chianti/dbase/ioneq/mazzotta_etal.ioneq'
;             +ioneq_name+'.ioneq')
;ioneq_name=strcompress(ioneq_name,/remove_all)
delvarx, spec_array
for i=0ul, n_elements(em)-1ul do begin
   ;temp=1.0*t[i]
   isothermal, wmin,wmax,wavestep, t[i], lambda,spectrum,$
      edensity=edensity[i] ,photons=photons,  $
      abund_name= abund_name , ioneq_name=ioneq_name, $
               /noverbose,  /con, $
               em=em[i],/all
if n_elements(spec_array) le 0 then spec_array=spectrum else $
   spec_array=[[spec_array], [spectrum]]
;stop
;temp1=alog10(t[i])
;temp=[temp1-1, temp1, temp1+.1]
;   ch_synthetic,wmin,wmax, output=transitions,$ ; pressure=pressure,$
 ;           [MODEL_FILE=MODEL_FILE, err_msg=err_msg, msg=msg, $
;                density=[edensity[i],edensity[i],edensity[i]],/all,$ ;sngl_ion=sngl_ion, $
;                /photons, $        ; masterlist=masterlist, $
;            save_file=save_file , verbose=verbose, $
;                logt_isothermal=temp,$
;                logem_isothermal=[0,em[i],0] ,$
;                ioneq_name=ioneq_name ; goft=goft,  dem_name=dem_name,$
                                ;           noprot=noprot,
                                ;           rphot=rphot,
                                ;           radtemp=radtemp,
                                ;           progress=progress
 
;   make_chianti_spec, TRANSITIONS,  LAMBDA, SPECTRUM,$ 
;                   [BIN_SIZE= ,  ,INSTR_FWHM= , PIXEL=PIXEL, BINSIZE = BINSIZE, $
;                      /all, abund_name= abund_name, /photons, /continuum
;                    WRANGE= , ALL=ALL, continuum=continuum, $
;                    ABUND_NAME= , MIN_ABUND=, photons=photons, effarea=effarea

; If spectrum[0] eq -1 then print, 'nope' else begin
;    if size(spectrum, /type) eq 8 then stop;spec_array+=spectrum.spectrum
;SPECTRUM=0
;endelse

endfor

;nt_spec=get_xr_emiss( loop, nt_brems, /nt_only, ENERGIES=ENERGIES) 
;nt_spec=total(nt_spec, 1)

energies2=reverse(ang2kev(lambda))

thermal_spec=spline(energies2, spec_array, ENERGIES)


end
