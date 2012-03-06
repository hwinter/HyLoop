 
print, 'the correct one'
;04/30/2005
;Get the proper path for the PATC codes.
;Defined in .cshrc
;emission_display_3.pro
patc_dir=getenv('PATC')
;Folder for where the simulation data is stored.
sub_folder='/2005_09_20_exp_loop/'

run_folder=strcompress(patc_dir+sub_folder,/REMOVE_ALL)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Where to write the gifs to make the movie
gif_dir=strcompress(run_folder+'gifs/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Switch.  -1=Delete gifs 1=Keep 'um
Keep_gifs=-1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Path to an IDL save file of a loop magnetic loop
file1=strcompress(run_folder+'hd_out.sav',/REMOVE_ALL)
;file2=dialog_pickfile()
;print,file2
file2=strcompress(run_folder+'full_test_1.sav',/REMOVE_ALL)

;file1='hd_out.sav'
;file2='full_test_1.sav'
restore, file1
restore, file2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
beam_time=1d
;Total simulation time in seconds
loop_time=beam_time
;Total beam energy in ergs
Flare_energy=1d+28
time_step=0.05d ;[sec]
delta_time=time_step
color_table=39
plot_title='Model Loop Sim'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine the flux of particles in each energy bin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Spectral index of input electron distribution
delta_index=3d
energies=[20d,25d,30d,35d,40d,45d,50d]
;energies=[20d,50d]
num_test_particles=(100d)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

!p.multi=[0,2,2]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;plot the particles' positions along the loop
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
N = n_elements(lhist[n_lhist].v) 
;x on the volume element grid (like e, n_e)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 x_alt = [2*x[0]-x[1],(x[0:N-3]+x[1:N-2])/2.0,2*x[N-2]-x[N-3]]
       loop=loop_struct[n_lhist].loop
       loadct,0
e_beam=beam_struct[n_lhist].e_beam
vary=dindgen(n_elements(e_beam))/(n_elements(e_beam))
        plot,loop.axis[1,*],loop.axis[2,*]+loop.rad,THICK=3 , $
          TITLE=plot_title,CHARSIZE=1.2,CHARTHICK=1.2
        oplot,loop.axis[1,*],loop.axis[2,*],linestyle=2    
        oplot,loop.axis[1,*],loop.axis[2,*]-loop.rad,linestyle=0,THICK=3 
        loadct,color_table
;        
        legend, Ticknames,psym=syms, $
          colors=[reverse(color_factor*(energies)+color_offset),255],charsize=1.5,charthick=1.5
        legend,['Time= '+string(animate_index*delta_time,format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5


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
    pmm,t
        loadct,0
       	;Plot the Temperature
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	plot, x_alt,T, $
		xrange=[1e5,max(x_alt)], $;yrange=[3e3,2e7],/ystyle, $
		;position=[0.5+d,0+b,1-c,0.5-c], $
		TITLE="Temperature Profile", $
		ytitle='T (K)', xtitle='Loop Length (cm)', $
		charsize=1.2,CHARTHICK=1.2 ,LINESTYLE=0 ,$
		yrange=[100000,6d6], /ystyle; ,/noerase
        legend,['Time= '+string(animate_index*delta_time,format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the energy profile of the beam
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      energy_profile=beam_struct[n_lhist].energy_profile*(-1d*keV_2_ergs*scale_factor)/0.05d

      plot, loop.x, energy_profile, Title='Power Deposited Along the Loop', $
          xtitle='Loop Length cm', ytitle= 'ergs s^-1', $
          CHARSIZE=1.2,CHARTHICK=1.2 
        legend,['Time= '+string(animate_index*delta_time,format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the current screen a gif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      x2gif,strcompress(gif_dir+'big_movie'+string(animate_index,FORMAT='(I5.5)')+'.gif')
;print,tresponse;

     animate_index=animate_index+1

      
      beam_on_time=beam_on_time+time_step
    
  endfor

gifs=findfile(strcompress(gif_dir+'*.gif'))
BREAK_FILE, gifs[0], DISK_LOG, DIR, FILNAM, EXT

image2movie, gifs, movie_name=strcompress(gif_dir+'emission_movie.gif',/REMOVE_ALL), $
  gif_animate=1,nodelete=keep_gifs,/loop

end

        
