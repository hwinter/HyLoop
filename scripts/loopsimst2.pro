;Simulate loop equilibria at a variety of temperatures
;loopsimst2
; ssw_batch loopsims loopsims2.log

set_plot,'x'


;Access loop modeling s/w
;!PATH = '/disk/tanal/kankel/loopmodel:'+!PATH
;spawn,'cp /disk/tanal/kankel/loopmodel/bnh_splint.so .'
;wait,5

;Variables to tell the software what computer you are on.
computer=!computer
so =get_bnh_so(computer)
patc_dir=getenv('PATC')
;Tmax = [0.6, 1.0, 1.5, 2.0, 2.5, 3.0, 5.0, 7.0, 10.0]
Tmax = [1.0]
	;Maximum temps of loops, MK
	
Length = 4d9 ;cm, total loop length

Nloops = n_elements(Tmax)
i=0
;for i = 0, Nloops-1 do begin
	fname = $
               patc_dir+'/test/loop_data/loop_T' $
               + strcompress(string(Tmax[i],format='(f4.1)'),$
		/remove_all) + '_eq.sav'
        fname='SC_test_loop_1d6.sav'
	loopeqt2, Ttop=Tmax[i]*1e6, LENGTH=Length, fname=fname, $
                 rebin=400, depth=2e5, rtime=60d0*60d0,$
                 safety=1.5,computer=!computer,/LOUD
       ; print,'Min, Max velocity'
       ; pmm,state
;endfor



end