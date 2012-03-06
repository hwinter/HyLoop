FUNCTION GET_SPECTRA,abund,ib,t,n_e

;+
; NAME:  get_spectra.pro
;	
;
; PURPOSE:  to retrieve intensity and wavelength arrays of spectra
; corresponding to certain abundances, ionization balances,
; temperatures and electron densities
;	
;
; CATEGORY:
;	
;
; CALLING SEQUENCE:
;	
;
; INPUTS: abundance - string, ionization balance - string
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	
;
; OPTIONAL OUTPUTS:
;	
;
; COMMON BLOCKS:
;	
;
; SIDE EFFECTS:
;	
;
; RESTRICTIONS:
;	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	result=get_spectra('mazzotta_etal_ext','sun_coronal_ext',4.8,5d9)
;
; MODIFICATION HISTORY:
; 	Written by: Jenna Rettenmayer, 18 Jan 2006, Version 1.0	
;-


;cd,'SPECTRA'
;Need to make this a global variable
spec_folder='/disk/hl2/data/winter/data2/jenna/SP2006/SPECTRA/'
;get folder name and change to that folder
t_folder=string(t,format='(f3.1)')
n_e_folder=string(n_e,format='(e8.2)')
;print,n_e_folder
;pause
folder=string(spec_folder+abund+'/'+ib+'/'+t_folder+'/'+n_e_folder)
;cd,folder
    
;restore file that contains structure
restore,strcompress(folder'spectra.sav',/remove_all)
;n=n_elements(spectra.wavelength)
;m=n_elements(spectra.intensity)
;spectrum=make_array(n,2,value=-1)
;spectrum[*,0]=spectra.wavelength
;spectrum[*,1]=spectra.intensity[0:m-2]

return,spectra


END
