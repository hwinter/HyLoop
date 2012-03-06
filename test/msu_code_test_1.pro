
;Simulate loop equilibria at a variety of temperatures
;
; ssw_batch msu_code_test_1 msu_code_test_batch.txt

set_plot,'x'
;patc_dir=getenv('PATC')
;sav_dir= patc_dir+'/test/loop_data/' 
so =get_bnh_so(!computer,/INIT)
rtime=60d0*60d0
if size(name_prefix,/TYPE) ne 7 then  $
 name_prefix =strcompress(arr2str(bin_date(),$
                            DELIM='_',/NO_DUP),$
                    /REMOVE_ALL)
fname1=name_prefix+ '_test_eq.sav'
fname2=name_prefix+ '_test_eq.loop'



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make some settings to make use of IDL multithreading
;Most of the defaults are ok.
n_cpu=(!CPU.HW_NCPU)+0

CPU ,TPOOL_MAX_ELTS = 1d6 ,TPOOL_MIN_ELTS = 5d3,$
     TPOOL_NTHREADS=n_cpu

;Tmax = [0.6, 1.0, 1.5, 2.0, 2.5, 3.0, 5.0, 7.0, 10.0]
Tmax = [1.0]
	;Maximum temps of loops, MK
LOOP=1
mk_semi_circular_loop, $
  /NOSAVE,$
  outname=outname,N_CELLS=N_CELLS,$
  X_SHIFT=X_SHIFT,Y_SHIFT=Y_SHIFT,$
  Z_SHIFT=Z_SHIFT, LOOP=LOOP

Nloops = n_elements(Tmax)
i=0
STATE_out=1
	loopeqt2, Ttop=Tmax[i]*1e6, LENGTH=loop.l, fname=fname, $
                  rebin=n_elements(loop.state.e),$
                  DEPTH=0, RTIME=rtime,$
                  safety=1.5,computer=!computer,$
                  STATE_OUT=STATE_OUT ,/LOUD
        print,'Min, Max velocity'

loop.state=loop.lhist
save, loop, FILE=fname2

end
