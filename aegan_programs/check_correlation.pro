;Check correlation
; inputs nothing/initial_parameters? and returns the value of
; correlation w/o time-shift, the optimal time-shift and the
; correlation at the optimal time shift
;pro check_correlation


;Restore all data, calculate derivative
goes_restore=SAVE_FOLDER+initial_parameters+'_GOES_collect.sav'
restore, goes_restore, /v

HXR_restore=SAVE_FOLDER+initial_parameters+'_hxr_emission.sav'
restore, HXR_restore,/v

total_seconds=size(long, /N_ELEMENTS)-1
time_array=indgen(total_Seconds+1)

Derived=DERIV(time_array, long)

orig=correlate(derived/max(derived), hxr_array/max(hxr_array))
print, "Base Correlation:", orig

max_time=15
correlations=make_array(max_time*2+1)
i=0
for j=0, max_time*2 do begin

correlations[j]=correlate(derived[i:total_seconds]/max(derived),hxr_array/max(hxr_array))
print, 'time=',i, " correlation:",correlations[j]

i=i+0.5

endfor

best_corr=max(correlations, max_subscript)
print, "best time:", max_subscript/2

print, best_corr
!p.multi=[0,2,0]
set_plot, 'ps'
filename=plot_folder+initial_parameters+"_correlation_plot.ps"
device, filename=filename, decomposed=0, /color
plot, time_array, hxr_array/max(hxr_array), Title="Time-Shifted Data", xtitle="Time (s)"
oplot, time_array, derived[max_subscript/2:total_seconds]/max(derived), COLOR=4
legend, ["Parameters:"+initial_parameters,"Time Shift="+string(float(max_subscript/2), '(f0.2)')+" s"], /top_legend, /left_legend
plot, derived[max_subscript/2:total_seconds]/max(derived), hxr_array/max(hxr_array), title="Correlated", xr=[0,1],yr=[0,1], psym=4, xtitle="Derived", ytitle="HXR"
legend, ["Best Correlation:"+string(best_corr, '(f0.4)')], /top_legend, /left_legend

device, /close
!p.multi=0
set_plot, 'x'
END
