 goes_restore=SAVE_FOLDER+initial_parameters+'_GOES_collect.sav'
  restore, goes_restore

 HXR_restore=SAVE_FOLDER+initial_parameters+'_hxr_emission.sav'
  restore, HXR_restore
 GOES=long

time_array=indgen(total_Seconds+1)

 Derived=DERIV(time_array, GOES)

print, correlate(derived/max(derived),hxr_array/max(hxr_array))   

END
