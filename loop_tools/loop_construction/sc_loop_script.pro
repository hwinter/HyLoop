;sc_loop_script
set_plot,'z'
data_dir=getenv('DATA')
patc_dir=getenv('PATC')
dir=patc_dir+'/runs/2006_JUN_12'
fname='/sc_loop'
save_file=dir+fname

diameter=2.5d8
length=7.68d9
B=100d
t_max=1d6
;X_SHIFT=0d;.5d*length
;Y_SHIFT=0d;5d*length
;Z_SHIFT=0d;3d*1d8
N_CELLS=400l
n_depth=101l

;Variables to tell the software what computer you are on.
;computer='filament'
computer='dawntreader'
;computer='mithra'

;Don't worry about the next line
so =get_bnh_so(computer,/init)

mk_semi_circular_loop,diameter,length, B, lhist, $
  axis, rad, g,A,x, E_h, L, $
  T_max, orig, n_depth,$
  Q0=Q0, $                      ;power=power, $
  outname=save_file,N_CELLS=N_CELLS

;stop

q0=get_serio_heat(max(x),T_max)
restore , save_file+'.start'
DELTA_T=60d; Number of seconds per time step
interval=10;number of steps to take

outfile=fname+'_eq.sav'
;Now run loopmodelt with the new heating function
loopmodelt, g, A, x,q0 , interval, state=lhist,  $
            T0=T0, outfile=outfile, /src, /uri, /fal, $
            depth=depth, safety=safety,SO=SO,DELTA_T=DELTA_T


end

;
