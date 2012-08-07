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

mazzotta_etal='/usr/local/ssw/packages/chianti/dbase/ioneq/mazzotta_etal.ioneq'
abundance='/usr/local/ssw/packages/chianti/dbase/abundance/sun_coronal.abund'

patc_dir=getenv('PATC')
;Folder for where the simulation data is stored.
sub_folder='/runs/2005_11_03c/'
run_folder=strcompress(patc_dir+sub_folder,/REMOVE_ALL)

file1=strcompress(run_folder+'hd_out.sav',/REMOVE_ALL)
file2=strcompress(run_folder+'full_test_2.sav',/REMOVE_ALL)
restore,file1
restore,file2
num=n_elements(lhist)

factor=4L
n_elem=num/factor

pixel_size=4.25d;arcsec
pixel_size=pixel_size*(1d/60d)*(1d/60d);deg
pixel_size=pixel_size*(double(!pi)/180d);rad
pixel_size=pixel_size^2d
;stop
blah=n_elements(lhist[0].n_e)
em=rebin([10d27],blah) ;make emission measure array
kB=1.3807d-16 ;conversion factor
min_wavelength=min(area.wave)
max_wavelength=max(area.wave)
delta_lambda=area.wave[1]-area.wave[0]
num2=max_wavelength-min_wavelength+1
;loop_spectrum=rebin([0],num,blah,num2)
;loop_lambda=rebin([0],num,blah,num2)

loop=loop_struct[0].loop
 N=n_elements(loop.x)
a=!pi*loop.rad*loop.rad
 dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))
vol=dblarr(n)
a=!pi*loop.rad*loop.rad

for i=1,n-2 do begin
    length=loop.x[i+1]-loop.x[i]
    vol[i]=a[i]*length
endfor
vol[n-1]=a[n-1]*length
resp_1=area.ENTRANCE* area.CCD*area.MIRROR*Area.FILTER[0,*]
resp_2=area.ENTRANCE* area.CCD*area.MIRROR*Area.FILTER[1,*]
resp_3=area.ENTRANCE* area.CCD*area.MIRROR*Area.FILTER[2,*]
resp_4=area.ENTRANCE* area.CCD*area.MIRROR*Area.FILTER[3,*]
resp_5=area.ENTRANCE* area.CCD*area.MIRROR*Area.FILTER[4,*]
resp_6=area.ENTRANCE* area.CCD*area.MIRROR*Area.FILTER[5,*]

elements=[25,100,200]
num_elements=n_elements(elements)
lambda=area.wave
signal_1=fltarr(n_elem,num_elements)
signal_2=fltarr(n_elem,num_elements)
signal_3=fltarr(n_elem,num_elements)
signal_4=fltarr(n_elem,num_elements)
signal_5=fltarr(n_elem,num_elements)
signal_6=fltarr(n_elem,num_elements)

big_spec=fltarr(n_elem,num_elements,n_elements(area.wave))

FOR i=0, 1 DO BEGIN; n_elem DO BEGIN
    n_lhist=i*factor
     T=lhist[n_lhist].e/(3.0* lhist[n_lhist].n_e*kB)
     n_e=lhist[n_lhist].n_e[0:blah-2]
     em=double(n_e*n_e)*vol
     FOR j=0,1 DO BEGIN
         
          isothermal,double(min_wavelength),double(max_wavelength),$
            2d,T[elements[j]],lambda,spectrum,list_wvl,$
            list_ident,edensity=n_e[elements[j]],abund_name=abundance,$
            ioneq_name=mazzotta_etal,/photons,/cont,em=em[elements[j]]
          if spectrum[0] eq -1  then new_spec=1d

          if n_elements(spectrum) gt 1 then $
            new_spec=spline(lambda,spectrum,area.wave) & print,"success!!!"

          n_photons1=new_spec*resp_1*pixel_size
          n_photons2=new_spec*resp_2*pixel_size
          n_photons3=new_spec*resp_3*pixel_size
          n_photons4=new_spec*resp_4*pixel_size
          n_photons5=new_spec*resp_5*pixel_size         
          n_photons6=new_spec*resp_6*pixel_size
          

          ev_per_angstrom=(12398.5/area.wave)
          inverse_work_function=(1./3.65)
          factor=ev_per_angstrom*inverse_work_function
          n_elects_1=n_photons1*factor
          n_elects_2=n_photons2*factor
          n_elects_3=n_photons3*factor
          n_elects_4=n_photons4*factor
          n_elects_5=n_photons5*factor
          n_elects_6=n_photons6*factor

          signal_1[n_lhist,j]=abs(total(n_elects_1/100.))+13.
          signal_2[n_lhist,j]=abs(total(n_elects_2/100.))+13.
          signal_3[n_lhist,j]=abs(total(n_elects_3/100.))+13.
          signal_4[n_lhist,j]=abs(total(n_elects_4/100.))+13.
          signal_5[n_lhist,j]=abs(total(n_elects_5/100.))+13.
          signal_6[n_lhist,j]=abs(total(n_elects_6/100.))+13.
          ;big_spec[n_lhist,j,*]=new_spec
     
      ENDFOR
      ;stop
 ENDFOR
save, lambda,list_wvl,list_ident,signal_1,signal_2,$
  signal_3,signal_4,signal_5,signal_6
END
