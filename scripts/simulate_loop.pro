
;
;
; ssw_batch simulate_loop simulate_loop


;This is to make it compliant with batch jobs.
;If you want to watch the output as it comes out, 
; comment the next line out
;set_plot,'z'

;To plot to the screen
Set_plot,'x'

;Variables to tell the software what computer you are on.
;computer='filament'
computer='dawntreader'
;computer='mithra'

;The next line is necessary to ensure that the software can work on the computer
;you are on
so =get_bnh_so(computer,/init)

;This is a safety factor for the stability of the numerical solution.
;The bigger the safety the smaller the timestep.
safety=10

;You can run this in a loop with several temperatures
;Tmax = [0.6, 1.0, 1.5, 2.0, 2.5, 3.0, 5.0, 7.0, 10.0]*1d6

;Or just one
Tmax = 0.6*1d6 ;Maximum temps of loops, MK
	
Length = 4e9 ;[cm], total loop length
depth=2e5 ;[cm] Depth of your boundary condition chromosphere
T0=1d4 ;[K] Temp. of your boundary condition chromosphere

;Number of seconds for the initial simulation to run
rtime=30*60d
;Warning!  I've made the codes general enough that they shouldn't crash,
;but the downside is that they now take longer to run. ~20 real seconds 
;for every simulated second

i=0
;The next two lines are for making a loop to step through many temperatures
;Nloops = n_elements(Tmax)
;for i = 0, Nloops-1 do begin

;Make the file save name whatever you like.
;The command below makes the name a function of the temperature.
fname = 'loop_T' + strcompress(string(Tmax[i]),$
                               /remove_all) + '_eq.sav'

;This program will make a semi-circular loop of constant cross-section.
;It also calculates a constant heating rate for a loop based on RTV scaling laws
loopeqt2, Ttop=Tmax[i], L=Length, fname=fname, $
          rebin=200, depth=depth, rtime=rtime,$
          safety=safety,computer=computer

;endfor
        
;Now that we have simulated a semicircular loop of constant cross section 
;let's get some information from it.
restore, fname
help
;
;When you type help you should see all of the variables we talked about listed.
;We mainly want to deal with the last value of lhist in the lhist array
; so let's separate out that one.
state=lhist[n_elements(lhist)-1l]
;This is going to be the starting point for every other heating situation
state.time=0.
state0=state
;Get the temperature along the loop
Temperature=get_loop_temp(state)

;But temperatures are defined on the volume grid, so let's get the x
; coordinates on the volumes
x_alt=get_loop_s_alt(x,/GT0) 

;Now plot T vs x
plot, x_alt,Temperature, TITLE=' Loop Temperature '
;Get the loop volume elements
volumes=get_loop_vol(x,a,TOTAL=total_loop_volume)
pmm,volumes
;Note that volumes had N-2 elements.  That's because we don't count the first and last one.
; That's because they are only used as boundary conditions 

;The following variable, heat, is the constant heating rate for the loop described above.
;ergs cm^-3 s^-1 
help,heat

;Switch the heating fuction to a total power put into the loop.
power=total(heat*volumes)

help,power
;How much total power was put into that loop?
print, 'total power:'+string(power)
N=n_elements(state.e)

;Calculate the emission measure of the loop
EM=state.n_e[1:N-2]*state.n_e[1:N-2]*volumes

;Find the index of the loop midpoint
print, where(abs(x-Length/2.) eq min(abs(x-length/2.)) )
index_half=where(abs(x-Length/2.) eq min(abs(x-length/2.)) )

;Add background heat
new_e_h =dblarr(n_elements(volumes))+heat
;Add additional heat at the loop top
new_e_h[90:108] = new_e_h[90:108]*1.10

;Smooth it out a bit
for j=0,  5 do new_e_h=smooth(new_e_h,5,/EDGE)

help,new_e_h
;Let's plot the new heating function
plot, x_alt[1:197], new_e_h
;NOTE that the heating funtion has N-2 elements also.  This is again because 
; of the fact that the first an last grid elements are only boundary conditions.

DELTA_T=60d; Number of seconds per time step
interval=30;number of steps to take
;With these settings the loop will model for a half an hour of simulated time.

Print,'Apex heating.'
print,  "Old Power: "+strcompress(string(power),/remove_all)
print,  "New Power: "+strcompress(string(new_e_h*volumes),/remove_all)

;Save the file here.
outfile='apex_heat.sav'
;stop

;Now run loopmodelt with the new heating function
loopmodelt2, g, A, x,new_e_h , interval, state=state0,  $
		T0=T0, outfile=outfile, /src, /uri, /fal, $
                 safety=safety,SO=SO,DELTA_T=DELTA_T

restore, outfile
 
help,lhist
apex_state=lhist[n_elements(lhist)-1l]

;Now do it again but with the heat at the foot points
;Get the temperature along the loop
T=get_loop_temp(state0)
;Identify the corona
 corona=where(t ge T0*1.2)

;Now take 40 elements on either side of the loop
heat_elem_1=lindgen(40)+min(corona)
heat_elem_2=max(corona)-reverse(lindgen(40))


;Add constant  background heat
new_e_h =dblarr(n_elements(volumes))+heat
;Heat the footpoints
new_e_h[heat_elem_1]=heat[0]*1.1
new_e_h[heat_elem_2]=heat[0]*1.1
for j=0,  5 do new_e_h=smooth(new_e_h,5,/EDGE)
Print,"Footpoint heating"
print,  "Old Power: "+strcompress(string(power),/remove_all)
print,  "New Power: "+strcompress(string(total(new_e_h*volumes)),/remove_all)
outfile='foot_point_heat.sav'

;Plot out the new heating function
plot, x_alt[1:197], new_e_h

;Simulate the loop
loopmodelt2, g, A, x,new_e_h , interval, state=state0,  $
		T0=T0, outfile=outfile, /src, /uri, /fal, $
                 safety=safety,SO=SO,DELTA_T=DELTA_T

;If you plan on running this in batch mode, uncomment the next line.
;EXIT
end
