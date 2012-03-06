$unlimit
print, 'under construction by Jenna'
;11/3/2005
;hd_time_plots1
;Get the proper path for the PATC codes.
;Defined in .cshrc - make sure it is blah/PATC not blah/PATC/
patc_dir=getenv('PATC')
;Folder for where the simulation data is stored.
sub_folder='/runs/2005_12_2/'
;run_folder=strcompress(patc_dir+sub_folder,/REMOVE_ALL)
;print,run_folder
run_folder='/disk/data2/winter/PATC/runs/2005_12_2/'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Indicies to plot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

index1=0
index2=100
index3=175
set_plot,'x'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot characteristics
charthick=1
charsize=1.
xsize=7
ysize=7
window,0
;set_plot,'ps'
;device,/portrait,color=8,file='fig2.eps',$
;  /encaps,/HELV
; 
colorLevel = [[0, 0, 0], $ ; black  
   [255, 0, 0], $ ; red  
   [255, 255, 0], $ ; yellow  
   [0, 255, 0], $ ; green  
   [0, 255, 255], $ ; cyan  
   [0, 0, 255], $ ; blue  
   [255, 0, 255], $ ; magenta  
   [255, 255, 255]] ; white  
 
numberOfLevels = CEIL(!D.TABLE_SIZE/8.)  
level = INDGEN(!D.TABLE_SIZE)/numberOfLevels  
 

newRed = colorLevel[0, level]  
newGreen = colorLevel[1, level]  
newBlue = colorLevel[2, level]  


newRed[!D.TABLE_SIZE - 1] = 255  
newGreen[!D.TABLE_SIZE - 1] = 255  
newBlue[!D.TABLE_SIZE - 1] = 255 
  
yellow=95
blue=168
green=126
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Path to an IDL save file of a  magnetic loop
file1=strcompress(run_folder+'hd_out.sav',/REMOVE_ALL)
file2=strcompress(run_folder+'full_test_2.sav',/REMOVE_ALL)
restore,file1
restore,file2
beam_time=2d
;Total simulation time in seconds
loop_time=beam_time
;Total beam energy in ergs
Flare_energy=1d+28
time_step=0.05d ;[sec]
delta_time=time_step
color_table=39
plot_title='Model Loop Sim'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 loop=loop_struct[0].loop
loop.axis[1,*]=reverse(loop.axis[1,*])

;

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
scale_factor=100.
;window,0,xsize=xsize,ysize=ysize

 animate_index=0

record_temp=dindgen(n_elements(lhist),n_elements(lhist[0].e))
record_energy=dindgen(n_elements(lhist),n_elements(lhist[0].e)-1)
record_density=dindgen(n_elements(lhist),n_elements(lhist[0].e))

;;;;need a loop here to get the proper color tables change to array

     T = lhist.e/(3.0*lhist.n_e*kB)

     record_temp = T
     energy_profile = beam_struct.energy_profile*$
        (-1d*keV_2_ergs*scale_factor)/0.05d
      record_energy = energy_profile
      record_density = lhist.n_e

temp_difference=max(record_temp)-min(record_temp)
energy_difference=max(record_energy)-min(record_energy)
density_difference=max(record_density)-min(record_density)
print,'Temp max is: ',max(record_temp[*,0])
print,'Temp min is: ',min(record_temp)
print,'energy max is: ',max(record_energy)
print,'energy min is: ',min(record_energy)
print,'density max is: ',max(record_density)
print,'density min is: ',min(record_density)
;;pause
;make color choices for temperature
    T_color_factor=255/(temp_difference)
    temp_color_lower_bound=min(record_temp)*T_color_factor
    ntempcolors=255-temp_color_lower_bound
    scale_factor= T_color_factor
    scale_factor=(135./max(record_temp[*,0]))
;color choices for energy
    E_color_factor=240/(energy_difference/100)
    energy_color_lower_bound=min(record_energy)*E_color_factor
    nenergycolors=240-energy_color_lower_bound
;color choices for density
    D_color_factor=(240-100)/(density_difference)
    density_color_lower_bound=min(record_density)*D_color_factor
    ndensitycolors=240-density_color_lower_bound
    print,ndensitycolors
;pause
;for n_lhist=0, n_elements(lhist)-1 do begin
n_lhist=0
old_p_state=!p.multi
!p.multi=[0,2,2] ;position multiple plots 1 column and 4 rows
;!p.multi=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot a temperature loop with filled regions coresponding 
;  to the elements that are going to plotted out.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the temperature 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    T = lhist[n_lhist].e/(3.0* lhist[n_lhist].n_e*kB)
     ;record_temp[n_lhist,*]=t
        loadct,0
       	;Plot the Temperature
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;plot loop axes here
      z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
      z_max=z_max[0]
      theta=atan(abs(loop.axis[2,*]/loop.axis[1,*])) 
;this will give an angle
;less than Pi/2 but greater than 0

       plot,loop.axis[1,*],loop.axis[2,*],linestyle=2, $
         TITLE='Model Loop',$
          XTITLE='[cm]', YTITLE='[cm]',$
          yrange=[1d7,2d9],ystyle=1, $
         charthick=charthick, charsize=charsize,xticks=4

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
   
    T_color=T_color_factor*T
     T_color=scale_factor*T
red_temperature=3 ;this is what to call with loadct, and i have modified this
;color table using xpalette to make it more orange and less black       
 loadct,red_temperature

         num=n_elements(loop.x)
         z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
         z_max=z_max[0]
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

