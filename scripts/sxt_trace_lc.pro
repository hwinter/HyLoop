;loop_isothermal.pro
;created by Jenna Rettenmayer
;2005/10/31
;uses isothermal to create spectra
; as function of x from loop data
;Modified HDWIII 11/29/2005
ssw_packages,/chianti
ssw_path,/SXT
file = CONCAT_DIR('$DIR_SXT_SENSITIVE','sra950419_01.genx')
restgen,file=file, str=area
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Select targets on the loop for analysis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
targets=[45,158, 202]
items=['1', '2','3']
colors=[1,2,3]

patc_dir=getenv('PATC')
;Folder for where the simulation data is stored.
sub_folder='/runs/2005_12_2/'
run_folder=strcompress(patc_dir+sub_folder,/REMOVE_ALL)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Where to write the gifs
gif_dir=strcompress(run_folder+'gifs/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

file1=strcompress(run_folder+'hd_out.sav',/REMOVE_ALL)
file2=strcompress(run_folder+'full_test_2.sav',/REMOVE_ALL)
file3=strcompress(run_folder+'idlsave.dat',/REMOVE_ALL)
restore,file1
restore,file2
restore,file3
loop=loop_struct[0].loop
;loop.axis[0,*]=reverse(loop.axis[0,*])
;loop.axis[1,*]=reverse(loop.axis[1,*])
;loop.axis[2,*]=reverse(loop.axis[2,*])


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define Colors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define plot keywords
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
xsize=1000
ysize=xsize*1.5
thick=3.2
charsize=2.5
charthick=2.
symsize=3
SYM_CIRCLE, /fill
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot targets on the loop for analysis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

window,18,xsize=xsize, ysize=ysize
plot,reverse(loop.axis[1,*]),loop.axis[2,*] , $
  xrange=[max(loop.axis[1,*]),min(loop.axis[1,*])] ,$
  thick=thick, charsize=charsize, charthick=charthick ,$
  TITLE='Test Positions Along the Loop',$
  xstyle=2

oplot,reverse(loop.axis[1,*]),loop.axis[2,*], thick=thick
plots,loop.axis[1,targets],loop.axis[2,targets],$
  psym=8,color=colors ,$
   symsize=symsize, thick=thick
xyouts,loop.axis[1,targets]+12e6 ,loop.axis[2,targets]+10e6 ,items , $
  ALIGNMENT= 1.0, CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK

x2gif,strcompress(gif_dir+'lcur_positions'+'.gif')

window,1,xsize=xsize, ysize=ysize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Al 12 filter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
top1=max(sxt_signal_5[*,targets[0]])
top2=max(sxt_signal_5[*,targets[1]])
top3=max(sxt_signal_5[*,targets[2]])
top=max([top1,top2, top3]) 

plot, lhist.time, $
  sxt_signal_5[*,targets[0]]/max(sxt_signal_5[*,targets[0]]),$
  XRANGE=[0,max(lhist.time)+.1],/XSTYLE,/nodata,$
  thick=thick, charsize=charsize, charthick=charthick,$
  TITLE='SXT Al 12 !4l!3m', YTITLE='Response [Normalized Units]',$
  XTITLE='Time [sec]'
  ;yrange=[0,top[0]],/YSTYLE,$

oplot, lhist.time, $
  sxt_signal_5[*,targets[0]]/max(sxt_signal_5[*,targets[0]]),$
  color=1,$
  thick=thick

oplot,lhist.time,$
  sxt_signal_5[*,targets[1]]/max(sxt_signal_5[*,targets[1]]),$
  color=2,$
  thick=thick

pmm,  sxt_signal_5[*,targets[1]]/max(sxt_signal_5[*,targets[1]])

oplot,  lhist.time,$
  sxt_signal_5[*,targets[2]]/max(sxt_signal_5[*,targets[2]]),$
  color=3,$
  thick=thick

legend, items, linestyle=0,colors=colors,$
  charsize=charsize, charthick=charthick,thick=thick,$
  box=0
x2gif,strcompress(gif_dir+'lcur_sxt_al_12'+'.gif')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Be  filter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
window,2,xsize=xsize, ysize=ysize
;top1=max(sxt_signal_4[*,targets[0]])
;top2=max(sxt_signal_4[*,targets[1]])
;top3=max(sxt_signal_4[*,targets[2]])
;top=max([top1,top2, top3]) 

plot, lhist.time, $
  sxt_signal_4[*,targets[0]]/max(sxt_signal_4[*,targets[0]]),$
  XRANGE=[0,max(lhist.time)],/XSTYLE,/nodata,$
  thick=thick, charsize=charsize, charthick=charthick,$
  TITLE='SXT Be 119 !4l!3m', YTITLE='Response [Normalized Units]',$
  XTITLE='Time [sec]'
  
  ;yrange=[0,top[0]],/YSTYLE,$
oplot, lhist.time, $
  (sxt_signal_4[*,targets[0]]/max(sxt_signal_4[*,targets[0]])),$
  color=1,$
  thick=thick
oplot,  lhist.time,$
  (sxt_signal_4[*,targets[1]]/(max(sxt_signal_4[*,targets[1]]))),$
  color=2,$
  thick=thick
oplot,  lhist.time,$
  (sxt_signal_4[*,targets[2]]/max(sxt_signal_4[*,targets[2]])),$
  color=3,$
  thick=thick

x2gif,strcompress(gif_dir+'lcur_sxt_be'+'.gif')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Dag  filter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
window,2,xsize=xsize, ysize=ysize
;top1=max(sxt_signal_4[*,targets[0]])
;top2=max(sxt_signal_4[*,targets[1]])
;top3=max(sxt_signal_4[*,targets[2]])
;top=max([top1,top2, top3]) 

plot, lhist.time, $
  sxt_signal_3[*,targets[0]]/max(sxt_signal_3[*,targets[0]]),$
  XRANGE=[0,max(lhist.time)],/XSTYLE,/nodata,$
  thick=thick, charsize=charsize, charthick=charthick,$
  TITLE='SXT Dag', YTITLE='Response [Normalized Units]',$
  XTITLE='Time [sec]'
  
  ;yrange=[0,top[0]],/YSTYLE,$
oplot, lhist.time, $
  (sxt_signal_3[*,targets[0]]/max(sxt_signal_3[*,targets[0]])),$
  color=1,$
  thick=thick
oplot,  lhist.time,$
  (sxt_signal_3[*,targets[1]]/(max(sxt_signal_3[*,targets[1]]))),$
  color=2,$
  thick=thick
oplot,  lhist.time,$
  (sxt_signal_3[*,targets[2]]/max(sxt_signal_3[*,targets[2]])),$
  color=3,$
  thick=thick

x2gif,strcompress(gif_dir+'lcur_sxt_dag'+'.gif')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;TRACE 171  filter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
angstrom = '!6!sA!r!u!9 %!6!n!3'

tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
window,3,xsize=xsize, ysize=ysize
;top1=max(sxt_signal_4[*,targets[0]])
;top2=max(sxt_signal_4[*,targets[1]])
;top3=max(sxt_signal_4[*,targets[2]])
;top=max([top1,top2, top3]) 

plot, lhist.time, $
  trace_signal_1[*,targets[0]]/max(trace_signal_1[*,targets[0]]),$
  XRANGE=[0,max(lhist.time)],/XSTYLE,/nodata,$
  thick=thick, charsize=charsize, charthick=charthick,$
  TITLE='!3TRACE 171 '+Angstrom, YTITLE='Response [Normalized Units]',$
  XTITLE='Time [sec]'
oplot, lhist.time, $
  (trace_signal_1[*,targets[0]]/max(trace_signal_1[*,targets[0]])),$
  color=1,$
  thick=thick
oplot,  lhist.time,$
  (trace_signal_1[*,targets[1]]/(max(trace_signal_1[*,targets[1]]))),$
  color=2,$
  thick=thick
oplot,  lhist.time,$
  (trace_signal_1[*,targets[2]]/max(trace_signal_1[*,targets[2]])),$
  color=3,$
  thick=thick

x2gif,strcompress(gif_dir+'lcur_trace_171'+'.gif')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;TRACE 195  filter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
window,4,xsize=xsize, ysize=ysize
plot, lhist.time, $
  trace_signal_2[*,targets[0]]/max(trace_signal_2[*,targets[0]]),$
  XRANGE=[0,max(lhist.time)],/XSTYLE,/nodata,$
  thick=thick, charsize=charsize, charthick=charthick,$
  TITLE='!3TRACE 195 '+Angstrom, YTITLE='Response [Normalized Units]',$
  XTITLE='Time [sec]'
oplot, lhist.time, $
  (trace_signal_2[*,targets[0]]/max(trace_signal_2[*,targets[0]])),$
  color=1,$
  thick=thick
oplot,  lhist.time,$
  (trace_signal_2[*,targets[1]]/(max(trace_signal_2[*,targets[1]]))),$
  color=2,$
  thick=thick
oplot,  lhist.time,$
  (trace_signal_2[*,targets[2]]/max(trace_signal_2[*,targets[2]])),$
  color=3,$
  thick=thick

x2gif,strcompress(gif_dir+'lcur_trace_195'+'.gif')



END
