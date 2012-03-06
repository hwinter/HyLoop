;+
; NAME:
;	mk_nt_p_struct
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
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	Must have a current version of SSW
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
;       2006_JUL_21 HDWIII Major modifications from mk_nt_beam in order
;       to make a more flexible tool.
;    2006-SEP-15  HDW III Replaced many double variable with floats when I could.
;                 I find that I'm often running out of memory space during the simulations 
;                 with an adequate number of particles.  Oh, bother...
;-
function mk_nt_p_struct, length, height, b, $
  N_PART=N_PART, IP=IP, $
  E_0=E_0,  Z=Z, $
  PITCH_ANGLE=PITCH_ANGLE,MASS=MASS,$
  PROT=PROT,ELECTS=ELECTS, $
  SCALE_FACTOR=SCALE_FACTOR, $
  ALPHA=ALPHA, BETA=BETA,grr=grr
version=1.2
COMPILE_OPT  STRICTARR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Charge on an electron in statcoulombs
e=4.8032d-10 
;Electron mass in grams
e_mass_g=9.1094d-28 
;Proton mass in grams
p_mass_g=1.6726d-24 
MASS=e_mass_g
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Default # particles =1000
IF( NOT keyword_set(N_PART)) THEN  N_PART = 100UL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Default average particle energy=30 keV
IF(NOT keyword_set(E_0)) THEN E_0=25d $
  else E_0=double(E_0)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define a constant pitch angle cosine. 
IF NOT keyword_set(PITCH_ANGLE) THEN begin
    if N_PART eq 1 then PITCH_ANGLE=!DPI/2d 
    if N_PART ne 1 then  begin
       ; print, 'Making Distribution'
        PITCH_ANGLE=mk_distro(N_PARTICLES=N_PART,$
                              MIN_MAX=[0,!DPI],/SIN,$
                             ALPHA=ALPHA, BETA=BETA,grr=1)
        N_PART=n_elements(PITCH_ANGLE)
        ;plot_histo, PITCH_ANGLE, title='mk_nt_p_struct', steps, histo
        ;if n_elements(histo) le 1 then stop
    endif

endif ;else PITCH_ANGLE=PITCH_ANGLE+dblarr(N_PART); & print,"Setting PA"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define a charge per e.  Default to an electron  charge
IF(NOT keyword_set(Z)) THEN charge=-1d*e else charge=double(z)*e
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define a MASS
IF(NOT keyword_set(MASS)) THEN MASS=e_mass_g
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Proton beam
IF( keyword_set(PROT)) THEN MASS=p_mass_g & charge=e

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Electron beam
IF( keyword_set(elects)) THEN MASS=e_mass_g & Charge=-1d*e
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;How many particles is this one standing in for???
IF(not  keyword_set(scale_factor)) THEN scale_factor=1d

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
         scale_factor:double(scale_factor),$
         position_index:ulong(0),$
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

nt_beam[*].PITCH_ANGLE=PITCH_ANGLE
nt_beam[*].mass=mass
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;If the IP is set to 'z' make it loop top.
;If the IP is not set then put it where the 
;magnetic field is the weakest
if(not keyword_set(IP)) then ip = 'z'
if IP eq 'z' then begin
   position_index1 = where(max(height) eq height)
   if n_elements(position_index1) gt 1 then $
     ii=long(n_elements(position_index1)/2) else $
     ii=0
   position_index2 =  where(min(b) eq b)
   if n_elements(position_index2) gt 1 then $
     jj=long(n_elements(position_index2)/2) else $
     jj=0
   index=where(randomn(seed, N_PART) ge 0,COMPLEMENT=other)
   position_index=ulonarr(n_part)
   if index[0] ne -1 then  position_index[index]=position_index1[ii]
   if other[0] ne -1 then  position_index[other]=position_index2[jj]
   
endif  else $
  position_index = IP
  ;position_index =  where(min(b) eq b)
 
nt_beam.x=length[position_index]
nt_beam.position_index=position_index
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;I decided that I was getting behind while sweating the details.
;I decided to just use a constant as the kinetic energies for the
;particles.  I'll do something more realistic later.
if n_elements(e_0) gt 1 then $
  nt_beam[*].ke_total=E_0[0:n_part-1ul] else $
  nt_beam[*].ke_total=E_0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Initial magnetic moment
;Using the definition of  magnetic moment from Benz and some algebra
nt_beam.mag_moment=((sin(nt_beam.pitch_angle)^2d)*nt_beam.ke_total)/ $
  b[position_index[0]]

   
return, nt_beam
end
