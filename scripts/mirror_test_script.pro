;04/30/2005
journal,'output.txt'
run_time=systime(1)
start_time=systime(0)

!EXCEPT=1
;Total simulation time in seconds
loop_time=1d*60d;minutes times seconds
loop_time=1d
;Total beam injection time in seconds
beam_time=.5d*60d
beam_time=1d
;Total beam energy in ergs
;Flare_energy=1d+30
time_step=20.d ;[sec]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;number of test particles
num_test_particles=1L
;Path to an IDL save file of a loop magnetic loop
;Local
start_file='~/PATC/loop_data/exp_b_scl.start'
loop_file='~/PATC/loop_data/exp_b_scl.sav'
;Solar Machines
;start_file='/disk/pd2/data/winter/data1/PATC/loop_data/exp_b_scl.start'
;loop_file='/disk/pd2/data/winter/data1/PATC/loop_data/exp_b_scl.sav'
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;Define the number of iterations that the code will make
N_interations=fix(loop_time/time_step)

;Defince the number of iterations you are going to
;   need for your electron beam
N_beam_iter=fix(beam_time/time_step)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For testing purposes
N_beam_iter=1

;print,'N_beam_iter:', string(N_beam_iter)


restore, loop_file
rad=rad*1d8
restore,start_file
;Need more spatial resolution!
;n_x=n_elements(x)
n_x=10000L
;Good grief! I had to work with this part for awhile!
ind0=lindgen(401)*max(x)/400
ind=lindgen(n_x)*max(x)/(n_x-1l)
new_x=spline(ind0,x,ind)
e=spline(x,lhist.e,new_x)
n_e=spline(x,lhist.n_e,new_x)
v=spline(x,lhist.v,new_x)
g=spline(x,g,new_x)
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


loop={x:new_x, $  ;Convert to cm
     axis:new_axis,$
     e:e ,$
     n_e:n_e,$
     v:v,$
     b:b2,$
     g:g,$
     rad:rad2,$
     t_max:t_max,$
     note:note,$
     start_file:start_file}
 
    
;stop
;loop=lhist
;No collisions
loop.n_e[*]=0
;Add length along loop but change to cm
;loop=ADD_TAG(loop,x,'x')
;loop=ADD_TAG(loop,g,'g')
;loop=ADD_TAG(loop,b2,'b')
;loop=ADD_TAG(loop,new_axis,'axis')
;loop=ADD_TAG(loop,t_max,'t_max')
;loop=ADD_TAG(loop,note,'note')
;loop=ADD_TAG(loop,start_file,'start_file')
;stop
for i=0, N_beam_iter-1 do begin
    e_beam_temp=mk_e_beam(loop.x,loop.axis[2,*], loop.B,$
                          N_Part=num_test_particles,IP='z')
    if n_elements(e_beam) eq 0 then e_beam=e_beam_temp $
      else e_beam=concat_struct(e_beam,e_beam_temp)
endfor
;e_beam=mk_e_beam(loop.l,loop.axis[2,*], loop.B, N_Part=,IP='z')

;stop

;NEED TO THINK ABOUT THIS IMPLEMENTATION LATER
;We defined a total energy for a flare.  The next two lines define a
;scale factor so that we acheive that energy
;energy_per_beam=total(ics[0].v)*keV_2_ergs
;scale_factor=Flare_energy/(N_beam_iter*energy_per_beam)


;We are at the beginning of the run so start out some counters at 0
beam_step=0
beam_on_time=0
sim_time=0
curr_beam_iter =0
counter=0


b_mp=loop.b[where(max(loop.axis[2,*]) eq loop.axis[2,*])] $
  *(1/0.96d)
b_mp=b_mp[0]
;PRINT, loop.b[where(max(loop.axis[2,*]) eq loop.axis[2,*])]
;PRINT,b_mp
mirr_points_index=where(abs(b_mp-loop.b) le  .005*b_mp)



;STOP
deriv=deriv(MIRR_POINTS_INDEX)
break_point=where(deriv eq max(deriv))
mp_ind_1=MIRR_POINTS_INDEX[0:break_point[0]]                           
mp_ind_2=MIRR_POINTS_INDEX[break_point[1]:n_elements(MIRR_POINTS_INDEX)-1]

MP={b_mp:b_mp, mp_ind_1:mp_ind_1, mp_ind_2:mp_ind_2,$
    FILE:'~/PATC/mirror_test.mpg'}
;print,'mirr_points',mirr_points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;set_plot,'ps'
;device,/landscape,file='mirror_test.ps'
;p_old=!p.multi
;!p.multi=[0,1,2]
position_index=where(abs(e_beam[0].x-loop.x) eq $
                            min(abs(e_beam[0].x-loop.x)))
line=dblarr(n_x)
line3=fltarr(n_elements(MP.mp_ind_1)+n_elements(MP.mp_ind_2))
;plot,loop.x,line,/xstyle,/ystyle, TITLE='mirror test', $
;  XTITLE='X position along loop [cm]',$
;  yrange=[-1,1],XRANGE=[min(loop.x),max(loop.x)]

;plots,mirr_points,line3,psym=1
;plots,loop.x[position_index] ,0, psym=2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Main loop
;This loop spans the whole loop simulation time.
;Electron Beam injection
;Loop cooling post beam injection.
;Electron thermalization. etc.  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Keep the loop going until time's up
n_sim_iter=0l
;while sim_time le loop_time do begin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;script to properly scale length for loop to the regrided lengths
;This was done by trial and error for 2005 Sonoma RHESSI meeting.
;Needs to be looked at at length
;Not neccessary for project implementation
;    end_add_on=(max(x)-1d8*max(loop.l))/2
;    bottom_index=where(x ge end_add_on)
;    top_index=where(x ge max(x)-end_add_on)
;    new_x=(x[bottom_index[0]:top_index[0]]-x[bottom_index[0]])/1e+8
;    test=spline(new_x,lhist.n_e[bottom_index[0]:top_index[0]],p_loop.l)
;    p_loop.n_e=abs(test[0:n_elements(test)-2])
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This is a loop nested in the main loop.  It will last as long as the
;beam is on
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ; if beam_on_time le beam_time then begin

        e_beam_before=e_beam
                    patc, e_beam,loop,time_step,MP=MP

    ;    endif

n_sim_iter=n_sim_iter+1

    junk=where(e_beam.state eq 'NT')
    if junk[0] eq -1 then goto, end_jump
;endwhile
;device,/close
set_plot,'x'


end_jump:
end
