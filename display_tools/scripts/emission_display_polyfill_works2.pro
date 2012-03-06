 
;emission_display_3.pro
print, 'under construction by Jenna'
;10/04/2005
;Get the proper path for the PATC codes.
;Defined in .cshrc - make sure it is blah/PATC not blah/PATC/
patc_dir=getenv('PATC')
;Folder for where the simulation data is stored.
sub_folder='/2005_09_20_exp_loop/'
run_folder=strcompress(patc_dir+sub_folder,/REMOVE_ALL)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Where to write the gifs to make the movie
gif_dir=strcompress(run_folder+'gifs/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Switch.  O=Delete gifs 1=Keep 'um
Keep_gifs=0
;This currently does not work - need to figure this out so the gifs
;are deleted
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Path to an IDL save file of a  magnetic loop
file1=strcompress(run_folder+'hd_out.sav',/REMOVE_ALL)
;file2=dialog_pickfile()
;print,file2
file2=strcompress(run_folder+'full_test_1.sav',/REMOVE_ALL)
print,'The magnetic loop file is: ',file1
print,'The other file is: ',file2

;print restored variables, just for kicks
restore, file1,/verbose
restore, file2,/verbose
beam_time=1d
;Total simulation time in seconds
loop_time=beam_time
;Total beam energy in ergs
Flare_energy=1d+28
time_step=0.05d ;[sec]
delta_time=time_step
color_table=39
plot_title='Model Loop Sim'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine the flux of particles in each energy bin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Spectral index of input electron distribution
delta_index=3d
energies=[20d,25d,30d,35d,40d,45d,50d]
num_test_particles=(100d)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the number of iterations you are going to
;   need for your electron beam.
N_beam_iter=long(beam_time/time_step)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

percent=double(energies^(-delta_index))/ $
  max(energies^(-delta_index))

;junk=where( (percent mod 1) ge .5 ) 
;if junk[0] ne -1 then percent[junk]=percent[junk]+1d

number_n_E_bin=long(percent*num_test_particles)
junk=where(number_n_E_bin le 0)
if junk[0] ne -1 then number_n_E_bin[junk] =1L

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End of flux of particles in each energy bin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Let's make some color choices for the displays
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
kb=k_boltz_ergs
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
 BEAM_ON_TIME=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_plot,'x'
window,0,xsize=1200,ysize=1200

 animate_index=0
for n_lhist=0, n_elements(lhist)-1 do begin

!p.multi=[0,2,2] ;position multiple plots 2 rows and 2 columns
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;plot the particles' positions along the loop
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
N = n_elements(lhist[n_lhist].v) 
;x on the volume element grid (like e, n_e)
;x is a variable saved in the save file /hd_out.sav
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 x_alt = [2*x[0]-x[1],(x[0:N-3]+x[1:N-2])/2.0,2*x[N-2]-x[N-3]]
       loop=loop_struct[n_lhist].loop
       loadct,0
e_beam=beam_struct[n_lhist].e_beam
vary=dindgen(n_elements(e_beam))/(n_elements(e_beam))
      z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
      z_max=z_max[0]
      print,z_max
      theta=atan(abs(loop.axis[2,*]/loop.axis[1,*])) 
;this will give an angle
;less than Pi/2 but greater than 0

       plot,loop.axis[1,*],loop.axis[2,*],linestyle=2, $
         TITLE=plot_title,CHARSIZE=1.2,CHARTHICK=1.2,yrange=[0,2d9],ystyle=1

       ;plot right part of loop
        oplot,loop.axis[1,0:z_max]+cos(theta[0:z_max])*loop.rad[0:z_max],$
         loop.axis[2,0:z_max]+sin(theta[0:z_max])*loop.rad[0:z_max],$
          thick=3
        oplot,loop.axis[1,0:z_max]-cos(theta[0:z_max])*loop.rad[0:z_max],$
          loop.axis[2,0:z_max]-sin(theta[0:z_max])*loop.rad[0:z_max],$
          thick=3

      ;plot left part of loop
        oplot,loop.axis[1,z_max:*]-cos(theta[z_max:*])*loop.rad[z_max:*],$
         loop.axis[2,z_max:*]+sin(theta[z_max:*])*loop.rad[z_max:*],$
          thick=2
           oplot,loop.axis[1,z_max:*]+cos(theta[z_max:*])*loop.rad[z_max:*],$
         loop.axis[2,z_max:*]-sin(theta[z_max:*])*loop.rad[z_max:*],$
         thick=2

        loadct,color_table
;
        legend, Ticknames,psym=syms, $
          colors=[reverse(color_factor*(energies)+color_offset),255],$
          charsize=1.5,charthick=1.5
        legend,['Time= '+string(animate_index*delta_time,$
            format='(d8.3)')+' sec'],box=0,/right,charsize=2,charthick=1.5


        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;plot the particles' positions along the loop
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        for beam_index=0, n_elements(e_beam)-1 do begin
            
            position_index=long(where(abs(e_beam[beam_index].x-x_alt) eq $
                            min(abs(e_beam[beam_index].x-x_alt))))
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;end of plot the particles' positions along the loop
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the temperature 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    T = lhist[n_lhist].e/(3.0* lhist[n_lhist].n_e*kB)
    
        loadct,0
       	;Plot the Temperature
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;plot loop axes here
 z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
      z_max=z_max[0]
      print,z_max
      theta=atan(abs(loop.axis[2,*]/loop.axis[1,*])) 
;this will give an angle
;less than Pi/2 but greater than 0

       plot,loop.axis[1,*],loop.axis[2,*],linestyle=2, $
         TITLE='Temperature Profile',CHARSIZE=1.2,CHARTHICK=1.2,$
          yrange=[0,2d9],ystyle=1

       ;plot right part of loop
        oplot,loop.axis[1,0:z_max]+cos(theta[0:z_max])*loop.rad[0:z_max],$
         loop.axis[2,0:z_max]+sin(theta[0:z_max])*loop.rad[0:z_max],$
          thick=3
        oplot,loop.axis[1,0:z_max]-cos(theta[0:z_max])*loop.rad[0:z_max],$
          loop.axis[2,0:z_max]-sin(theta[0:z_max])*loop.rad[0:z_max],$
          thick=3

      ;plot left part of loop
        oplot,loop.axis[1,z_max:*]-cos(theta[z_max:*])*loop.rad[z_max:*],$
         loop.axis[2,z_max:*]+sin(theta[z_max:*])*loop.rad[z_max:*],$
          thick=2
           oplot,loop.axis[1,z_max:*]+cos(theta[z_max:*])*loop.rad[z_max:*],$
         loop.axis[2,z_max:*]-sin(theta[z_max:*])*loop.rad[z_max:*],$
         thick=2

 ;;;;;Define colors;;;;
    new_color_lower_bound=0
    T_color_factor=(200-new_color_lower_bound)/(max(T)-min(T))
    T_color_offset=200-color_factor
    T_color=T_color_factor*T+T_color_offset
red_temperature=3 ;this is what to call with loadct, and i have modified this
;color table using xpalette to make it more orange and less black       
 loadct,red_temperature

         num=n_elements(loop.x)
         z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
         z_max=z_max[0]
         ;for ii=200,204 do begin
         for ii=0,z_max do begin
           polyfill,[REFORM(loop.axis[1,ii]-cos(theta[ii])*loop.rad[ii]),$
                     REFORM(loop.axis[1,ii]+cos(theta[ii])*loop.rad[ii]),$
                    REFORM(loop.axis[1,ii+1]+cos(theta[ii+1])*loop.rad[ii+1]),$
                   REFORM(loop.axis[1,ii+1]-cos(theta[ii+1])*loop.rad[ii+1])],$
             [REFORM(loop.axis[2,ii]-sin(theta[ii])*loop.rad[ii]),$
                REFORM(loop.axis[2,ii]+sin(theta[ii])*loop.rad[ii]),$
                REFORM(loop.axis[2,ii+1]+sin(theta[ii+1])*loop.rad[ii+1]),$
                  REFORM(loop.axis[2,ii+1]-sin(theta[ii+1])*loop.rad[ii+1])],$
                color=T_color[ii]    
       endfor
       for ii=z_max+1,num-2 do begin
           polyfill,[REFORM(loop.axis[1,ii]+cos(theta[ii])*loop.rad[ii]),$
                     REFORM(loop.axis[1,ii]-cos(theta[ii])*loop.rad[ii]),$
                    REFORM(loop.axis[1,ii+1]-cos(theta[ii+1])*loop.rad[ii+1]),$
                   REFORM(loop.axis[1,ii+1]+cos(theta[ii+1])*loop.rad[ii+1])],$
             [REFORM(loop.axis[2,ii]-sin(theta[ii])*loop.rad[ii]),$
                REFORM(loop.axis[2,ii]+sin(theta[ii])*loop.rad[ii]),$
                REFORM(loop.axis[2,ii+1]+sin(theta[ii+1])*loop.rad[ii+1]),$
                 REFORM(loop.axis[2,ii+1]-sin(theta[ii+1])*loop.rad[ii+1])],$
                color=T_color[ii]
       endfor

        legend,['Time= '+string(animate_index*delta_time,$
                                format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
        
         ;plots,loop.axis[1,*],T+loop.axis[2,*]
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the energy profile of the beam
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      energy_profile=beam_struct[n_lhist].energy_profile*$
        (-1d*keV_2_ergs*scale_factor)/0.05d
      

;plot loop axes here
       z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
      z_max=z_max[0]
      print,z_max
      theta=atan(abs(loop.axis[2,*]/loop.axis[1,*])) 
;this will give an angle
;less than Pi/2 but greater than 0

       plot,loop.axis[1,*],loop.axis[2,*],linestyle=2, $
         TITLE='Energy Profile',CHARSIZE=1.2,CHARTHICK=1.2,$
         yrange=[0,2d9],ystyle=1

       ;plot right part of loop
        oplot,loop.axis[1,0:z_max]+cos(theta[0:z_max])*loop.rad[0:z_max],$
         loop.axis[2,0:z_max]+sin(theta[0:z_max])*loop.rad[0:z_max],$
          thick=3
        oplot,loop.axis[1,0:z_max]-cos(theta[0:z_max])*loop.rad[0:z_max],$
          loop.axis[2,0:z_max]-sin(theta[0:z_max])*loop.rad[0:z_max],$
          thick=3

      ;plot left part of loop
        oplot,loop.axis[1,z_max:*]-cos(theta[z_max:*])*loop.rad[z_max:*],$
         loop.axis[2,z_max:*]+sin(theta[z_max:*])*loop.rad[z_max:*],$
          thick=2
           oplot,loop.axis[1,z_max:*]+cos(theta[z_max:*])*loop.rad[z_max:*],$
         loop.axis[2,z_max:*]-sin(theta[z_max:*])*loop.rad[z_max:*],$
         thick=2

 ;;;;;Define colors;;;;
    new_color_lower_bound=110
E=energy_profile
print,'energy difference is:',max(e)-min(e)
difference=(max(e)-min(e))/10d23
    E_color_factor=(255-new_color_lower_bound)/double(difference)
    E_color_offset=255-color_factor
    E_color=E_color_factor*E+E_color_offset

 loadct,color_table ;use same as for the electron energies

         num=n_elements(loop.x)
         z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
         z_max=z_max[0]
         ;for ii=200,204 do begin
         for ii=0,z_max do begin
           polyfill,[REFORM(loop.axis[1,ii]-cos(theta[ii])*loop.rad[ii]),$
                     REFORM(loop.axis[1,ii]+cos(theta[ii])*loop.rad[ii]),$
                    REFORM(loop.axis[1,ii+1]+cos(theta[ii+1])*loop.rad[ii+1]),$
                   REFORM(loop.axis[1,ii+1]-cos(theta[ii+1])*loop.rad[ii+1])],$
             [REFORM(loop.axis[2,ii]-sin(theta[ii])*loop.rad[ii]),$
                REFORM(loop.axis[2,ii]+sin(theta[ii])*loop.rad[ii]),$
                REFORM(loop.axis[2,ii+1]+sin(theta[ii+1])*loop.rad[ii+1]),$
                  REFORM(loop.axis[2,ii+1]-sin(theta[ii+1])*loop.rad[ii+1])],$
                color=T_color[ii]    
       endfor
       for ii=z_max+1,num-2 do begin
           polyfill,[REFORM(loop.axis[1,ii]+cos(theta[ii])*loop.rad[ii]),$
                     REFORM(loop.axis[1,ii]-cos(theta[ii])*loop.rad[ii]),$
                    REFORM(loop.axis[1,ii+1]-cos(theta[ii+1])*loop.rad[ii+1]),$
                   REFORM(loop.axis[1,ii+1]+cos(theta[ii+1])*loop.rad[ii+1])],$
             [REFORM(loop.axis[2,ii]-sin(theta[ii])*loop.rad[ii]),$
                REFORM(loop.axis[2,ii]+sin(theta[ii])*loop.rad[ii]),$
                REFORM(loop.axis[2,ii+1]+sin(theta[ii+1])*loop.rad[ii+1]),$
                 REFORM(loop.axis[2,ii+1]-sin(theta[ii+1])*loop.rad[ii+1])],$
                color=T_color[ii]
       endfor

        legend,['Time= '+string(animate_index*delta_time,$
                                format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the electron density
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;plot loop axes here
 z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
      z_max=z_max[0]
      print,z_max
      theta=atan(abs(loop.axis[2,*]/loop.axis[1,*])) 
;this will give an angle
;less than Pi/2 but greater than 0

       plot,loop.axis[1,*],loop.axis[2,*],linestyle=2, $
         TITLE=plot_title,CHARSIZE=1.2,CHARTHICK=1.2,yrange=[0,2d9],ystyle=1

       ;plot right part of loop
        oplot,loop.axis[1,0:z_max]+cos(theta[0:z_max])*loop.rad[0:z_max],$
         loop.axis[2,0:z_max]+sin(theta[0:z_max])*loop.rad[0:z_max],$
          thick=3
        oplot,loop.axis[1,0:z_max]-cos(theta[0:z_max])*loop.rad[0:z_max],$
          loop.axis[2,0:z_max]-sin(theta[0:z_max])*loop.rad[0:z_max],$
          thick=3

      ;plot left part of loop
        oplot,loop.axis[1,z_max:*]-cos(theta[z_max:*])*loop.rad[z_max:*],$
         loop.axis[2,z_max:*]+sin(theta[z_max:*])*loop.rad[z_max:*],$
          thick=2
           oplot,loop.axis[1,z_max:*]+cos(theta[z_max:*])*loop.rad[z_max:*],$
         loop.axis[2,z_max:*]-sin(theta[z_max:*])*loop.rad[z_max:*],$
         thick=2

 ;;;;;Define colors;;;;
    new_color_lower_bound=110
D=lhist[n_lhist].n_e[*]

difference=(max(D)-min(D))/10d23
    D_color_factor=(255-new_color_lower_bound)/double(difference)
    D_color_offset=255-color_factor
    D_color=E_color_factor*E+E_color_offset
density_colors=2
 loadct,density_colors ;use blue/white

         num=n_elements(loop.x)
         z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
         z_max=z_max[0]
         ;for ii=200,204 do begin
         for ii=0,z_max do begin
           polyfill,[REFORM(loop.axis[1,ii]-cos(theta[ii])*loop.rad[ii]),$
                     REFORM(loop.axis[1,ii]+cos(theta[ii])*loop.rad[ii]),$
                    REFORM(loop.axis[1,ii+1]+cos(theta[ii+1])*loop.rad[ii+1]),$
                   REFORM(loop.axis[1,ii+1]-cos(theta[ii+1])*loop.rad[ii+1])],$
             [REFORM(loop.axis[2,ii]-sin(theta[ii])*loop.rad[ii]),$
                REFORM(loop.axis[2,ii]+sin(theta[ii])*loop.rad[ii]),$
                REFORM(loop.axis[2,ii+1]+sin(theta[ii+1])*loop.rad[ii+1]),$
                  REFORM(loop.axis[2,ii+1]-sin(theta[ii+1])*loop.rad[ii+1])],$
                color=T_color[ii]    
       endfor
       for ii=z_max+1,num-2 do begin
           polyfill,[REFORM(loop.axis[1,ii]+cos(theta[ii])*loop.rad[ii]),$
                     REFORM(loop.axis[1,ii]-cos(theta[ii])*loop.rad[ii]),$
                    REFORM(loop.axis[1,ii+1]-cos(theta[ii+1])*loop.rad[ii+1]),$
                   REFORM(loop.axis[1,ii+1]+cos(theta[ii+1])*loop.rad[ii+1])],$
             [REFORM(loop.axis[2,ii]-sin(theta[ii])*loop.rad[ii]),$
                REFORM(loop.axis[2,ii]+sin(theta[ii])*loop.rad[ii]),$
                REFORM(loop.axis[2,ii+1]+sin(theta[ii+1])*loop.rad[ii+1]),$
                 REFORM(loop.axis[2,ii+1]-sin(theta[ii+1])*loop.rad[ii+1])],$
                color=T_color[ii]
       endfor
    
        legend,['Time= '+string(animate_index*delta_time,$
                                format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the current screen a gif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      x2gif,strcompress(gif_dir+'big_movie'+string(animate_index,FORMAT=$
      '(I5.5)')+'.gif')
;print,tresponse;

     animate_index=animate_index+1

      
      beam_on_time=beam_on_time+time_step
    
  endfor

gifs=findfile(strcompress(gif_dir+'*.gif'))
BREAK_FILE, gifs[0], DISK_LOG, DIR, FILNAM, EXT

image2movie,gifs,$
  movie_name=strcompress(gif_dir+'emission_movie.gif',/REMOVE_ALL), $
  gif_animate=1,nodelete=keep_gifs,/loop

end
