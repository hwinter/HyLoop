;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;.r mk_hinode_plots_w_error
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EXPERIMENT_DIR=getenv('DATA')+'/HyLoop/runs/flare_exp_05'
ALPHA_FOLDERS=['alpha=-4/','alpha=0','alpha=4/'];,$
 ;        'alpha=-4/'
GRID_FOLDERS='699_25/'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
j=0
Current_folder=EXPERIMENT_DIR[0]+'/'+ $
               ALPHA_FOLDERS[j]+'/'+ $
               GRID_FOLDERS[0]+'/'
restore, Current_folder+'sig_vars_w_dev.sav'

A_SIGNAL_1_am4=A_SIGNAL_1
A_SIGNAL_2_am4=A_SIGNAL_2
A_SIGNAL_3_am4=A_SIGNAL_3

FP_SIGNAL_1_am4=FP_SIGNAL_1
FP_SIGNAL_2_am4=FP_SIGNAL_2
FP_SIGNAL_3_am4=FP_SIGNAL_3

A_DEV_1_am4=a_signal_dev_1
A_DEV_2_am4=a_signal_dev_2
A_DEV_3_am4=a_signal_dev_3
FP_DEV_1_am4=fp_signal_dev_1
FP_DEV_2_am4=fp_signal_dev_2
FP_DEV_3_am4=fp_signal_dev_3

SCL_1_am4=SCL_1
SCL_2_am4=SCL_2
SCL_3_am4=SCL_3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
j=1
Current_folder=EXPERIMENT_DIR[0]+'/'+ $
               ALPHA_FOLDERS[j]+'/'+ $
               GRID_FOLDERS[0]+'/'
restore, Current_folder+'sig_vars_w_dev.sav'

A_SIGNAL_1_a0=A_SIGNAL_1
A_SIGNAL_2_a0=A_SIGNAL_2
A_SIGNAL_3_a0=A_SIGNAL_3

FP_SIGNAL_1_a0=FP_SIGNAL_1
FP_SIGNAL_2_a0=FP_SIGNAL_2
FP_SIGNAL_3_a0=FP_SIGNAL_3

A_DEV_1_a0=a_signal_dev_1
A_DEV_2_a0=a_signal_dev_2
A_DEV_3_a0=a_signal_dev_3
FP_DEV_1_a0=fp_signal_dev_1
FP_DEV_2_a0=fp_signal_dev_2
FP_DEV_3_a0=fp_signal_dev_3

SCL_1_a0=SCL_1
SCL_2_a0=SCL_2
SCL_3_a0=SCL_3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
j=2
Current_folder=EXPERIMENT_DIR[0]+'/'+ $
               ALPHA_FOLDERS[j]+'/'+ $
               GRID_FOLDERS[0]+'/'
restore, Current_folder+'sig_vars_w_dev.sav'

A_SIGNAL_1_a4=A_SIGNAL_1
A_SIGNAL_2_a4=A_SIGNAL_2
A_SIGNAL_3_a4=A_SIGNAL_3

FP_SIGNAL_1_a4=FP_SIGNAL_1
FP_SIGNAL_2_a4=FP_SIGNAL_2
FP_SIGNAL_3_a4=FP_SIGNAL_3

A_DEV_1_a4=a_signal_dev_1
A_DEV_2_a4=a_signal_dev_2
A_DEV_3_a4=a_signal_dev_3
FP_DEV_1_a4=fp_signal_dev_1
FP_DEV_2_a4=fp_signal_dev_2
FP_DEV_3_a4=fp_signal_dev_3

SCL_1_a4=SCL_1
SCL_2_a4=SCL_2
SCL_3_a4=SCL_3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sig_1_am4=SCL_1_am4/SCL_2_am4
sig_2_am4=SCL_1_am4/SCL_3_am4
sig_3_am4=SCL_2_am4/SCL_3_am4

sig_1_a0=SCL_1_a0/SCL_2_a0
sig_2_a0=SCL_1_a0/SCL_2_a0
sig_3_a0=SCL_2_a0/SCL_3_a0

sig_1_a4=SCL_1_a4/SCL_2_a4
sig_2_a4=SCL_1_a4/SCL_2_a4
sig_3_a4=SCL_2_a4/SCL_3_a4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the ratios.
ratio_1_am4=a_signal_1_am4/fp_signal_1_am4
ratio_2_am4=a_signal_2_am4/fp_signal_2_am4
ratio_3_am4=a_signal_3_am4/fp_signal_3_am4

ratio_1_a0=a_signal_1_a0/fp_signal_1_a0
ratio_2_a0=a_signal_2_a0/fp_signal_2_a0
ratio_3_a0=a_signal_3_a0/fp_signal_3_a0

ratio_1_a4=a_signal_1_a4/fp_signal_1_a4
ratio_2_a4=a_signal_2_a4/fp_signal_2_a4
ratio_3_a4=a_signal_3_a4/fp_signal_3_a4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the error on the ratios.

