; reu_2011_calculate_flare_therm_energy.pro

folder='/Volumes/itch/Users/hwinter/Data/HyLoop/runs/2011_REU_pre_arrival/pa_m4_nt_50_bt_2min/run_0066'
old_device=!d.name
prefix='patc'
extension='loop'
files=file_search(folder, prefix+'*'+extension, $
                  COUNT=n_files, /FULLY_QUALIFY_PATH ) 


if n_files eq 0 then begin
   print, 'No files matching '+prefix+'*'+extension+' were found.'
   stop
endif

restore, files[0]

base_e=loop.e_h
volume=get_loop_vol(loop)
flare_e=dblarr(n_elements(base_e), n_files-1ul)
flare_e_h=flare_e
old_pmulti=!p.multi
!p.multi=[0,1,2]
for i=1ul, n_files-1ul do begin
   plot1name='flare_e_h_'+strcompress(string(I, format='(I04)'), /remove)
   
   restore, files[i]
   flare_e_h[*,i-1]=loop.e_h-base_e
   flare_e[*,i-1]=(loop.e_h-base_e)*volume
   t=get_loop_temp(loop)
   
;    hdw_pretty_plot1, loop.s_alt,flare_e_h[*,i-1],$
 ;                     PoSt=plot1name+'.ps'
   
;   spawn, 'convert '+plot1name+'.ps'+ ' '+plot1name+'.tif'
plot, loop.s_alt,flare_e_h[*,i-1], psym=4, yrange=[0, 120], /ys, $
      TITLE='E_h Time: '+string(loop.state.time, format='(I4)')

plot, loop.s_alt,(t), psym=4,  yrange=[1d5, 1.7d8],/ys, $
      yTITLE= 'Kelvin', xtitle='cm'

x2png, plot1name+'.png'


endfor
!p.multi=old_pmulti
total_flare_e=total(flare_e)
print, total_flare_e
set_plot, old_device


END
