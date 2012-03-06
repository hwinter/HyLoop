;+
; NAME:
;	mk_nt_beam
;
; PURPOSE:
;    To return structure containing initialv elocity, position
;    on loop, and mu for a non-thermal particle beam
;
; CATEGORY:
;	
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
;        IP: Initial position of particle along the loop length
;        N_PART: # particles
;	
;
; OUTPUTS:
;	A struture 
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
;	
;
; MODIFICATION HISTORY:
; 	Written by: Henry deg. Winter III (Trae) 04/28/2005
;          Some elements borrowed for Elizabeth Noonan's initial.pro	
;-
function mk_nt_beam, length, height, b, N_PART=N_PART, IP=IP, $
                    E_0=E_0,E_MAX=E_MAX, SPEC_INDEX=SPEC_INDEX, $
                    PITCH_ANGLE=PITCH_ANGLE,MASS=MASS, Z=Z, $
                    PROT=PROT,ELECTS=ELECTS, $
                    SCALE_FACTOR=SCALE_FACTOR

version=1.2
old_except=!except
!except=2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;Proton mass in grams
p_mass_g=1.6726d-24 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Default # particles =1000
IF( NOT keyword_set(N_PART)) THEN  N_PART = 1000L
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Default average particle energy=30 keV
IF(NOT keyword_set(E_0)) THEN E_0=25d $
  else E_0=double(E_0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Default spectral index=3
IF(NOT keyword_set(SPEC_INDEX)) THEN SPEC_INDEX=3d $
  else SPEC_INDEX=double(SPEC_INDEX)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define a constant pitch angle cosine. 
IF NOT keyword_set(PITCH_ANGLE) THEN begin
    PITCH_ANGLE=1
  PITCH_ANGLE=mk_distro(N_PARTICLES=N_PART, MIN_MAX=[0,!DPI])
  N_PART=n_elements(PITCH_ANGLE)
endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define a charge per e.  Default to an electron  charge
IF(NOT keyword_set(Z)) THEN charge=-1d*!msul_qe else $
  charge=double(z)*!msul_qe
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define a MASS
IF(NOT keyword_set(MASS)) THEN MASS=!msul_me
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Proton beam
IF( keyword_set(PROT)) THEN MASS=!msul_mp & charge=!msul_qe

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Electron beam
IF( keyword_set(elects)) THEN MASS=!msul_me & Charge=-1d*!msul_qe
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;How many particles is this one standing in for???
IF(not  keyword_set(scale_factor)) THEN scale_factor=1d0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the structure for an electron test particle
nt_beam={ke_total:double(0),$
         mass:double(0),$
         PITCH_ANGLE:double(0),$
         x:double(0),$
         charge:charge,$
         alive_time:double(0),$
         state:'NT',$
         mag_moment:double(0),$
         scale_factor:scale_factor,$
         description:strarr(11),$
         version:version}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Provide a descrition of the different tag values
nt_beam.description[0]='ke_total: Total Kinetic Energy [keV]'
nt_beam.description[1]='mass: Particle mass in grams'
nt_beam.description[2]='pitch_angle:Current Pitch angle of particle [] '
nt_beam.description[3]='x; Current position along the loop [cm]'
nt_beam.description[4]=$
  'z: Charge per unit e. Not to be confused with the coordinate'
nt_beam.description[5]='alive_time: Time since injection that the'+ $
         'particle remains non-thermal [seconds]'
nt_beam.description[6]='state: NT:Non-Thermal, TL:Thermalized in loop,'+ $
         'RF: thick target in right foot point, LF: T.T. in left foot point '
nt_beam.description[7]='mag_moment: Magnetic moment of particle'
nt_beam.description[8]=$
  'scale_factor: How many partiles is this test particle standing in for'
nt_beam.description[9]='description:A description of each structure tag'
nt_beam.description[10]='VersionCurrent version of mk_p_beam being used'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Makin' copies
nt_beam=replicate(temporary(nt_beam),N_PART)

nt_beam.PITCH_ANGLE=PITCH_ANGLE
nt_beam[*].mass=mass
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;If the IP is set to 'z' make it loop top.
;If the IP is not set then put it where the 
;magnetic field is the weakest
if(not keyword_set(IP)) then ip = 'z'
if IP eq 'z' then $
   position_index = where(max(height) eq height) $
 else $
  position_index = IP
  ;position_index =  where(min(b) eq b)
 
nt_beam.x=length[position_index[0]]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;I decided that I was getting behind while sweating the details.
;I decided to just use a constant as the kinetic energies for the
;particles.  I'll do something more realistic later.
nt_beam[*].ke_total=E_0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Initial magnetic moment
;Using the definition of  magnetic moment from Benz and some algebra
nt_beam.mag_moment=((sin(nt_beam.pitch_angle)^2d)*nt_beam.ke_total)/ $
  b[position_index[0]]


!except=old_except
return, nt_beam
end
