;mc_test
;Monte carlo test
;I'm just testing some of the ways I'm thinking of handling the monte carlo collisions
;This is the current version to beta test before insertion into PATC
; See p. 65 2006-Oct-17

data_dir= getenv('DATA')
patc_dir= getenv('PATC')
;file=data_dir+'/PATC/runs/2006_SEP_26/00001.loop'
file=patc_dir+'/test/loop_data/gcsm_loop.sav'
restore,file



beam_struct=beam_generator(loop,[15d0, 200d0], $
                                    total_energy=1d30, $
                                    SPEC_INDEX=3, $
                                    time=1, delta_t=1,$
                                    IP='z',n_PART=1d5, $
                                    ALPHA=4,$
                                    FRACTION_PART=100, $
                                    T_PROFILE='Gaussian')
nt_particles=beam_struct[0].nt_beam
DURATION=.1
;nt_particles[*].ke_total=10
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the progress meter
;progress_label='PATC progress'
;progress,0,LABEL=progress_label,/RESET,FREQUENCY=600,$
;        BIGSTEP=1, SMALLSTEP=1d-1
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
;Avg # of protons in ambient (thermal) plasma.
Z_bar=1.
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;How can this be done without the loop?
    for k=0ul, n_elem_nt_particles-1ul do begin
     
       position_index_vol=where(abs(nt_particles[k].x-s_alt2) eq $
                            min(abs(nt_particles[k].x-s_alt2)))
       nt_particles[k].position_index=position_index_vol[0]
   endfor
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
pos_index_2=ulonarr(n_elem_nt_particles)
position_index_s=ulonarr(n_elem_nt_particles)
  
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

