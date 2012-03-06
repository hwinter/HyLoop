;file='/disk/hl2/data/winter/data1/PATC/runs/2006_JUN_23/initial_e_beam.sav'

patc_dir=getenv('PATC')
;Folder for where the simulation data is stored.
sub_folder='/runs/2006_JUN_23/'
run_folder=strcompress(patc_dir+sub_folder,/REMOVE_ALL)

file1=strcompress(run_folder+'hd_out.sav',/REMOVE_ALL)
file2=strcompress(run_folder+'full_test_2.sav',/REMOVE_ALL)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Where to write the gifs
gif_dir=strcompress(run_folder+'gifs/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define plot keywords
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
xsize=1000
ysize=xsize*1.5
thick=3.2
charsize=2.5
charthick=1.9
symsize=3
SYM_CIRCLE, /fill
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define Colors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot targets on the loop for analysis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

window,18,xsize=xsize, ysize=ysize

;restore,file
e_beam=beam_struct[0].e_beam
 help,e_beam
animate_index=0
plot_histo, cos(E_BEAM.pitch_angle),delta=.1, $
  thick=thick, charsize=charsize, charthick=charthick, $
  TITLE='I Distribution of Pitch Angle Cosine', $
  YTITLE='# of Particles', xTITLE='Pitch Angle Cosine',$
  bcolor=1




    x2gif,strcompress(gif_dir+'pa_dist'+string(animate_index,FORMAT='(I5.5)')+'.gif')


restore,file2
for i=0, n_elements(beam_struct)-1 do begin
    e_beam=beam_struct[i].e_beam
    plot_histo, cos(E_BEAM.pitch_angle),delta=.1, $
      thick=thick, charsize=charsize, charthick=charthick, $
      TITLE='Distribution of Pitch Angle Cosine', $
      YTITLE='# of Particles', xTITLE='Pitch Angle Cosine',$
      bcolor=1

    x2gif,strcompress(gif_dir+'pa_dist'+string(animate_index,FORMAT='(I5.5)')+'.gif')
    animate_index=animate_index+1

endfor


end
