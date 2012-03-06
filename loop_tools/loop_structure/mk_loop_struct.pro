
;+
; NAME:
;	mk_loop_struct
;
; PURPOSE:
;	To make a loop stucture to be used with the SHrEC and PaTC codes 
;
; CATEGORY:
;	Simulation.  Flare studies
;
; CALLING SEQUENCE:
;	loop=mk_loop_struct(N_volumes)
;
; INPUTS:
;	N_volumes: Number of volume elements in loop
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	N: Number of copies of the structure to make
;
; OUTPUTS:
;	Loop structure for use in patc.pro
;
; OPTIONAL OUTPUTS:
;	
;
; COMMON BLOCKS:
;	None
;
; SIDE EFFECTS:
;	None
;
; RESTRICTIONS:
;	None
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	loop=mk_loop_struct(300)
;
; CURRENT VERSION:
;    2.2 
; MODIFICATION HISTORY:
; 	Written by:	Henry deG. Winter III (Trae) 04/26/2006
;                HDW III (1.1) Added E_h double array tag.  This version of loop will
;    completely replace lhist,x,g,a,e_h in hd routines.
;    2006-SEP-15  HDW III Replaced many double variable with floats when I could.
;                 I find that I'm often running out of memory space during the simulations 
;                 with an adequate number of particles.  Oh, bother...
;    2007-APR-4   Major re-write (V 2.0).  Made the program capable of making an empty loop
;                 if given just N_VOLUMES (300 being the default.  Also took out the NOTE keyword
;                 and added the NOTES keyword for an array of possible notes. 
;    2007-SEP     HDW III: Changed most numerical variables to doubles. (V 2.1)
;    2007-NOV-7   HDW III:(V 2.1) Added the SAFETY_GRID and SAFETY_GRID tags.  
;                  If not passed they are set to 0.)
;    2012-JAN-9   HDW III:(V 2.2) Added the P_BC tag.  This is a constant
;    pressure term at the boundary.  
;    2012-JAN-9   HDW III:(V 2.2) Added the CHROMO_MODEL tag.  This a
;    string variable telling the various programs which chromospheric
;    model to use.
;-  



function mk_loop_struct,N_VOLUMES, $
                        S_ARRAY=S_ARRAY, $
                        STATE=STATE,B=B,G=G,AXIS=AXIS, $
                        RAD=RAD,E_H=E_H,T_MAX=T_MAX,$
                        N_DEPTH=N_DEPTH, note, $
                        COPIES=COPIES,AREA=AREA,P_0=P_0, P_BC=P_BC, $
                        START_FILE=START_FILE,TIME=TIME,$
                        DEPTH=DEPTH, NOTES=NOTES,$
                        SAFETY_GRID=SAFETY_GRID, SAFETY_TIME=SAFETY_TIME,$
                        CHROMO_MODEL=CHROMO_MODEL
 
;Set so that () is for functions and [] is for array indices
compile_opt strictarr
Version=2.2
LOOP=-1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check to see what's defined.  If something isn't passed, then set
;  it equal to 0.
;Check to see if state is defined.  This trumps N_VOLUMES.
if keyword_set(state) then N_VOLUMES=n_elements(state.e)
;Now, if N_VOLUMES is not yet set then define it.
if size( N_VOLUMES, /TYPE) eq 0 then N_VOLUMES=300

if not keyword_set(state) then $
  state={e:dblarr(N_VOLUMES), n_e:dblarr(N_VOLUMES),$
         v:dblarr(N_VOLUMES-1),time:0d0}

if not keyword_set(S_ARRAY) then s=dblarr(N_VOLUMES-1)$
  ELSE S=S_ARRAY
if not keyword_set(time) then time=double(state[0].time)
if not keyword_set(B) then B=dblarr(N_VOLUMES-1)
if not keyword_set(G) then G=dblarr(N_VOLUMES-1)
if not keyword_set(AXIS) then AXIS=dblarr(3,N_VOLUMES-1)
if not keyword_set(E_H) then E_H=dblarr(N_VOLUMES-2)
;T_MAX is handled further down.
if not keyword_set(N_DEPTH) then N_DEPTH=0l
if not keyword_set(P_0) then P_0=0d
if not keyword_set(P_BC) then P_BC=[0d, 0d]
if not keyword_set(START_FILE) then START_FILE=''
if not keyword_set(DEPTH) then DEPTH=0d0
if not keyword_set(NOTES) then NOTES=STRARR(5)
if not keyword_set(SAFETY_GRID) then SAFETY_GRID= 0.
if not keyword_set(SAFETY_TIME) then SAFETY_TIME= 0.
if not keyword_set(CHROMO_MODEL) then CHROMO_MODEL= 'SINGLE CELL'

