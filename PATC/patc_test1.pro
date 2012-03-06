

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

out=patc_de_dt( t , e_n_vp, dl, dens,m,c,a,b)

;stop
return, out

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro  patc ,nt_particles,loop,duration, DELTA_E=DELTA_E,$
           MP=MP,bmp=bmp,OUT_BEAM=OUT_BEAM,$
           DELTA_MOMENTUM=DELTA_MOMENTUM,$
           MIN_PHOTON=MIN_PHOTON, MAX_PHOTON=MAX_PHOTON,$
           Z_AVG=Z_AVG,$
           NT_BREMS=NT_BREMS, $
           N_E_CHANGE=N_E_CHANGE, $
           E_H=E_H              ;, DELTA_V_VECTOR=DELTA_V_VECTOR

common beam, v_total, cls_b
common beam2,a_c, b_c, density, mass, charge, d_length

version=1.0
;ssw_packages,/xray
energy_floor=1d0
!except=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;how often to output text
freq_out=1000

N_COLLS=10
nt_old=nt_particles
n_elem_nt_particles=n_elements(nt_particles)

s_alt=get_loop_s_alt(loop,/gt0)
s_alt2=s_alt[1:N_ELEMENTS(s_alt)-2]
volumes=get_loop_vol(loop)
n_volumes=N_ELEMENTS(s_alt2)
N_elements_x=n_elements(loop.s)
N_E_CHANGE=dblarr(n_volumes)
;Conversion factor for energy removed from the particles in KE
;  to the energy input to the plas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
z_avg= !msul_charge_z

;Settings for bremsstrahlung
;if not  keyword_set(NT_BREMS) then begin
    if not keyword_set(MIN_PHOTON) then MIN_PHOTON=1. ;keV
    if not keyword_set(MAX_PHOTON) then MAX_PHOTON=100. ;keV
; Mean atomic number of the target plasma
;Default value given by T-H & E (1988)
    if not keyword_set(Z_AVG) then Z_AVG=1.4
    
    ph_energies=MIN_PHOTON+dindgen(MAX_PHOTON-MIN_PHOTON+1d)
    n_ph_e_array=n_elements(ph_energies)
    n_photons=dblarr(n_ph_e_array)
    nt_brems={ph_energies:ph_energies,$
              n_photons:n_photons}
    nt_brems=replicate(nt_brems,n_volumes)
;endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Note that the output for delta_e is in keV.
DELTA_E=dblarr(n_volumes)
E_H=DELTA_E
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
              (loop.state.n_e))^0.5d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Spacing of grid cells
