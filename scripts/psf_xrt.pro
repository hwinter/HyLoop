;.r psf_xrt
start_time=systime(1)
patc=getenv('PATC')
restore,patc+ '/scripts/trace_171.map'
window, 0, xs=700, ys=900
!p.multi=[0,2,1]
plot_map, map171
data=map171.data
;nPixel=[n_elements(data[*,0]),n_elements(data[0,*])]
;psf = psf_Gaussian( NPIXEL=nPixel, FWHM=2 ,$
;                     /NORMALIZE);, ST_DEV=,  NDIMEN= ] ) 

psf = psf_Gaussian( NPIXEL=[5,5], FWHM=2 ,$
                     /NORMALIZE);, ST_DEV=,  NDIMEN= ] ) 
help, data
help, psf
time_start_convol=systime(1)
data=convol(data, psf,EDGE_ZERO=1)
print, 'Convol took '+string((systime(1)-time_start_convol)/60d)+$
       ' minutes to run.'
new_map=map171
new_map.data=data

plot_map,new_map


print, 'psf_crt.pro '+string((systime(1)-start_time)/60d)+$
       ' minutes to run.'
x2gif,'./trace_psf.gif'


end 
