!p.multi=[0,1,2]

file_1='/Users/winter/Data/PATC/runs/2006_AUG_21/injected_beam.sav'
file_2='/Users/winter/Data/PATC/runs/2006_AUG_21/gcsm_loop.sav'
restore, file_1
restore,file_2 
n_elem=1000ul
v=(3.5d9) *dindgen(n_elem)/(n_elem-1ul)

f=msu_speed_dist(LOOP.T_MAX,V=v)

volumes=get_loop_vol(loop[0])
total_particles_t=total(volumes*loop.state.n_e)
total_particles_nt=total(injected_beam.nt_beam.scale_factor)
total_particles_nt=1d34
total_particles=total_particles_t+total_particles_nt

loadct,3,/SILENT

f=f*total_particles_t/total_particles
plot, v,f, xtitle='[cm s!E-1!N]',$
      YTITLE='F(v) N!E-1!N',$
      charsize=1.7, charthick=1.7,$
      TITLE='Loop Plasma',$
      THICK=2,/NODATA
oplot, v,f, color=135, thick=3

fdf=flux_dist_func(injected_beam[0].nt_beam,loop[0],energies,v)

;
fdf=fdf/total(fdf)
fdf=fdf*total_particles_nt/total_particles

;*total(injected_beam.nt_beam.scale_factor)/total_particles


plot, v,fdf, $
      xtitle='[cm s!E-1!N]',$
      YTITLE='F(v) N!E-1!N',$
      charsize=1.7, charthick=1.7,$
      TITLE='Injected Particles',$
      THICK=2.,/NODATA

oplot,v,fdf, color=135, thick=3

legend,'d=3',box=0,/right
X2GIF,'F_v_plot_0.gif'

end
