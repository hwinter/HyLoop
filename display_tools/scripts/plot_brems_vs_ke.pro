;.r plot_brems_vs_ke
;PURPOSE:  
;         To illustrate the Bremstrahlung cross-section's dependence
;          on particle KE
n_ke_array=200
;Kinetic Energies
ke_array=1.0+dindgen(n_ke_array)
v_array=energy2vel(ke_array)
;Array of photon energies
ph_energies=3.0+(3.0*dindgen(10)/9.)
;Integrated # of photons per second
photons_per_sec=ke_array
;Array of cross sections
B_cross=dblarr(n_ke_array)
;mean atomic number
z=1.4
;Electron Density
n_e=1d9


for i=0ul, n_ke_array-1ul do begin
    
       Brm_BremCross,ke_array[i],$
                     ph_energies, $
                     z, cross_1 
       junk=where(finite(cross_1) eq 0)
       if junk[0] ne -1 then cross_1[junk]=0


       photons_temp=n_e*v_array[i] $
                    *abs(cross_1)

       
       photons_per_sec[i]=total((photons_temp))
       B_cross[i]=abs(cross_1[5])

      ; print, ph_energies[4]


endfor


;window, 1
;plot, ke_array, photons_per_sec, title= textoidl('\sigma')

;window, 2
;plot, ke_array, B_cross;/ke_array


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a plot
tvlct, r_old,g_old,b_old,/GET
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]

font=1
ps_name='brems_vs_ke_plot.eps'
gif_name='brems_vs_ke_plot.tiff'
                set_plot, 'ps'
                print, ps_name
                device, /portrait, file= ps_name , color=16, /enc

;Plot the temperature array  with no axes on the right
                plot, ke_array, $
                     YRANGE=[.98*min(photons_per_sec),$
                         1.02*max(photons_per_sec)], $
                     YSTYLE=9, $
                     POSITION=[.2,.15, .85,.90], $
                     CHARTHICK=1.5, CHARSIZE=1.5, $
                                ;                 TITLE=TITLE, $
                     XTITLE='Particle Kinetic Energy keV',$
                     YTITLE='Prob. of a Photon between  3-6 keV s!U-1!N',$
                     /NODATA, FONT=FONT,$
                     THICK=10, $
                     XRANGE=[min(ke_array) ,$
                             max(ke_array)], XS=1,$
                      TITLE='Bremsstrahlung vs. Energy'
                OPLOT,ke_array, photons_per_sec, thick=8, COLOR=1
                
                axis, YAXIS=1, $
                      YRANGE=[.98*min(B_cross),$
                         1.0*max(B_cross)], $;[95, 100], $
                      YTITLE= textoidl('\sigma',f=1)+'!DB!N[E, 4.5 keV] cm!U2!N',$
                      /YSTYLE, $
                      CHARTHICK=1.5, CHARSIZE=1.5,$
                      /SAVE, FONT=FONT

                oplot,ke_array,B_cross, $
                      COLOR=3,thick=6
                
                legend, ['Photons', textoidl('\sigma',f=1)+'!DB!N'],$
                        line=[0,0],$ ;PSYM=[4,4],$
                        COLOR=[1,3], /RIGHT, BOX=0,$
                        FONT=0,CHARTHICK=1.3, CHARSIZE=1.3, THICK=6, $
                        /TOP
              
            
                device, /CLOSE
                spawn, 'convert '+ ps_name+' '+gif_name
                print, gif_name   
set_plot, 'x'
end

 
