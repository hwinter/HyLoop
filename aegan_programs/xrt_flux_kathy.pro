function xrt_flux, band, logt_in, losEM, specfile = specfile, ctime=ctime,$
                   reinit=reinit, area=area

;NAME : xrt_flux
; 
;PURPOSE : calculate the total flux in XRT filters
;
;CALLING SEQUENCE : flux = xrt_flux(band, logt_in, losEM, specfile=specfile,$
;                                   ctime=ctime, reinit=1)
;
;INPUTS : logt_in - scalar or vector array of temperature
;         losEM - line of signt emission measure
;         band - XRT filter - one of (syntax matters!):
;                Al-mesh    Al-poly/Al-mesh 
;                Al-poly    Al-poly/Ti-poly
;                C-poly     Al-poly/Al-thick
;                Ti-poly    Al-poly/Be-thick 
;                Be-thin    C-poly/Ti-poly
;                Be-med     C-poly/Al-thick
;                Al-med
;                Al-thick 
;                Be-thick
;
;KEYWORDS : spec_file - name of file containing spectrum.  Must be a genx file 
;                       containing wave, emiss, units, logt.  Units should be
;                       photons/s/cm^2/A/str.
;           ctime - time of observation (for calculating contamination)
;           reinit - For speed. Set reinit=1 on first time in a loop, $
;                    to calculate response functions.  On subsequent times,
;                    use reinit = 0.
;           area - returns responses in units of DN/s/cm^2
;
;OUTPUTS : flux - XRT flux in filter (given by band) in DN/s
; 
;EXAMPLE : inten = xrt_flux('Al-mesh',logt, 1e29,$
;                           ctime='2007-Aug-09 01:00:00', reinit=1)
;
;WRITTEN : 03/17/09 KKR
;          11/05/09 Added common block for speed KKR
;          01/22/10 Added area keyword for DN/s/cm^2
; 
;-


  if not keyword_set(ctime) then ctime = '26-sept-2006'
  if n_elements(reinit) eq 0 then reinit = 1

  if keyword_set(specfile) then begin
     ;; some work needs to be done to put spectrum into 
     ;; XRT format.  See make_xrt_emiss_model.

     common xrt_flux_com, xrt, init
     if n_elements(init) eq 0 or reinit eq 1 then init = 1
     if init then begin
        print, 'running common block'
        rd_genx,specfile,spec

        modelname = 'A. R. Winebarger Chianti spectrum for PredSci kernels'   
        wave = spec.wave
        temp = 10^(spec.logt)
        spectrum = reform(spec.emissivity[*,*,4])
        abund_model = 'coronal abundances'
        ioneq_model = 'Mazzotta et al. (1998)'
        dens_model = '1e10 cm-3'
        data_files = 'saic_emissivity.genx'

        emiss_model = make_xrt_emiss_model(modelname, wave, temp, spectrum, $
                                           abund_model, ioneq_model,dens_model,$
                                           data_files=data_files)

        w_resp = make_xrt_wave_resp(contam_time=ctime)
        xrt = make_xrt_temp_resp(w_resp, emiss_model)

        init=0
     endif
  endif else begin
     ;; use default apec spectrum
     common xrt_flux_com, xrt, init
     if n_elements(init) eq 0 or reinit eq 1 then init = 1
     if init then begin
        print, 'running common block'

        w_resp = make_xrt_wave_resp(contam_time=ctime)
        xrt = make_xrt_temp_resp(w_resp, /apec)

        init=0
     endif
  endelse
  
  names = xrt.confg.name

  match = where(strmatch(names,band) eq 1)

  
  temp = xrt[match].temp
  resp = xrt[match].temp_resp

  logt=alog10(temp(where(temp ne 0)))
  resp = resp(where(logt ne 0))

  resp_out = spl_init(logt,resp)

  result = spl_interp(logt, resp,resp_out, logt_in, /double)

  match = where(result lt 0)
  
  
  if match(0) ne -1 then begin
     result(match) = 0

  endif

  inten = result*losEM 
  ;;units: e/pix/s/cm-5 * DN/e * cm-5 = DN/s/pix

  if keyword_set(area) then begin
     pix_size = 1.0286  ;;arcsec
     rad_per_arcsec = 4.848e-6  ;; radian/arcsec
     pix_size = pix_size*rad_per_arcsec ;; radians
     au = 1.49598e13    ;; cm

     sun_area = pix_size^2*au^2  ;; cm^2/pixel

     inten = inten/sun_area  ;; DN/s/pix / cm^2/pix = DN/s/cm^2

  endif

  return, inten

end

  	
