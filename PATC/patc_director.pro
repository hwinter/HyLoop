;+
; NAME:
;	PATC (PArticle Transport Code)
;This codes sends the particles to the most efficient code to handle it.
;
; PURPOSE:
;	To track a system of non-thermal particles in a magnetic field
;	and record changes due to collsions and non-uniform magnetic fields 
;
; CATEGORY:
;	Simulation.  Flare studies
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
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
;	DELTA_E: Change in particle energy as a function of volume (N_v-2) position.  
;                [keV]
;       N_E_CHANGE: Change in local particle density as a function of volume (N_v-2) position.  
;                [n cm^-3]
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
;	
;
; CURRENT VERSION:
;    1.0
; MODIFICATION HISTORY:
; 	Written by:	Henry deG. Winter III (Trae) 04/30/2005
;                  2008-JUN-03 Added the N_E_CHANGE keyword to make the codes
;                              self consistent
;                
;-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro  patc ,nt_particles,loop,duration, DELTA_E=DELTA_E,$
           MP=MP,bmp=bmp,OUT_BEAM=OUT_BEAM,$
           DELTA_MOMENTUM=DELTA_MOMENTUM,$
           MIN_PHOTON=MIN_PHOTON, MAX_PHOTON=MAX_PHOTON,$
           Z_AVG=Z_AVG,$
           NT_BREMS=NT_BREMS, $
           N_E_CHANGE=N_E_CHANGE, $
           E_H=E_H  , $
           NO_BREMS=NO_BREMS                


if n_elements(nt_particles) le 0.5d4 then $
   patc_matrix ,nt_particles,loop,duration, DELTA_E=DELTA_E,$
           MP=MP,bmp=bmp,OUT_BEAM=OUT_BEAM,$
           DELTA_MOMENTUM=DELTA_MOMENTUM,$
           MIN_PHOTON=MIN_PHOTON, MAX_PHOTON=MAX_PHOTON,$
           Z_AVG=Z_AVG,$
           NT_BREMS=NT_BREMS, $
           N_E_CHANGE=N_E_CHANGE, $
           E_H=E_H  , $
           NO_BREMS=NO_BREMS $
else $
    patc_for_loop ,nt_particles,loop,duration, DELTA_E=DELTA_E,$
           MP=MP,bmp=bmp,OUT_BEAM=OUT_BEAM,$
           DELTA_MOMENTUM=DELTA_MOMENTUM,$
           MIN_PHOTON=MIN_PHOTON, MAX_PHOTON=MAX_PHOTON,$
           Z_AVG=Z_AVG,$
           NT_BREMS=NT_BREMS, $
           N_E_CHANGE=N_E_CHANGE, $
           E_H=E_H  , $
           NO_BREMS=NO_BREMS 



END; Of MAIN patc

