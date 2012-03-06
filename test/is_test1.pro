;is_test1
n_energies=100
n_density=6
n_t=6
T_plasma=[1d4,1d5,1d6,5d6,1d7,5d7]
T_plasma_str='T='+['1d4','1d5','1d6','5d6','1d7','5d7']
dens_index=3
photons=75d0+25d0*dindgen(100)/99
photon_name='75_2_100.ps'
energies=10d0+140*dindgen(n_energies)/(n_energies-1l)
;densities=1d8+1d11*dindgen(n_density)/(n_density-1l)
densities=[1d7, 1d8,1d9,1d10,1d11,1d12]
dens_str='n='+['1d7', '1d8','1d9','1d10','1d11','1d12']
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;1 keV=1.602e-9 ergs
; converts keV to ergs
keV_2_ergs = 1.6022d-9
;converts keV to Joules
keV_2_Joules = 1.6022d-16
;Charge on an electron in statcoulombs
e=4.8032d-10
;Boltzmann's constant in ergs/[K]
k_boltz_ergs=1.3807d-16
;Boltzmann's constant in Joules/[K]
k_boltz_joules=1.3807d-23 
;Electron mass in grams
e_mass_g=9.1094d-28 
;Proton mass in grams
p_mass_g=1.6726d-24 
;Electron radius in cm (classical)
e_rad=2.8179d-13
delta_t=1d
z_avg=1.4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
old_plot=!d.name
set_plot, 'ps'


velocities=energy2vel(energies)
e_deposit=dblarr(n_t,n_density,n_energies)
nt_brems=dblarr(n_t,n_density,n_energies)
for h=0l, n_t-1 do begin
    debye_length=((k_boltz_ergs*T_plasma[h])/ $
                  (4d*!pi*e^2d))^0.5d
    for i=0l, n_density-1 do begin
        
        for j=0l, n_energies-1 do begin 
            
            b_crit=(e^2d)/(2d*energies[j]*keV_2_ergs )
            ln_lambda=mean(alog(debye_length/b_crit))
            
            e_deposit[h,i,j]= $
              (((-2d)*(!pi)*(ln_lambda)*$
                (e^4d))/(energies[j]*kev_2_ergs)) $
              *((e_mass_g/p_mass_g)+1d)$
              *(densities[i]) $
              *velocities[j]*delta_t $
              *(1d/kev_2_ergs)
            
           Brm_BremCross,energies[j],$
                         photons, $
                         z_avg, cross_1 
;Calculate the number of photons produced
           nt_brems[h,i,j]=$
             total(delta_t*densities[i]* $
             abs(velocities[j]*cross_1))
        endfor
    endfor
endfor
e_deposit=abs(e_deposit)

total_energy=max(e_deposit[3,*,*])
device, /LANDSCAPE, FILENAME='density_plot.ps'
plot_io, energies, e_deposit[3,0,*], yr=[1d-5,100],/ys,$
         /NODATA, XTITLE='Energy [keV]',ytitle='Percent of max', $
         TITLE='Energy Lost'
         
legend,dens_str, lines = indgen(6)   , /bottom
for  i=0l, n_density-1 do begin 
    oplot, energies, 100d0*e_deposit[3,i,*]/total_energy, $
          linestyle=i
    
    
endfor  
device, /CLOSE

n_e_name=strcompress(string(densities[dens_index],format='(E11.4)'),/remove_all)
device, /LANDSCAPE, FILENAME='temperature_plot_'+n_e_name+'.ps'

total_energy=max(e_deposit[*,3,*])
plot, energies, e_deposit[3,0,*], yr=[0,100],/ys,$
         /NODATA, XTITLE='Energy [keV]',ytitle='Percent of max', $
         TITLE='Energy Lost'         
legend,t_plasma_str, lines = indgen(6)   , /bottom
legend, 'n_e='+n_e_name,/top,/right, box=0
for  i=0l, n_t-1 do begin 
    oplot, energies, 100d0*e_deposit[i,3,*]/total_energy, $
          linestyle=i
endfor  

device, /CLOSE

device, /LANDSCAPE, FILENAME=photon_name


total_photons=max(nt_brems[0,*,*],/NAN)
plot, energies, nt_brems[0,*,*], yr=[0,100],/ys,$
      /NODATA, XTITLE='Energy [keV]',ytitle='Percent of max', $
      TITLE='Photons Emitted ['$
      +strcompress(string(min(photons)),/remove)$
      +', '+strcompress(string(max(photons)),/remove)$
      +']'
legend,dens_str , lines = indgen(6)   , /bottom
for  i=0l, n_t-1 do begin 
    oplot, energies, 100d0*nt_brems[0,i,*]/total_photons, $
          linestyle=i 
endfor  
device, /close

set_plot,old_plot
end
