;Restore files
;.r mk_hinode_plots2
restore, '/Users/winter/tmp/am4/sig_vars.sav'
A_SIGNAL_1_am4=A_SIGNAL_1
A_SIGNAL_2_am4=A_SIGNAL_2
A_SIGNAL_3_am4=A_SIGNAL_3

FP_SIGNAL_1_am4=FP_SIGNAL_1
FP_SIGNAL_2_am4=FP_SIGNAL_2
FP_SIGNAL_3_am4=FP_SIGNAL_3

SCL_1_am4=SCL_1
SCL_2_am4=SCL_2
SCL_3_am4=SCL_3
restore, '/Users/winter/tmp/a0/sig_vars.sav'
A_SIGNAL_1_a0=A_SIGNAL_1
A_SIGNAL_2_a0=A_SIGNAL_2
A_SIGNAL_3_a0=A_SIGNAL_3

FP_SIGNAL_1_a0=FP_SIGNAL_1
FP_SIGNAL_2_a0=FP_SIGNAL_2
FP_SIGNAL_3_a0=FP_SIGNAL_3

SCL_1_a0=SCL_1
SCL_2_a0=SCL_2
SCL_3_a0=SCL_3

restore, '/Users/winter/tmp/a4/sig_vars.sav'
A_SIGNAL_1_a4=A_SIGNAL_1
A_SIGNAL_2_a4=A_SIGNAL_2
A_SIGNAL_3_a4=A_SIGNAL_3

FP_SIGNAL_1_a4=FP_SIGNAL_1
FP_SIGNAL_2_a4=FP_SIGNAL_2
FP_SIGNAL_3_a4=FP_SIGNAL_3

SCL_1_a4=SCL_1
SCL_2_a4=SCL_2
SCL_3_a4=SCL_3

sig_1_am4=SCL_1_am4/SCL_2_am4
sig_2_am4=SCL_1_am4/SCL_3_am4
sig_3_am4=SCL_2_am4/SCL_3_am4

sig_1_a0=SCL_1_a0/SCL_2_a0
sig_2_a0=SCL_1_a0/SCL_2_a0
sig_3_a0=SCL_2_a0/SCL_3_a0

sig_1_a4=SCL_1_a4/SCL_2_a4
sig_2_a4=SCL_1_a4/SCL_2_a0
sig_3_a4=SCL_2_a4/SCL_3_a0




n_images=74

;Make a plot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        ps_name=+'.eps'
;        gif_name=gif_dir+prefix+string(time,format='(I05)')+'.gif'
set_plot, 'ps'
      device, /portrait, file= 'plot_1.eps', color=16, /enc
;Plot the temperature array  with no axes on the right
        


TITLE=['!9g=-4!3','!9g=0!3', '!9g=4!3']           ;'Al Med.'
      
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
YRange=[.9*min([a4[0:n_images]]), $
        1.0*max([a_signal_1_am4[0:n_images]/fp_signal_1_am4[0:n_images],$
                 a_signal_1_a0[0:n_images]/fp_signal_1_a0[0:n_images],$
                 a_signal_1_a4[0:n_images]/fp_signal_1_a4[0:n_images]]) ] ;,$
erase

plot, times,(a_signal_1_am4[0:n_images])/fp_signal_1_am4[0:n_images] , /nodata, $
      POSITION=[0.12, 0.15, .95, .3333],$
      font=0,charthick=0.9, charsize=0.9,$
      yTITLE="Ratio", $;XTITLE="Seconds",$
      XRANGE=[0, 425],YRANGE=YRANGE,$
      _EXTRA=GANG_PLOT_POS(3,1,0,0)
                               ;  /YLOG
oplot, times,$
       (a_signal_1_am4[0:n_images])/fp_signal_1_am4[0:n_images],$
       thick=4, line=0,color=1
oplot, times, $
       (a_signal_1_a0[0:n_images])/fp_signal_1_a0[0:n_images], $
       color=2, thick=4, line=0
oplot, times, $
       (a_signal_1_a4[0:n_images])/fp_signal_1_a4[0:n_images],  $
       color=3, thick=4, line=0  ;, psym=4

legend, title, color=[1,2,3],box=0,$
        thick=[4,4,4], /TOP,$   ; horizontal=1,$
        line=[0,0,0],charthick=1.2, charsize=1.2,$
        /RIGHT,font=0
