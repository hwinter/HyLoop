PRO t_mk_spectra,ioneq_name,abund_name,wave_min,wave_max,$
            wave_step,t_min,t_max,t_step,n_e_min,n_e_max,n_e_step
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
;       n_e_max = maximum electron density
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
;-

;Note, you must be in SP2006
;file_mkdir,'SPECTRA' ;make SPECTRA if it does not exist already
cd,'/disk/hl2/data/winter/data2/jenna/SP2006/SPECTRA'
                                ;change to SPECTRA directory to place folders
;this file is saved in ../SPECTRA or SP2006

em=10d27

;create wavelength, temperature, and electron density arrays from inputs
wave=findgen((wave_max-wave_min)/wave_step)*wave_step+wave_min
t=dindgen((t_max-t_min)/t_step)*t_step+t_min
n_e=findgen(((n_e_max-n_e_min)/n_e_step)+2)*n_e_step+n_e_min

;create main folder for ionization balance and abundance
;parent_folder=ioneq_name/abund_name
parent_folder=strcompress(string(ioneq_name,"/",abund_name),/remove_all)
file_mkdir,parent_folder
;change to that folder and then set the current folder equal to main
cd,parent_folder,current=main
;main=./SP2006/SPECTRA

;set abundance and ib names to be called correctly in isothermal
;paths for files:
;/usr/local/ssw/packages/chianti/dbase/ioneq/mazzotta_etal_ext.ioneq
;/usr/local/ssw/packages/chianti/dbase/abundance/sun_coronal_ext.abund

abund=string('/usr/local/ssw/packages/chianti/dbase/abundance/'$
+abund_name+'.abund')
abund=strcompress(abund,/remove_all)
ioneq=string('/usr/local/ssw/packages/chianti/dbase/ioneq/'$
             +ioneq_name+'.ioneq')
ioneq=strcompress(ioneq,/remove_all)

;loops to create subfolders for density and temperature
;also run isothermal here, create structure for results of isothermal
;save spectra.sav in each folder
;spectra.sav contains a structure with all the results


FOR t_index=0,n_elements(t)-1 DO BEGIN
    FOR n_e_index=0,n_elements(n_e)-1 DO BEGIN
        ;format the foldernames for shorter names
        t_folder=string(t[t_index],format='(f3.1)')
        n_e_folder=string(n_e[n_e_index],format='(e8.2)')
        foldername=string(t_folder+'/'+n_e_folder)
        foldername=strcompress(foldername,/remove_all)
        current_folder=strcompress(string(main+'/'+parent_folder+'/'+$
                  foldername),/remove_all)
        file_mkdir,current_folder
        cd,current_folder
        isothermal,wave_min,wave_max,wave_step,10^t[t_index],lambda,spectrum,$
          list_wvl,list_ident,edensity=n_e[n_e_index],abund_name=abund,$
          ioneq_name=ioneq,/CONT,em=em,/noverbose
        spectra={wavelength:wave,intensity:spectrum,$
                 units:'photons*cm^3*sr^-1*sec^-1',abundance:abund,$
                 ionization:ioneq,date:systime(),version:'1.1',$
                em:em}
        save,spectra,filename='spectra.sav'
    ENDFOR
ENDFOR
;change back to folder where i started './SP2006'
cd,main
cd,'..'

END
