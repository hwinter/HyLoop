;Brem_test
set_loop_sys_variables
n=[2d0, 1d1, 1d2, 1d3, 1d4, 1d5, 1d6]
n_n=n_elements(n)
t1=dblarr(n_n)
t2=t1



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n_volumes=400
n_es=dblarr(n_volumes)
min=0
max=40
N_cells=40
 
nt_brems={ph_energies:!ph_energies,$
          n_photons:!ph_energies}
n_ph_energies=n_elements(!ph_energies)

nt_brems=replicate(nt_brems,n_volumes)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for i=0ul, n_n-1ul do begin

   energies=200.0*dindgen(n[i])/(n[i]-1)
   position_indices=long(randomu(seed, n[i])*(n_volumes-2))
   scale_factor=randomn(seed, n[i])
   v_avg=energies

   delta_t=dblarr(n[i])+1d-4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   t1_start=systime(1)

   indices=hdw_get_position_index(energies, !BREMS_PART_E_ARRAY)
   cross_1=!BREMS_CROSS_SECTION[*,indices]
   nt_brems[min:max].n_photons+= $
      total( $
      rebin(reform(delta_t*n_es[position_indices],n[i]), n_ph_energies,n[i])*$
      abs(rebin(reform(v_avg, 1,n[i]), n_ph_energies,n[i])*cross_1)$
      *rebin(reform(scale_factor, 1,n[i]), n_ph_energies,n[i]), $
      2)
   

   t1[i]=systime(1)-t1_start
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   t2_start=systime(1)
   for j=0ul, n[i]-1ul do begin
      
      Brm_BremCross,energies[j],$
                    !ph_energies, $
                    1.4, cross_1 

          
      nt_brems[min:max].n_photons+= $
         delta_t[j]*n_es[position_indices]*$
         abs(v_avg[j]*cross_1)$
         *scale_factor[j] 

   endfor
   t2[i]=systime(1)-t2_start


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print, t2[i]/t1[i]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
endfor
plot, n, t2/t1, /xlog, /ylog

end










