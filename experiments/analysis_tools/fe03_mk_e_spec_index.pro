;.r  fe03_mk_e_spec_index.pro

file_name='e_spec_index.sav'
ps_name='e_spec_vs_time.eps'
set_plot, 'z'

data_dir=getenv('DATA')+'/PATC/runs/flare_exp_05/'
;data_dir='/Users/winter/Documents/My Posters/2007_Fall_agu/flare_files/'
;folders=['alpha=-100/',$
;         'alpha=-75/',$
;         'alpha=-50/',$
;         'alpha=-25/',$
;         'alpha=-4/',$
;         'alpha=-3/',$
;         'alpha=-2/',$
;         'alpha=-1/',$
;         'alpha=0/',$
;         'alpha=1/',$
;         'alpha=2/',$
;         'alpha=3/',$
;         'alpha=4/',$
;         'alpha=25/',$
;         'alpha=50/',$
;         'alpha=75/',$
;         'alpha=100/']

grid_folders=['699_25/']

run_folders=['run_01/',$
             'run_02/',$
             'run_03/',$
             'run_04/',$
             'run_05/']

sub_folders=['699_25/run_01/',$
             '699_25/run_02/',$
             '699_25/run_03/',$
             '699_25/run_04/',$
             '699_25/run_05/']
;sub_folders=grid_folders+run_folders

folders=['alpha=0/']
n_folders=n_elements(folders)
n_runs=n_elements(sub_folders)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VAR_FOLDER=strcompress(data_dir+folders[0]+grid_folders[0]+'vars', /REMOVE_ALL)
PLOTS_FOLDER=strcompress(data_dir+folders[0]+grid_folders[0]+'plots', /REMOVE_ALL)

spawn, 'mkdir '+VAR_FOLDER
spawn, 'mkdir '+PLOTS_FOLDER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loop_count=ulong(1d6)
for i=0ul,  n_folders-1ul do begin
    for k=0ul, n_runs-1ul do begin
        files=file_search( data_dir+folders[i]+sub_folders[k],$
                           'patc*.loop', $
                           COUNT=N_loops, $
                           /FULLY_QUALIFY_PATH)
        loop_count<=N_loops
    endfor
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for i=0ul,  n_folders-1ul do begin
    spec_index=dblarr(n_runs,loop_count )
    for k=0ul, n_runs-1ul do begin
        
        files=file_search( data_dir+folders[i]+sub_folders[k],$
                           'patc*.loop', $
                           /FULLY_QUALIFY_PATH)
        for l=0ul,loop_count-1ul do begin
            
            restore, files[l]
            spec_index[k,l]= get_nt_beam_spec_index(nt_beam)
            
        endfor
    endfor

        save, spec_index, FILE=VAR_FOLDER+file_name

        Q=spec_index
        mean_Q=total(Q, 1)/loop_count
        
        n_elem=n_elements(mean_Q[*,0])
        mQ2=rebin(mean_Q,n_elem,  n_loops)
        
        VARIANCE=(1d0/(n_loops-1ul))*$
                 total((Q-mQ2)*(Q-mQ2), 1)
        
        STD_DEV=sqrt(VARIANCE)

    ; stop
 endfor



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end