;am4
error_1_am4=sqrt( $
            (ratio_1_am4^2.0)*$
            ( $
            ((A_DEV_1_am4^2.0)/(a_signal_1_am4^2.0)) $
            +((FP_DEV_1_am4^2.0)/(fp_signal_1_am4^2.0)) $
            ) $
                )
error_2_am4=sqrt( $
            (ratio_2_am4^2.0)*$
            ( $
            ((A_DEV_2_am4^2.0)/(a_signal_2_am4^2.0)) $
            +((FP_DEV_2_am4^2.0)/(fp_signal_2_am4^2.0)) $
            ) $
                )
error_3_am4=sqrt( $
            (ratio_3_am4^2.0)*$
            ( $
            ((A_DEV_3_am4^2.0)/(a_signal_3_am4^2.0)) $
            +((FP_DEV_3_am4^2.0)/(fp_signal_3_am4^2.0)) $
            ) $
                )
;a0
error_1_a0=sqrt( $
            (ratio_1_a0^2.0)*$
            ( $
            ((A_DEV_1_a0^2.0)/(a_signal_1_a0^2.0)) $
            +((FP_DEV_1_a0^2.0)/(fp_signal_1_a0^2.0)) $
            ) $
                )
error_2_a0=sqrt( $
            (ratio_2_a0^2.0)*$
            ( $
            ((A_DEV_2_a0^2.0)/(a_signal_2_a0^2.0)) $
            +((FP_DEV_2_a0^2.0)/(fp_signal_2_a0^2.0)) $
            ) $
                )
error_3_a0=sqrt( $
            (ratio_3_a0^2.0)*$
            ( $
            ((A_DEV_3_a0^2.0)/(a_signal_3_a0^2.0)) $
            +((FP_DEV_3_a0^2.0)/(fp_signal_3_a0^2.0)) $
            ) $
                )
;a4
error_1_a4=sqrt( $
            (ratio_1_a4^2.0)*$
            ( $
            ((A_DEV_1_a4^2.0)/(a_signal_1_a4^2.0)) $
            +((FP_DEV_1_a4^2.0)/(fp_signal_1_a4^2.0)) $
            ) $
                )
error_2_a4=sqrt( $
            (ratio_2_a4^2.0)*$
            ( $
            ((A_DEV_2_a4^2.0)/(a_signal_2_a4^2.0)) $
            +((FP_DEV_2_a4^2.0)/(fp_signal_2_a4^2.0)) $
            ) $
                )
error_3_a4=sqrt( $
            (ratio_1_a4^2.0)*$
            ( $
            ((A_DEV_3_a4^2.0)/(a_signal_3_a4^2.0)) $
            +((FP_DEV_3_a4^2.0)/(fp_signal_3_a4^2.0)) $
            ) $
                )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n_images=300

index1=UINDGEN(n_images-2)+2
index2=index1
index3=index1
;for i=0, n_images-1, 10 do index1=[index1,times[i]]
;index2=times[6]
;for i=12, n_images-1, 10 do index2=[index2,times[i]]
;index2 <= n_images
;index3=12
;for i=24, n_images-1, 10 do index3=[index3,times[i]]
;index3 <= n_images
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a plot.
set_plot, 'ps'
      device, /portrait, file= 'a_fp_ratio_w_error.eps',$
              /CMYK, color=16, /enc
;Plot the temperature array  with no axes on the right
        


TITLE=['!9g!3!DPA!N=-4','!9g!3!DPA!N=0', '!9g!3!DPA!N=4']           ;'Al Med.'
      
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
YRange=[.9*min([ratio_1_am4[index1]-error_1_am4[index1],$
                 ratio_1_a0[index2]-error_1_a0[index2],$
                 ratio_1_a4[index3]-error_1_a4[index3]]), $
        1.0*max([ratio_1_am4[index1]+error_1_am4[index1],$
                 ratio_1_a0[index2]+error_1_a0[index2],$
                 ratio_1_a4[index3]+error_1_a4[index3]]) ] ;,$

YRANGE<=6
YRANGE>=0
erase

plot, times,ratio_1_am4[0:n_images] , /nodata, $
      POSITION=[0.12, 0.15, .95, .3333],$
      font=0,charthick=0.9, charsize=0.9,$
      yTITLE="Ratio", $;XTITLE="Seconds",$
      XRANGE=[0, 425],YRANGE=YRANGE,$
      _EXTRA=GANG_PLOT_POS(3,1,0,0)
                               ;  /YLOG
oplot, times,$
       ratio_1_am4[0:n_images],$
       thick=4, line=0,color=1
;Error plot
errplot, times[index1],$
         ratio_1_am4[index1]-error_1_am4[index1],$
         ratio_1_am4[index1]+error_1_am4[index1],$
         color=1