;while max(delta_t) gt  0. do begin
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
    n_elem_nt_particles=n_elements(nt_particles[a_i])
    ;help,n_elem_nt_particles  
    pos_index_2[a_i]=nt_particles[a_i].position_index
        
  for k=0ul, n_elem_nt_particles-1ul do begin    
      position_index_s[a_i[k]]=where(abs(nt_particles[a_i[k]].x-loop[0].s) eq $
                                min(abs(nt_particles[a_i[k]].x-loop[0].s)))
  endfor
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
       delta_t[a_i] <=(duration *1d-2) 
       ;Assign a min delta_t
       delta_t[a_i]>= 1d-4
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
N_collisions=1000
unit_matrix=dblarr(N_collisions)+1d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the reduced mass
;A random array of reduced masses for the collisions,
;assuming about half of the collisions are electron collisions
;and the other half are proton collisions
reduced_mass=randomn(seed ,N_collisions ,n_elem_nt_particles)
electron_index=where(reduced_mass ge 1,complement=proton_index)
reduced_mass[electron_index]=e_mass_g
reduced_mass[proton_index]=p_mass_g
reduced_mass=(REDUCED_MASS*(unit_matrix#nt_particles.mass)) $
             /(reduced_mass+(unit_matrix#nt_particles.mass))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make an array of target masses, which is needed for the delta-E and 
;delta-v parallel calculations
target_mass=reduced_mass
;Reuse the indices defined before.
target_mass[electron_index]=e_mass_g
target_mass[proton_index]=p_mass_g

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make an array of target charges so that the code can be completely general.
;Again reuse the previously made indices.
charge=reduced_mass
charge[electron_index]=-1.*e
charge[proton_index]=e

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define a maximum impact parameter based on the potential energy of a 
;Coulomb scatterer and the kinetic energy of the incident particle 
b_max=abs(nt_particles[a_i].charge*e)/(e_mass_g*v_total*v_total*6d-5)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define a mean free path based upon b_max as the radius for the scattering
;cross-section
mfp=(!dpi*(b_max*b_max)*loop.state.n_e[nt_particles[a_i].position_index])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define a maximum impact parameter based on the potential energy of a 
;Coulomb scatterer and the kinetic energy of the incident particle
b_energy=abs(nt_particles[a_i].charge*e)/(e_mass_g*nt_particles[a_i].ke_total*kev_2_ergs)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the number of collisions based on the different M.F.P.s
n_c=(v_total*delta_t[a_i])/mfp
n_c2=(v_total*delta_t[a_i])/mean_free_path[nt_particles[a_i].position_index]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Ratio of total collsions to modeled collisions  
collision_factor=n_c/N_collisions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Characterstic scale length of the energy loss est.
;Blatantly stolen from Emslie, 1978
cst_e_loss= abs((((-2d)*(!dpi)*(ln_lambda)*$
              (e^4d))/nt_particles[a_i].KE_total) $
            *((nt_particles[a_i].mass/p_mass_g))$
            *(loop.state.N_e[nt_particles[a_i].position_index]) $
            *v_total/(nt_particles[a_i].KE_total))^(-1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Structure that will contain the impact parameter for each
;collision.  The indexing structure is 
b_impact={b:dblarr(N_collisions)}
b_impact=replicate(temporary(b_impact),n_elem_nt_particles)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Cross-sectional area of scatterer based on the debye length
sigma_dl=(debye_length[nt_particles[a_i].position_index]-b_crit)/6d

;
;delta=unit_matrix#((debye_length[nt_particles[a_i].position_index]-b_crit)/2d)
delta=unit_matrix#(b_max/2d)

b_impact.b=delta+ $
  ((delta/3d)*randomn(seed ,N_collisions ,n_elem_nt_particles)) 

b_impact.b>=(unit_matrix)#b_crit
avg_b= total(b_impact.b,1)/N_collisions

theta=(2d)*atan( $
                abs(nt_particles.charge*e) $
                /(b_impact.b*((unit_matrix#nt_particles.KE_total)*keV_2_ergs)))


delta_energy=total((-1d)(unit_matrix#(nt_particles.KE_total^2d)) $
                   *((1d)-cos(theta*2d))$
                   *(reduced_mass*reduced_mass/target_mass),1) $
             *collision_factor


print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
print,avg_b/(b_crit+(debye_length[nt_particles[a_i].position_index]-b_crit)/2d)
print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'

;endwhile
;junk1=where(avg_b/debye_length[nt_particles[a_i].position_index] gt 1, count_1)
;junk1=where(avg_b/debye_length[nt_particles[a_i].position_index] lt 1, count_2)

;print, count_1,count_2

window, 2
plot, debye_length[nt_particles[a_i].position_index],psym=6
oplot, (debye_length[nt_particles[a_i].position_index]-b_crit)/2
oplot, b_crit,psym=6
oplot, avg_b,line=2

i2=1
window, 3
pmm, abs(delta_energy)
plot, b_impacts[i2].b_collision
pmm, b_impacts[i2].b_collision
oplot, [0,1000], [avg_b[i2],avg_b[i2]]





end_loop:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Begin new bright idea
min_compute_angle=5.1d-5
b_limit=nt_particles.charge/(energy2gamma(nt_particles.ke_total) $
                             *(v_total*v_total) $
                             *min_compute_angle)

b_limit=(1d/reduced_mass)*(unit_matrix#abs(temporary(b_limit)))*abs(charge)
      

b_impacts={b_collision:dblarr(N_collisions)}
b_impacts=replicate(temporary(b_impacts),n_elem_nt_particles)
b_impacts[*].b_collision[*]=b_limit*randomu(seed, N_collisions ,n_elem_nt_particles)
sigma_dl_matrix=unit_matrix#sigma_dl
p_of_b=(1./sqrt(2.*!dpi)) $
       *(1./(sigma_dl_matrix)) $
       *exp(-1d*(($
                  (b_impacts[*].b_collision[*]- $
                   3d* $
                   sigma_dl_matrix)^2.)/(2.*sigma_dl_matrix*sigma_dl_matrix)))

mfp2=(!dpi*(b_limit)*(b_limit)*loop.state.n_e[nt_particles[a_i].position_index])

b_lim=2.*e*e/(energy2gamma(nt_particles.ke_total) $
                             *(v_total*v_total) $
                             *min_compute_angle*e_mass_g)

mfp3=(!dpi*b_energy*b_energy*loop.state.n_e[nt_particles[a_i].position_index])
n_c2=(v_total*delta_t[a_i])/mfp2
n_c3=(v_total*delta_t[a_i])/mfp3
print, n_c2
print, n_c3


mfp4=(!dpi*(b_lim)*(b_lim)*loop.state.n_e[nt_particles[a_i].position_index])
; #number of collisions using b_limit as b_max
n_c4=(v_total*delta_t[a_i])/mfp4
print, n_c4


;p_of_b=


end