case 1 of 
    (not keyword_set(AREA) and not keyword_set(RAD)):begin
         AREA=dblarr(N_VOLUMES-1)
         RAD=dblarr(N_VOLUMES-1)
     end
     (not keyword_set(AREA) and  keyword_set(RAD)):begin
         AREA=!dpi*RAD*RAD
     end
     ( keyword_set(AREA) and not keyword_set(RAD)):begin
         RAD=sqrt(AREA/!dpi)
     end
     ( keyword_set(AREA) and  keyword_set(RAD)):begin
     end

 endcase

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Explanations of each tag
tag_notes=[$                  
          '{l:double; Loop length [cm]',$ 
          's:dblarr[N-1]; length of cell [cm], defined on surfaces',$
          's_alt:dblarr[N-1]; lengths inside the volume [cm], defined on volumes',$
          'axis:dblarr[3,N-1]; 3D axis of the loop [cm],defined on surfaces',$
          'e:dblarr[N]; Energy in each volume [ergs],defined on volumes ',$
          'n_e:dblarr;[N] Electron number density in a volume',$
          'v:dblarr[N-1]; Velocity of plasma [cm s^-1],defined on surfaces',$
          'b:dblarr;[N-1] Magnetic field on a surface [Gauss],defined on surfaces',$
          'g:dblarr[N-1]; Gravitational acceleration [cm s^-2], defined on surfaces',$
          'rad:dblarr[N-1]; Radius of each surface  [cm]',$
          'A:dblarr[N-1]; area if each surface.',$
          'e_h:dblarr[N-2]; Volumetric heating rate for each interior volumes (not the ends) [erg s^-1 cm^-3]',$
          't_max:double; Maximum temperature of loop [K]',$
          'n_depth:int; Number of cells on each footpoint that were added',$
          'start_file:string; Name of the file used to start the sim',$
          'T:dblarrdblarr[N-1];;Temperature of loop [K], defined on volumes',$
          'Version:INT ; Version number',$
          'P_BC:double ;Constant Pressure of the boundary Cell',$
          'CHROMO_MODEL:string ;Name of chromospheric model to be used',$
          'tag_notes:strarr(n_tags); Explanations of each tag',$
          'Notes:strarr(?);Whatever you want it to be']      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Since this is really confusing, I'll take the time to explain it
;again so that I don't get confused.  Loop parameters are defined on a
;staggered grid.  The number of volumes in that grid are defined by
;N. The parameters defined in those volumes are n_e and e.  Velocities
;are deifned on the surfaces of these volumes and there is always one
;less surface than volume.  (The endpoint volumes have one side each
;that is unbounded).  
;
;Gravity is defined on the surface boundaries as are the coordinates
;for the axes.  E_H or the heat input is defined in volumes which
;number two less that than the grid volumes because they do not
;contaion the endpoint volumes that are unbounded on a side.
;
;Any derived quantity (such as temperature) is defined on the part of
;the grid (volume or surface) that the components for its derivation
;are defined on (i.e. since temperature is derived from density and
;energy, it is defined in the volumes).
;
;I'm defining B on the surfaces.  The reason is that flux (B*Area) is
;an invariant in ideal MHD.  Since area is defined on the surfaces, so
;should B.
;
;
;-WHEW!
;
if n_elements(E_H) ne N_VOLUMES-2 then E_H=dblarr(N_VOLUMES-2)+e_h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;x on the volume element grid (like e, n_e)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
s_alt = shrec_get_s_alt(s)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
T = shrec_get_temp(state)
if size(t_max,/TYPE) ne (4 OR 5) then $
  t_max=max(T)

         loop={l:double(max(s)), $   ;Loop length [cm]
               L_half:float(max(s))/2., $ ;Loop half length [cm]
               s:double(s), $                      ;length of cell from surface to surface [cm]
               s_alt:double(s_alt),$               ;3D axis of the loop [cm]
               axis:double(axis),$                 ; ;3D axis of the loop [cm]
               state:state,$ 
               b:Double(b),$            ;Magnetic field in a surface [Gauss]
               g:Double(g),$            ;Gravitational acceleration [cm s^-2]
               rad:Double(rad) ,$       ;Radius of each surface  [cm]
               A:Double(Area)  ,$          ; area if each surface.',$
               e_h:Double(e_h) ,$       ; Volumetric heating rate for each interior volumes (not the ends)',$
               t_max:double(t_max),$   ;Maximum temperature of loop [K]
               n_depth:long(n_depth),$ ;Number of cells on each footpoint that were added
               depth:double(depth),$     ;Depth of Chromsphere [cm]
               P_BC:double(P_BC),$    ;Constant Pressure of the boundary Cell
               start_file:start_file,$   ;Name of the file used to start the sim
               Version:float(Version)  ,$ ;version number
               tag_notes:tag_notes,$
               notes:notes,$
               SAFETY_GRID:float(SAFETY_GRID),$
               SAFETY_TIME:float(SAFETY_TIME),$
               CHROMO_MODEL:CHROMO_MODEL}    
     

if keyword_set(COPIES) then $
  loop=replicate(loop, COPIES)

return, loop
     
     
 END                            ; of main