TVLCT, newRed, newGreen, newBlue 
kk=z_max+index1
polyfill,[REFORM(loop.axis[1,kk]+cos(theta[kk])*loop.rad[kk]), $
                     REFORM(loop.axis[1,kk]-cos(theta[kk])*loop.rad[kk]), $
                     REFORM(loop.axis[1,kk+6]-cos(theta[kk+6])*loop.rad[kk+6]), $
                     REFORM(loop.axis[1,kk+6]+cos(theta[kk+6])*loop.rad[kk+6])], $
             [REFORM(loop.axis[2,kk]-sin(theta[kk])*loop.rad[kk]), $
              REFORM(loop.axis[2,kk]+sin(theta[kk])*loop.rad[kk]), $
              REFORM(loop.axis[2,kk+1]+sin(theta[kk+1])*loop.rad[kk+1]), $
              REFORM(loop.axis[2,kk+1]-sin(theta[kk+1])*loop.rad[kk+1])], $
             color=yellow
       
kk=z_max+index2
polyfill,[REFORM(loop.axis[1,kk]+cos(theta[kk])*loop.rad[kk]), $
          REFORM(loop.axis[1,kk]-cos(theta[kk])*loop.rad[kk]), $
          REFORM(loop.axis[1,kk+6]-cos(theta[kk+6])*loop.rad[kk+6]), $
          REFORM(loop.axis[1,kk+6]+cos(theta[kk+6])*loop.rad[kk+6])], $
  [REFORM(loop.axis[2,kk]-sin(theta[kk])*loop.rad[kk]), $
   REFORM(loop.axis[2,kk]+sin(theta[kk])*loop.rad[kk]), $
   REFORM(loop.axis[2,kk+1]+sin(theta[kk+1])*loop.rad[kk+1]), $
   REFORM(loop.axis[2,kk+1]-sin(theta[kk+1])*loop.rad[kk+1])], $
  color=blue

kk=z_max+index3
polyfill,[REFORM(loop.axis[1,kk]+cos(theta[kk])*loop.rad[kk]), $
          REFORM(loop.axis[1,kk]-cos(theta[kk])*loop.rad[kk]), $
          REFORM(loop.axis[1,kk+4]-cos(theta[kk+4])*loop.rad[kk+4]), $
          REFORM(loop.axis[1,kk+4]+cos(theta[kk+4])*loop.rad[kk+4])], $
  [REFORM(loop.axis[2,kk]-sin(theta[kk])*loop.rad[kk]), $
   REFORM(loop.axis[2,kk]+sin(theta[kk])*loop.rad[kk]), $
   REFORM(loop.axis[2,kk+1]+sin(theta[kk+1])*loop.rad[kk+1]), $
   REFORM(loop.axis[2,kk+1]-sin(theta[kk+1])*loop.rad[kk+1])], $
  color=green


;loadct,0
time=lhist.time

THICK=3
T = lhist.e/(3.0*lhist.n_e*kB)
Temperatures=  t[z_max+index1,*]
plot,time,alog10(Temperatures),/nodata,$
  yrange=[4.0,7.5], XRANGE=[0,20],YSTYLE=1, $
  TITLE='Temperature Profile',$
  XTITLE='Time [sec]',$
  YTITLE='Log T [Kelvin]', $
  charthick=charthick, charsize=charsize,xticks=4,yticks=4


oplot,time,alog10(Temperatures),COLOR=yellow, $
  THICK=THICK
Temperatures=  t[z_max+index2,*]
oplot,time,alog10(Temperatures),COLOR=blue, $
  THICK=THICK
Temperatures=  t[z_max+index3,*]
oplot,time,alog10(Temperatures),COLOR=green, $
  THICK=THICK


HEIGHT=ALOG10(MAX([lhist.n_e[z_max+index1,*],lhist.n_e[z_max+index2,*],lhist.n_e[z_max+index3,*] ]))
LOW=ALOG10(MIN([lhist.n_e[z_max+index1,*],lhist.n_e[z_max+index2,*],lhist.n_e[z_max+index3,*]] ))

plot, time,ALOG10(lhist.n_e[z_max+index3]),YSTYLE=1, /NODATA, $
  yrange=[LOW,HEIGHT ], XRANGE=[0,20], $
  TITLE='Electron Density Profile',$
  XTITLE='Time [sec]',$
  YTITLE='Log N!De!N [cm!E-3!N]', $
  charthick=charthick, charsize=charsize,xticks=4,yticks=4
oplot,time,ALOG10(lhist.n_e[z_max+index1,*]),COLOR=yellow, $
  THICK=THICK
oplot,time,ALOG10(lhist.n_e[z_max+index2,*]),COLOR=blue, $
  THICK=THICK
oplot,time,ALOG10(lhist.n_e[z_max+index3,*]),COLOR=green, $
  THICK=THICK

SCALE_FACTOR =    2.0621876d+31

energy_dep=float(-1d*beam_struct.ENERGY_PROFILE*keV_2_ergs*scale_factor)
pmm, energy_dep
index3=index3-5
HEIGHT=max([energy_dep[z_max+index1,*],$
            energy_dep[z_max+index2,*],$
            energy_dep[z_max+index3,*]])
low=min([energy_dep[z_max+index1,*],$
            energy_dep[z_max+index2,*],$
            energy_dep[z_max+index3,*]])

;plot, time,energy_dep[z_max+index1,*],YSTYLE=1, /NODATA, $
;  yrange=[low,HEIGHT ], XRANGE=[0,20], $
;  TITLE='Energy Deposition Profile',$
;  XTITLE='Time [sec]',$
;  YTITLE='ergs', $
;  charthick=charthick, charsize=charsize,xticks=4,yticks=4
;oplot,time,energy_dep[z_max+index1,*],COLOR=yellow, $
;  THICK=THICK
;oplot,time,energy_dep[z_max+index2,*],COLOR=blue, $
;  THICK=THICK
;oplot,time,energy_dep[z_max+index3,*],COLOR=green, $
;  THICK=THICK


!p.multi=old_p_state
END