legend, 'Ti-Poly',charsize=1.3, charthick=1.3 , font=0, box=0, $
        /RIGHT, /BOTTOM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;           
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
YRange=[.9*min([a_signal_2_am4[0:n_images]/fp_signal_2_am4[0:n_images],$
                a_signal_2_a0[0:n_images]/fp_signal_2_a0[0:n_images],$
                a_signal_2_a4[0:n_images]/fp_signal_2_a4[0:n_images]]), $
        1.0*max([a_signal_2_am4[0:n_images]/fp_signal_2_am4[0:n_images],$
                 a_signal_2_a0[0:n_images]/fp_signal_2_a0[0:n_images],$
                 a_signal_2_a4[0:n_images]/fp_signal_2_a4[0:n_images]]) ] ;,$


plot, times, (a_signal_2_am4[0:n_images])/fp_signal_2_am4[0:n_images], $
      /nodata, $
      POSITION=[0.12, 0.15, .95, .3333],$
      font=0,charthick=0.9, charsize=0.9,$
      yTITLE="Ratio",$ ; XTITLE="Seconds",$
      XRANGE=[0, 425],YRANGE=YRANGE,$
      _EXTRA=GANG_PLOT_POS(3,1,1)
                               ;  /YLOG
oplot, times,$
       (a_signal_2_am4[0:n_images])/fp_signal_2_am4[0:n_images],$
       thick=4, line=0,color=1
oplot, times, $
       (a_signal_2_a0[0:n_images])/fp_signal_2_a0[0:n_images], $
       color=2, thick=4, line=0
oplot, times, $
       (a_signal_2_a4[0:n_images])/fp_signal_2_a4[0:n_images],  $
       color=3, thick=4, line=0  ;, psym=4

legend, title, color=[1,2,3],box=0,$
        thick=[4,4,4], /TOP,$   ; horizontal=1,$
        line=[0,0,0],charthick=1.2, charsize=1.2,$
        /RIGHT,font=0
legend, 'Be Thin',charsize=1.3, charthick=1.3, font=0, box=0, $
        /RIGHT, /BOTTOM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;           
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
YRange=[.9*min([a_signal_3_am4[0:n_images]/fp_signal_3_am4[0:n_images],$
                a_signal_3_a0[0:n_images]/fp_signal_3_a0[0:n_images],$
                a_signal_3_a4[0:n_images]/fp_signal_3_a4[0:n_images]]), $
        1.0*max([a_signal_3_am4[0:n_images]/fp_signal_3_am4[0:n_images],$
                 a_signal_3_a0[0:n_images]/fp_signal_3_a0[0:n_images],$
                 a_signal_3_a4[0:n_images]/fp_signal_3_a4[0:n_images]]) ] ;,$


plot, times, (a_signal_3_am4[0:n_images])/fp_signal_3_am4[0:n_images], $
      /nodata, $
      POSITION=[0.12, 0.15, .95, .3333],$
      font=0,charthick=0.9, charsize=0.9,$
      yTITLE="Ratio", XTITLE="Seconds",$
      XRANGE=[0, 425],YRANGE=YRANGE,$
      _EXTRA=GANG_PLOT_POS(3,1,2)
                               ;  /YLOG
oplot, times,$
       (a_signal_3_am4[0:n_images])/fp_signal_3_am4[0:n_images],$
       thick=4, line=0,color=1
oplot, times, $
       (a_signal_3_a0[0:n_images])/fp_signal_3_a0[0:n_images], $
       color=2, thick=4, line=0
oplot, times, $
       (a_signal_3_a4[0:n_images])/fp_signal_3_a4[0:n_images],  $
       color=3, thick=4, line=0  ;, psym=4

legend, title, color=[1,2,3],box=0,$
        thick=[4,4,4], /TOP,$   ; horizontal=1,$
        line=[0,0,0],charthick=1.2, charsize=1.2,$
        /RIGHT,font=0

legend, 'Be Med',charsize=1.3, charthick=1.3, font=0, box=0, $
        /RIGHT, /BOTTOM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        device, /CLOSE
 ;       spawn, 'convert '+ ps_name+' '+gif_name
 ;       print, gif_name
      ;  gif_files=[gif_files, gif_name]
      ;  
      ;  gif_files=gif_files[1:N_ELEMENTS(gif_files)-1UL]
      ;  print, ps_name
  ;      print, movie_dir+movie_name
   ;     image2movie,gif_files, $
   ;                 movie_name=movie_name+'.mpg',$
 ;                   movie_dir=movie_dir,$
 ;                   /mpeg,$     ;/java,$
 ;                   scratchdir=gif_dir
 ;       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset the plotting environment.
;tvlct, r_old,g_old,b_old
;set_plot, old_state
end
