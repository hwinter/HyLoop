;plot_fdf_script

patc_dir=getenv('PATC')

file=patc_dir+'/runs/2006_AUG_17/injected_beam.sav'
restore, file

file=patc_dir+'/runs/2006_AUG_17/gcsm_loop.sav'
restore, file

nt_beam=injected_beam[0].nt_beam
fdf=flux_dist_func(nt_beam,loop, E,v)
window,0,xs=600, ys=700
plot, e,fdf/e,/ylog,/xlog,$
      XRANGE=[min((e)), max((e))], $
      yrange=[min((fdf/e)), max((fdf/e))],$
      thick=2, psym=10,/xstyle,/ystyle, $
      title='Flux Distribution Function', $
      xtitle='Energy [keV]',$
      YTITLE='[electrons cm!U-2!N s!U-1!N keV!U-1!N]',$
      charsize=2, charthick=1.999;,font='Helvetica'

;legend,BOX=0



END
