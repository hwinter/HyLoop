;+
; NAME:
;	PATC (PArticle Transport Code) patc_matrix.pro
;
;       Matrix version of PATC.  Based on patc_pp4.pro
;
; PURPOSE:
;	To track a system of non-thermal particles in a magnetic field
;	and record changes due to collsions and non-uniform magnetic
;	fields.  This version uses matrix operations to speed up
;	processing time. 
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
; OUTPUT:S
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
;	Can't work with more than 1d5 particles.
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
;                  2009-SEP-16 HDWIII Vectorized version
;                
;-

function derivs1, t , v_parallel
common beam, a, b
dvdt=-0.5*$
     ((a-abs(v_parallel))^2d0)/b
return, dvdt
end


function derivs2, t , e_n_vp
;See my notes from Jan 18, 2008 for derivation and 
;  Deviation from   Emslie, 1978
common beam2, a, b,dens, m, c,dl

out=patc_de_dt_pp( t , e_n_vp, dl, dens,m,c,a,b)

;stop
return, out

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro  patc_matrix ,nt_particles,loop,duration, DELTA_E=DELTA_E,$
           MP=MP,bmp=bmp,OUT_BEAM=OUT_BEAM,$
           DELTA_MOMENTUM=DELTA_MOMENTUM,$
           MIN_PHOTON=MIN_PHOTON, MAX_PHOTON=MAX_PHOTON,$
           Z_AVG=Z_AVG,$
           NT_BREMS=NT_BREMS, $
           N_E_CHANGE=N_E_CHANGE, $
           E_H=E_H  , $
           NO_BREMS=NO_BREMS                   ;, DELTA_V_VECTOR=DELTA_V_VECTOR

common beam, v_total, cls_b
common beam2,a_c, b_c, density, mass, charge, d_length
;gpuinit
version=1.0
;ssw_packages,/xray
energy_floor=1d0
!except=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;how often to output text
;freq_out=1000
n_elem_nt_particles=n_elements(nt_particles)
;s_alt=get_loop_s_alt(loop,/gt0)
N_elements_x=n_elements(loop.s)
s_alt2=loop.s_alt[1:N_ELEMENTS(loop.s_alt)-2]
volumes=get_loop_vol(loop)
n_volumes=N_elements_x-1ul
N_E_CHANGE=dblarr(n_volumes)
n_e=ptr_new(loop.state.n_e)
;Conversion factor for energy removed from the particles in KE
;  to the energy input to the plas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
z_avg= !msul_charge_z
;Settings for bremsstrahlung
;if not  keyword_set(NT_BREMS) then begin
 ;   if not keyword_set(MIN_PHOTON) then MIN_PHOTON=1. ;keV
 ;   if not keyword_set(MAX_PHOTON) then MAX_PHOTON=100. ;keV
; Mean atomic number of the target plasma
;Default value given by T-H & E (1988)
;    if not keyword_set(Z_AVG) then Z_AVG=1.4
    
;    ph_energies=MIN_PHOTON+dindgen(MAX_PHOTON-MIN_PHOTON+1d)
;    n_ph_e_array=n_elements(ph_energies)

    nt_brems={ph_energies:!ph_energies,$
              n_photons:dblarr(!n_ph_energies)}
    nt_brems=replicate(nt_brems,n_volumes)
;endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Note that the output for delta_e is in keV.
DELTA_E=dblarr(n_volumes)
delta_momentum=dblarr(n_elements_x)
;delta_v_vector=dblarr(n_volumes)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
if keyword_set(MP) then begin
    MP=-1+lonarr(n_elem_nt_particles)
    BMP=-1d0+dblarr(n_elem_nt_particles)
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find the gradient of the magnetic field everywhere
cls_b_over=(DERIV(loop.s, loop.b)/loop.b)^(-1)
junk_b=where(finite(cls_b_over) ne 1)
if junk_b[0] ne -1 then cls_b_over[junk_b]=1d30
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find the temperature of the plasma in the volume  grid cell [K]
T_plasma=get_loop_temp(loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Debye Screening length
;Different than Choudhuri and Benz but about the same as 
;  The NRL plasma formulary
debye_length=6.9010323*((T_plasma)/ $
              (*n_e))^0.5d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Spacing of grid cells
ds=get_loop_ds(loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
sim_time=dblarr(n_elem_nt_particles)
alive_mask=ulonarr(n_elem_nt_particles)+1
nt_particles_orignal=nt_particles


while min(sim_time) lt  duration do begin
       alive_index=where(nt_particles_orignal.state eq 'NT',Complement=dead_index)
       if dead_index[0] ne -1 then begin
          alive_mask[dead_index]=0
          sim_time[dead_index]=duration
       endif
       
       alive_index=where(sim_time lt duration ,Complement=dead_index)
       if dead_index[0] ne -1 then alive_mask[dead_index]=0

       
       alive_index=where(alive_mask eq 1,n_elem_nt_particles )
       if alive_index[0] ne -1 then $
          
          nt_part_ptr=ptr_new(nt_particles_orignal[alive_index]) $
       else  goto, end_loop
       
;Unit vector
Unit_vector=dblarr(n_elem_nt_particles)+1.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       position_index_vol=hdw_get_position_index((*nt_part_ptr).x,s_alt2 )
       position_index_s=hdw_get_position_index((*nt_part_ptr).x, loop.s)
       
 ;      position_index_vol_old=position_index_vol
 ;      position_index_s_old=position_index_s
       
       v_total=energy2vel((*nt_part_ptr).KE_total)
       v_parallel=cos((*nt_part_ptr).pitch_angle)* v_total
       v_parallel_old=v_parallel
       v_total_old=v_total
       E_old=(*nt_part_ptr).KE_total
       cls_b=cls_b_over[position_index_s]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Elements needed for derivs2
        density=(*n_e)[position_index_vol]
        mass=(*nt_part_ptr).mass
        charge=(*nt_part_ptr).charge
        d_length=debye_length[position_index_vol]
        e_and_v= [[e_old], [v_parallel]]
        a_c=dblarr(n_elem_nt_particles)+1
        b_c=a_c
;An initial call to derivs2 to calculate the initial timescale.
        de_dt=derivs2(delta_t,e_and_v)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;determine the time it would take for the particle to travel 
;  a half of the cell's distance.  May change to an order
;  of magnitude
        delta_t=abs(min([abs(cls_b)/1d1,abs(ds[position_index_vol])/1d1])$
                    /v_parallel_old)
;Set a time scale for dt=E_0*(1-e^-1)/(de/dt)
        delta_t<= abs((.95*e_old-e_old)/de_dt[*,0])
;Make sure it isn't too ridiculous
        delta_t>=1d-9
;Make it less than the duration of the run
        delta_t<=duration*(5d-1)
        
        too_big_index=where(sim_time[alive_index]+delta_t gt duration )
        if too_big_index[0] ne -1 then delta_t[too_big_index]=duration-sim_time[alive_index[too_big_index]]
        temp=duration+delta_t
        delta_t=temp-duration
     ;   print, delta_t

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
if max((*n_e)) le 0 then begin
    delta_v_parallel_1=0d0
    goto, mirror_force
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Random element Number of electron collisions to proton collisions
        a_c=(1d0)+(.0333d0)*randomn(seed,n_elem_nt_particles )
        b_c=(2d0)-a_c
 ;       a_c=1d0
 ;       b_c=1d0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Now redo the call to derivs2 with the new random coefficients.
        de_dt=derivs2(delta_t,e_and_v)
        e_n_vp=rk42step_vector(e_and_v,de_dt,sim_time,delta_t, 'derivs2', /Double  )

      
        new_energy=e_n_vp[*,0]
        new_energy>=0.
;stop
;Deflection in the collision frame
        delta_v_parallel_1=e_n_vp[*,1]-v_parallel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Assign the new energy
        (*nt_part_ptr).KE_total=new_energy
        delta_energy=new_energy-e_old
;New velocity
        v_total=energy2vel((*nt_part_ptr).KE_total)
        
   ;     if (*nt_part_ptr).KE_total le energy_Floor then goto, test
        ;random_rot=sign(unit_vector,randomn(seed,n_elem_nt_particles))
        v_para_coll=sign(v_total+delta_v_parallel_1,$
                         v_parallel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;See if the particle got turned around
       turned_index=where(abs(v_para_coll) gt v_total) 
        if turned_index[0] ne -1 then begin
            sign_power=abs(fix(0.5+abs(v_para_coll[turned_index])/v_total[turned_index]))
            print, 'ping collision 1 ', 'sign power:',sign_power
;Have to enclose the -1 in paranthesis or else it is interpreted as 
; -(1^power)           
            print, 'v_para_coll old', v_para_coll[turned_index]
            v_para_coll[turned_index] =((-1d0)^sign_power[turned_index])*(v_para_coll[turned_index] mod v_total[turned_index])
            print, 'v_para_coll new', v_para_coll[turned_index]       
         endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the change in perpendicular velocity with a random direction.

        random_rot=randomn(seed,n_elem_nt_particles )
        random_rot=sign(unit_vector, random_rot)
        v_perp_coll=sign(sqrt((v_total*v_total)-(v_para_coll*v_para_coll)),$
                         random_rot)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Transform delta_v_parallel_1 to the loop frame
        v_parallel=cos((*nt_part_ptr).PITCH_ANGLE)*v_para_coll $
                   +sin((*nt_part_ptr).PITCH_ANGLE)*v_perp_coll
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;See if the particle got turned around
       turned_index=where(abs(v_parallel) gt v_total) 
        if turned_index[0] ne -1 then begin
            sign_power=abs(fix(.5+v_para_coll[turned_index]/v_total[turned_index]))
            print, 'ping collision 2 ', 'sign_power:',sign_power
;Have to enclose the -1 in paranthesis or else it is interpreted as 
; -(1^power)           
           v_parallel[turned_index]=((-1d0)^sign_power)*(v_parallel[turned_index] mod v_total[turned_index])
       endif
        delta_v_parallel_1=v_parallel_old-v_parallel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;Note that the output for delta_e is in keV.
       DELTA_E[position_index_vol]+= $
         (delta_energy*(*nt_part_ptr).scale_factor)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       delta_momentum[position_index_s]+= $
         delta_v_parallel_1* (*nt_part_ptr).mass $
         *(*nt_part_ptr).scale_factor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
;Calculate the new pitch-angle of the particles
          bad_index=where(v_total eq 0, COMPLEMENT=good_index)
;          if bad_index[0] ne -1 then (*nt_part_ptr)[bad_index].pitch_angle=!dpi/2.
          if good_index[0] ne -1 then (*nt_part_ptr)[good_index].pitch_angle=acos((v_parallel[good_index])/v_total[good_index])
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine if we screwed up
          bad_pas=where(finite((*nt_part_ptr).pitch_angle) ne 1)

       if bad_pas ne -1 then begin
           print,"Math error in PATC!!! Non-finite PA!!"
           print, 'Number of bad PAs:', n_elements(bad_pas)
           print,'Particle indices: ', bad_pas
       ;    print, 'Was in cell:', position_index_vol_old[bad_pas]
       ;    print, 'Now in cell:', position_index_vol[bad_pas]
 ;          help, v_parallel[0],v_total[0]
           print,'(v_parallel)/v_total)='+string((v_parallel[bad_pas])/v_total[bad_pas])
           stop
       endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mirror_force:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Mirror_force     See Bai, 1982, and Benz,1993
       if keyword_set(MP) then mu_old=cos((*nt_part_ptr).pitch_angle)

       dvdt=derivs1(sim_time,v_parallel )
       v_parallel=rk42step_vector(v_parallel,dvdt,sim_time , delta_t,'derivs1', /DOUBLE )
;       delta_v_parallel_2=v_parallel_t-v_parallel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;See if the particle got turned around by 180.
;  Not likely if I've done everything right
       bad_index=where(abs(v_parallel) gt v_total)
       if bad_index[0] ne -1 then begin
           sign_power=abs(fix(0.5+abs(v_parallel[bad_index])/v_total[bad_index]))
           print, 'ping mirror ', 'sign_power',sign_power 
           v_parallel[bad_index]=((-1d0)^sign_power)*(v_parallel[bad_index] mod v_total[bad_index])
       endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Advance the particle a step
       (*nt_part_ptr).x+=v_parallel*DELTA_T
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make an index array mask for the upcoming operations
       mask=lonarr(n_elem_nt_particles)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check to see if the particles went out of the loop.
;Note that the output for delta_e is in keV.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Particle has escaped through the right footpoint of the loop
       test_index_01=where((*nt_part_ptr).x ge max(s_alt2), count1)
          if test_index_01[0] ne -1 then begin
             mask[test_index_01]=1
             index3=n_volumes ;
             (*nt_part_ptr)[test_index_01].state='RF'
;Spread the energy out evenly across the Chromosphere.  Numerically
;nessary to prevent crashes.  Needs to be smarter.
             delta_e[INDEX3-loop.n_depth:INDEX3-1ul]+=$
                total(((*nt_part_ptr)[test_index_01].ke_total) $
                      *(*nt_part_ptr)[test_index_01].scale_factor)/loop.n_depth
             (*nt_part_ptr)[test_index_01].ke_total=0d0 ;energy_floor
             (*nt_part_ptr)[test_index_01].x=s_alt2[INDEX3-1ul]
             
             N_E_CHANGE[INDEX3-loop.n_depth:INDEX3-1ul]+=$
                abs((total((*nt_part_ptr)[test_index_01].scale_factor)/loop.n_depth)$
                    /volumes[INDEX3-loop.n_depth:INDEX3-1ul])
             
             position_index_vol[test_index_01]=INDEX3-1               
             position_index_s[test_index_01]=INDEX3+1ul
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Settings for bremsstrahlung
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             if not keyword_set(NO_BREMS) then begin
;Grab the crossections from a system variable array.
                indices=hdw_get_position_index(E_old[test_index_01], !BREMS_PART_E_ARRAY)
                cross_1=!BREMS_CROSS_SECTION[*,indices]
;Compute the addition to bremsstralung radiation and spread it out over the chromosphere.
                if count1 eq 1 then $
                   nt_brems[INDEX3-loop.n_depth:INDEX3-1ul ].n_photons+= $
                   total( $
                   rebin(reform(delta_t[test_index_01]*(*n_e)[position_index_vol[test_index_01]],1,count1),$
                         !n_ph_energies,count1)*$
                   abs(rebin(reform(v_total_old[test_index_01], 1,count1), !n_ph_energies,count1)*cross_1)$
                   *rebin(reform((*nt_part_ptr)[test_index_01].scale_factor/loop.n_depth, 1,count1), !n_ph_energies,count1) )$
                else $
                   nt_brems[INDEX3-loop.n_depth:INDEX3-1ul ].n_photons+= $           
                   total( $
                   rebin(reform(delta_t[test_index_01]*(*n_e)[position_index_vol[test_index_01]],1,count1),$
                         !n_ph_energies,count1)*$
                   abs(rebin(reform(v_total_old[test_index_01], 1,count1), !n_ph_energies,count1)*cross_1)$
                   *rebin(reform((*nt_part_ptr)[test_index_01].scale_factor/loop.n_depth, 1,count1), !n_ph_energies,count1), $
                   2)
        endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
    endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Particle has escaped through the left footpoint of the loop
          test_index_02=where((*nt_part_ptr).x le min(s_alt2), count2)
          if test_index_02[0] ne -1 then begin
             mask[test_index_02]=1
             index3=0
             (*nt_part_ptr)[test_index_02].state='LF'
             delta_e[INDEX3:loop.n_depth-1ul]+=$
                total(((*nt_part_ptr)[test_index_02].ke_total) $
                      *(*nt_part_ptr)[test_index_02].scale_factor/loop.n_depth,2)
             
             (*nt_part_ptr)[test_index_02].ke_total=energy_floor
             
             (*nt_part_ptr)[test_index_02].x=s_alt2[INDEX3]
             
             N_E_CHANGE[INDEX3:loop.n_depth-1ul]+=$
                abs(((*nt_part_ptr)[test_index_02].scale_factor/loop.n_depth)$
                    /volumes[INDEX3:loop.n_depth-1ul])
             position_index_vol[test_index_02]=0ul
             position_index_s[test_index_02]= 0ul
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Settings for bremsstrahlung
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Compute the addition to bremsstralung radiation 
       if not keyword_set(NO_BREMS) then  begin
          
;Grab the crossections from a system variable array.
                  indices=hdw_get_position_index(E_old[test_index_02], !BREMS_PART_E_ARRAY)
;Compute the addition to bremsstralung radiation and spread it out over the chromosphere.
                  if count2 eq 1 then $
                     nt_brems[INDEX3:loop.n_depth-1ul].n_photons+= $
                     total( $
                     rebin(reform(delta_t[test_index_02]*(*n_e)[position_index_vol[test_index_02]],1,count2),$
                           !n_ph_energies,count2)*$
                     abs(rebin(reform(v_total_old[test_index_02], 1,count2), !n_ph_energies,count2)*cross_1)$
                     *rebin(reform((*nt_part_ptr)[test_index_02].scale_factor/loop.n_depth, 1,count2), !n_ph_energies,count2))$
                  else $
                     nt_brems[INDEX3:loop.n_depth-1ul].n_photons+= $
                     total( $
                     rebin(reform(delta_t[test_index_02]*(*n_e)[position_index_vol[test_index_02]],1,count2),$
                           !n_ph_energies,count2)*$
                     abs(rebin(reform(v_total_old[test_index_02], 1,count2), !n_ph_energies,count2)*cross_1)$
                     *rebin(reform((*nt_part_ptr)[test_index_02].scale_factor/loop.n_depth, 1,count2), !n_ph_energies,count2), $
                     2)
               endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Particle has become part of the thermal distribution.
          test_index_03=where((*nt_part_ptr).ke_total lt energy_floor, count3)
          if test_index_03[0] ne -1 then begin
             mask[test_index_03]=1

             (*nt_part_ptr)[test_index_03].state='TL'
             
             position_index_vol[test_index_03]=hdw_get_position_index((*nt_part_ptr)[test_index_03].x,s_alt2 )
             ;position_index_s[test_index_03]=hdw_get_position_index((*nt_part_ptr)[test_index_03].x, loop.s)
             
             delta_e[position_index_vol[test_index_03]]+= $
                (((*nt_part_ptr)[test_index_03].ke_total) $
                 *(*nt_part_ptr)[test_index_03].scale_factor)
             (*nt_part_ptr)[test_index_03].ke_total=0d0 ;energy_floor
             
             N_E_CHANGE[position_index_vol[test_index_03]]+=$
                abs(((*nt_part_ptr)[test_index_03].scale_factor)$
                 /volumes[position_index_vol[test_index_03]])
             
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Settings for bremsstrahlung
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Compute the addition to bremsstralung radiation 
       if not keyword_set(NO_BREMS) then  begin
          
;Grab the crossections from a system variable array.
          indices=hdw_get_position_index(E_old[test_index_03], !BREMS_PART_E_ARRAY)
          cross_1=!BREMS_CROSS_SECTION[*,indices]
;Compute the addition to bremsstralung radiation and spread it out
;over the chromosphere.
          if count3 eq 1 then $
             nt_brems[position_index_vol].n_photons+= $
             total( $
             rebin(reform(delta_t[test_index_03]*(*n_e)[position_index_vol[test_index_03]],1,count3),$
                   !n_ph_energies,count3)*$
             abs(rebin(reform(v_total_old[test_index_03], 1,count3), !n_ph_energies,count3)*cross_1)$
             *rebin(reform((*nt_part_ptr)[test_index_03].scale_factor/loop.n_depth, 1,count3), !n_ph_energies,count3))$
             else $
             nt_brems[position_index_vol].n_photons+= $
             total( $
             rebin(reform(delta_t[test_index_03]*(*n_e)[position_index_vol[test_index_03]],1,count3), $
                   !n_ph_energies,count3)*$
             abs(rebin(reform(v_total_old[test_index_03], 1,count3), !n_ph_energies,count3)*cross_1)$
             *rebin(reform((*nt_part_ptr)[test_index_03].scale_factor/loop.n_depth, 1,count3), !n_ph_energies,count3), $
             2)
       endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Particle continues on.  
;If none of the other conditions caught the particle, this one will 
          test_index_04=where(mask eq 0, count4)
          if test_index_04[0] ne -1 then begin
              (*nt_part_ptr)[test_index_04].alive_time=(*nt_part_ptr)[test_index_04].alive_time+delta_t[test_index_04]
              
              position_index_vol[test_index_04]=hdw_get_position_index((*nt_part_ptr)[test_index_04].x,s_alt2 )        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Settings for bremsstrahlung
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

       if not keyword_set(NO_BREMS) then  begin
          
;Grab the crossections from a system variable array.
          indices=hdw_get_position_index(E_old[test_index_04], !BREMS_PART_E_ARRAY)
          cross_1=!BREMS_CROSS_SECTION[*,indices]
;Compute the addition to bremsstralung radiation and spread it out
;over the chromosphere.
          if count4 eq 1 then $
             nt_brems[position_index_vol[test_index_04]].n_photons+= $
             total( $
             rebin(reform(delta_t[test_index_04]*(*n_e)[position_index_vol[test_index_04]],1,count4),$
                   !n_ph_energies,count4)*$
             abs(rebin(reform(v_total_old[test_index_04], 1,count4), !n_ph_energies,count4)*cross_1)$
             *rebin(reform((*nt_part_ptr)[test_index_04].scale_factor, 1,count4), !n_ph_energies,count4))$
             else $
             nt_brems[position_index_vol[test_index_04]].n_photons+= $
             total( $
             rebin(reform(delta_t[test_index_04]*(*n_e)[position_index_vol[test_index_04]],1,count4), $
                   !n_ph_energies,count4)*$
             abs(rebin(reform(v_total_old[test_index_04], 1,count4), !n_ph_energies,count4)*cross_1)$
             *rebin(reform((*nt_part_ptr)[test_index_04].scale_factor, 1,count4), !n_ph_energies,count4),$
             2)
       endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       if keyword_set(MP) then begin
           mu_new=cos((*nt_part_ptr).pitch_angle)
           bounce_index=where(mu_new/mu_old lt 0)
           
           if bounce_index[0] ne -1 then begin
              position_index_s[test_index_04]=hdw_get_position_index((*nt_part_ptr)[test_index_04].x, loop.s)   
              MP[bounce_index]=position_index_s[bounce_index]
              bmp[bounce_index]=spline(loop.s, loop.b, (*nt_part_ptr)[bounce_index].x)
           endif
        endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

           sim_time[alive_index]=sim_time[alive_index] +delta_t
           nt_particles_orignal[alive_index]=(*nt_part_ptr)
;stop
           ptr_free, nt_part_ptr
       endwhile

;   print, 'PaTC Time:' , loop.state.time
end_loop:
;   for jj=0, 10 do DELTA_MOMENTUM=smooth(DELTA_MOMENTUM,3)
;   DELTA_MOMENTUM=DELTA_MOMENTUM/duration
;stop
nt_particles=nt_particles_orignal
   OUT_BEAM=NT_PARTICLES

ptr_free, n_e, nt_part_ptr
heap_gc, /ptr
;n_e_change=
;N_E_CHANGE=dblarr(n_volumes)
END; Of MAIN patc

