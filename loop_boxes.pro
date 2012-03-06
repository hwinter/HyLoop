 
;emission_display_script.pro
print, 'under construction by Jenna'
;11/3/2005
;Get the proper path for the PATC codes.
patc_dir=getenv('PATC')
;Folder for where the simulation data is stored.
sub_folder='runs/2005_11_03/'
run_folder=strcompress(patc_dir+sub_folder,/REMOVE_ALL)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Where to write the gifs to make the movie
gif_dir=strcompress(run_folder+'gifs2/')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Path to an IDL save file of a  magnetic loop
file1=strcompress(run_folder+'hd_out.sav',/REMOVE_ALL)
;file2=strcompress(run_folder+'full_test_1.sav',/REMOVE_ALL)
file2='/Users/winter/Desktop/quick_loop.sav'

restore,file1
restore,file2
!p.multi=0
;plot_title='Model Loop Sim'
plot_title='Temperature Profile'
loop=loop_struct[0].loop

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

record_temp=dindgen(n_elements(lhist),n_elements(lhist[0].e))
k_boltz_ergs=1.3807d-16
kb=k_boltz_ergs
T = lhist.e/(3.0*lhist.n_e*kB)
     record_temp = T

temp_difference=max(record_temp)-min(record_temp)

 T_color_factor=255/(temp_difference)
    temp_color_lower_bound=min(record_temp)*T_color_factor
    ntempcolors=255-temp_color_lower_bound

  T_color=T_color_factor*T
red_temperature=3 ;this is what to call with loadct, and i have modified this
;color table using xpalette to make it more orange and less black       
 loadct,red_temperature
colorbar, title='Cold      Temp (10e4 K)         Hot',ncolors=ntempcolors,$
        position=[0.34,0.18,0.72,0.28],max=max(record_temp)/10d4,divisions=2
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
       for ii=z_max+1,num-125 do begin
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



loadct,39

ii=z_max

x1=loop.axis[1,ii]+cos(theta[ii])*loop.rad[ii]
x2=loop.axis[1,ii]-cos(theta[ii])*loop.rad[ii]
x3=loop.axis[1,ii+1]-cos(theta[ii+1])*loop.rad[ii+1]
x4=loop.axis[1,ii+1]+cos(theta[ii+1])*loop.rad[ii+1]

y1=loop.axis[2,ii]-sin(theta[ii])*loop.rad[ii]
y2=loop.axis[2,ii]+sin(theta[ii])*loop.rad[ii]
y3=loop.axis[2,ii+1]+sin(theta[ii+1])*loop.rad[ii+1]
y4=loop.axis[2,ii+1]-sin(theta[ii+1])*loop.rad[ii+1]

oplot,[x1,x2],[y1,y2],color=51,thick=1.5
oplot,[x2,x3],[y2,y3],color=51,thick=1.5
oplot,[x3,x4],[y3,y4],color=51,thick=1.5
oplot,[x4,x1],[y4,y1],color=51,thick=1.5

jj=z_max+65

x1=loop.axis[1,jj]+cos(theta[jj])*loop.rad[jj]
x2=loop.axis[1,jj]-cos(theta[jj])*loop.rad[jj]
x3=loop.axis[1,jj+1]-cos(theta[jj+1])*loop.rad[jj+1]
x4=loop.axis[1,jj+1]+cos(theta[jj+1])*loop.rad[jj+1]

y1=loop.axis[2,jj]-sin(theta[jj])*loop.rad[jj]
y2=loop.axis[2,jj]+sin(theta[jj])*loop.rad[jj]
y3=loop.axis[2,jj+1]+sin(theta[jj+1])*loop.rad[jj+1]
y4=loop.axis[2,jj+1]-sin(theta[jj+1])*loop.rad[jj+1]

oplot,[x1,x2],[y1,y2],color=151,thick=2
oplot,[x2,x3],[y2,y3],color=151,thick=2
oplot,[x3,x4],[y3,y4],color=151,thick=2
oplot,[x4,x1],[y4,y1],color=151,thick=2

kk=z_max+87

x1=loop.axis[1,kk]+cos(theta[kk])*loop.rad[kk]
x2=loop.axis[1,kk]-cos(theta[kk])*loop.rad[kk]
x3=loop.axis[1,kk+1]-cos(theta[kk+1])*loop.rad[kk+1]
x4=loop.axis[1,kk+1]+cos(theta[kk+1])*loop.rad[kk+1]

y1=loop.axis[2,kk]-sin(theta[kk])*loop.rad[kk]
y2=loop.axis[2,kk]+sin(theta[kk])*loop.rad[kk]
y3=loop.axis[2,kk+1]+sin(theta[kk+1])*loop.rad[kk+1]
y4=loop.axis[2,kk+1]-sin(theta[kk+1])*loop.rad[kk+1]


oplot,[x1,x2],[y1,y2],color=247,thick=2
oplot,[x2,x3],[y2,y3],color=247,thick=2
oplot,[x3,x4],[y3,y4],color=247,thick=2
oplot,[x4,x1],[y4,y1],color=247,thick=2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the current screen a gif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      x2gif,strcompress('./diagram_loop'+'.gif')
;print,tresponse;

   ;  animate_index=animate_index+1

      
 ;     beam_on_time=beam_on_time+time_step
    
;  endfor

;gifs=findfile(strcompress(gif_dir+'*.gif'))
;BREAK_FILE, gifs[0], DISK_LOG, DIR, FILNAM, EXT

;image2movie,gifs,$
 ; movie_name=strcompress(gif_dir+'emission_movie.gif',/REMOVE_ALL), $
  ;gif_animate=1,loop=1

;file_delete,gifs


end
