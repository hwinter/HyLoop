;+
; NAME:
;	beam_generator
;
; PURPOSE:
;	
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
;	IP: Injection point.  If set to 'Z' then the particles will be 
;              injected at the loop apex.  Otheriwise this is the index
;              corresponding to the s_alt position of particle injection
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
; RESTRICTIONS:	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by: Henry deg. Winter III (Trae) 2006_JUL_19
;    2006-SEP-15  HDW III Replaced many double variable with floats when I could.
;                 I find that I'm often running out of memory space during the simulations 
;                 with an adequate number of particles.  Oh, bother...
;-



function beam_generator, loop,min_max, TOTAL_ENERGY=TOTAL_ENERGY, $
  SPEC_INDEX=SPEC_INDEX, N_BINS=N_BINS, N_PART=N_PART,$
  N_BEAMS=N_BEAMS,IP=IP,T_PROFILE=T_PROFILE,$
  PROT=PROT,ELECTS=ELECTS,SAVE_FILE=SAVE_FILE, $
  E_RES=E_RES, TIME=TIME, DELTA_T=DELTA_T,$
  ALPHA=ALPHA, RAndom=random, FRACTION_PART=FRACTION_PART
;Random is now defunct.

sheet_width=(loop.l*.01)
version=2.0
compile_opt strictarr
if n_elements(min_max) ne 2 then begin
    box_message, ['Error in beam_generator.pro',$
                  'min_max must be a two element array',$
                  'containing the minumum and maximum',$
                  'non-thermal particle energy']
    nt_beam=-1
    goto, end_jump
endif

n_loop=n_elements(loop)

if n_elements(min_max) ne 2 then begin
    box_message, ['Error in beam_generator.pro',$
                  'Loop must be a HyLoop loop structure.']
    nt_beam=-1
    goto, end_jump
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;If not already defined, define important quantities
if size(TOTAL_ENERGY, /TYPE) eq 0  then TOTAL_ENERGY=1d+30;ergs
if size(SPEC_INDEX, /TYPE) eq 0 then SPEC_INDEX=3d
if not keyword_set(N_PART) THEN N_PART= 50UL
if not keyword_set(IP) THEN IP='z'
if not keyword_set(RANDOM) THEN RANDOM=1
if not keyword_set(ALPHA) THEN ALPHA=0.
if not keyword_set(charge) then charge=!shrec_qe
if not keyword_set(MASS) then MASS=!shrec_me
if  size(FRACTION_PART, /TYPE) eq 0 then FRACTION_PART=.5D0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Particle_energy=TOTAL_ENERGY*FRACTION_PART
;Set the resolution and number of energy bins
case 1  of 
    ((keyword_set(E_RES) lt 1) and $
    (keyword_set(N_BINS) lt 1)): begin
        E_RES=5d               ;keV
        n_bins=(min_max[1]-min_max[0])/E_RES
    end
    
    ((keyword_set(E_RES) gt 0) and $
      (keyword_set(N_BINS) lt 1)): begin
        n_bins=(min_max[1]-min_max[0])/E_RES
    end
    ((keyword_set(E_RES) lt 1) and $
     (keyword_set(N_BINS) gt 0)): begin
       E_RES=(min_max[1]-min_max[0])/N_BINS
   end
   else:  begin
       box_message, ['Error in beam_generator.pro',$
                       'bins case statement'] 
       stop
   endelse

    endcase
n_bins=ULONG(n_bins)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;How long does the beam last?
duration=max(time)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine the time step
case 1  of 
    ((keyword_set(DELTA_T) lt 1) and $
    (keyword_set(N_BEAMS) lt 1)): begin
        ;print, 'Case1a'
        DELTA_TIME=TIME       ;seconds
        N_BEAMS=1
    end
    ((keyword_set(DELTA_T) gt 0) and $
      (keyword_set(N_BEAMS) lt 1)): begin
        ;print, 'Case2a'
        N_BEAMS=ulong(duration/DELTA_T)
    end
    ((keyword_set(DELTA_T) lt 1) and $
     (keyword_set(N_BEAMS) gt 0)): begin
        ;print, 'Case3a'
        DELTA_T=duration/N_BEAMS
 end
   else:  box_message, ['Error in beam_generator.pro',$
                       'DELTA_T case statement']
endcase;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine the time profile
case 1  of 
    ((keyword_set(TIME) lt 1) and $
    (keyword_set(T_PROFILE) lt 1)): begin
        TIME=1D       ;seconds
        T_PROFILE=(1/N_BEAMS)+dblarr(N_BEAMS)
        ;print, 'Case1b'
    end
    
    ((keyword_set(TIME) gt 0) and $
      size(T_PROFILE, /TYPE)  EQ 0): begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

       T_PROFILE=(1d/N_BEAMS)+dblarr((N_BEAMS))
        ;print, 'Case2b'
    end
    ((keyword_set(TIME) lt 1) and $
     (keyword_set(T_PROFILE) gt 0)): begin
      time=dindgen(n_elements(T_PROFILE))
  end
   (SIZE(T_PROFILE, /TYPE) EQ 7 and  strlowcase(T_PROFILE) eq 'gaussian'): begin
       range=-3.+6.0*dindgen(n_beams)/(n_beams-1)
       T_PROFILE=exp(-1.0*range^2)
       T_PROFILE=T_PROFILE/total(T_PROFILE)
 ;      HELP, N_BEAMS
       ;print, 'Case3b'
       end
   else:    begin
       box_message, ['Error in beam_generator.pro',$
                       'time case statement']
       stop
   end

endcase
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


