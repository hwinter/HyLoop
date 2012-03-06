

;+
; NAME:
;	PATC (PArticle Transport Code)
;
; PURPOSE:
;	To track a system of non-thermal particles in a magnetic field
;	and record changes due to collsions and non-uniform magnetic fields 
;
; CATEGORY:
;	Simulation.  Flare studies
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	
;
; OPTIONAL OUTPUTS:
;	
;
; COMMON BLOCKS:
;	
;
; SIDE EFFECTS:
;	
;
; RESTRICTIONS:
;	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; CURRENT VERSION:
;    1.0
; MODIFICATION HISTORY:
; 	Written by:	Henry deG. Winter III (Trae) 04/30/2005
;                
;-


function eom_4_patc


END ; of  eom_4_patc

pro  patc,elects,loop,duration, DELTA_E=DELTA_E,$
          MP=MP,OUT_BEAM=OUT_BEAM,$
          DELTA_MOMENTUM=DELTA_MOMENTUM,$
          NT_BREMS=NT_BREMS

version=1.0
openu,lun,'patc_out.txt',get_lun=1,/append


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;1 keV=1.602e-9 ergs
; converts keV to ergs
keV_2_ergs = 1.6022d-9
;converts keV to Joules
keV_2_Joules = 1.6022d-16
;Charge on an electron in Coulombs
e=1.6022d-19
;Charge on an electron in statcoulombs
e=4.8032d-10
;Boltzmann's constant in ergs/[K]
k_boltz_ergs=1.3807d-16
;Boltzmann's constant in Joules/[K]
k_boltz_joules=1.3807d-23 
;Electron mass in grams
e_mass_g=9.1094d-28 
;Proton mass in grams
p_mass_g=1.6726d-24 
;Electron radius in cm (classical)
e_rad=2.8179d-13
;how often to output text
freq_out=1000

;Way too small.  Will have to work on it
delta_t=1d-3

counter=0l
n_elem_elects=n_elements(elects)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find the initial position of the particle.
;This is only needed for the MP test and should be removed along with
;the MP test
position_index_0=long(where(abs(elects.x-loop.x) eq $
                            min(abs(elects.x-loop.x))))
position_index=position_index_0


N_elements_x=n_elements(loop.x)

DELTA_E=dblarr(N_elements_x)
delta_momentum=dblarr(N_elements_x)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find the gradient of the magnetic field everywhere
dbdx = DERIV(loop.x, loop.b)
pmm,loop.n_e
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find the temperature of the plasma in every grid cell [K]
T_plasma=ABS(loop.e/(3.0d*loop.n_e*(k_boltz_ergs)))



;Determine the initial velocities of the particles [cm/s]
 v_total=sqrt((2*elects.KE_total *keV_2_ergs)/e_mass_g)
;Determine the initial velocities of the particles along the loop
;[cm/s]
 v_parallel_0=cos(elects.pitch_angle)* v_total

