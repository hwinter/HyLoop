
set_plot, 'z'

prefix='sjc_therm_nt_'
TITLE='Thermal vs Non-Thermal'
movie_name='sjc_1_them_nt'
web_name='sjc_1_them_nt_java/'

xr=[-20, 20]
yr=[-35, 50]
outs_y=40
cthick=5

max_n_files=200
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
data_dir=getenv('DATA')+'/PATC/runs/flare_exp_01/'
plots_dir=data_dir+'plots/'
gif_dir=data_dir+'gifs/'



spawn, 'mkdir '+plots_dir

image_name=['alpha_-4__hxr_3_6_']
;folders=['alpha=-4/',$
;         'alpha=-3/',$
;         'alpha=-2/',$
;         'alpha=-1/',$
;         'alpha=0/',$
;         'alpha=1/',$
;         'alpha=2/',$
;         'alpha=3/',$
;         'alpha=4/']
;sub_folders=['699_25/run_01/',$
;             '699_25/run_02/',$
;             '699_25/run_03/',$
;             '699_25/run_04/',$
;             '699_25/run_05/']
folders=['alpha=-4/']
sub_folders=['699_25/run_01/']

n_folders=n_elements(folders)
n_runs=n_elements(sub_folders)

 for i=0ul,  n_folders-1ul do begin
     
     for j=0ul, n_runs-1ul do begin
         eps_names=''
         gif_names=''
         cd , data_dir+folders[i]+sub_folders[j]
         files=FILE_SEARCH('./', '*.loop', COUNT=N_FILES, $
                          /FULLY_QUALIFY_PATH)
         n_files<=max_n_files
         
             restore, files[0]
;Calculate emissions
             therm_n_nt=get_xr_emiss(loop, nt_brems, ENERGIES=energies1)
             min_flux=min(therm_n_nt)
             max_flux=max(therm_n_nt)
         for k=1ul, n_files-1ul do begin
;Restore current loop file
             restore, files[k]
;Calculate emissions
             therm_n_nt=get_xr_emiss(loop, nt_brems, ENERGIES=energies1)
             min_flux<=min(therm_n_nt)
             max_flux>=max(therm_n_nt)
         endfor
         
         for k=0ul, n_files-1ul do begin
;Restore current loop file
             restore, files[k]
;Calculate emissions
             therm_n_nt=get_xr_emiss(loop, nt_brems, ENERGIES=energies1)
             therm_only=get_xr_emiss(loop, nt_brems, ENERGIES=energies2,/THERM_ONLY)
             nt_only=get_xr_emiss(loop, nt_brems, ENERGIES=energies3,/NT_ONLY)
;Turn emission into arrays for hdw_pretty_plot2              
             xy0=[[energies1], [therm_n_nt]/max_flux]
             xy1=[[energies2],[therm_only]/max_flux]
             xy2=[[energies3],[nt_only]/max_flux]
             eps_name=plots_dir+prefix+string(loop.state.time,format='(I05)')+'.eps'
             gif_name=plots_dir+prefix+string(loop.state.time,format='(I05)')+'.gif'
             hdw_pretty_plot2, xy0,xy1,xy2,$
                               LABELS=['Total', 'Thermal', 'Non-Thermal'],$
                               BOX=0, /RIGHT,EPS=eps_name,$
                               /ys, YRANGE=[min_flux/max_flux, 1]
             
             PRint, 'Working on: '+eps_name
             spawn, 'convert '+ ps_name+' '+gif_name

   ;     spawn, "convert  -rotate '-90' "+ $
    ;           gif_name+'  '+gif_name

         endfor ; k loop
         

         gif_files=gif_files[1:N_ELEMENTS(gif_files)-1UL]
         print, movie_dir+movie_name
         image2movie,gif_files, $
                     movie_name=movie_name+'.mpg',$
                     movie_dir=movie_dir,$
                     /mpeg,$         ;/java,$
                     scratchdir=gif_dir ,$ ;nothumbnail=1,$
                     /nodelete




     endfor; j loop
 endfor ; i loop








end