if n_elements(time) ne N_BEAMS then begin
  time=reverse(duration*((1d)-(dindgen(N_BEAMS)/(N_BEAMS-1d))))
  ;t_profile=temporary(t_profile[0])+dblarr(N_BEAMS)/N_BEAMS
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;Old way to do it.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the particle energies based on the above
;energies=min_max[0]+$
;         ((min_max[1]-min_max[0])*dindgen(N_BINS)/(N_BINS-1ul))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;f=A(E/E_0)^(-delta)
;E_0=min(energies)
;percent=double((energies/E_0)^(-SPEC_INDEX)) 
;percent=percent/total(percent)
;distribution=exp(-1.*SPEC_INDEX $
;                  *(energies-min_max[0])/(min_max[1]-(min_max[0])))
;distribution=N_PART  $
;             *(distribution)/total((distribution))
;window,0
;plot, energies, distribution, title='Energy p(x)'  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;End old way. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;energies=-1d0*alog(randomu(seed, n_part))* $
;              (1./SPEC_INDEX)*(min_max[1]-(min_max[0]))+min_max[0]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delta_e=min_max[1]-min_max[0]
one_minus_delta=1d0-SPEC_INDEX
;window,15, title='Beam gen PA'
;plot_histo, pitch_angle
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
energy_per_beam=(TOTAL_ENERGY)*t_profile


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inject_point=where(loop.axis[2, *] eq max(loop.axis[2, *]))

n_i_points=n_elements(inject_point)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a structure for each time step.
for i=0ul, N_BEAMS-1ul do begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the energy arrays
    A_0=one_minus_delta/((min_max[1]^(one_minus_delta))-(min_max[0]^(one_minus_delta)))
    
    energies=abs(randomu(seed,N_PART)*(one_minus_delta/A_0) )^(1d0/one_minus_delta)
    if min(energies) lt min_max[0] then $
      MIN_E=(min(energies)-min_max[0]) else $
      MIN_E=0
    energies=energies-MIN_E
    done=0

    while not done do begin
        junk=where(energies gt min_max[1])
        if junk[0] eq -1 then done =1 else begin
            n_junk=n_elements(junk)
            energies[junk]=abs(randomu(seed,n_junk)*(one_minus_delta/A_0) )^(1d0/one_minus_delta)
        endelse
    endwhile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;help, alpha
    dist=mk_distro6(ALPHA, N_PART=N_PART)
    pitch_angle=acos(dist)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the structure for an electron test particle
    nt_beam={ke_total:double(0),$
             mass:double(0),$
             PITCH_ANGLE:double(0),$
             x:double(0),$
             charge:charge ,$
             alive_time:double(0),$
             state:'NT',$
             mag_moment:double(0),$
             scale_factor:double(1),$
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

    nt_beam.PITCH_ANGLE=PITCH_ANGLE
    nt_beam.mass=mass
    nt_beam.ke_total=energies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
   ; if n_i_points eq 1 then nt_beam.x=loop.s[inject_point[0]] else begin
   ;     random=long(randomu(seed, n_elements(nt_beam)*n_i_point))
   ;     random <= n_i_points-1l
   ;     nt_beam.x=loop.s[n_i_points[random]]
   ; endelse
nt_beam.x=(loop.l/2.0)+sheet_width*randomn(seed, N_PART)

    ;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;We defined a total energy for a flare.  The next three lines define a
;scale factor so that we acheive that energy.
    nt_beam.scale_factor= $
                         (FRACTION_PART*energy_per_beam[i]/!shrec_keV_2_ergs)$
                         / total(nt_beam.ke_total)
;stop
    if n_elements(nt_beam) eq 0 then nt_beam=nt_beam_temp $
    else nt_beam=concat_struct(temporary(nt_beam),nt_beam_temp)


    temp_beam_struct={nt_beam:nt_beam,TIME:TIME[i],$
                      t_profile: t_profile[i] ,$
                      thermal_E:(1.0-FRACTION_PART)*energy_per_beam[i] }
    
    delvarx, nt_beam
        
    if n_elements(beam_struct) eq 0ul then $
      beam_struct=temp_beam_struct $
      else $
      beam_struct=concat_struct(temporary(beam_struct), $
                                      temp_beam_struct)

endfor

;Change for generallity
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Test to make sure we have the proper flare energy
t_ke=total(beam_struct.nt_beam.ke_total* $
         beam_struct.nt_beam.scale_factor*!shrec_keV_2_ergs)
;print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
;help,t_ke
if  t_ke ne total_energy then begin
    re_scale=(total_energy*FRACTION_PART)/t_ke
    beam_struct[*].nt_beam[*].scale_factor= $
      beam_struct[*].nt_beam[*].scale_factor*re_scale
endif


;print, re_scale

t_ke=total(beam_struct.nt_beam.ke_total* $
         beam_struct.nt_beam.scale_factor*!shrec_keV_2_ergs)
;print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
;help,t_ke
;te_total=t_ke+total(beam_struct.thermal_e)
;help, te_total
;help, beam_struct
;print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'            
;stop
IF keyword_set(SAVE_FILE) then begin
    if size(SAVE_FILE,/TYPE) ne 7 then $
      SAVE_FILE='initial_beam_stuct.sav'
    save,beam_struct , file=SAVE_FILE
endif


    

end_jump:
t_ke=total(beam_struct.nt_beam.ke_total* $
         beam_struct.nt_beam.scale_factor*!shrec_keV_2_ergs)
;print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
;help,t_ke
;help, beam_struct
;print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;' 
;stop
return , beam_struct
END
