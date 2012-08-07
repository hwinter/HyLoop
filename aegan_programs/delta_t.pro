; delta t

pro delta_t, $
   INITIAL_PARAMETERS=initial_parameters,$
   SAVE_FOLDER=save_folder,$
TOTAL_SECONDS=total_seconds, $
PERCENT=percent



 if size(INITIAL_PARAMETERS,/TYPE) ne 7 then begin
     print, 'please specify INITIAL_PARAMETERS'
     STOP
  endif
 if size(SAVE_FOLDER,/TYPE) ne 7 then $
     SAVE_FOLDER='/Volumes/Herschel/aegan/Data/saved/'
;set percentage value for hxr

;;;;;;;;;;;;
; Restore data

 goes_restore=SAVE_FOLDER+initial_parameters+'_GOES_collect.sav'
 print, 'Restoring '+goes_restore
 restore, goes_restore, /verb

 HXR_restore=SAVE_FOLDER+initial_parameters+'_hxr_emission.sav'
 print, 'Restoring '+HXR_restore
 restore, HXR_restore, /verb


;;;;;;;;;;;;;;;;;;;;
;Find max goes
max_goes=max(long)
peak_time=where(long eq max_goes)

;print, 'max goes', max_goes
;print, 'peak_time', peak_time

;;;;;;;;;;;;;;;;;;;
;Find end of HXR
;;Found by looking for when it gets to 10% after having already passed
;the peak

max_hxr=max(hxr_array)
;print, 'max_hxr', max_hxr
peak_hxr=where(hxr_array eq max_hxr)
;print, 'peak hxr time', peak_hxr
hxr_end=where(hxr_array le percent*max_hxr)
;print, 'hxr end',hxr_end
for i=0, size(hxr_end,/N_ELEMENTS) do begin
   if hxr_end[i] gt peak_hxr then begin
;print, 'hxr ends', hxr_end[i]
      break
   endif
endfor
print, 'DIFFERENCE:', hxr_end[i]-peak_time
END
;delta_t, initial_parameters=initial_parameters,save_folder=save_folder, total_seconds=total_seconds
