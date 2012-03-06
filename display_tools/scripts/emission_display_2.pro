 
print, 'the correct one'
patc_dir=getenv('PATC')
;04/30/2005
patc_dir=getenv('PATC')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Path to an IDL save file of a loop magnetic loop
start_file=patc_dir+'loop_data/exp_b_scl.start'
loop_file=patc_dir+'loop_data/exp_b_scl.sav'
save_file=patc_dir+'/full_test_1.sav'

file1='/Users/winter/PATC/2005_05_20_exp_loop/hd_out.sav'
;file2=dialog_pickfile()
;print,file2
file2='/Users/winter/PATC/2005_05_20_exp_loop/full_test_1.sav'

file1='hd_out.sav'
file2='full_test_1.sav'
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
run_folder=strcompress(patc_dir+'2005_05_20_final_exp_loop/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Give an output filename for the HD code. .sav will be added
outname=strcompress(run_folder+'hd_out.sav')

gif_dir=strcompress(run_folder)
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
!p.multi=[0,2,2]

 animate_index=0   
for n_lhist=0, n_elements(lhist)-1 do begin
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
		yrange=[100000,3d7], /ystyle; ,/noerase
        legend,['Time= '+string(animate_index*delta_time,format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
	; 
      energy_profile=beam_struct[n_lhist].energy_profile*(-1d*keV_2_ergs*scale_factor)/0.05d

      plot, loop.x, energy_profile, Title='Power Deposited Along the Loop', $
          xtitle='Loop Length cm', ytitle= 'ergs s^-1', $
          CHARSIZE=1.2,CHARTHICK=1.2 
        legend,['Time= '+string(animate_index*delta_time,format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
         
        ;plot,loop.x,line,/xstyle,/ystyle, TITLE='mirror test', $
         ;    XTITLE='X position along loop [cm]',$
         ;    yrange=[-1,1], XRANGE=[0D,max(loop.x)]  
         plot,loop.axis[1,*],loop.axis[2,*]+loop.rad,linestyle=0,$
           TITLE='TRACE 195 Response', charsize=1.2,CHARTHICK=1.2,$
           xTITLE='Exponential Cartoon loop',/NODATA

         oplot,loop.axis[1,*],loop.axis[2,*]+loop.rad,THICK=3
         oplot,loop.axis[1,*],loop.axis[2,*]-loop.rad,linestyle=0,THICK=3  
 
        legend,['Time= '+string(animate_index*delta_time,format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the region where the B field strength is about the same as the B_mp     
        ;plots,loop.AXIS[1,mp.mp_ind_1] ,loop.AXIS[2,mp.mp_ind_1],PSYM=3,$
        ;  COLOR=3,SYMSIZE=2,THICK=4
         trace_colors,195, r, g, b, $
          load=1
        n=n_elements(A)
        volumes= 0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))
        
         for index2=0, n_elements(loop.x)-3 do begin
            position_index=long(where(abs(loop.x[index2+1]-x_alt) eq $
                            min(abs(loop.x[index2+1]-x_alt))))
            n_e=lhist[n_lhist].n_e[position_index]
            t_e=t[position_index]
         result=trace_t_resp('195oa', T_e)
         em=(n_e^2)*volumes[position_index]
         tresponse=result*em
         polyfill,[ REFORM(loop.AXIS[1,index2 ]),$
                   REFORM(loop.AXIS[1,index2]),REFORM(loop.AXIS[1,index2+1]),$
                   REFORM(loop.AXIS[1,index2+1]) ],$
          [REFORM(loop.AXIS[2,index2]-loop.RAD[index2]), $
           REFORM(loop.AXIS[2,index2]+loop.RAD[index2]), REFORM(loop.AXIS[2,index2+1]+loop.RAD[index2+1]) ,$
           REFORM(loop.AXIS[2,index2]-loop.RAD[index2]) ], $
          COLOR=n_lhist , /FILL_PATTERN;/LINE_FILL
        endfor
        loadct,0
        x2gif,strcompress(gif_dir+'big_movie'+string(animate_index,FORMAT='(I5.5)')+'.gif')


       animate_index=animate_index+1

      
       beam_on_time=beam_on_time+time_step
    
endfor

end

        
