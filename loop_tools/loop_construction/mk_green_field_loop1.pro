;No SRC
function mk_green_field_loop2, N_CELLS=N_CELLS, N_DEPTH=N_DEPTH,$
  max_height=max_height,Area_0=Area_0, TEST=TEST

if not keyword_set(N_CELLS) then n_cells=700l ;Number of initial volumes
;if not keyword_set(N_DEPTH) then n_depth=25l;Number of initial surfaces in the Chromosphere
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Begin parameter definition section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Check for and report math errors 
old_except= !except                  
;!except=2
compile_opt strictarr
;From line_trace2.pro
plot_state=!d.name
set_plot,'z'
loop_file_name='gcsm_loop.sav'
n_levels=40;Number of levels to contour
B0=100d ;Maximum Magnetic field [Gauss]
if not keyword_set(Area_0) then $
  Area_0=!dpi*(1d8)^2d          ;Footpoint area [cm^2]
;range=
if not keyword_set(max_height) then $
  max_height=1.6d9              ;Loop height Fletcher & Martens

;Exponent of the temperature dependance.
DEFSYSV, '!heat_alpha', EXISTS = test1
if test1 ne 1 then  begin
    alpha=3d/2d 
    DEFSYSV, '!heat_alpha',alpha
endif else alpha=!heat_alpha
;Loop top temperature (Approximate)

DEFSYSV, '!heat_alpha',alpha
DEFSYSV, '!heat_Tmax', EXISTS = test1
if test1 ne 1 then begin
    T_MAX=1.5d6
    DEFSYSV, '!heat_Tmax',T_MAX
endif else T_max=!heat_Tmax
  
heat_name='get_p_t_law_const_flux_heat'
;q0=7d-4
NOVISC=1
;Place to save the loop parameters before the equilibrium procedure.
start_file=getenv('PATC')+'/test/loop_data/'+ $
           strcompress(string(bin_date()),/REMOVE_ALL)+ $
           '_'+!computer+'_gcsm_start.loop'

;line_index=0
separator_offset=0
chars=1.
chart=1.
bungey_cells=1d3
;computer='dawntreader'
;computer='mithra'
max_time=1d0*60d0*60d0          ;Time to allow loop to come to equilibrium
rtime=5d0*60d0                  ;Output timestep
DELTA_T=1.                      ;reporting  timestep
time=0d0                        ;The simulation start time
safety=5d0                      ;Number that will be divided by
                                ;  the C. condition to determine the timestep
grid_safety=10d                 ;Number that will be divided by
                                ;  the minimum characterstic scale length to determine
                                ;  the grid sizing
note='Green style current sheet initially given RTV scaling'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End parameter definition section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define some constants
Mega_meter2cm=1d8
cm2Mega_meter=1d-8
;Solar surface gravity acceleration[cm s^-2]
g0 =2.74d4
;Solar radius [cm]
R_Sun=6.96d10
d_chrom=2500*1d5
depth=d_chrom;*.7
;Height of the Corona above the photosphere[cm]
h_corona=2d8
;Boltzmann constant (erg/K)
kB = 1.38d-16      
;proton mass (g)
mp = 1.67d-24     
;Chromospheric Temperature   
T0=1.d4 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Start section to define loop from a Green style current sheet.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Plotting choices
bgc=255
fgc=0
xs=600
ys=600
regrid_window=18
evolve_window=19
if !d.name ne 'Z' then DEVICE, SET_FONT='Times', /TT_FONT  
if !d.name eq'X' then window,regrid_window  
if !d.name eq 'X' then window,evolve_window,TITLE='Evolve Window'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine the number of volumes that will be in the corona.
;The final + two are for endpoints that will be replaced by 
;n_depth cells
;N_corona=n_cells-(2*n_depth)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the magnetic field given by a Green type reconnection
;  model
bungey_priest_field,B_z,b_y,z,y,f,a=1,B_DRC=0.5,$
                    B0=b0,B_total=B_total,$
                    N_ELEM=bungey_cells
xy_array=bp_field_line_tracer(BT=B_total)
B_total=B_total/max(B_total)
B_total=B_total*B0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;plot the Separator field line over the the other field lines
;Make a contour map of field lines
;make it red and plot it

;stop
;if !d.name eq 'X' then x2gif,'field_lines.gif'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find the number of points corresponding to the line you are
;interested in

