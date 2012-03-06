set_plot,'X'
patc_dir=getenv('PATC')
;restore, patc_dir+'scripts/gcsm_loop.sav'
restore,'/disk/hl2/data/winter/data2/PATC/runs/2006_SEP_26/gcsm_loop.sav'
rtime=60d0*60d0
fname1=patc_dir+'2007_01_19_test1.sav'
fname2=patc_dir+'2007_01_19_test2.sav'

so=get_bnh_so(/init)

n_loop=n_elements(loop)
heat=loop[n_loop-1l].e_h[*,0]
g=loop[n_loop-1l].g
a=loop[n_loop-1l].a
x=loop[n_loop-1l].s
depth=loop[n_loop-1l].depth
state=loop[n_loop-1l].state
safety=5

loopmodelt, g, A, x, heat, rtime, state=state, T0=1e4, $
            outfile=fname1, /src, /fal, /uri,$
            depth=depth, safety=safety,$
            so=so

regrid3, loop,/SHOWME,/NOSAVE
         

heat=loop[n_loop-1l].e_h[*,0]
g=loop[n_loop-1l].g
a=loop[n_loop-1l].a
x=loop[n_loop-1l].s
depth=loop[n_loop-1l].depth
state=loop[n_loop-1l].state
safety=5

loopmodelt, g, A, x, heat, rtime, state=state, T0=1e4, $
            outfile=fname2, /src, /fal, /uri,$
            depth=depth, safety=safety,$
            so=so



end
