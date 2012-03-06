;.r plot_distros2
;Adding the !p.multi statement is the differece between the two plots
!p.multi=[0,1,2]
DIR=getenv('DATA')+'Hyloop/runs/2011_REU_2nd_swing/pa-4_nt_100_bt_2min/run_0005/'

file_1=DIR+'initial_nt_beam.sav'
file_1='/data/jannah/hwinter/Data/HyLoop/runs/flare_exp_05/alpha=0/699_25/run_01/initial_nt_beam.sav'
file_2=DIR+'patc_test_000001.loop'
restore, file_1
restore,file_2 





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermal
n_elem=2000ul
v_therm=(7.3d9) *dindgen(n_elem)/(n_elem-1ul)

f=msu_speed_dist(LOOP.T_MAX,V=v_therm)
low_index=where(f) le 1d-10
if low_index[0] ne -1 then f[low_index]=0.
f=f/int_tabulated(v_therm, f)
volumes=get_loop_vol(loop[0])
total_particles_t=total(volumes*loop.state.n_e)
total_particles_nt1=total(injected_beam.nt_beam.scale_factor)
total_particles_nt=1d35
total_particles_t=1d35
total_particles=total_particles_t+total_particles_nt
f=f*total_particles_t/total_particles


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Non-Thermal

;
in_beam=injected_beam[0].nt_beam

for i=0ul, 25  do in_beam=[in_beam, injected_beam[1].nt_beam];,n_elements(in_beam)-1ul 
total_particles_nt1=total(in_beam.scale_factor)
min_energy=min(in_beam.ke_total)
max_energy=max(in_beam.ke_total)
delta=max_energy-min_energy
step=1
n_elem=long(.5+delta/step)
energy_array=min_energy+delta*dindgen(n_elem)/(n_elem-1ul)
n_array=dindgen(n_elem)

for i=0ul, n_elem-1ul do begin
   z=where(in_beam.ke_total le energy_array[i]+(step/2.) $
           and $
           in_beam.ke_total ge energy_array[i] -(step/2.), count)
   if z[0] ne -1 then $
      n_array[i]=total(in_beam[z].scale_factor) $
   else n_array[i]=0.
                                ;stop
endfor


;n_array>=10^0

for ii=0, 10 do n_array=smooth(n_array,3)
v_nt=energy2vel(energy_array)
n_array=n_array/int_tabulated(v_nt, n_array)
n_array*=total_particles_nt
n_array/=total_particles
n_array=n_array[1:*]
v_nt=v_nt[1:*]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;*total(injected_beam.nt_beam.scale_factor)/total_particles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot
;
;plot, v_therm,f, xtitle='[cm s!E-1!N]',$
;      YTITLE='F(v) N!E-1!N',$
;      charsize=1.7, charthick=1.7,$
;      TITLE='Loop Plasma',$
;      THICK=2,/NODATA
;oplot, v_therm,f, color=fsc_color('red'), thick=3
;plot, v_nt,smooth(n_array,4), $
;      xtitle='[cm s!E-1!N]',$
;      YTITLE='F(v) N!E-1!N',$
;      charsize=1.7, charthick=1.7,$
;      TITLE='Injected Particles',$
;      THICK=2.,/NODATA
;
;oplot,v_nt,n_array, color=fsc_color('blue'), thick=3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;window, 2

vels=[v_therm, v_nt]
fs=[f,n_array ]
fs=fs/(int_tabulated(vels, fs))

set_plot, 'ps'
device, file='distribution_plot2.ps', color=16, /landscape
plot, vels,fs, xtitle='[cm s!E-1!N]',$
      YTITLE='F(v) N!E-1!N',$
      charsize=1.7, charthick=1.7,$
      TITLE='Speed Distribution',$
      THICK=2,/NODATA, xrange=[1d7, 1.2d10], font=0, /xs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Fill in the thermal portion
PXVAL = [v_therm[0], v_therm, v_therm[n_elements(v_therm)-1]]
; Get y value along bottom x-axis:
MINVAL = !Y.CRANGE[0]
; Make a polygon by extending the edges down to the x-axis:
POLYFILL, PXVAL, [MINVAL,f , MINVAL], $
   COL = fsc_color('red')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Fill in the non-thermal portion
max_x_val= !x.CRANGE[1]
PXVAL = [v_nt[0], v_nt<max_x_val,max_x_val ]
; Get y value along bottom x-axis:
MINVAL = !Y.CRANGE[0]
; Make a polygon by extending the edges down to the x-axis:
POLYFILL, PXVAL, [MINVAL,n_array , MINVAL], $
   COL = fsc_color('blue')


oplot,vels,fs, color=fsc_color('black'), thick=8

device, /close
set_plot, 'x'

end
