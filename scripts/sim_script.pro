;pro full_monte

;04/30/2005
patc_dir=getenv('PATC')
start_time=systime(0)
computer='earth'
!EXCEPT=1
beam_time=1d
;Total simulation time in seconds
loop_time=beam_time
;Total beam energy in ergs
Flare_energy=1d+28
time_step=0.05d ;[sec]
delta_time=time_step
color_table=39
plot_title='Model Loop Sim'
run_folder=strcompress(patc_dir+'2005_05_20_exp_loop/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Give an output filename for the HD code. .sav will be added
outname=strcompress(run_folder+'hd_out.sav')

gif_dir=strcompress(run_folder+'gifs/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Background heating 
q0=0.007                    ;erg/s/cm^3
sm_width=11
delta_index=3d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine the flux of of particles in each energy bin

energies=[20d,25d,30d,35d,40d,45d,50d]
;energies=[20d,50d]
num_test_particles=(100d)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Path to an IDL save file of a loop magnetic loop
start_file=patc_dir+'loop_data/exp_b_scl.start'
loop_file=patc_dir+'loop_data/exp_b_scl.sav'
save_file=run_folder+'/full_test_1.sav'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Define the number of iterations you are going to
;   need for your electron beam.
N_beam_iter=long(beam_time/time_step)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

percent=double(energies^(-delta_index))/ $
  max(energies^(-delta_index))


junk=where( (percent mod 1) ge .5 ) 
if junk[0] ne -1 then percent[junk]=percent[junk]+1d

number_n_E_bin=long(percent*num_test_particles)
junk=where(number_n_E_bin le 0)
if junk[0] ne -1 then number_n_E_bin[junk] =1L

color_lower_bound=(110)
syms=[4, intarr(n_elements(energies))+8]
color_factor=(255-color_lower_bound)/(max(energies)-min(energies))
color_offset=255-(color_factor)

 Ticknames=[string(energies, format='(I2.2)')+' keV']
Ticknames=reverse(Ticknames)
 Ticknames=[Ticknames,'Thermal']

syms=reverse(syms)
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
scale_factor=2.78d26/energy_per_beam
;Define the number of iterations that the code will make.
N_interations=fix(loop_time/time_step)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;print,'N_beam_iter:', string(N_beam_iter)


restore, loop_file
rad=rad*1d8

restore,start_file
 elements=n_elements(lhist.n_e)/2  
 for i=1 , elements-1 do lhist.n_e[2*elements-1]=lhist.n_e[i-1] 

 elements=n_elements(lhist.e)/2  
 for i=1 , elements-1 do lhist.e[2*elements-1]=lhist.e[i-1] 
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

l=dblarr(n_x)
l=spline(orig.x,l,new_x[index[0]:index2[0]])
loop_x=loop.l*1d+8
loop={l:loop.l, $
     x:x, $                    ;Convert to cm
     axis:new_axis,$
     e:lhist.e[0:n_x-1] ,$
     n_e:lhist.n_e[0:n_x-1],$
     v:lhist.v,$
     b:b2,$
     g:g,$
     rad:rad2,$
     t_max:t_max,$
     note:note,$
     start_file:start_file}


             for x_index=0, n_elements(x)-1 do begin
                 
                 position_index=where(abs(x[x_index]-loop.x) eq $
                            min(abs(x[x_index]-loop.x)))
                 loop.n_e[position_index]=lhist[0].n_e[x_index]
                 loop.e[position_index]=lhist[0].e[x_index]
             endfor

loop_struct={time:0.0, Loop:loop}
 
for i =0 , n_elements(energies)-1 do  begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Remembering that best is the enemy of good, I'm not doing a full
;pitch angle distrubution function.  I'm just doing something simple
;here 
    cos_pitch_angle=cos(!pi*dindgen(number_n_E_bin[i])/(number_n_E_bin[i]))

    
    e_beam_temp=mk_e_beam(loop.x,loop.axis[2,*], loop.B,$
                N_Part=number_n_E_bin[i],$;
                IP='z',$
                E_0=energies[i], $
                pitch_angle=acos(cos_pitch_angle))

    if n_elements(e_beam) eq 0 then e_beam=e_beam_temp $
      else e_beam=concat_struct(e_beam,e_beam_temp)
endfor

save, e_beam, file='initial_e_beam.sav'
;stop
original_beam=e_beam

;NEED TO THINK ABOUT THIS IMPLEMENTATION LATER
;

;We are at the beginning of the run so start out some counters at 0
beam_step=0
beam_on_time=0
sim_time=0
curr_beam_iter =0
counter=0
animate_index=0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;set_plot,'ps'
;device,/landscape,file='mirror_test.ps'
;p_old=!p.multi
;!p.multi=[0,1,2]
position_index=where(abs(e_beam[0].x-loop.x) eq $
                            min(abs(e_beam[0].x-loop.x)))
;;;;;;;;;;;;;;;;
;Main loop
;This loop spans the whole loop simulation time.
;Electron Beam injection
;Loop cooling post beam injection.
;Electron thermalization. etc.  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Keep the loop going until time's up
n_sim_iter=0l
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This is a loop nested in the main loop.  It will last as long as the
;beam is on


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;for MSULoop
outfile=outname
 
DELTA_E=dblarr(n_elements(loop.x))
momentum_profile=dblarr(n_elements(loop.x))
beam_struct={time:0d, e_beam:e_beam,$
             energy_profile:DELTA_E,$ 
             momentum_profile:momentum_profile}
    
;
animate_index=0
window,0,XSIZE=600   ,YSIZE=600  
window,1,XSIZE=600   ,YSIZE=600  
window,2,XSIZE=600   ,YSIZE=600 
window,3,XSIZE=600   ,YSIZE=600   
loadct,0
vary=dindgen(n_elements(e_beam))/(n_elements(e_beam))
WSET,0
   plot,loop.axis[1,*],loop.axis[2,*]+loop.rad,THICK=3 , $
          TITLE=plot_title,CHARSIZE=1.2,CHARTHICK=1.2 
        oplot,loop.axis[1,*],loop.axis[2,*],linestyle=2    
        oplot,loop.axis[1,*],loop.axis[2,*]-loop.rad,linestyle=0,THICK=3 
       
        loadct,color_table
        
        legend, Ticknames,psym=syms, $
          colors=[reverse(color_factor*(energies)+color_offset),255],charsize=1.5,charthick=1.5
        legend,['Time= '+string(0d,format='(d8.3)')+' sec'],$
          box=0,/right,charsize=1.5,charthick=1.5
        for beam_index=0, n_elements(e_beam)-1 do begin
            
            position_index=long(where(abs(e_beam[beam_index].x-loop.x) eq $
                            min(abs(e_beam[beam_index].x-loop.x))))
            plots,loop.AXIS[1,position_index[0]] ,$
              vary[beam_index]*2d0* $
              loop.RAD[position_index[0]]+(loop.AXIS[2,position_index[0]] $
              -loop.RAD[position_index[0]]), $
              psym=8, $
              color=color_factor*(e_beam[beam_index].ke_total),$
              SYMSIZE=1,THICK=2
        endfor;

    x2gif,strcompress(gif_dir+'particles'+string(animate_index,FORMAT='(I5.5)')+'.gif')
       
loadct,0
        
          
       wset,1;

       stateplot2, x,lhist[0] , /screen

      x2gif,strcompress(gif_dir+'hd'+string(animate_index,FORMAT='(I5.5)')+'.gif')
       wset,2
       energy_profile=dblarr(n_elements(loop.x))
       s_form=dblarr(n_elements(loop.x))
        plot, loop.x, energy_profile, Title='Power', $
          xtitle='loop length cm', ytitle= 'ergs s^-1', $
          CHARSIZE=1.2,CHARTHICK=1.2 
        legend,['Time= '+string(animate_index*delta_time,format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
        x2gif,strcompress(gif_dir+'power'+string(animate_index,FORMAT='(I5.5)')+'.gif')
       wset,3
        plot,x,s_form, Title='Power per Volume', $
            xtitle='loop length cm', ytitle= 'ergs cm ^-3 s^-1', $
          CHARSIZE=1.2,CHARTHICK=1.2 
        legend,['Time= '+string(animate_index*delta_time,format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
        
        x2gif,strcompress(gif_dir+'power_per_vol'+string(animate_index,FORMAT='(I5.5)')+'.gif')

animate_index=1

beam_counter=0
sim_time=0d
beam_on_time=0d
while sim_time le loop_time do begin
    time_step=delta_time
    loop=loop_struct[beam_counter].loop
        junk=where(e_beam.state eq 'NT')
        ;print,'junk',junk
        if junk[0] eq -1 then begin
            DELTA_MOMENTUM=dblarr(n_elements(loop.x))
            DELTA_E=dblarr(n_elements(loop.x))
            goto, skip_patc
        endif

        patc, e_beam,loop,time_step, DELTA_E=DELTA_E,$
          DELTA_MOMENTUM=DELTA_MOMENTUM

        skip_patc:

        temp_beam_struct={time:beam_on_time,$
                          e_beam:e_beam,$
                          energy_profile:DELTA_E ,$
                         momentum_profile:DELTA_MOMENTUM}

        beam_struct=concat_struct(beam_struct,temp_beam_struct)
       

        momentum_profile=-1d*DELTA_MOMENTUM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Whatever energy change the particles' had the plasma had to have an
;equal yet opposite delta E

        energy_profile=-1d*DELTA_E*keV_2_ergs*scale_factor

        print,'Total Energy', total(energy_profile), ' ergs'
        energy_profile=energy_profile/(time_step)

        print,'Total Power', total(energy_profile), ' ergs s^-1'
       
        if total(energy_profile) le 0d then begin
            print, 'No collision case'
            s_form=0
            m_form=0
            energy_profile=dblarr(n_elements(loop.x))
            s_form=dblarr(n_elements(x))
            goto, no_energy
        endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ergs s^-1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate volumes of each bit

        n=n_elements(A)
        volumes= 0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Put the energy and momentum where it goes for MSULoop

        s_form=dblarr(n_elements(x))
        m_form=dblarr(n_elements(x))
        for x_index=0, n_elements(loop.x)-1 do begin
            
            position_index=where(abs(loop.x[x_index]-x) eq $
                            min(abs(loop.x[x_index]-x)))
            s_form[position_index]=s_form[position_index]+energy_profile[x_index]
            m_form[position_index]=m_form[position_index]+momentum_profile[x_index]
        endfor
        s_form=abs(smooth((s_form/volumes), sm_width))

lhist[n_elements(lhist)-1].v=(lhist[n_elements(lhist)-1].v) $
  +(smooth(m_form, sm_width)/(lhist[n_elements(lhist)-1].n_e*volumes))
no_energy:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Put the energy and momentum where it goes for MSULoop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;start MSULoop code
lhist[n_elements(lhist)-1].e=abs(lhist[n_elements(lhist)-1].e)
lhist[n_elements(lhist)-1].n_e=abs(lhist[n_elements(lhist)-1].n_e)
old_lhist=lhist
junk=where((finite(s_form)) eq 0)
if junk[0] ne -1 then s_form[junk]=0d

old_lhist2=old_lhist[n_elements(lhist)-1]
       inname='temp.sav'
       save,lhist ,g,a,x,e_h,file=inname
       lhist=old_lhist
       q0=0.00700000
        ;regrid4, lhist,g,a,x,e_h, $
        ;   outfile=inname
        
        time_step=delta_time
        if max(s_form) le 0d then begin
          
              print,'No energy input!'
            evolve10_t,inname ,time_step ,time_step, $
              outfile=outfile, $
              computer=computer,$
              bgheat=q0 
        endif else begin
              print,'Energy input!'
                evolve10_t,inname ,time_step ,time_step, $
                  outfile=outfile, $ ;
                  s_form=s_form, $ ;q0=q0,
                  computer=computer,$
                  bgheat=q0 
            endelse


              
            restore, outfile

             n_lhist=n_elements(lhist)             
lhist[n_lhist-1].e=abs(lhist[n_lhist-1].e)
lhist[n_lhist-1].n_e=abs(lhist[n_lhist-1].n_e)
             for x_index=0, n_elements(loop.x)-1 do begin
                 
                 position_index=where(abs(x-loop.x[x_index]) eq $
                            min(abs(x-loop.x[x_index])))
                 loop.n_e[x_index]=lhist[n_lhist-1].n_e[position_index]
                 loop.e[x_index]=lhist[n_lhist-1].e[position_index]
             endfor

            temp_loop_struct={time: beam_on_time, loop:loop}

        loop_struct=concat_struct(loop_struct,temp_loop_struct)

       ; lhist=concat_struct(old_lhist, lhist)

        save,beam_struct,loop_struct,lhist,s_form,$
          file=save_file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;plot the particles' positions along the loop

       loadct,0    
       wset,0

        plot,loop.axis[1,*],loop.axis[2,*]+loop.rad,THICK=3 , $
          TITLE=plot_title,CHARSIZE=1.2,CHARTHICK=1.2
        oplot,loop.axis[1,*],loop.axis[2,*],linestyle=2    
        oplot,loop.axis[1,*],loop.axis[2,*]-loop.rad,linestyle=0,THICK=3 
        loadct,color_table
        
        legend, Ticknames,psym=syms, $
          colors=[reverse(color_factor*(energies)+color_offset),255],charsize=1.5,charthick=1.5
        legend,['Time= '+string(animate_index*delta_time,format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
        for beam_index=0, n_elements(e_beam)-1 do begin
            
            position_index=long(where(abs(e_beam[beam_index].x-loop.x) eq $
                            min(abs(e_beam[beam_index].x-loop.x))))
            if e_beam[beam_index].state eq 'NT' then begin
            plots,loop.AXIS[1,position_index[0]] ,$
              vary[beam_index]*2d0* $
              loop.RAD[position_index[0]]+(loop.AXIS[2,position_index[0]] $
              -loop.RAD[position_index[0]]), $
              psym=8,SYMSIZE=1, $
              color=color_factor*(e_beam[beam_index].ke_total),$
              THICK=2
        endif else begin
            plots,loop.AXIS[1,position_index[0]] ,$
              vary[beam_index]*2d0* $
              loop.RAD[position_index[0]]+(loop.AXIS[2,position_index[0]] $
              -loop.RAD[position_index[0]]), $
              psym=4,$
              SYMSIZE=1,THICK=1.5
        endelse
        
    endfor
    x2gif,strcompress(gif_dir+'particles'+string(animate_index,FORMAT='(I5.5)')+'.gif')
        loadct,0
        
          
       wset,1

       stateplot2, x,lhist[n_lhist-1] , /screen

       x2gif,strcompress(gif_dir+'hd'+string(animate_index,FORMAT='(I5.5)')+'.gif')
       wset,2
        plot, loop.x, energy_profile, Title='Power', $
          xtitle='loop length cm', ytitle= 'ergs s^-1', $
          CHARSIZE=1.2,CHARTHICK=1.2 
        legend,['Time= '+string(animate_index*delta_time,format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
        x2gif,strcompress(gif_dir+'power'+string(animate_index,FORMAT='(I5.5)')+'.gif')
       wset,3
        plot,x,s_form, Title='Power per Volume', $
            xtitle='loop length cm', ytitle= 'ergs cm ^-3 s^-1', $
          CHARSIZE=1.2,CHARTHICK=1.2 
        legend,['Time= '+string(animate_index*delta_time,format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
        
        x2gif,strcompress(gif_dir+'power_per_vol'+string(animate_index,FORMAT='(I5.5)')+'.gif')


       animate_index=animate_index+1

      
        beam_on_time=beam_on_time+time_step
        
       ; if beam_on_time le beam_time then begin
       ;     e_beam=concat_struct(e_beam,original_beam)
       ;     vary=[vary,vary]
        ;endif

    endwhile


end
