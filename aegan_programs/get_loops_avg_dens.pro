;
; NAME: get_loops_avg_dens
; 
;
; PURPOSE: Collects average density data (maintaining spatial resolution) for one second when given an
;          array of loops
;          (modification of Trae's get_loops_avg_temp
;
; 
;
; CALLING SEQUENCE: density[t,*]=get_loops_avg_dens(run_loops, std_dev=std_dev)
; 
;
; INPUTS: run_loops ->array of loop structures over runs
;
; KEYWORD PARAMETERS:
;   Specific Keywords:    
;          STD_DEV=std_dev ->standard deviation of average
;   General analysis keywords:  **NOT SUPPORTED**
;
; 
; 
;
; OUTPUTS: mean_Q ->average density over runs (maintaining spatial resolution)
;
; OPTIONAL OUTPUTS: TEMPS, DENSITY,losEM, LENGTH, DENS_DEV, TEMP_DEV ->(See above)
; 
; SAVED:   length, temps, density, dens_dev, losEM, temp_dev
;                          ->FILENAME='/Volumes/Herschel/aegan/Data/saved/'+initial_parameters+'_temps_dens.sav'
; 
;
; MODIFICATION HISTORY:
;   Written by: Andrea Egan, July 2011
;



function get_loops_avg_dens, loops, STD_DEV=STD_DEV, VARIANCE=VARIANCE

n_loops=n_elements(loops)
Q=loops.state.n_e


mean_Q=total(q, 2)/n_loops

n_elem=n_elements(mean_Q[*,0])
mQ2=rebin(mean_Q,n_elem,  n_loops)

VARIANCE=(1d0/(n_loops-1ul))*$
         total((Q-mQ2)*(Q-mQ2), 2)

STD_DEV=sqrt(VARIANCE)


return, mean_Q


END