;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Number of iterations
n_iter=long(duration/delta_t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Debye Screening length
debye_length=((k_boltz_ergs*T_plasma)/ $
              (4d*!pi*e^2d))^0.5d

       

mean_free_path=1d/denominator
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the mean free path of each cell in the loop

       denominator=(sqrt(2)*loop.n_e[position_index[0]] *$
                    !pi*debye_length[position_index[0]]^2d)
       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ROUTINES FOR MAPPING MIRRORING TEST
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;only needed for testing purposes
 if  keyword_set(MP)  then begin
    ; set_plot,'ps'
    ; device,/landscape,file='mirror_test.ps'
     r=[0,255,0,0]
     g=[0,0,255,0]
     b= [5,0,0,255]
     tvlct, r, g,b
     tvlct, r, g,b,/GET
     ANIMATE_COUNTER=0
        line=dblarr(n_elements_x)
        line2=[-1,0,1]
        line2_x=[loop.x[position_index_0[0]],loop.x[position_index_0[0]],$
                  loop.x[position_index_0[0]]]
        ;window,2
        circle_sym,  THICK=2, /FILL
        n1=n_elements(mp.mp_ind_1)-1l
        n2=n_elements(mp.mp_ind_2)-1l

        top1= loop.AXIS[2,mp.mp_ind_1]+loop.RAD[mp.mp_ind_1]

        top2= loop.AXIS[2,mp.mp_ind_2]+loop.RAD[mp.mp_ind_2]

 
        WINDOW,0,XSIZE=600,YSIZE=600
        ;true_val=1
        ;WRITE_GIF, 'mirror_test.gif', TVRD(),r,g,b,/MULTIPLE
        ;XINTERANIMATE , SET=[600,600,long(n_iter/freq_out)], $
        ;             /SHOWLOAD, MPEG_OPEN,$
        ;  MPEG_FILENAME=MP.FILE
        movie=bytarr(600,600,(n_iter/freq_out))

        window,2
        plot,loop.axis[1,*],loop.axis[2,*]+loop.rad,THICK=3 
        oplot,loop.axis[1,*],loop.axis[2,*],linestyle=2    
        oplot,loop.axis[1,*],loop.axis[2,*]-loop.rad,linestyle=0,THICK=3 
        wset,0
        

    endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
For i=0d, n_iter-1l do begin


 if  keyword_set(MP) then begin
        if (counter mod freq_out ) eq 0 then begin
         
        ;plot,loop.x,line,/xstyle,/ystyle, TITLE='mirror test', $
         ;    XTITLE='X position along loop [cm]',$
         ;    yrange=[-1,1], XRANGE=[0D,max(loop.x)]  
         plot,loop.axis[1,*],loop.axis[2,*]+loop.rad,linestyle=0,$
           TITLE='Mirror Test',$
           xTITLE='Cartoon Loop',/NODATA
         oplot,loop.axis[1,*],loop.axis[2,*]+loop.rad,THICK=3 
         oplot,loop.axis[1,*],loop.axis[2,*],linestyle=2    
         oplot,loop.axis[1,*],loop.axis[2,*]-loop.rad,linestyle=0,THICK=3  
 
        plots, loop.axis[1,position_index_0[0]] ,$
          loop.axis[2,position_index_0[0]] , PSYM=1,SYMSIZE=3,$
          COLOR=2,THICK=2

    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plot the region where the B field strength is about the same as the B_mp     
        ;plots,loop.AXIS[1,mp.mp_ind_1] ,loop.AXIS[2,mp.mp_ind_1],PSYM=3,$
        ;  COLOR=3,SYMSIZE=2,THICK=4
        polyfill,[ REFORM(loop.AXIS[1,mp.mp_ind_1[0]]),$
                   REFORM(loop.AXIS[1,mp.mp_ind_1]),$
                   REFORM(loop.AXIS[1,mp.mp_ind_1[n1]]) ],$
          [REFORM(loop.AXIS[2,mp.mp_ind_1[0]]-loop.RAD[mp.mp_ind_1[0]]), $
           REFORM(top1[0,*]) ,$
           REFORM(loop.AXIS[2,mp.mp_ind_1[n1]]-loop.RAD[mp.mp_ind_1[n1]]) ], $
          COLOR=3 , /FILL_PATTERN;/LINE_FILL
        
        polyfill,[ REFORM(loop.AXIS[1,mp.mp_ind_2[0]]),$
                   REFORM(loop.AXIS[1,mp.mp_ind_2]),$
                   REFORM(loop.AXIS[1,mp.mp_ind_2[n2]]) ],$
          [REFORM(loop.AXIS[2,mp.mp_ind_2[0]]-loop.RAD[mp.mp_ind_2[0]]), $
           REFORM(top2[0,*]) ,$
           REFORM(loop.AXIS[2,mp.mp_ind_2[n2]]-loop.RAD[mp.mp_ind_2[n2]]) ], $
          COLOR=3, /FILL_PATTERN;,/LINE_FILL

    endif
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Impact parameter for 90 deg deflection
;Didn't put in the loop because the change in b_crit shouldn't be
;much.
;  See ???? for a reference.
       b_crit=(e^2d)/(2d*elects.ke_total*keV_2_ergs )

   for j=0,n_elem_elects-1 do begin
      ; stop
      ;If this particle is no longer non-
      ;thermal, I don't need to waste time
      ;on it 
       if elects[j].state ne 'NT' then goto, elect_loop_end
       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Got to figure out how to do this without the loop
       position_index=where(abs(elects[j].x-loop.x) eq $
                            min(abs(elects[j].x-loop.x)))
       ;help,position_index
       v_total=sqrt((2*elects[j].KE_total*keV_2_ergs)/e_mass_g)
       v_parallel=cos(elects[j].pitch_angle)* v_total
       v_parallel_old=v_parallel
       if (counter mod freq_out) eq 0 then $
         printf,lun, 'v_parallel',v_parallel
       
       case 1 of 
           denominator[position_index[0]] eq 0 : begin
             ;print,'No Collisions'
               N_collisions =0d
               goto, no_collisions
           end
           finite(denominator[position_index[0]]) eq 0 : begin
          ;print,'No Collisions'
               N_collisions =0d
               goto, no_collisions
           end
           else:
       endcase



       ;An assumption that delta v total is small is being made here.
       n_c=((v_total*delta_t)/mean_free_path[position_index[0]])
       N_collisions =n_c+( n_c *randomn(seed))

       ;print,' N_collisions', N_collisions
        if (N_collisions mod 1) ge .5 then $
          N_collisions = (temporary(N_collisions[0]))+1d $
          else  N_collisions = (temporary(N_collisions[0]))
       ;print,' N_collisions', N_collisions
      
       no_collisions:
       if  N_collisions le 0d then begin
          ; print,'No collisions.'
           V_PARALLEL_OLD=v_parallel[0]
           DELTA_V_PARALLEL_1=0
          delta_x=v_parallel*delta_t
          x_new=elects.x+v_parallel*delta_t
          goto,mirror_force
       endif

       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Had some trouble figuring out how to turn b_crit and the Debye
;Screening length into lengths.  But if I keep all of my units the
;same I should do alright
;A little test to make sure I did that right.
       ln_lambda=mean(alog(debye_length[position_index]/b_crit[j]))
       ;print,'ln_lambda',ln_lambda
       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Can't account for all the collisions.  So do a 1000 of them and then
;factor in the others
; collision_factor=1d
;if N_collisions[0] gt 1000d then begin
;    collision_factor= N_collisions[0]/1000d
;    N_collisions[0]=1000d

;endif



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;impact parameter  randomly chosen between b_critical (and the Debye
;length
;       
;       b_impact=b_crit[j]+$
;         (debye_length[position_index[0]]-b_crit[j])* $
;;         randomu(seed, long(reform(N_collisions[0])));
;
;       arc_tan=atan((e^2d)/(b_impact*elects[j].KE_total*keV_2_ergs))
;   

;       delta_energy=total((-.5d)*(elects[j].KE_total)*((1d)-cos(arc_tan*2d))) $
 ;        *collision_factor
;       delta_v_parallel_1=total((-0.5d)*v_total*((1d)-cos(arc_tan*2d))) $
;         *collision_factor
       random_1=randomn(seed)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Blatantly stolen from Emslie, 1978
       delta_energy= (((-2d)*(!pi)*(ln_lambda)*(e^4d))/(elects[j].KE_total*kev_2_ergs)) $
         *((e_mass_g/p_mass_g)+1d)$
         *(loop.N_e[position_index[0]]) $
         *v_total*delta_t $
         *(1d/kev_2_ergs)

       delta_v_parallel_1=cos(elects[j].pitch_angle) $
         *(((-!pi)*(ln_lambda)*(e^4d))/((elects[j].KE_total*kev_2_ergs)^2d)) $
         *((2d)+(e_mass_g/p_mass_g)+(1d)) $
         *(loop.N_e[position_index[0]]) $
         *(v_total^2d)*delta_t

      ; delta_v_parallel_1=delta_v_parallel_1*(random_1/abs(random_1))

       elects[j].KE_total=temporary(elects[j].KE_total)+delta_energy

       v_total=sqrt((2*elects[j].KE_total*kev_2_ergs)/e_mass_g)

       DELTA_E[position_index]=temporary(DELTA_E[position_index]) $
         +delta_energy

       delta_momentum[position_index]=temporary(delta_momentum[position_index]) $
         +delta_v_parallel_1*e_mass_g
;;;;;;;;;;;;;;;;;;;;;;;;;

;print, 'delta_energy=', delta_energy
;print, 'delta_v_parallel_1', delta_v_parallel_1
;print, 'DELTA_E[position_index]=' ,DELTA_E[position_index]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Velocity of each particle along the magnetic field line
;Fudging the geometry here.
;NEED TO REFINE LATER
       ;v_parallel_old=v_parallel
       v_parallel=temporary(v_parallel)+delta_v_parallel_1
       elects[j].pitch_angle=acos(v_parallel/v_total)
      ;if abs(elects[j].mu) ge 1 then $
      ; elects[j].mu=elects[j].mu/abs(elects[j].mu)
       
mirror_force:
       delta_x=v_parallel_old*delta_t
       x_new=elects[j].x+delta_x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Mirror_force     See Bai, 1982, and Benz,1993
 
       pos_index_2=where(abs(x_new-loop.x) eq min(abs(x_new-loop.x)))
  
       delta_v_parallel_2=-1d* $
         (elects[j].ke_total) *(sin(elects[j].pitch_angle)^2d) $
         * keV_2_ergs *(1d/e_mass_g)  $
         *(double(1)-(cos(elects[j].pitch_angle))^2d) $
         *(dbdx[pos_index_2[0]]/loop.b[pos_index_2[0]]) $
         * delta_t
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Mirror_force is currently in ergs/cm


v_parallel=(v_parallel_old+delta_v_parallel_1+delta_v_parallel_2)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Compute new particle position

       elects[j].x=temporary(elects[j].x)+(v_parallel_old*delta_t) $
         +(0.5d*(delta_v_parallel_1+delta_v_parallel_2)*(delta_t))

      pos_ind_3=where(abs(elects[j].x-loop.x) eq min(abs(elects[j].x-loop.x)))
     
       ;print,'new position',elects[j].x
      ; print, 'v_parallel=', v_parallel_old+delta_v_parallel_1+delta_v_parallel_2

      ; avg_v_parallel=(v_parallel_old+ $
      ;                 v_parallel_old+delta_v_parallel_1+ $
      ;                 v_parallel_old+delta_v_parallel_2)/3d

      ; elects[j].x=temporary( elects[j].x)+(avg_v_parallel*delta_t)
       elects[j].pitch_angle=acos((v_parallel)/v_total)
       if not finite(elects[j].pitch_angle) then begin
           print,"Math error!!!"
           ;help
           ;wait,10*60
       endif


      ;if (counter mod freq_out) eq 0 then begin
      ;    printf,lun,'mu', (v_parallel+delta_v_parallel_2)/v_total 
      ;    print,'mu', (v_parallel+delta_v_parallel_2)/v_total 
      ;endif


      if keyword_set(MP) then begin
          if  (v_parallel)/v_parallel_old lt 0d then begin
              printf,lun, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
              printf,lun, 'Turn around at:',elects[j].x
              printf,lun, 'B analytical mirror point:',mp.b_mp
              b_mirror_point=loop.b[pos_ind_3]
              printf,lun, 'B numerical mirror point:',b_mirror_point
              printf,lun, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'

              print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
              print, 'Turn around at:',elects[j].x
              print, 'B analytical mirror point:',mp.b_mp
              print, 'B numerical mirror point:',b_mirror_point
              print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
              help,elects, /str
              
        
          endif
      endif
;stop

      ; elects[j].mu=elects[j].mu/abs(elects[j].mu)
                                ;stop
   
    if keyword_set(MP) then begin    
        if (counter mod freq_out) eq 0 then begin
            printf,lun,'length_ratio=',abs(delta_x)*(dbdx[pos_index_2[0]]/loop.b[pos_index_2[0]]) 
            help,elects, /str
            help, pos_ind_3
            wset,2
            PLOTS, loop.axis[1,pos_ind_3[0]],loop.axis[2,pos_ind_3[0]],$
              psym=4,symsize=10, thick=3
            print,  loop.axis[1,pos_ind_3[0]],loop.axis[2,pos_ind_3[0]]
            wset,0
 
        endif
    endif


              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



       Case 1 of
           elects[j].x ge max(loop.x): begin
               elects[j].state='RF'
               delta_e[where(loop.x eq max(loop.x))]=elects[j].ke_total-15d
           end
           elects[j].x le min(loop.x):  begin
               elects[j].state='LF'
               delta_e[where(loop.x eq min(loop.x))]=elects[j].ke_total-15d
           end
           elects[j].ke_total lt 15d: begin
               elects[j].state='TL'
           end
           else:begin
               elects[j].alive_time=elects[j].alive_time+delta_t
           end

       ENDCASE




       if  keyword_set(MP) then begin
           if (counter mod freq_out ) eq 0 then begin

               plots,loop.AXIS[1,pos_ind_3[0]] ,loop.AXIS[2,pos_ind_3[0]],$
                 psym=8, color=1,SYMSIZE=3,THICK=2
         
           endif


       endif


   
elect_loop_end:
endfor;j loop for particles

 if  keyword_set(MP) then begin
        if (counter mod freq_out ) eq 0 then begin
            wset,0
            movie[*,*,ANIMATE_COUNTER]=tvrd()
            ANIMATE_COUNTER=ANIMATE_COUNTER+1l
       ; WRITE_GIF, 'mirror_test.gif', TVRD(),r,g,b,/MULTIPLE
        endif
    endif
    junk=where(elects.state eq 'NT')

    if junk[0] eq -1 then goto, end_loop


    counter=counter+1d
endfor; iloop for time
end_loop:
;device,/close
;set_plot,'x'
FREE_LUN,lun
;stop
 
if  keyword_set(MP) then $
save, movie,r,g,b,FILE=mp.file
 ; XINTERANIMATE, /MPEG_CLOSE

;WRITE_GIF, 'mirror_test.gif',/CLOSE
;window,16
;plot,loop.x,loop.n_e
;window,17
;plot,loop.x,loop.e
OUT_BEAM=ELECTS
END; Of MAIN patc
