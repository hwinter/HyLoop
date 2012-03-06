function get_nfe_gauss_dist, loop, s_nano,power_nano, fwhm

n_nanos=n_elements(s_nano)

e_h=loop.s_alt[1:n_elements(loop.s_alt)-2ul]*0d

if n_elements(power_nano) ne n_nanos  then $
   power_nano_in=power_nano[0]*(1.0+dblarr(n_nanos)) else $
      power_nano_in=power_nano

if n_elements(fwhm) ne n_nanos  then $
   fwhm_in=fwhm[0]*(1.0+dblarr(n_nanos)) else $
      fwhm_in=fwhm

for i=0ul, n_nanos-1ul do begin
   
   g_nano=gaussian(loop.s_alt[1:n_elements(loop.s_alt)-2ul],$
                   [1.0,s_nano[i], fwhm_in[i]/2.3548 ])
   g_nano=power_nano_in[i]*(g_nano/total(g_nano))

   ;window, /free
   
   e_h+=g_nano
   ;help, g_nano, e_h
   ;window, /free
   ;plot,, g_nano, title='g_nano'
   ;window, /free
   ;plot,loop.s_alt[1:n_elements(loop.s_alt)-2ul], e_h, title='e_h'
;stop
endfor
vol=get_loop_vol(loop)
e_h/=vol
return, e_h
End ;get_nf_gauss
