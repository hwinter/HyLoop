 
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
       ;loop=loop_struct[n_lhist].loop
 loop=loop_struct[0].loop
       loadct,0
e_beam=beam_struct[n_lhist].e_beam
vary=dindgen(n_elements(e_beam))/(n_elements(e_beam))
      z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
      z_max=z_max[0]
      theta=atan(abs(loop.axis[2,*]/loop.axis[1,*])) 
;this will give an angle
;less than Pi/2 but greater than 0
time_stamp=lhist[n_lhist].time
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
          charsize=1.5,charthick=1.5,position=[.225,.77],/norm
        legend,['Time= '+string(time_stamp,$
            format='(d8.3)')+' sec'],box=0,/right,charsize=1.5,charthick=1.5

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
   
    T_color=T_color_factor*T
red_temperature=3 ;this is what to call with loadct, and i have modified this
;color table using xpalette to make it more orange and less black       
 loadct,red_temperature
colorbar, title='Cold      Temp (10e5 K)         Hot',ncolors=ntempcolors,$
        position=[0.68,0.62,0.88,0.67],max=max(record_temp)/10d4,divisions=2
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

        legend,['Time= '+string(time_stamp,$
                                format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
        
         ;plots,loop.axis[1,*],T+loop.axis[2,*]
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the energy profile of the beam
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      energy_profile=beam_struct[n_lhist].energy_profile*$
        (-1d*keV_2_ergs*scale_factor)/0.05d
      ;record_energy[n_lhist,*]=energy_profile

;plot loop axes here
       z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
      z_max=z_max[0]
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
E=energy_profile
E_color=E_color_factor*E;+100 ;get rid of black

energy_colors = 9 ;green exp
 loadct,energy_colors ;use same as for the electron energies
colorbar,title='Power(10e23 erg s^-1 cm^-3',divisions=2,$
       position=[0.18,0.12,0.38,0.17],max=max(record_energy)/10d23,$
       bottom=energy_color_lower_bound,ncolors=nenergycolors
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
                color=E_color[ii]    
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
                color=E_color[ii]
       endfor

        legend,['Time= '+string(time_stamp,$
                                format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the electron density
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;record_density[n_lhist,*]=lhist[n_lhist].n_e

;        ;plot loop axes here
;      z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
;      z_max=z_max[0]
;      theta=atan(abs(loop.axis[2,*]/loop.axis[1,*])) 
;this will give an angle
;less than Pi/2 but greater than 0
;
;       plot,loop.axis[1,*],loop.axis[2,*],linestyle=2, $
;         TITLE='Density',CHARSIZE=1.2,CHARTHICK=1.2,yrange=[0,2d9],ystyle=1;
;
;       ;plot right part of loop
;        oplot,loop.axis[1,0:z_max]+cos(theta[0:z_max])*loop.rad[0:z_max],$
;         loop.axis[2,0:z_max]+sin(theta[0:z_max])*loop.rad[0:z_max],$
;          thick=3
;        oplot,loop.axis[1,0:z_max]-cos(theta[0:z_max])*loop.rad[0:z_max],$
;          loop.axis[2,0:z_max]-sin(theta[0:z_max])*loop.rad[0:z_max],$
;          thick=3;

      ;plot left part of loop
;        oplot,loop.axis[1,z_max:*]-cos(theta[z_max:*])*loop.rad[z_max:*],$
;         loop.axis[2,z_max:*]+sin(theta[z_max:*])*loop.rad[z_max:*],$
;          thick=2
 ;          oplot,loop.axis[1,z_max:*]+cos(theta[z_max:*])*loop.rad[z_max:*],$
;         loop.axis[2,z_max:*]-sin(theta[z_max:*])*loop.rad[z_max:*],$
 ;        thick=2

 ;;;;;Define colors;;;;
 ;   D=lhist[n_lhist].n_e
;print,d
 ;   D_color=D_color_factor*(D/10d9)+100 ;add fifty to get rid of black
;density_colors=15
 ;loadct,density_colors ;use blue/white, 
;colorbar, title='Low    Density (10e9)     High',divisions=2,$
;        position=[0.68,0.12,0.88,0.17],max=max(record_density)/10d9,$
;        bottom=density_color_lower_bound;,ncolors=ndensitycolors,format='(e2.3)'
;         num=n_elements(loop.x)
;         z_max=where(loop.axis[2,*] EQ max(loop.axis[2,*]))
;         z_max=z_max[0]
;         ;for ii=200,204 do begin
;         for ii=0,z_max do begin
;           polyfill,[REFORM(loop.axis[1,ii]-cos(theta[ii])*loop.rad[ii]),$
;                     REFORM(loop.axis[1,ii]+cos(theta[ii])*loop.rad[ii]),$
;                    REFORM(loop.axis[1,ii+1]+cos(theta[ii+1])*loop.rad[ii+1]),$
;                   REFORM(loop.axis[1,ii+1]-cos(theta[ii+1])*loop.rad[ii+1])],$
;             [REFORM(loop.axis[2,ii]-sin(theta[ii])*loop.rad[ii]),$
;                REFORM(loop.axis[2,ii]+sin(theta[ii])*loop.rad[ii]),$
;                REFORM(loop.axis[2,ii+1]+sin(theta[ii+1])*loop.rad[ii+1]),$
;                  REFORM(loop.axis[2,ii+1]-sin(theta[ii+1])*loop.rad[ii+1])],$
;                color=D_color[ii]    
;       endfor
;       for ii=z_max+1,num-2 do begin
;           polyfill,[REFORM(loop.axis[1,ii]+cos(theta[ii])*loop.rad[ii]),$
;                     REFORM(loop.axis[1,ii]-cos(theta[ii])*loop.rad[ii]),$
;                    REFORM(loop.axis[1,ii+1]-cos(theta[ii+1])*loop.rad[ii+1]),$
;                   REFORM(loop.axis[1,ii+1]+cos(theta[ii+1])*loop.rad[ii+1])],$
;             [REFORM(loop.axis[2,ii]-sin(theta[ii])*loop.rad[ii]),$
;                REFORM(loop.axis[2,ii]+sin(theta[ii])*loop.rad[ii]),$
;                REFORM(loop.axis[2,ii+1]+sin(theta[ii+1])*loop.rad[ii+1]),$
;                 REFORM(loop.axis[2,ii+1]-sin(theta[ii+1])*loop.rad[ii+1])],$
;                color=D_color[ii]
;       endfor
;    
;        legend,['Time= '+string(time_stamp,$
 ;                               format='(d8.3)')+' sec'],$
 ;         box=0,/right,charsize=2,charthick=1.5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
  gif_animate=1,loop=1

;file_delete,gifs


end