y=xy_array[*,0]
z=xy_array[*,1]
b=B_total
help,b

;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Scale everything to Z
shift_z=-1d*min(z)
z=z+shift_z
shift_y=-1d*min(y)
y=y+shift_y
;y=reverse(y)
scale_factor=max_height/max(z)
;z=z*scale_factor+d_chrom
z=z*scale_factor
y=y*scale_factor;(y/total(y))*scale_factor
z=z+!shrec_h_corona
;s=s*scale_factor 
n_z=n_elements(z)
dz=z[1:N_z-1] - z[0:N_z-2]
dy=y[1:N_z-1] - y[0:N_z-2]

n_s=n_elements(s)
s=dblarr(n_elements(dz)+1)
s[1:*]=total(sqrt((dz^2.)+(dy^2.)), /CUMULATIVE)
s[0]=0.d
n_s=n_elements(s)
;s(n_elements(s)-1)=


length=max(s)
s2=mk_gauss_grid( n_cells-1ul, length, $
                 SIGMA_FACTOR=5. )


n_cells=n_elements(s2)+1ul
b_old=b
y_old=y
z_old=z
new_b=interpol(b,s,s2, /SPLINE)
new_y=interpol(y,s,s2, /SPLINE)
new_z=interpol(z,s,s2, /SPLINE)
;new_b=spline(s,b,s2)
;new_y=spline(s,y,s2)
;new_z=spline(s,z,s2)
;for i=0, 100 do new_b=smooth(new_b,3)
;for i=0, 100 do new_y=smooth(new_y,3)
;for i=0, 100 do new_z=smooth(new_z, 3)
new_z=(new_z/max(new_z))*max(z_old)
new_b=(new_b/max(new_b))*max(b_old)
new_y=(new_y/max(new_y))*max(y_old)


axis=dblarr(3,n_cells-1ul)
help,axis
axis[0,*]=0d
axis[1,*]=new_y
axis[2,*]=new_z


s=s2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bad=where(finite(new_b) lt 1)
if bad[0] ne -1 then stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;get rid of leading space	04/30/02	RAM
;s=s-s[0]                     
s_alt = shrec_get_s_alt(s)   
;s_alt=shrec_get_s_alt(s,/GT0)

a=Area_0*(max(new_b)/new_b)
rad=sqrt(a/!dpi)

z_alt=shrec_get_s_alt(new_z)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
coronal_index=where(z_alt gt d_chrom, COMPLEMENT=chromo_index)
n_corona=n_elements(coronal_index)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;if !d.name eq 'X' then window,1
;plot,axis[1,*],axis[2,*], Title='Loop axis', $
;     XTITLE="Y [cm]",YTITLE='Z [cm]',$
;     /ISOTROPIC

sine_theta=-1d*smooth(deriv(new_z)/deriv(s),10,/EDGE)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Dimensionless gravitational acceleration parallel to the loop.
; See Klimchuck,Tanner, & Moore, 2004
;Theta is defined differently from my notes so the sine is more
;appropriate than the cosine
;g=sin(theta)*((R_Sun/(R_Sun+axis[2,*]))^2d)
g=sine_theta*((R_Sun/(R_Sun+axis[2,*]))^2d)

;Gravitational acceleration [cm s^2]
g=reform(g)*g0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End section to define loop from a Green style current sheet.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

flux =get_p_t_law_flux(length+2d0*depth, alpha,T_Max)

DEFSYSV, '!constant_heat_flux',flux
P=get_p_t_law_pressure(length+2d0*depth, alpha,$
                                TMAX=T_MAX)
T=get_p_t_law_temp_profile(s_alt, alpha, tmax=t_max)

T   >= T0    
n_e=   0.5*(P/(!shrec_kB*T))   
E=3./2. *2*n_e* !shrec_kB*T            

;N = n_elements(e)
v = fltarr(n_cells-1ul)
volumes=shrec_get_volume(s,a)
e_h=dblarr(n_elements(volumes))
;stop
;Force symmetry around the loop apex
n_eh=n_elements(e_h)
even_odd_test= n_eh mod 2

case 1 of 
    (even_odd_test eq 1):begin
        e_h[0:(n_eh/2)-1ul]=$
          reverse(e_h[(n_eh/2)+1ul:*])
    end
    (even_odd_test eq 0):begin
        e_h[0:(n_eh/2)-1ul]=$
          reverse(e_h[(n_eh/2):*])
        
    end
