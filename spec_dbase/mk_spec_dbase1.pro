;PRO mk_spec_dbase, ioneq_name,wave_min,wave_max,$
;                   wave_step,t_min,t_max,t_step,n_e_min,$
;                   n_e_max,n_e_step, $
;                   abund_name=abund_name
;+
; NAME: spectra
;	
;
; PURPOSE: to create spectra for a range of temperatures and electron densities
;	for certain wavelengths, abundances, and ionization balances.
;	This procedure creates many folders corresponding to abundance
;	files, ionization balance files, temperature, and electron
;	density.  In each electron density folder there is a file
;	named spectra.sav that contains a structure named spectra.  
;
; CATEGORY:
;	
;
; CALLING SEQUENCE: spectra, ioneq_name,abund_name, wave_min, wave_max,
;	wave_step,t_min,t_max,t_step,n_e_min,n_e_max,n_e_step
;
; INPUTS:
;	ioneq_name = (string)name of the ionization balance file
;       abund_name = (string)name of the abundance file 
;       wave_min = minimum wavelength, angstroms
;       wave_max = maximum wavelength, angstroms
;       wave_step = wavelength step, angstroms
;       t_min = minimum temperature, log kelvin
;       t_max = maximum temperature, log kelvin
;       t_step = temperature step, log kelvin
;       n_e_min = minimum electron density
;       n_e_max = maximum electron density$
;       n_e_step = electron density step
;
; OPTIONAL INPUTS:
;	none
;	
; KEYWORD PARAMETERS:
;	none
;
; OUTPUTS: spectra.sav stored in appropriate folder
;       structure:  spectra={wavelength:,intensity:,units:,abundance:,ionization:,date:,version:}	
;
; OPTIONAL OUTPUTS:
;	none
;
; SIDE EFFECTS:
;	You might create directories in the wrong place.  See below.
;
; RESTRICTIONS:
;	make sure you are in the correct directory each time you
;	re-compile and run spectra.pro.  The directories are very important.
;
; EXAMPLE:
;	spectra,'mazzotta_etal_ext','sun_coronal_ext',25.,420.,.1,4.,8.,.1,$
;             5d8,1d10,.1d8
;
; MODIFICATION HISTORY:
; 	Written by: Jenna Rettenmayer 11 Jan 2006
;                Modified from J.R. spectra .pro.  HDW 27-Jan-2008	
;-
ssw_packages, /chianti

wave_min=0.5d0
wave_max=300d0
help, wave_min, wave_max
wave_step=.5d0
t_min=5.5
t_max=8.9
t_step=0.2
n_e_max=1d13
n_e_min=1d7
n_e_step=n_e_min
ioneq_name='mazzotta_etal'
abund_name='sun_coronal'
filename='spectra.sav'
data_dir=getenv('DATA')

;this is messy but I need soemthing quickly
exponents=7d0+dindgen(7)
a = dindgen(10)
;b=dindgen(10)/10
b=dindgen(5)/5.

n_e=(a[0]+b[0])*(10d0^exponents[0])
n_e=[0d0]
for i=0ul, n_elements(exponents)-1ul do begin
    for j=0ul, n_elements(a)-1ul do begin
        for k=0ul, n_elements(b)-1ul do begin
            n_e_temp=(a[j]+b[k])*(10d0^exponents[i])
            n_e=[n_e, n_e_temp]
        endfor

    endfor

endfor
n_e=n_e[1:n_elements(n_e)-1ul]
junk=where(n_e ne 0)
n_e=n_e[junk]
;Note, you must be in SP2006
spec_dbase_folder=data_dir+'/spectral_dbase/'
spawn , 'mkdir '+spec_dbase_folder  ;make SPECTRA if it does not exist already
;this file is saved in ../SPECTRA or SP2006

;create wavelength, temperature, and electron density arrays from inputs
wave=dindgen(long(wave_max-wave_min)/wave_step)*wave_step+wave_min
t=t_min+dindgen(long((t_max-t_min)/t_step))*t_step 
;n_e=n_e_min+(n_e_max-n_e_min)*dindgen(1d3)/((1d3)-1d0)



;create main folder for ionization balance and abundance
;parent_folder=ioneq_name/abund_name
parent_folder=spec_dbase_folder+ $
              ioneq_name+"/"

spawn , 'mkdir '+parent_folder
parent_folder=parent_folder+abund_name+'/'
spawn , 'mkdir '+parent_folder


;change to that folder and then set the current folder equal to main
cd,parent_folder,current=main;set abundance and ib names to be called correctly in isothermal
;paths for files:
;/usr/local/ssw/packages/chianti/dbase/ioneq/mazzotta_etal_ext.ioneq
;/usr/local/ssw/packages/chianti/dbase/abundance/sun_coronal_ext.abund

abund=!xuvtop+'/abundance/' $
      +abund_name+'.abund'
abund=strcompress(abund,/remove_all)
ioneq=!xuvtop+'/ioneq/' $
      +ioneq_name+'.ioneq'
ioneq=strcompress(ioneq,/remove_all)
spec_files=strarr(n_elements(t), n_elements(n_e))

;loops to create subfolders for density and temperature
;also run isothermal here, create structure for results of isothermal
;save spectra.sav in each folder
;spectra.sav contains a structure with all the results

FOR t_index=0,n_elements(t)-1 DO BEGIN
    FOR n_e_index=0,n_elements(n_e)-1 DO BEGIN
        ;format the foldernames for shorter names
        t_string=string(t[t_index],format='(f3.1)')
        n_e_string=string(n_e[n_e_index],format='(e8.2)')
        

        filename='T_'+t_string+'_'+'n_e_'+n_e_string+$
                  'spec.sav'
        filename=strcompress(filename,/remove_all)

        spec_files[t_index, n_e_index]=filename

        isothermal,wave_min,wave_max,wave_step,10.^t[t_index],lambda,spectrum,$
                   list_wvl,list_ident,edensity=n_e[n_e_index],$
                   abund_name=abund,ioneq_name=ioneq,/CONT,$
                    /all, /noverbose, /photons, EM=1
;
        spectrum=spectrum
                   

        version=1.1
        date=systime()
        units='photons*cm^3*sr^-1*sec^-1'
        abundance=abund
        ionization=ioneq
       ; help, spectrum
      ;  pmm, spectrum
        ;spectra={wavelength:wave,intensity:spectrum,$
        ;         units:'photons*cm^3*sr^-1*sec^-1',abundance:abund,$
        ;         ionization:ioneq,date:systime(),version:'1.1'}

        save,lambda, spectrum, $
             version,date,units,abundance, ionization,$
             filename=filename

        save, spec_files,t, n_e, filename='spec_files_index.sav'
    ENDFOR
ENDFOR
;change back to folder where i started './SP2006'
cd,main


END