;
oplot, times, $
       ratio_1_a0[0:n_images], $
       color=2, thick=4, line=0
;Error plot
errplot, times[index2],$
         ratio_1_a0[index2]-error_1_a0[index2],$
         ratio_1_a0[index2]+error_1_a0[index2], $
         color=2
;
oplot, times, $
       ratio_1_a4[0:n_images],  $
       color=3, thick=4, line=0  ;, psym=4
;Error plot
errplot, times[index3],$
         ratio_1_a4[index3]-error_1_a4[index3],$
         ratio_1_a4[index3]+error_1_a4[index3],  $
         color=3
;

legend, title, color=[1,2,3],box=0,$
        thick=[4,4,4], /TOP,$   ; horizontal=1,$
        line=[0,0,0],charthick=1.2, charsize=1.2,$
        /RIGHT,font=0
legend, 'Ti-Poly',charsize=1.3, charthick=1.3 , font=0, box=0, $
        /RIGHT, /BOTTOM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;           
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]

YRange=[.9*min([ratio_2_am4[index1]-error_2_am4[index1],$
                 ratio_2_a0[index2]-error_2_a0[index2],$
                 ratio_2_a4[index3]-error_2_a4[index3]]), $
        1.0*max([ratio_2_am4[index1]+error_2_am4[index1],$
                 ratio_2_a0[index2]+error_2_a0[index2],$
                 ratio_2_a4[index3]+error_2_a4[index3]]) ]


plot, times, ratio_2_am4[0:n_images], $
      /nodata, $
      POSITION=[0.12, 0.15, .95, .3333],$
      font=0,charthick=0.9, charsize=0.9,$
      yTITLE="Ratio",$ ; XTITLE="Seconds",$
      XRANGE=[0, 425],YRANGE=YRANGE,$
      _EXTRA=GANG_PLOT_POS(3,1,1)
                               ;  /YLOG
oplot, times,$
       ratio_2_am4[0:n_images],$
       thick=4, line=0,color=1
;Error plot
errplot, times[index1],$
         ratio_2_am4[index1]-error_2_am4[index1],$
         ratio_2_am4[index1]+error_2_am4[index1], $
         color=1
;
oplot, times, $
       ratio_2_a0[0:n_images], $
       color=2, thick=4, line=0
;Error plot
errplot, times[index2],$
         ratio_2_a0[index2]-error_2_a0[index2],$
         ratio_2_a0[index2]+error_2_a0[index2], $
         color=2
;
oplot, times, $
       ratio_2_a4[0:n_images],  $
       color=3, thick=4, line=0  ;, psym=4
;Error plot
errplot, times[index3],$
         ratio_2_a4[index3]-error_2_a4[index3],$
         ratio_2_a4[index3]+error_2_a4[index3],  $
         color=3
;

legend, title, color=[1,2,3],box=0,$
        thick=[4,4,4], /TOP,$   ; horizontal=1,$
        line=[0,0,0],charthick=1.2, charsize=1.2,$
        /RIGHT,font=0
legend, 'Be Thin',charsize=1.3, charthick=1.3, font=0, box=0, $
        /RIGHT, /BOTTOM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;           
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
YRange=[.9*min([ratio_3_am4[index1]-error_3_am4[index1],$
                 ratio_3_a0[index2]-error_3_a0[index2],$
                 ratio_3_a4[index3]-error_3_a4[index3]]), $
        1.0*max([ratio_3_am4[index1]+error_3_am4[index1],$
                 ratio_3_a0[index2]+error_3_a0[index2],$
                 ratio_3_a4[index3]+error_3_a4[index3]]) ]




plot, times, ratio_3_am4[0:n_images], $
      /nodata, $
      POSITION=[0.12, 0.15, .95, .3333],$
      font=0,charthick=0.9, charsize=0.9,$
      yTITLE="Ratio", XTITLE="Seconds",$
      XRANGE=[0, 425],YRANGE=YRANGE,$
      _EXTRA=GANG_PLOT_POS(3,1,2)
                               ;  /YLOG
oplot, times,$
       ratio_3_am4[0:n_images],$
       thick=4, line=0,color=1
;Error plot
errplot, times[index1],$
         ratio_3_am4[index1]-error_3_am4[index1],$
         ratio_3_am4[index1]+error_3_am4[index1],$
         color=1

oplot, times, $
       ratio_3_a0[0:n_images], $
       color=2, thick=4, line=0
;Error plot
errplot, times[index2],$
         ratio_3_a0[index2]-error_3_a0[index2],$
         ratio_3_a0[index2]+error_3_a0[index2], $
         color=2

oplot, times, $
       ratio_3_a4[0:n_images],  $
       color=3, thick=4, line=0  ;, psym=4
;Error plot
errplot, times[index3],$
         ratio_3_a4[index3]-error_3_a4[index3],$
         ratio_3_a4[index3]+error_3_a4[index3],  $
         color=3


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