endcase
n_s=n_elements(s)
even_odd_test= n_s mod 2

case 1 of 
    (even_odd_test eq 1):begin
        A[0:(n_s/2)-1ul]=$
          reverse(A[(n_s/2)+1ul:*])
        b[0:(n_s/2)-1ul]=$
          reverse(b[(n_s/2)+1ul:*])
        RAD[0:(n_s/2)-1ul]=$
          reverse(rad[(n_s/2)+1ul:*])
        
    end
    (even_odd_test eq 0):begin
        A[0:(n_s/2)-1ul]=$
          reverse(A[(n_s/2):*])
        new_b[0:(n_s/2)-1ul]=$
          reverse(new_b[(n_s/2):*])
        rad[0:(n_s/2)-1ul]=$
          reverse(rad[(n_s/2):*])
        
    end
endcase

n_n_e=n_elements(N_e)
even_odd_test= n_n_e mod 2

case 1 of 
    (even_odd_test eq 1):begin
        e[0:(n_n_e/2)-1ul]=$
          reverse(e[(n_n_e/2)+1ul:*])
        n_e[0:(n_n_e/2)-1ul]=$
          reverse(n_e[(n_n_e/2)+1ul:*])
        
    end
    (even_odd_test eq 0):begin
        e[0:(n_n_e/2)-1ul]=$
          reverse(e[(n_n_e/2):*])
        n_e[0:(n_n_e/2)-1ul]=$
          reverse(n_e[(n_n_e/2):*])
        
    end
endcase

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the state structure out of the variables that we have defined.
state={e:double(e), n_e:double(n_e), $
       v:double(v), time:double(0)}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the loop structure for PaTC
LOOP=mk_loop_struct(STATE=state,$
                    S_ARRAY=s,B=new_b,G=g,AXIS=axis,$
                    AREA=A,RAD=rad, $
                    E_H=e_h,T_MAX=t_max,N_DEPTH=n_depth,$
                    NOTES=notes,DEPTH=DEPTH,$
                    start_file=loop_file_name)

LOOP.e_h=get_p_t_law_heat( LOOP, $
                           tmax=t_max, $
                           alpha=alpha, $
                           beta=beta, $
                           P_0=p) 

;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Add on the Chromosphere
LOOP=add_loop_chromo1(loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOOP.e_h=get_p_t_law_heat( LOOP, $
                           tmax=t_max, $
                           alpha=alpha, $
                           beta=beta, $
                           P_0=p) 
;stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Start equilibrium section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
equil_counter=1
done=0
max_v=1d7
;stop
if keyword_set(test) then goto,end_jump 
while done le 0 do begin

    n_loop=n_elements(Loop)
    temp_loop=loop[n_loop-1l]
    hyloop ,temp_loop, $
                    rtime, DELTA_T=DELTA_T, $ ;
                    T0=1d4,  src=src, uri=uri, fal=fal, $
                    safety= safety , $;SHOWME=SHOWME, DEBUG=DEBUG   , $
                    QUIET=QUIET, HEAT_FUNCTION=heat_name,$
                    PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, $
                    MAX_STEP=MAX_STEP, FILE_EXT='stable', $
                    grid_safety= grid_safety,$; ,regrid=REGRID , $
                    E_H=E_H, FILE_PREFIX=OUTPUT_PREFIX,$
                    NOVISC=NOVISC;,DEPTH=depth
    
    loop=temp_loop
    if !d.name eq 'X' then begin
        wset, evolve_window
        stateplot3, loop, /SCREEN
        endif
;Determine the maximum veloxity
    max_v=max(abs(loop.state.v))
    if max_v le 2d5  then done =1 else done =0

        print, 'Min/Max velocity:'
        pmm,abs(loop.state.v)
        
        if equil_counter eq 400 then done=1
        if done le 0 then begin
;Artificially smooth
            for j=0,10 do loop.state.e=smooth(loop.state.e,3)    
;Artificially kill the velocity
            loop.state.v=0d0
        endif
        equil_counter +=1
    ;if loop.state.time gt max_time then done=1
endwhile

loop.state.time=0d
end_jump:
e_h=e_h[*,0]
print,'Saving file: '+ loop_file_name
save,g, A, s, rad, state, E_h,axis,b,loop,q0, heat,e_h,file=loop_file_name



;reset the except state             
!except=old_except
set_plot, plot_state
;stop
return, loop
END

