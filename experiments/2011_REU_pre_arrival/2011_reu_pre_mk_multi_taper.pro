
lengths=[5d8,1d9,5d9, 1d10]
lengths_string=['5d8','1d9','5d9', '1d10']
taper_ratio=[2,4,6,8,10]
file_name=''


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HEAT_NAME=
T_MAX=1d6
N_DEPTH=30
T0=T0
;debug=
B_Mag=10
N_CELLS=700
DEPTH=2d6
;ADD_CHROMO=ADD_CHROMO
SIGMA_FACTOR=SIGMA_FACTOR
PSL=PSL
ALPHA=ALPHA 
BETA=BETA
NOVISC=1
STABILIZE=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
top_dir='/home/hwinter/Data/HyLoop/runs/2011_REU_pre_arrival/'

for i=0ul, n_elements(lengths)-1ul do begin
   for j=0ul, n_elements(taper_ratio)-1ul do begin
      current_folder=top_dir+'l='+lengths_string[i]+'_taper='+taper_ratio_string[j]+'/'
      
      spawn, 'mkdir '+current_folder
      outname=current_folder+file_name
      
      loop=mk_tapered_loop(gamma, diameter, length, $
                           T_MAX=T_MAX, N_DEPTH=N_DEPTH,$
                           TO=T0,debug=debug, $
                           B_Mag=B_Mag,Q0=Q0,  nosave=nosave, $
                           outname=outname,N_CELLS=N_CELLS,$
                           X_SHIFT=X_SHIFT,Y_SHIFT=Y_SHIFT,$
                           Z_SHIFT=Z_SHIFT, LOOP=LOOP,$
                           DEPTH=DEPTH,$
                           ADD_CHROMO=ADD_CHROMO,$
                           SIGMA_FACTOR=SIGMA_FACTOR,$
                           PSL=PSL, ALPHA=ALPHA, BETA=BETA,$
                           HEAT_NAME=HEAT_NAME, NOVISC=NOVISC, $
                           STABILIZE=STABILIZE,_Extra=Extra

      save, loop, FILE=

   endfor
endfor






















END