ds=get_loop_ds(loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
for j=0ul,n_elem_nt_particles-1ul do begin
;   For i=0ul, n_iter-1ul do begin
    sim_time=0d
    while sim_time lt  duration do begin
;If this particle is no longer non-
;thermal, I don't need to waste time
;on it       
        if nt_particles[j].state ne 'NT' then begin
            sim_time=duration*1.01
            goto, elect_loop_end
        endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Got to figure out how to do this without the loop
        position_index_vol=where(abs(nt_particles[j].x-s_alt2) eq $
                                 min(abs(nt_particles[j].x-s_alt2)))
        
        position_index_s=where(abs(nt_particles[j].x-loop.s) eq $
                               min(abs(nt_particles[j].x-loop.s)))
                                ;help,position_index_vol
        position_index_vol=position_index_vol[0]
        position_index_s=position_index_s[0]
        position_index_vol_old=position_index_vol
        position_index_s_old=position_index_s

        v_total=energy2vel(nt_particles[j].KE_total)
        v_parallel=cos(nt_particles[j].pitch_angle)* v_total
        v_parallel_old=v_parallel
        v_total_old=v_total
        E_old=nt_particles[j].KE_total
        cls_b=cls_b_over[position_index_s[0]]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Elements needed for derivs2
        density=loop.state.n_e[position_index_vol[0]]
        mass=nt_particles[j].mass
        charge=nt_particles[j].charge
        d_length=debye_length[position_index_vol[0]]
        e_and_v= [e_old, v_parallel]
        a_c=1.
        b_c=1.
;An initial call to derivs2 to calculate the initial timescale.
        de_dt=derivs2(delta_t,e_and_v)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;determine the time it would take for the particle to travel 
;  a half of the cell's distance.  May change to an order
;  of magnitude
        delta_t=abs(min([abs(cls_b)/1d1,abs(ds[position_index_vol])/1d1])$
                    /v_parallel_old)
;Set a time scale for dt=E_0*(1-e^-1)/(de/dt)
        delta_t<= abs((.95*e_old-e_old)/de_dt[0])
;Make sure it isn't too ridiculous
        delta_t>=1d-9
;Make it less than the duration of the run
        delta_t<=duration*(5d-1)
        if sim_time+delta_t gt duration then delta_t=duration-sim_time
        temp=duration+delta_t
        delta_t=temp-duration
     ;   print, delta_t
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
if max(loop.state.n_e) le 0 then begin
    delta_v_parallel_1=0d0
    goto, mirror_force
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Random element Number of electron collisions to proton collisions
        a_c=(1d0)+(.0333d0)*randomn(seed)
        b_c=(2d0)-a_c
 ;       a_c=1d0
 ;       b_c=1d0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Now redo the call to derivs2 with the new random coefficients.
        de_dt=derivs2(delta_t,e_and_v)
        e_n_vp=rk42step(e_and_v,de_dt,sim_time,delta_t, 'derivs2', /Double  )
        new_energy=e_n_vp[0]
        new_energy>=0.
;stop
;Deflection in the collision frame
        delta_v_parallel_1=e_n_vp[1]-v_parallel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Assign the new energy
        nt_particles[j].KE_total=new_energy
        delta_energy=new_energy-e_old
;New velocity
        v_total=energy2vel(nt_particles[j].KE_total)
        
        if nt_particles[j].KE_total le energy_Floor then goto, test

        random_rot=randomn(seed)
        random_rot=sign(1, random_rot)
        
        v_para_coll=sign(v_total+delta_v_parallel_1,$
                         v_parallel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;See if the particle got turned around
        if abs(v_para_coll) gt v_total then begin
            sign_power=abs(fix(0.5+abs(v_para_coll)/v_total))
            print, 'ping collision 1 ', 'sign power:',sign_power
;Have to enclose the -1 in paranthesis or else it is interpreted as 
; -(1^power)           
            print, 'v_para_coll old', v_para_coll
            v_para_coll =((-1d0)^sign_power)*(v_para_coll mod v_total)
            print, 'v_para_coll new', v_para_coll
            
        endif
;Calculate the change in perpendicular velocity with a random direction.
       v_perp_coll=sign(sqrt((v_total*v_total)-(v_para_coll*v_para_coll)),$
                        random_rot)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Transform delta_v_parallel_1 to the loop frame
;Using sin(-A)=-sin(A) &  cos(-A)=cos(A) & 
; remembering that IDL is column major. 
        rot_matrix=[[cos(nt_particles[j].PITCH_ANGLE), $
                     sin(nt_particles[j].PITCH_ANGLE)], $
                    [-sin(nt_particles[j].PITCH_ANGLE),$
                     cos(nt_particles[j].PITCH_ANGLE)]]
        
        v_vector=rot_matrix#[v_para_coll, v_perp_coll]
;Why doesn't the above work?
        v_parallel=sign(v_vector[0], v_para_coll)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;See if the particle got turned around
       if abs(v_parallel) gt v_total then begin
           sign_power=abs(fix(.5+v_para_coll/v_total))
            print, 'ping collision 2 ', 'sign_power:',sign_power
;Have to enclose the -1 in paranthesis or else it is interpreted as 
; -(1^power)           
           v_parallel=((-1d0)^sign_power)*(v_parallel mod v_total)

       endif
        delta_v_parallel_1=v_parallel_old-v_parallel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;Note that the output for delta_e is in keV.
       DELTA_E[position_index_vol[0]]= $
         DELTA_E[position_index_vol[0]] $
          +(delta_energy*nt_particles[j].scale_factor)
      ; if max(DELTA_E) ge 0 then stop
       delta_momentum[position_index_s[0]]=$
         temporary(delta_momentum[position_index_s[0]]) $
         +delta_v_parallel_1* nt_particles[j].mass $
         *nt_particles[j].scale_factor
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
       if  v_total ne 0 then begin 
           if abs(v_parallel) gt v_total then v_parallel=(v_parallel/v_parallel)*v_total
           nt_particles[j].pitch_angle=acos((v_parallel)/v_total) 
       endif 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       if not finite(nt_particles[j].pitch_angle) then begin
           print,"Math error in PATC!!! Non-finite PA!!"
           print,'Particle:'+string(j)
           print, 'Was in cell:'+string(position_index_vol_old)
           print, 'Now in cell:'+string(position_index_vol[0])
           help, v_parallel[0],v_total[0]
           print,'(v_parallel)/v_total)='+string((v_parallel)/v_total)
                                ; v_parallel=v_total*sign(1, v_parallel)
          ; nt_particles[j].pitch_angle=acos((v_parallel)/v_total)
           stop
       endif
       if not finite( nt_particles[j].pitch_angle) then stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mirror_force:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Mirror_force     See Bai, 1982, and Benz,1993
       if keyword_set(MP) then mu_old=cos(nt_particles[j].pitch_angle)
       
;       delta_v_parallel_2=-0.5*delta_t*$
;                          ((v_total-v_parallel)^2d0)/cls_b
                          ;((v_total*sin(nt_particles[j].pitch_angle))^2d0)/cls_b

       dvdt=derivs1(sim_time,v_parallel )
       v_parallel=rk42step(v_parallel,dvdt,sim_time , delta_t,'derivs1', /DOUBLE )
;       delta_v_parallel_2=v_parallel_t-v_parallel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;See if the particle got turned around by 180.
;  Not likely if I've done everything right
       if abs(v_parallel) gt v_total then begin
           sign_power=abs(fix(0.5+abs(v_parallel)/v_total))
           print, 'ping mirror ', 'sign_power',sign_power
           
           v_parallel=((-1d0)^sign_power)*(v_parallel mod v_total)

       endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Advance the particle a step
;       accel_t=(delta_v_parallel_2+delta_v_parallel_1)
;       nt_particles[j].x=temporary(nt_particles[j].x)+ $
;                         (v_parallel_old*delta_t)+ $
;                         (delta_v_parallel_2+delta_v_parallel_1)*delta_t
       nt_particles[j].x=temporary(nt_particles[j].x)+ $
                         v_parallel*DELTA_T
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check to see if the particles went out of the loop.
;Note that the output for delta_e is in keV.
TEST:
       Case 1 of
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Particle has escaped through the right footpoint of the loop
           nt_particles[j].x ge max(s_alt2): begin
               index3=n_elements(s_alt2);-10ul;0ul
               
               nt_particles[j].state='RF'
               delta_e[INDEX3-loop.n_depth:INDEX3-1ul]=$
                 delta_e[INDEX3-loop.n_depth:INDEX3-1ul] $
                              +((nt_particles[j].ke_total) $
                              *nt_particles[j].scale_factor/loop.n_depth)
             ;  nt_particles[j].ke_total=0d0;energy_floor
             ;  delta_e[INDEX3-loop.n_depth:INDEX3]=$
             ;    delta_e[INDEX3] $
             ;                 +((nt_particles[j].ke_total) $
             ;                  *nt_particles[j].scale_factor)
               nt_particles[j].ke_total=0d0;energy_floor
               nt_particles[j].x=s_alt2[INDEX3-1ul]
               
               N_E_CHANGE[INDEX3-loop.n_depth:INDEX3-1ul]=$
                  N_E_CHANGE[INDEX3-loop.n_depth:INDEX3-1ul]+ $
                 abs((nt_particles[j].scale_factor/loop.n_depth)$
                 /volumes[INDEX3-loop.n_depth:INDEX3-1ul])

               position_index_vol=[INDEX3-1]               
               position_index_s=INDEX3+1ul
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Settings for bremsstrahlung
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Compute the addition to bremsstralung radiation     
;Calculate the crosssections
       E_new=nt_particles[j].KE_total
;       e_avg=abs(E_old+e_new)/2d0
;       v_avg=abs(v_total_old+v_total)/2d0
       e_avg=E_old
       v_avg=v_total_old
       Brm_BremCross,E_avg,$
                     nt_brems[position_index_vol[0]].ph_energies, $
                         z_avg, cross_1 
        ;   Brm_BremCross,E_old,$
        ;                 nt_brems[position_index_vol[0]].ph_energies, $
        ;                 z_avg, cross_1 
           junk=where(finite(cross_1) ne 1)
           if junk[0] ne -1 then cross_1[junk]=0d0
;           Brm_BremCross,E_new,$
;                         nt_brems[position_index_vol[0]].ph_energies, $
;                         z_avg, cross_2 
;           junk=where(finite(cross_2) ne 1)
;           if junk[0] ne -1 then cross_2[junk]=0d0

;Calculate the number of photons produced
           nt_brems[INDEX3-loop.n_depth:INDEX3-1ul ].n_photons=$
             delta_t*loop.state.n_e[position_index_vol[0]]* $
             abs(v_avg*cross_1)* $
             nt_particles[j].scale_factor/loop.n_depth
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  

       end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Particle has escaped through the left footpoint of the loop
           nt_particles[j].x le min(s_alt2):  begin
               index3=0
               nt_particles[j].state='LF'
               delta_e[INDEX3:loop.n_depth-1ul]=$
                 delta_e[INDEX3:loop.n_depth-1ul] $
                 +((nt_particles[j].ke_total) $
                   *nt_particles[j].scale_factor/loop.n_depth)
            ;   delta_e[INDEX3:loop.n_depth]=delta_e[INDEX3] $
            ;                  +((nt_particles[j].ke_total) $
             ;                  *nt_particles[j].scale_factor)
               nt_particles[j].ke_total=energy_floor
               
               nt_particles[j].x=s_alt2[INDEX3]

               N_E_CHANGE[INDEX3:loop.n_depth-1ul]= $
                 N_E_CHANGE[INDEX3:loop.n_depth-1ul] +$
                 abs((nt_particles[j].scale_factor/loop.n_depth)$
                 /volumes[INDEX3:loop.n_depth-1ul])
             ;  N_E_CHANGE[INDEX3]= $
             ;    N_E_CHANGE[INDEX3] +$
             ;    abs((nt_particles[j].scale_factor)$
             ;    /volumes[INDEX3])
               position_index_vol=0ul
               position_index_s=  0ul
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Settings for bremsstrahlung
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Compute the addition to bremsstralung radiation     
;Calculate the crosssections
       E_new=nt_particles[j].KE_total
;       e_avg=abs(E_old+e_new)/2d0
;       v_avg=abs(v_total_old+v_total)/2d0
       e_avg=E_old
       v_avg=v_total_old
       Brm_BremCross,E_avg,$
                     nt_brems[position_index_vol[0]].ph_energies, $
                         z_avg, cross_1 
        ;   Brm_BremCross,E_old,$
        ;                 nt_brems[position_index_vol[0]].ph_energies, $
        ;                 z_avg, cross_1 
           junk=where(finite(cross_1) ne 1)
           if junk[0] ne -1 then cross_1[junk]=0d0
;           Brm_BremCross,E_new,$
;                         nt_brems[position_index_vol[0]].ph_energies, $
;                         z_avg, cross_2 
;           junk=where(finite(cross_2) ne 1)
;           if junk[0] ne -1 then cross_2[junk]=0d0

;Calculate the number of photons produced
;Spread it out over the chromosphere.
           nt_brems[INDEX3:loop.n_depth-1ul].n_photons=$
             delta_t*loop.state.n_e[position_index_vol[0]]* $
             abs(v_avg*cross_1)* $
             nt_particles[j].scale_factor/loop.n_depth
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
           end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Particle has become part of the thermal distribution.
           nt_particles[j].ke_total lt energy_floor : begin
               nt_particles[j].state='TL'
               
               position_index_vol=where(abs(nt_particles[j].x-s_alt2) eq $
                                        min(abs(nt_particles[j].x-s_alt2)))
               
               position_index_s=where(abs(nt_particles[j].x-loop.s) eq $
                                      min(abs(nt_particles[j].x-loop.s)))
               position_index_vol=position_index_vol[0]
               position_index_s=position_index_s[0]
               
               delta_e[position_index_vol]=delta_e[position_index_vol] $
                              +((nt_particles[j].ke_total) $
                               *nt_particles[j].scale_factor)
               nt_particles[j].ke_total=0d0;energy_floor

               N_E_CHANGE[position_index_vol]=$
                 N_E_CHANGE[position_index_vol]+ $
                 abs((nt_particles[j].scale_factor)$
                 /volumes[position_index_vol])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Settings for bremsstrahlung
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Compute the addition to bremsstralung radiation     
;Calculate the crosssections
       E_new=nt_particles[j].KE_total
;       e_avg=abs(E_old+e_new)/2d0
;       v_avg=abs(v_total_old+v_total)/2d0
       e_avg=E_old
       v_avg=v_total_old
       Brm_BremCross,E_avg,$
                     nt_brems[position_index_vol[0]].ph_energies, $
                         z_avg, cross_1 
        ;   Brm_BremCross,E_old,$
        ;                 nt_brems[position_index_vol[0]].ph_energies, $
        ;                 z_avg, cross_1 
           junk=where(finite(cross_1) ne 1)
           if junk[0] ne -1 then cross_1[junk]=0d0
;           Brm_BremCross,E_new,$
;                         nt_brems[position_index_vol[0]].ph_energies, $
;                         z_avg, cross_2 
;           junk=where(finite(cross_2) ne 1)
;           if junk[0] ne -1 then cross_2[junk]=0d0

;Calculate the number of photons produced
           nt_brems[position_index_vol[0]].n_photons=$
             delta_t*loop.state.n_e[position_index_vol[0]]* $
             abs(v_avg*cross_1)* $
             nt_particles[j].scale_factor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
           end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Particle continues on
           else:begin
               nt_particles[j].alive_time=nt_particles[j].alive_time+delta_t
               
               position_index_vol=where(abs(nt_particles[j].x-s_alt2) eq $
                                        min(abs(nt_particles[j].x-s_alt2)))
               
               position_index_s=where(abs(nt_particles[j].x-loop.s) eq $
                                      min(abs(nt_particles[j].x-loop.s)))
               
               position_index_vol=position_index_vol[0]
               position_index_s=position_index_s[0]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Settings for bremsstrahlung
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Compute the addition to bremsstralung radiation     
;Calculate the crosssections
       E_new=nt_particles[j].KE_total
;       e_avg=abs(E_old+e_new)/2d0
;       v_avg=abs(v_total_old+v_total)/2d0
       e_avg=E_old
       v_avg=v_total_old
       Brm_BremCross,E_avg,$
                     nt_brems[position_index_vol[0]].ph_energies, $
                         z_avg, cross_1 
        ;   Brm_BremCross,E_old,$
        ;                 nt_brems[position_index_vol[0]].ph_energies, $
        ;                 z_avg, cross_1 
           junk=where(finite(cross_1) ne 1)
           if junk[0] ne -1 then cross_1[junk]=0d0
;           Brm_BremCross,E_new,$
;                         nt_brems[position_index_vol[0]].ph_energies, $
;                         z_avg, cross_2 
;           junk=where(finite(cross_2) ne 1)
;           if junk[0] ne -1 then cross_2[junk]=0d0

;Calculate the number of photons produced
           nt_brems[position_index_vol[0]].n_photons=$
             delta_t*loop.state.n_e[position_index_vol[0]]* $
             abs(v_avg*cross_1)* $
             nt_particles[j].scale_factor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;           
               
           end

       ENDCASE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     
       
       if  v_total ne 0 then begin 
           if abs(v_parallel) gt v_total then v_parallel=(v_parallel/v_parallel)*v_total
           nt_particles[j].pitch_angle=acos((v_parallel)/v_total) 
       endif 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       if not finite(nt_particles[j].pitch_angle) then begin
           print,"Math error in PATC!!! Non-finite PA!!"
           print,'Particle:'+string(j)
           print, 'Was in cell:'+string(position_index_vol_old)
           print, 'Now in cell:'+string(position_index_vol[0])
           help, v_parallel[0],v_total[0]
           print,'(v_parallel)/v_total)='+string((v_parallel)/v_total)
                                ; v_parallel=v_total*sign(1, v_parallel)
          ; nt_particles[j].pitch_angle=acos((v_parallel)/v_total)
           stop
           ;help
           ;wait,10*60
       endif
       if not finite( nt_particles[j].pitch_angle) then stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

       if keyword_set(MP) then begin
           mu_new=cos(nt_particles[j].pitch_angle)
           if mu_new/mu_old lt 0 then begin
               MP[j]=position_index_s[0]
               bmp[j]= $
                     ; loop.b[position_index_s[0]]
                      spline(loop.s, loop.b, nt_particles[j].x)
               endif
       endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;stop

           sim_time=temporary(sim_time) +delta_t
;           print, position_index_vol[0], delta_energy,DELTA_E[position_index_vol[0]],delta_t 
elect_loop_end:
       endwhile
       junk=where(nt_particles.state eq 'NT')

       if junk[0] eq -1 then goto, end_loop
 ;      if nt_particles[j].state eq 'NT' then begin
 ;          v_z=energy2vel(nt_particles[j].ke_total)$
 ;              * cos(nt_particles[j].pitch_angle)
 ;          print, 'v_z='+$
 ;                 string(v_z)
 ;          print, 'delta_v1 '+string(delta_v_parallel_1) ;/v_total)
 ;          print, 'delta_v2 '+string(delta_v_parallel_2) ;/v_total)
 ;          if v_z le 0 then stop
 ;      endif
           
;stop
   endfor
   
                                ; j loop for particles
;   help, nt_brems,/STR
;pmm, nt_brems.n_photons
   print, 'PaTC Time:' , loop.state.time
end_loop:
   for jj=0, 10 do DELTA_MOMENTUM=smooth(DELTA_MOMENTUM,3)
   DELTA_MOMENTUM=DELTA_MOMENTUM/duration
   OUT_BEAM=NT_PARTICLES
;n_e_change=
;N_E_CHANGE=dblarr(n_volumes)
;stop
END; Of MAIN patc

