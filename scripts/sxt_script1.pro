
DENSITY=1d+9 ;cm^(-3)
ioneq_file='/ssw/packages/chianti/dbase/ioneq/mazzotta_etal.ioneq'
;abund_file='/ssw/packages/chianti/dbase/abundance/version_3/meyer_coronal.abund'
abund_file='/ssw/packages/chianti/dbase/abundance/sun_coronal.abund'
defsysv,'!abund_file',abund_file
dem_name=''
ssw_packages,/chianti


restgen,file='sra950419_01.genx',str=area

ch_synthetic,area.wave[0] ,area.wave[289],OUTPUT=spec_struct,DENSITY=DENSITY,$
				IONEQ_NAME=IONEQ_FILE,/PHOTONS,ALL=ALL, $
				VERBOSE=VERBOSE, DEM_NAME=dem_name

;restore, 'sxt_script.sav'
make_chianti_spec,spec_struct,lambda , spectrum,$ 
                BIN_SIZE=0.03,/ALL, /CONTINUUM, /PHOTONS, $
                ABUND_NAME=ABUND_FILE

ph_spectrum=spline(lambda,spectrum.spectrum,area.wave)
index=where(ph_spectrum lt 0)
ph_spectrum[index]=0
set_plot,'ps'
device,/landscape,file=ps_file,yoffset=28.5
plot,lambda,ph_spectrum,ytitle="Photons cm^(-2) s^(-1) sr^(-1)",$
	xtitle="Wavelength in Angstroms" ,title="Flare Spectrum"
;help, spec_struct,/str
device,/close
set_plot,'x'

;effective_area=spline(area.wave,area.filter[2,*],lambda)
effective_area=dblarr(290)
for i=0,289 do begin
effective_area[i]=area.filter[2,i]
endfor
;effective_area=area.filter[2,*]
sqrt_n= SQRT(ph_spectrum)
help,sqrt_n
energy=12400/area.wave
;energy=12.40/lambda
g=(1.417d-10)*(effective_area)

omega=1.417d-10
Power=g*(ph_spectrum)*alog10(energy)
index=where(power gt 0)
power=power[index]
num_e=total(Power)

num_e=(num_e/3.65)

signal=num_e/100
signal=signal+13
p_noise=g*omega*sqrt_n*energy

index=where(p_noise gt 0)
p_noise=p_noise[index]

noise=total(P_noise)/(3.65)
noise=noise+13
print,signal/noise
save,file='sxt_script.sav'
end
