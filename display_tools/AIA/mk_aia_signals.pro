function mk_aia_signals,x,a,lhist,ioneq_file=ioneq_file, $
                        ABUND_FILE=ABUND_FILE

if keyword_set(ioneq_file) ne 1 then ioneq_file='mazzotta_etal_ext'  
if keyword_set(ABUND_FILE) ne 1 then ABUND_FILE='sun_coronal_ext'

data_dir=getenv('DATA')
restgen,file=data_dir+'/AIA/AIA_DEM_TEST/demtest_data.genx',$
  str=AIA_data
restgen,file=data_dir+'/AIA/AIA_DEM_TEST/demtest_tresp.genx',$
  str=AIA_tresp
;Define Constants
;Pixel's extent in " times km/" * Guestimate
pixel=.6d*750d*1d3*1d2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
kB = 1.38e-16                   ;Boltzmann constant (erg/K)
mp = 1.67e-24 	;proton mass (g)
gamma = 5.0/3.0                 ;ratio of specific heats, Cp/Cv
gs = 2.74e4                     ;solar surface gravity
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;figure out grid size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
N = n_elements(lhist.v) 
;x on the volume element grid (like e, n_e)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x_alt = [2*x[0]-x[1],(x[0:N-3]+x[1:N-2])/2.0,2*x[N-2]-x[N-3]]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;find midpoint along loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
midpt = max(x_alt)/2.0 

;Calculate the temperature 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
T = lhist.e/(3.0*lhist.n_e*kB)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dv=1
temps=1
EM=loop_em(x,a,lhist,DV=DV,T=temps)
e_density=lhist.n_e[1:n_elements(dv)-2l]
n_volumes=n_elements(temps)
surface_area=calc_loop_areas(x,a)
;surface_area[*]=pixel*pixel
signal={A94:double(-1),$
        A131:double(-1),$
        A171:double(-1),$
        A194:double(-1),$
        A211:double(-1),$
        A335:double(-1)}

signal=replicate(signal,n_volumes)

phi=dblarr(6)
index=l64indgen(n_volumes)
for i=0, n_volumes-1l do begin
    index[i]=where(abs(alog10(t[i])-AIA_TRESP.logte) eq $
                min(abs(alog10(t[i])-AIA_TRESP.logte)))
   ; print,string(alog10(t[i]))+' '+string(AIA_TRESP.logte[index[i]]) 


    signal[i].A94=AIA_TRESP.A94.TRESP[index[i]]*EM[i]* $
      (1d/surface_area[i])

    signal[i].A131=AIA_TRESP.A131.TRESP[index[i]]*EM[i]* $
      (1d/surface_area[i])

    signal[i].A171=AIA_TRESP.A171.TRESP[index[i]] *EM[i]* $
      (1d/surface_area[i])

    signal[i].A194=AIA_TRESP.A194.TRESP[index[i]]*EM[i]* $
      (1d/surface_area[i])   

    signal[i].A211=AIA_TRESP.A211.TRESP[index[i]]*EM[i]* $
      (1d/surface_area[i])  

    signal[i].A335=AIA_TRESP.A335.TRESP[index[i]] *EM[i]* $
      (1d/surface_area[i]) 
;help,signal[i],/
endfor
;stop

;junk=where(signal.a94 lt 1)
;if junk[0] ne -1 then signal[junk].a94=0d
;junk=where(signal.a131 lt 1)
;if junk[0] ne -1 then signal[junk].a131=0d
;junk=where(signal.a171 lt 1)
;if junk[0] ne -1 then signal[junk].a171=0d
;junk=where(signal.a194 lt 1)
;if junk[0] ne -1 then signal[junk].a194=0d
;junk=where(signal.a211 lt 1)
;if junk[0] ne -1 then signal[junk].a211=0d
;junk=where(signal.a335 lt 1)
;if junk[0] ne -1 then signal[junk].a335=0d










;for i=0,n_volumes-1l do begin
;    in_temp=round_off(alog10(temps[i]),.1)
;    in_n_e=round_off(e_density[i],.1)
;    result=get_spectra(ioneq_file,ABUND_FILE,in_temp,in_n_e)
;    if result[0] ne -1 then begin
;        int=(EM[i]/surface_area[i])*(result.intensity/10d2)
;        int1=spline(result.wavelength,int,$
;                    AIA_data.response.a94.wave,$
;                   /double)
;        signal[i].A94=total(AIA_data.response.a94.ea $
;          *AIA_data.response.a94.PLATESCALE* $
;          int1);;;;;;
;
;        int1=spline(result.wavelength,int,$
;                    AIA_data.response.a131.wave,$
;                   /double);
;
;        signal[i].A131=total(AIA_data.response.a131.ea $
;          *AIA_data.response.a131.PLATESCALE* $
;          int1)
;
;        int1=spline(result.wavelength,int,$
;                    AIA_data.response.a171.wave,$
;                   /double)
;        signal[i].A171=total(AIA_data.response.a171.ea $
;          *AIA_data.response.a171.PLATESCALE* $
;          int1);
;
;        int1=spline(result.wavelength,int,$
 ;                   AIA_data.response.a194.wave,$
;                   /double)
;        signal[i].A194=total(AIA_data.response.a194.ea $
;          *AIA_data.response.a194.PLATESCALE* $
 ;         int1)
;
;        int1=spline(result.wavelength,int,$
;                    AIA_data.response.a211.wave,$
;                   /double)
;        signal[i].A211=total(AIA_data.response.a211.ea $
;          *AIA_data.response.a211.PLATESCALE* $
;          int1);
;
;        int1=spline(result.wavelength,int,$
;                    AIA_data.response.a335.wave,$
;                   /double)
;        signal[i].A335=total(AIA_data.response.a335.ea $
;          * AIA_data.response.a94.PLATESCALE* $
;          int1)
;    endif
;endfor


return, signal


end
