print,'boogie'

file='/disk/hl2/data/winter/data1/PATC/runs/2006_AUG_17/loop_hist.sav'
gif_dir='/disk/hl2/data/winter/data1/PATC/runs/2006_AUG_17/gifs/'
inj_beam='/disk/hl2/data/winter/data1/PATC/runs/2006_AUG_17/injected_beam.sav'
restore,inj_beam 
restore, file
beam_struct=concat_struct(injected_beam[0],beam_struct)
s_alt=get_loop_s_alt(loop[0].s)
window, 0,xs=1200,ys=600


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;1 keV=1.602e-9 ergs
; converts keV to ergs
keV_2_ergs = 1.602d-9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
temperature=get_loop_temp(loop.state)
temperature=temperature[1:n_elements(loop[0].state.n_e)-2l,*]
density=loop.state.n_e[1:n_elements(loop[0].state.n_e)-2l]
e_dep=(-1d)*beam_struct.ENERGY_PROFILE*keV_2_ergs

e_scale=255/(max(e_dep))
temp_scale=255/(max(temperature))
dens_scale=255/(max(density))

print, dens_scale
;position multiple plots 2 rows and 2 columns
  !p.multi=[0,2,2]      
for n_loop=0l, n_elements(loop)-1l do begin
    
  ;  for jj=0,4 do e_dep=smooth(e_dep,25)
    nt_beam=beam_struct[n_loop].nt_beam

    e_signal=beam_struct[n_loop].ENERGY_PROFILE*keV_2_ergs
    dens_signal=$
                (loop[n_loop].state.n_e[1:n_elements(loop[0].state.n_e)-2l])
    ;pmm,dens_signal
    ;pmm, dens_signal*dens_scale
    temperature=get_loop_temp(loop[n_loop].state)
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;plot the particles' positions along the loop
; 
    loadct,0,/silent
    nt_beam=beam_struct[n_loop].nt_beam
    vary=dindgen(n_elements(nt_beam))/(n_elements(nt_beam))
    z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
    z_max=z_max[0]
    plot, loop[n_loop].axis[1,*] , loop[n_loop].axis[2,*] ,$
          /iso, LINE=1,$
          TITLE='Particle Position'
    oplot, loop[n_loop].axis[1,*] , $
           loop[n_loop].axis[2,*]+ loop[n_loop].rad
    oplot, loop[n_loop].axis[1,*] , $
           loop[n_loop].axis[2,*]- loop[n_loop].rad
    legend, string(loop[n_loop].state.time,format='(D6.3)')
    pos_index=lonarr( n_elements(nt_beam))
   

    for ii=0l, n_elements(nt_beam)-1l do begin
        pos_index[ii]=where(abs(nt_beam[ii].x-s_alt) eq $
                        min(abs(nt_beam[ii].x-s_alt)))
    endfor



    plots, loop[n_loop].axis[1,pos_index] ,$
           loop[n_loop].axis[2,pos_index],$
           psym=2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Energy Deposition plot
    loadct,0,/silent
    plot, s_alt,e_dep
    legend, string(loop[n_loop].state.time,format='(D6.3)')
    loadct,13
    
       
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
    loadct,0,/silent


    plot, loop[n_loop].axis[1,*] , loop[n_loop].axis[2,*] ,/iso
    oplot, loop[n_loop].axis[1,*] , $
           loop[n_loop].axis[2,*]+ loop[n_loop].rad
    oplot, loop[n_loop].axis[1,*] , $
           loop[n_loop].axis[2,*]- loop[n_loop].rad
    loadct,9
    
    for i=0, n_elements(loop[n_loop].AXIS[1,*])-2 do begin
        polyfill,[ REFORM(loop[n_loop].AXIS[1,i]),$
                   REFORM(loop[n_loop].AXIS[1,i:i+1]),$
                   REFORM(loop[n_loop].AXIS[1,i+1]) ],$
                 [REFORM(loop[n_loop].AXIS[2,i]-loop[n_loop].RAD[i]), $
                  REFORM(loop[n_loop].AXIS[2,i:i+1]+loop[n_loop].RAD[i:i+1]) ,$
                  REFORM(loop[n_loop].AXIS[2,i+1]-loop[n_loop].RAD[i+1]) ], $
                 COLOR=dens_scale*dens_signal[i], $
                 /FILL_PATTERN  ;/LINE_FILL
    
    endfor



    plot, loop[n_loop].axis[1,*] , loop[n_loop].axis[2,*] ,/iso
    oplot, loop[n_loop].axis[1,*] , $
           loop[n_loop].axis[2,*]+ loop[n_loop].rad
    oplot, loop[n_loop].axis[1,*] , $
           loop[n_loop].axis[2,*]- loop[n_loop].rad
endfor



;gifs=findfile(strcompress(gif_dir+'*.gif'))
;BREAK_FILE, gifs[0], DISK_LOG, DIR, FILNAM, EXT

;image2movie,gifs,$
;  movie_name=strcompress(gif_dir+'emission_movie.gif',/REMOVE_ALL), $
;  gif_animate=1,loop=1

;file_delete,gifs


end
