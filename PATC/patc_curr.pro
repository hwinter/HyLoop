


;+
; NAME:
;	PATC (PArticle Transport Code)
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
; CURRENT VERSION:
;    1.1
; MODIFICATION HISTORY:
; 	Written by:	Henry deG. Winter III (Trae) 04/30/2005
;       Work in progress from  04/30/2005 -09/20/2006
;       10/2006  HDWIII Changed to matrix calculations in order to
;                make the most of IDL's parallel processing 
;                capabilities.
;                
;-

pro  patc_curr,nt_particles,loop,duration, DELTA_E=DELTA_E,$
            MP=MP,OUT_BEAM=OUT_BEAM,$
            DELTA_MOMENTUM=DELTA_MOMENTUM,$
            NT_BREMS=NT_BREMS ,$ ;, DELTA_V_VECTOR=DELTA_V_VECTOR
            MAX_PHOTON=MAX_PHOTON, MIN_PHOTON=MIN_PHOTON,$
            ERR0RS=ERRORS
version=1.1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the progress meter
;progress_label='PATC progress'
;progress,0,LABEL=progress_label,/RESET,FREQUENCY=600,$
;        BIGSTEP=1, SMALLSTEP=1d-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;1 keV=1.602e-9 ergs
; converts keV to ergs
keV_2_ergs = 1.6022d-9
;Charge on an electron in statcoulombs
e=4.8032d-10
;Boltzmann's constant in ergs/[K]
k_boltz_ergs=1.3807d-16
;Electron mass in grams
e_mass_g=9.1094d-28 
;Proton mass in grams
p_mass_g=1.6726d-24 
;Electron radius in cm (classical)
e_rad=2.8179d-13
;how often to output text
freq_out=1000
ERRORS=0UL
n_elem_nt_particles=n_elements(nt_particles)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sim_time=dblarr(n_elem_nt_particles)
s_alt=get_loop_s_alt(loop)
s_alt2=s_alt[1:N_ELEMENTS(s_alt)-2]
n_volumes=N_ELEMENTS(s_alt2)
N_elements_x=n_elements(loop.s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;detect if we are using an older beam without this tag
junk = TAG_NAMES(nt_particles)
junk=where(strlowcase(temporary(junk)) eq 'position_index')
if junk[0] eq -1 then begin
    nt_particles=ADD_TAG(temporary(nt_particles),$
                           ulong(0),'position_index') 
;The following can be done with hdw_get_position_index.pro,
;  but it works just the slightest bit faster if you don't
;   call a new routine
;Position index algorithm
    particle_pos_matrix=rebin(reform(nt_particles.x,$
                                    1,n_elem_nt_particles),$
                             n_volumes,$
                             n_elem_nt_particles)

    cell_matrix=rebin(s_alt2, n_volumes,n_elem_nt_particles)
    junk2=min(particle_pos_matrix-cell_matrix,$
             position_index, dim=1,/abs)
;Change the absolute array position to an index that relates to 
; cell_s.  "I dare you to make less sense!" -Dean Venture
    nt_particles.position_index=position_index mod n_volumes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;How can this be done without the loop?
;See Above!
 ;   for k=0ul, n_elem_nt_particles-1ul do begin
 ;    
 ;      position_index_vol[k]=where(abs(nt_particles[k].x-s_alt2) eq $
 ;                           min(abs(nt_particles[k].x-s_alt2)))
 ;      nt_particles[k].position_index=position_index_vol[0]
 ;  endfor
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
new_position=ulonarr(n_elem_nt_particles)
index_array=ulindgen(n_elem_nt_particles)
delta_x=dblarr(n_elem_nt_particles)
x_new=dblarr(n_elem_nt_particles)
dummy_val=dblarr(n_elem_nt_particles)+1
delta_t=duration*(dblarr(n_elem_nt_particles)+.1)
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Settings for bremsstrahlung
if keyword_set(NT_BREMS) then begin
    if not keyword_set(MIN_PHOTON) then MIN_PHOTON=6. ;keV
    if not keyword_set(MAX_PHOTON) then MAX_PHOTON=100. ;keV
; Mean atomic number of the target plasma
;Default value given by T-H & E (1988)
    ;if not keyword_set(Z_AVG) then Z_AVG=1.4
    
    ph_energies=MIN_PHOTON+dindgen(MAX_PHOTON-MIN_PHOTON+1d)
    n_ph_e_array=n_elements(ph_energies)
    n_photons=dblarr(n_ph_e_array)
    nt_brems={ph_energies:ph_energies,$
              n_photons:n_photons}
    nt_brems=replicate(nt_brems,n_volumes )
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
;Note that the output for delta_e is in keV.
DELTA_E=dblarr(n_volumes)
delta_momentum=dblarr(n_elements_x)
;delta_v_vector=dblarr(n_volumes)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find the gradient of the magnetic field everywhere
dbdx = DERIV(loop.s, loop.b)
;plot,  loop.s,dbdx
;Spline to the volume position array
dbdx =spline(loop.s,dbdx,s_alt2)
;oplot, s_alt2, dbdx, psym=2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find the temperature of the plasma in the volume  grid cell [K]
T_plasma=get_loop_temp(loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Debye Screening length
debye_length=((k_boltz_ergs*T_plasma)/ $
              (4d*!dpi*e^2d))^0.5d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the mean free path of each cell in the loop
denominator=(sqrt(2)*loop.state.n_e[1:n_volumes] $
             *!dpi*debye_length^2d)

mean_free_path=1d/denominator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
sim_time=dblarr(n_elem_nt_particles)
counter=0l

while max(delta_t) gt  0. do begin
    good=-1   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine the alive index (a_i)
    a_i=where(nt_particles.state eq 'NT')
    if a_i[0] eq -1 then goto, end_loop
    ;help,n_elem_nt_particles  
;Don't worry about particles that have already finished their
; simulation.
    junk=where(sim_time[a_i] ge duration)
    good=where(sim_time[a_i] lt duration)
    if junk[0] ne -1 then delta_t[a_i[junk]]=0
    if good[0] ne -1 then a_i=temporary([a_i[good]]) $
    else  goto, end_loop
    junk=-1  
    good=-1   
    good_i=-1
    bad_i=-1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;How many particles are left? 
    n_elem_nt_particles=n_elements(nt_particles[a_i])
                                ;help,n_elem_nt_particles  

;Get their origininal energy           
    E_old=nt_particles[a_i].KE_total
    pos_index_old=nt_particles[a_i].position_index    
;The following can be done with hdw_get_position_index.pro,
;  but it works just the slightest bit faster if you don't
;   call a new routine
;Position index algorithm
    particle_pos_matrix=rebin(reform(nt_particles[a_i].x,$
                                    1,n_elem_nt_particles),$
                             n_volumes,$
                             n_elem_nt_particles)

    cell_matrix=rebin(s_alt2, n_volumes,n_elem_nt_particles)
    junk2=min(particle_pos_matrix-cell_matrix,$
             position_index, dim=1,/abs)
;Change the absolute array position to an index that relates to 
; cell_s.  "I dare you to make less sense!" -Dean Venture
    position_index_vol=position_index mod n_volumes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    particle_pos_matrix=rebin(reform(nt_particles[a_i].x,$
                                    1,n_elem_nt_particles),$
                              N_elements_x ,$
                              n_elem_nt_particles)

    cell_matrix=rebin(loop[0].s, N_elements_x ,n_elem_nt_particles)
    junk2=min(particle_pos_matrix-cell_matrix,$
              position_index, dim=1,/abs)

    position_index_s=position_index mod N_elements_x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
;    for k=0ul, n_elem_nt_particles-1ul do begin    
;        position_index_s[a_i[k]]=where(abs(nt_particles[a_i[k]].x-loop[0].s) eq $
;                                       min(abs(nt_particles[a_i[k]].x-loop[0].s)))
;        position_index_vol=where(abs(nt_particles[a_i[k]].x-s_alt2) eq $
;                                 min(abs(nt_particles[a_i[k]].x-s_alt2)))
;        
;    endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Impact parameter for 90 deg deflection
;  See ???? for a reference.   
       b_crit=(e^2d)/(2d*nt_particles[a_i].ke_total*keV_2_ergs )     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
       v_total=energy2vel(nt_particles[a_i].KE_total)
       cos_pa_old=cos(nt_particles[a_i].pitch_angle)
       v_parallel=cos_pa_old*v_total
       v_parallel_old=v_parallel
       v_total_old=v_total
       sign_v=sign(dummy_val[a_i],v_parallel)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine the time it would take for the particle to cross 
;  into the next cell.

;Case where a particle is in the first cell and headed out.
       junk=where(nt_particles[a_i].position_index eq 0 and sign_v lt 0)
       if junk[0] ne -1 then  new_position[a_i[junk]]=s_alt2[0]-s_alt2[1]

;Case where a particle is in the last cell and headed out.   
       junk1=where(nt_particles[a_i].position_index ge N_elements_x-2l and sign_v gt 0)
       if junk1[0] ne -1 then  new_position[a_i[junk1]]=s_alt2[N_elements_x-2L]-s_alt2[N_elements_x-3L]
       
       good_i= where(index_array[a_i] ne junk)
       if good_i[0] ne -1 then begin
           good=index_array[a_i[good_i]]
           good_i= where(good ne junk1)
           if good_i[0] ne -1 then good=good[good_i]
       endif else begin
           good_i= where(index_array[a_i] ne junk1)
           if good_i[0] ne -1 then good=index_array[a_i[good_i]]
       endelse      
       if good[0] ne -1 then $          
         new_position[a_i[good]]=s_alt2[nt_particles[a_i[good]].position_index+sign_v[good]]
       
       
       delta_t[a_i]=abs(s_alt2[nt_particles[a_i].position_index]-new_position[a_i]) $
               /abs(v_parallel)            
       good=-1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Neat notation to efficiently use memory 
       ;Assign a max delta_t
       delta_t[a_i] <=(duration) 
       ;Assign a min delta_t
       delta_t[a_i]>= 1d-7
       ;Just in case something weird happens.   
       junk=where(nt_particles[a_i].ke_total le 15d)
       if junk[0] ne -1 then  delta_t[a_i[junk]]=0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Had some trouble figuring out how to turn b_crit and the Debye
;Screening length into lengths.  But if I keep all of my units the
;same I should do alright
;Indexed to the particle
;       ln_lambda=mean(alog(debye_length[nt_particles[a_i].position_index]/b_crit))
       ;print,'ln_lambda',ln_lambda       

ln_lambda=(alog(debye_length[nt_particles[a_i].position_index]/b_crit))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The following commented out section was my initial idea for doing the 
; Calculation.  It takes way too long, and has some coding errors.
; Went for a simpler approximation instead.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the initial v vector for bremstralung calculations
;       v_vector_old=[v_total*sin(nt_particles.pitch_angle), $
;                       v_parallel_old]      
;       case 1 of 
;           denominator[nt_particles[k].position_index[0]] eq 0 : begin
;             ;print,'No Collisions'
;               N_collisions =0d
;               goto, no_collisions
;           end
;           finite(denominator[nt_particles[k].position_index[0]]) eq 0 : begin
;          ;print,'No Collisions'
;               N_collisions =0d
;               goto, no_collisions
;           end
;           else:
;       endcase
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;An assumption that delta v total is small is being made here.
;
;       n_c=((v_total*delta_t[a_i])/mean_free_path[nt_particles.position_index])
;       N_collisions =n_c+( n_c *randomn(seed,n_elem_nt_particles))
;       
;       ;print,' N_collisions', N_collisions
;       junk=where( (N_collisions mod 1) ge .5 )
;       if junk[0] ne then $
;         N_collisions = (temporary(N_collisions[0]))+1d $
;         else  N_collisions = (temporary(N_collisions[0]))
;       ;print,' N_collisions', N_collisions
;      
;       no_collisions:
;       if  N_collisions le 0d then begin
;                                ; print,'No collisions.'
;           V_PARALLEL_OLD=v_parallel
;           DELTA_V_PARALLEL_1=0
;          delta_x=v_parallel*delta_t[a_i]
;          x_new=nt_particles.x+v_parallel*delta_t[a_i]
;          goto,mirror_force
;       endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Can't account for all the collisions.  So do a 1000 of them and then
;factor in the others
; collision_factor=1d
;if N_collisions[0] gt 1000d then begin
;    collision_factor= N_collisions[0]/1000d
;    N_collisions[0]=1000d

;endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;impact parameter  randomly chosen between b_critical and the Debye
;length
;       
;       b_impact=b_crit+$
;         (debye_length[nt_particles[k].position_index[0]]-b_crit)* $
;;         randomu(seed, long(reform(N_collisions[0])));
;
;       arc_tan=atan((e^2d)/(b_impact*nt_particles.KE_total*keV_2_ergs))
;   

;       delta_energy=total((-.5d)*(nt_particles.KE_total)*((1d)-cos(arc_tan*2d))) $
;        *collision_factor
;       delta_v_parallel_1=total((-0.5d)*v_total*((1d)-cos(arc_tan*2d))) $
;         *collision_factor
;       random_1=randomn(seed)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Blatantly stolen from Emslie, 1978
       delta_energy= $
                    (((-2d)*(!dpi)*(ln_lambda)*$
                      (e^4d))/(nt_particles[a_i].KE_total*kev_2_ergs)) $
                    *((e_mass_g/p_mass_g)+1d)$
                    *(loop.state.N_e[nt_particles[a_i].position_index]) $
                    *v_total*delta_t[a_i] $
                    *(1d/kev_2_ergs)
       
       junk=where(finite(delta_energy) ne 1)
       if junk[0] ne -1 then begin
           print, 'Non finite delta_energy'
           stop
       endif 
       junk=where(delta_energy gt 0)
       if junk[0] ne -1 then begin
           print, 'Positivie Delta E',delta_energy[junk]           
       endif
       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Assign the new energy
       nt_particles[a_i].KE_total= $
         temporary(nt_particles[a_i].KE_total)+delta_energy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;How much did the parallel component of the energy change?
       delta_v_parallel_1=cos(nt_particles[a_i].pitch_angle) $
                          *(((-!dpi)*(ln_lambda)*(e^4d)) $
                            /((nt_particles[a_i].KE_total*kev_2_ergs)^2d)) $
                          *((2d)+(e_mass_g/p_mass_g)+(1d)) $
                          *(loop.state.N_e[nt_particles[a_i].position_index]) $
                          *(v_total^2d)*delta_t[a_i]
       
       junk=where(finite(delta_v_parallel_1) ne 1)
       if junk[0] ne -1 then begin
           print, 'Non finite delta_v_parallel_1'
           stop
       endif
;Energy loss was more than what we had!
;This can happen quickly in chromospheric cells.
;Note that the output for delta_e is in keV.
       junk=where(nt_particles[a_i].KE_total le 15d)
       good=where(nt_particles[a_i].KE_total gt 15d)

       if junk[0] ne -1  then begin
           bad_i=a_i[junk]
           nt_particles[bad_i].KE_total = 15.
           v_total[junk]=energy2vel(nt_particles[bad_i].KE_total)
           v_parallel[junk]=0
           nt_particles[bad_i].pitch_angle=1.5707963
           
           DELTA_E[nt_particles[bad_i].position_index]=delta_energy[junk] $
             *nt_particles[bad_i].scale_factor
           
           delta_momentum[position_index_s[bad_i]]=$
             temporary(delta_momentum[position_index_s[bad_i]]) $
             +delta_v_parallel_1[junk]*e_mass_g $
             *nt_particles[bad_i].scale_factor
           nt_particles[bad_i].state='TL'
           nt_particles[bad_i].x= $
             s_alt2[nt_particles[bad_i].position_index]
           delta_t[bad_i]=0
       endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;Note that the output for delta_e is in keV.
       if good[0] ne -1 then begin
           good_i=a_i[good]
           v_total[good]=energy2vel(nt_particles[good_i].KE_total)
           
           DELTA_E[nt_particles[good_i].position_index]= $
             temporary(DELTA_E[nt_particles[good_i].position_index]) $
             +(delta_energy[good]*nt_particles[good_i].scale_factor)
           
           delta_momentum[position_index_s[good]]=$
             temporary(delta_momentum[position_index_s[good_i]]) $
             +delta_v_parallel_1[good]*e_mass_g $
             *nt_particles[good_i].scale_factor
           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Velocity of each particle along the magnetic field line
;Fudging the geometry here.
;NEED TO REFINE LATER
           v_parallel[good]=temporary(v_parallel[good])+delta_v_parallel_1[good]
           
           nt_particles[a_i[good]].pitch_angle=acos(v_parallel[good]/v_total_old[good])
           
;       v_vector_new=[v_total*sin(nt_particles.pitch_angle), $
;                     v_parallel] 
;      delta_v_vector[nt_particles[k].position_index]=delta_v_vector[nt_particles[k].position_index] + $
                                ;        abs(total((v_vector_old-v_vector_new)* $
                                ;                  (v_vector_old-v_vector_new)))
         ;  delta_x[a_i[good]]=v_parallel_old[good]*delta_t[a_i[good]]
         ;  x_new[a_i[good]]=nt_particles[a_i[good]].x+delta_x[a_i[good]]
           
           junk=where(finite(nt_particles[a_i].pitch_angle) ne 1)
           if junk[0] ne -1 then begin
              ; print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
              ; print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
              ; print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
              ; print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
              ; print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,"Math error in PATC!!! Non-finite PA!!"
               print,"Position 1"
               print,'Particle:'+string(a_i[junk])
               print, 'Was in cell:'+string(pos_index_old[[junk]])
               help, nt_particles[a_i[junk]],/str
               help, v_parallel,v_total
               print,'(v_parallel)/v_total)='+string((v_parallel[junk])/v_total[junk])
               ;                 v_parallel[junk]=v_total[junk]*sign(dummy_val[junk], v_parallel[junk])
               nt_particles[a_i[junk]].pitch_angle=acos((v_parallel[junk])/v_total[junk])
               nt_particles[a_i[junk]].pitch_angle=1.5707963
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               ERRORS+=n_elements(junk)

;stop
           ;help
           ;wait,10*60
           endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Mirror_force     See Bai, 1982, and Benz,1993
           delta_v_parallel_2=-1d* $
                              (nt_particles[good_i].ke_total) $
                              *(sin(nt_particles[good_i].pitch_angle)^2d) $
                              * keV_2_ergs *(1d/e_mass_g)  $
                              *((1d)-(cos(nt_particles[good_i].pitch_angle))^2d) $
                              *(dbdx[pos_index_old[good_i]]/loop.b[pos_index_old[good_i]]) $
                              *delta_t[good_i]
           
;Mirror_force is currently in ergs/cm
           v_parallel[good]=(v_parallel_old[good] $
                             +delta_v_parallel_1[good] $
                             +delta_v_parallel_2)
           nt_particles[good_i].pitch_angle=acos((v_parallel[good])/v_total[good])
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Compute new particle position      
           nt_particles[good_i].x= $
             temporary(nt_particles[good_i].x)+ $
             (0.5d*(v_parallel_old[good_i]+v_parallel[good])*(delta_t[good_i]))
           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Position index algorithm
           particle_pos_matrix=rebin(reform(nt_particles[a_i].x,$
                                            1,n_elem_nt_particles),$
                                     n_volumes,$
                                     n_elem_nt_particles)
           
           cell_matrix=rebin(s_alt2, n_volumes,n_elem_nt_particles)
           junk2=min(particle_pos_matrix-cell_matrix,$
                     position_index, dim=1,/abs)
           nt_particles[a_i].position_index=position_index mod n_volumes
;           for k=0ul, n_elem_nt_particles-1ul do begin
;               pos_index_old[k]=where(abs(nt_particles[a_i[k]].x-s_alt2) $
;                                         eq min(abs(nt_particles[a_i[k]].x-s_alt2)))
;           endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
           junk=where(finite(nt_particles[a_i].pitch_angle) ne 1)
           if junk[0] ne -1 then begin
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,"Math error in PATC!!! Non-finite PA!!"
               print,'Particle:'+string(a_i[junk])
               print, 'Was in cell:'+string(pos_index_old[junk])
               print, 'Now in cell:'+string(nt_particles[a_i[junk]].position_index)
               help, nt_particles[a_i[junk]],/str
               print,'(v_parallel)/v_total)='+string((v_parallel[junk])/v_total[junk])
               ;if max(v_parallel[junk]/v_total[junk]) gt 1.4 then stop
               v_parallel[junk]=v_total[junk]*sign(dummy_val[junk], v_parallel[junk])
               nt_particles[a_i[junk]].pitch_angle=acos((v_parallel[junk])/v_total[junk])
                                ;nt_particles[a_i[junk]].pitch_angle=1.5707963
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
               ERRORS+=n_elements(junk)
               
               
           
                                ;help
                                ;wait,10*60
           endif
           
           nt_particles[good_i].ALIVE_TIME=sim_time[good_i] $
             +delta_t[good_i]
       endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
thermalized_condition:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check to see if the 
;Note that the output for delta_e is in keV.
       
            
       junk=where(nt_particles[a_i].ke_total le 15d)
       if junk[0] ne -1 then begin
           nt_particles[a_i[junk]].state='TL'
           ;sim_time[a_i][junk]=duration
           delta_t[a_i[junk]]=0.
       endif

      junk=where(nt_particles[a_i].x ge max(s_alt2))
      if junk[0] ne -1 then begin
          index3_end=n_volumes-1ul
          n_d=50l
          index3_start=(n_volumes-1ul)-n_d-1l
          nt_particles[a_i[junk]].state='RF'
          delta_e[index3_start:index3_end]=delta_e[index3_start:index3_end] $
                          +total((nt_particles[a_i[junk]].ke_total-15d) $
                             *nt_particles[a_i[junk]].scale_factor/N_d)
          nt_particles[junk].ke_total=15d
          ;sim_time[a_i][junk]=duration
                                ; delta_v_vector[index3]=$
                                ;  delta_v_vector[index3]+v_total*v_total
          nt_particles[a_i[junk]].x=s_alt2[index3_end]
           delta_t[a_i[junk]]=0.
      endif

      junk=where(nt_particles[a_i].x le min(s_alt2))
      if junk[0] ne -1 then begin
          n_d=50l
          index3_end=n_d-1ul
          index3_start=0
               nt_particles[a_i[junk]].state='LF'
               delta_e[index3_start:index3_end]=delta_e[index3_start:index3_end] $
                              +total((nt_particles[a_i[junk]].ke_total-15d )$
                               *nt_particles[a_i[junk]].scale_factor/n_d)
               nt_particles[a_i[junk]].ke_total=15d
               ;sim_time[a_i][junk]=duration
               
           ;    delta_v_vector[index3]=$
           ;    delta_v_vector[index3]+v_total*v_total
                nt_particles[a_i[junk]].x=s_alt2[index3_start]
                delta_t[a_i[junk]]=0.
            endif

            nt_particles[a_i].alive_time=nt_particles[a_i].alive_time+delta_t[a_i]
           
            E_new=nt_particles[a_i].KE_total
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Settings for bremsstrahlung
            
       if keyword_set(NT_BREMS) then begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Compute the addition to bremsstralung radiation     
;      for bi=0l, n_ph_e_array-1l do begin
;Calculate the crosssections
           for jjj=0, n_elements(a_i)-1ul do begin
               Brm_BremCross,E_old[jjj],$
                             nt_brems[position_index_vol[jjj]].ph_energies, $
                             !msul_charge_z, cross_1 
               Brm_BremCross,E_new[jjj],$
                             nt_brems[position_index_vol[jjj]].ph_energies, $
                             !msul_charge_z, cross_2
;Calculate the number of photons produced
               nt_brems[position_index_vol[jjj]].n_photons=$
                 delta_t*loop.state.n_e[position_index_vol[jjj]]* $
                 abs(v_total*cross_2-v_total_old*cross_1)* $
                 nt_particles[a_i[jjj]].scale_factor
           endfor
 ;      endfor
      endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;           
;      endfor         
elect_loop_end:
 ;      endfor                   ;iloop for time
       
       
       junk=where(nt_particles.state ne 'NT')
       if junk[0] ne -1 then delta_t[junk]=0.
       junk=where(nt_particles[a_i].state eq 'NT')
       if junk[0] eq -1 then goto, end_loop
       
       sim_time[a_i]=temporary(sim_time[a_i]) +delta_t[a_i]
       junk=where(sim_time[a_i] ge duration)
       if junk[0] ne -1 then delta_t[a_i[junk]]=0
       counter=counter+1l
       delta_v_parallel_2[*]=0
       v_parallel=0
       ;print, 'min/max sim time: ',min(sim_time),'/',max(sim_time)
       ;print, 'min(sim_time[a_i])/duration', min(sim_time)/duration
       ;print, 'max(delta_t[a_i])',max(delta_t[a_i])
   endwhile


;    progress,j/n_elem_nt_particles,LABEL=progress_label,FREQUENCY=600.,$
;        BIGSTEP=1, SMALLSTEP=1d-2
    ;print,j
;endfor; j loop for particles
end_loop:
     ; print, 'min(sim_time[a_i])/duration', min(sim_time[a_i])/duration
     ; print, 'max(delta_t[a_i])',max(delta_t[a_i])
;progress,j/n_elem_nt_particles,LABEL=progress_label,/LAST
;if keyword_set(NT_BREMS) then NT_BREMS=NT_BREMS_struct
OUT_BEAM=NT_PARTICLES
END; Of MAIN patc

