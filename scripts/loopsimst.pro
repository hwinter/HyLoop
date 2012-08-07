;Simulate loop equilibria at a variety of temperatures
;
; ssw_batch loopsims loopsims2.log

set_plot,'x'


;Access loop modeling s/w
;!PATH = '/disk/tanal/kankel/loopmodel:'+!PATH
;spawn,'cp /disk/tanal/kankel/loopmodel/bnh_splint.so .'
;wait,5

;Variables to tell the software what computer you are on.
computer='filament'
;computer='dawntreader'
;computer='mithra'
so =get_bnh_so(computer)

;Tmax = [0.6, 1.0, 1.5, 2.0, 2.5, 3.0, 5.0, 7.0, 10.0]
Tmax = [0.6]
	;Maximum temps of loops, MK
	
Length = 4e9 ;cm, total loop length

Nloops = n_elements(Tmax)
i=0
;for i = 0, Nloops-1 do begin
	fname = 'loop_T' + strcompress(string(Tmax[i],format='(f4.1)'),$
		/remove_all) + '_eq.sav'
	loopeqt, Ttop=Tmax[i]*1e6, L=Length, fname=fname, $
                 rebin=200, depth=2e5, rtime=2d3,$
                 safety=1.5,computer=computer
       ; print,'Min, Max velocity'
       ; pmm,state
;endfor



end
