;+
; NAME:
;	mk_chromo_test_loop
;
; PURPOSE:
;	Generate a semi-circular loop of constant temperature ad  
;        create a file for input to the evolve hydro codes and PaTC
;
; CATEGORY:
;	Hydrodynamics codes
;       PaTC
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;       diameter: [cm] Cross-sectional diameter of loop. Considered
;       constant for now. 
;     
;       length: [cm] Length of the loop, It's a semi-circular loop so
;       the  radius of that circle will be length/!dpi. 
;
;       B: [Gauss] Considered constant since the loop diameter is
;       constant
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	Q0: Volumetric heating rates
;
; OUTPUTS:
;  Loop structure containing the tags
;	 state:  Loop History structure $
;       
;        g: [cm s^-2] Parallel acceleration due to gravity
;    
;        A:[cm^2] area of the faces
;       
;        s: [cm] length coordinate.  Face to face of the grid cells 
;        n: [cm^-3] Electron density
;        E_h, 
;        L [cm] New loop length,
;        T_max [[K] Loops maximum temperature
;        orig, 
;        n_depth depth of chomospheric penetration
;	
;
; OPTIONAL OUTPUTS:
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
; MODIFICATION HISTORY:
; 	Written by:Henry (Trae) Winter III (HDWIII) 2012-07-18
;'
;-

function mk_chromo_test_loop

lentgth=1d9
diameter=1d8

mk_semi_circular_loop,diameter,length, loop=loop

loop.state.n_e[*]=1d9
loop.state.e_h[*]=3.*loop.state.n_e[*]*!shrec_kB*1d6


'T0 APEX P0'
