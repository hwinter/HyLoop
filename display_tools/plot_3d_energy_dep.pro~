;restore,'/Users/winter/programs/PATC/runs/2005_12_1/full_test_2.sav'
set_plot,'x'
;old_beam_str=beam_struct
;beam_struct=old_beam_str
;if size(beam_struct,/type) ne 8 then $
  restore, '/Users/winter/programs/PATC/runs/2006_AUG_17/loop_hist.sav'
gif_dir='/Users/winter/programs/PATC/runs/2006_AUG_17/'
;beam_struct=old_beam_str
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;1 keV=1.602e-9 ergs
; converts keV to ergs
keV_2_ergs = 1.6022d-9

s_alt=get_loop_s_alt(loop.s)
s_alt=s_alt[0:n_elements(s_alt)-2]
;if n_elements(beam_struct) ne n_elements(loop) then $
  beam_struct=concat_struct(beam_struct[0], beam_struct)
beam_struct[0].energy_profile[*]=0
volumes=get_loop_vol(loop[0].s,loop[0].a)
max=max(abs(beam_struct.energy_profile*kev_2_ergs/volumes))
;i=0
dt=loop[1].state.time-loop[0].state.time
e_gifs=''
animate_index=0
for i=0, n_elements(beam_struct)-1l do begin
;Cheat
    e_dep=abs(beam_struct[i].energy_profile*kev_2_ergs)
    e_dep=e_dep*8/max
    half_index=long(n_elements(e_dep)/2)
    e_dep=e_dep/(dt*volumes)
    for jj=0,3 do e_dep=smooth(e_dep, 10)
    e_dep[half_index:n_elements(e_dep)-1l]= $
      reverse(e_dep[0:half_index-1])
    plot, s_alt,e_dep, psym=10,$
          TITLE='Energy Deposition',$
          YTITLE='ergs cm!E-3!N s!E-1!N',$
          XTITLE='Loop Coordinate [cm]',$
          thick=2, charthick=1.9, charsize=1.9,$
          xrange=[-1d8,8d9],/xstyle,$
          yrange=[0,8], ystyle=1
          

    legend, 'Time:'+strcompress(string(loop[i].state.time,$
                                       format='(d7.2)'), $
                                /remove_all),$
            BOX=0, charthick=1.9, charsize=1.9

     gif_file=strcompress(gif_dir+ $
                         'e_dep_'+string(animate_index,FORMAT= $  
                                                   '(i5.5)')+'.gif')
    

 x2gif, gif_file
e_gifs=[e_gifs,gif_file]
   
                                               
x2gif, gif_file
e_gifs=[e_gifs,gif_file]                             
x2gif, gif_file    
  
e_gifs=[e_gifs,gif_file]
   
animate_index=animate_index+1
ENDFOR

e_gifs=e_gifs[where(e_gifs ne '')]

image2movie,e_gifs,$
  movie_name=strcompress(gif_dir+'E_dep_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1
END
