 

patc_dir=getenv('PATC')
;04/30/2005
patc_dir=getenv('PATC')
start_time=systime(0)

!EXCEPT=1
;Total simulation time in seconds
loop_time=1d*60d;minutes times seconds
;Total beam injection time in seconds
beam_time=1d*60d
;Total beam energy in ergs
Flare_energy=1d+30
time_step=.01d ;[sec]
elect_density=4d9
t_plasma=1d+7
e_0=50d
mu=0.6d
color_table=3
plot_title='Model Loop Sim'
gif_dir='gifs/'
delta_index=3d
run_folder=strcompress(patc_dir+'2005_05_17_exp_loop')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine the flux of of particles in each energy bin

energies=[20d,35d,30d,35d,40d,45d,50d]
num_test_particles=(1000d)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Path to an IDL save file of a loop magnetic loop
start_file=patc_dir+'loop_data/exp_b_scl.start'
loop_file=patc_dir+'loop_data/exp_b_scl.sav'
save_file=patc_dir+'/full_test_1.sav'

color_factor=255/(max(energies)-5)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
N_beam_iter=1l

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

percent=double(energies^(-delta_index))/ $
  max(energies^(-delta_index))


junk=where( (percent mod 1) ge .5 ) 
if junk[0] ne -1 then percent[junk]=percent[junk]+1d

number_n_E_bin=long(percent*num_test_particles)
junk=where(number_n_E_bin le 0)
if junk[0] ne -1 then number_n_E_bin[junk] =1L

circle_sym,  THICK=2, /FILL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;1 keV=1.602e-9 ergs
; converts keV to ergs
keV_2_ergs = 1.602d-9
;converts ergs to keV
egs_2_kev=1d/(keV_2_ergs)
;Boltzmann's constant in ergs/[K]
k_boltz_ergs=1.3807d-16
;Boltzmann's constant in Joules/[K]
k_boltz_joules=1.3807d-23 
;Electron mass in grams
e_mass_g=9.1094d-28 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;We defined a total energy for a flare.  The next two lines define a
;scale factor so that we acheive that energy.
energy_per_beam=total(energies*number_n_E_bin)*keV_2_ergs
scale_factor=Flare_energy/(energy_per_beam*N_beam_iter)

;Define the number of iterations that the code will make.
N_interations=fix(loop_time/time_step)

;Define the number of iterations you are going to
;   need for your electron beam.
N_beam_iter=fix(beam_time/time_step)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;print,'N_beam_iter:', string(N_beam_iter)


restore, loop_file
rad=rad*1d8

restore,start_file
n_x=n_elements(x)
;n_x=10000L
;Good grief! I had to work with this part for awhile!
new_x=x
;Extrapolate a new magnetic field 
b2=dblarr(n_x)
index=where(abs(new_x-orig.x[0]) eq min(abs(new_x-orig.x[0])))
index2=where(abs(new_x-orig.x[n_elements(orig.x)-1]) $
             eq min(abs(new_x-orig.x[n_elements(orig.x)-1])))
b2[index[0]:index2[0] ]=spline(orig.x,orig.b,new_x[index[0]:index2[0]])
b2[0: index[0]]=b2[index[0]]
b2[index2[0]:n_elements(b2)-1]=b2[index2[0]]


;Extrapolate a new magnetic field 
rad2=dblarr(n_x)
rad2[index[0]:index2[0] ]=spline(orig.x,rad,new_x[index[0]:index2[0]])
rad2[0: index[0]]=rad2[index[0]]
rad2[index2[0]:n_elements(b2)-1]=rad2[index2[0]]


;Extrapolate a new axis in cm
new_axis=dblarr(3,n_x)
new_y=dblarr(n_x)
new_z=dblarr(n_x)
new_y[index[0]: index2[0]]=spline(orig.x,orig.axis[1,*],new_x[index[0]:index2[0]])
new_z[index[0]: index2[0]]=spline(orig.x,orig.axis[2,*],new_x[index[0]:index2[0]])
new_y[0: index[0]]=new_y[index[0]]
new_z[0: index[0]]=new_z[index[0]]
new_y[index2[0]:n_elements(new_y)-1]=new_y[index2[0]]
new_z[index2[0]:n_elements(new_y)-1]=new_z[index2[0]]
new_axis[1,*]=new_y*1d+8
new_axis[2,*]=new_z*1d+8


loop={x:x, $  ;Convert to cm
     axis:new_axis,$
     e:lhist.e[0:n_x-2] ,$
     n_e:lhist.n_e[0:n_x-2],$
     v:lhist.v,$
     b:b2,$
     g:g,$
     rad:rad2,$
     t_max:t_max,$
     note:note,$
     start_file:start_file}
 
        plot,loop.axis[1,*],loop.axis[2,*]+loop.rad,THICK=3 , $
          TITLE=plot_title,CHARSIZE=1.3,CHARTHICK=1.3
        oplot,loop.axis[1,*],loop.axis[2,*],linestyle=2    
        oplot,loop.axis[1,*],loop.axis[2,*]-loop.rad,linestyle=0,THICK=3
color_value=255*(max(alog10(lhist.n_e[0])))
for i=0, n_elements(loop.AXIS[1,*])-2 do begin
    polyfill,[ REFORM(loop.AXIS[1,i]),$
                   REFORM(loop.AXIS[1,i:i+1]),$
                   REFORM(loop.AXIS[1,i+1]) ],$
          [REFORM(loop.AXIS[2,i]-loop.RAD[i]), $
           REFORM(loop.AXIS[2,i:i+1]+loop.RAD[i:i+1]) ,$
           REFORM(loop.AXIS[2,i+1]-loop.RAD[i+1]) ], $
          COLOR=color_value*alog10(lhist.n_e[i]) , /FILL_PATTERN;/LINE_FILL
  
endfor

end

        
