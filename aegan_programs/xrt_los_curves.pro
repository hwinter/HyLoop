INITIAL_PARAMETERS='pa-4_nt_75_bt_2min'
Total_seconds=88
flux_m4_75=xrt_los_flux( run, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds, RUN_FORMAT=run_format)


INITIAL_PARAMETERS='pa_0_nt_50_bt_2min'
Total_seconds=114
flux_0_50=xrt_los_flux( run, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds, RUN_FORMAT=run_format)

INITIAL_PARAMETERS='pa-4_nt_100_bt_2min'
Total_seconds=83
flux_m4_100=xrt_los_flux( run, INITIAL_PARAMETERS=initial_parameters, TOTAL_SECONDS=total_seconds, RUN_FORMAT=run_format)



flux=flux_m4_100
GOES_C=2
HXR_C=0
XRT_C=4
DERIV_C=3


time_array=indgen(total_seconds)


set_plot, 'ps'
device, filename=Initial_parameters+"_XRT_los_flux.ps", decomposed=0,/color

plot, time_array, flux/max(flux), /nodata, $
title=Initial_parameters+" Comparison of fluxes", xtitle="Time(s)", $
ytitle="Normalized Emissions", xrange=[0,100],yrange=[0,1],  BACKGROUND=1,COLOR=0
XRT_restore='/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_XRT_be_thick_emission_avg.sav'
restore, XRT_restore
goes_restore='/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_GOES_collect.sav'
restore, goes_restore


GOES=long

XRT_be_thick=xrt_array
norm_GOES=GOES/Max(GOES)
norm_XRT_be=XRT_be_thick/Max(XRT_be_thick)
norm_XRT_LOS=flux/max(flux)

oplot, time_array, norm_GOES, COLOR=goes_c,THICK=1
oplot, time_array, norm_XRT_LOS, Color=hxr_c, thick=1
oplot, time_array, norm_XRT_be, COLOR=xrt_c, thick=1

legend,['GOES Long','XRT_LOS','XRT Be Thick'],outline_color=0,/top_legend,/right_legend,textcolors=0,font=1,LINESTYLE=[0,0,0],COLORS=[goes_c, hxr_c, xrt_c]

device, /close

END
