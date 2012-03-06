
pro pa_plot, nt_beam, GIF_NAME=GIF_NAME
patc_dir=getenv('PATC')
;restore,patc_dir+'initial_e_beam.sav'
run_folder=strcompress(patc_dir+'runs/2006_AUG_17/')

loadct,0
;nt_beam=injected_beambeam_struct[0].nt_beam
save_type2='pa_dist' 
!p.multi=[0,0,0]
;old_x_range=!X.CRANGE
!X.CRANGE=[-1.0,1.0]
;gif_dir=run_folder+'gifs/'   
;animate_index=0 
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
charthick=1.3
charsize=1.3




;xloadct
 plot_histo,cos(nt_beam.pitch_angle), 100,histo, delta=.05,xrange=[-1.0,1.0],$
   XTITLE='Cosine Pitch Angle',YTITLE='Number of Particles',$
   TITLE='Initial Pitch Angle Distribution', $
   CHARSIZE=charsize,CHARTHICK=charthick, $
   BCOLOR=1,XSTYLE=1,BACKGROUND = 255, COLOR = 0  

;set_plot,'ps'
;device, /PORTRAIT,/COLOR,/ENCAPSULATED,$
;  FILE='/disk/hl2/data/winter/data3/Meetings/2005_11_Kyoto/pa_dis.eps'


 plot_histo,cos(nt_beam.pitch_angle), 100,histo, delta=.05,xrange=[-1.0,1.0],$
   XTITLE='Cosine Pitch Angle',YTITLE='Number of Particles',$
   TITLE='Initial Pitch Angle Distribution', $
   CHARSIZE=charsize,CHARTHICK=charthick,$
   BCOLOR=1,XSTYLE=1

IF KEYWORD_SET(GIF_NAME) THEN x2gif,'fig1.gif'
;device,/CLOSE
; set_plot,'x'
;!X.CRANGE=old_x_range
end

