set_plot,'z'

top_dir=getenv('DATA')+'/PATC/runs/piet_scaling_laws/Const_flux/'
    
P_L_dirs=['alpha=-2.5_beta=0.0/', $
          'alpha=-2.4_beta=0.0/', $
          'alpha=-2.0_beta=0.0/', $
          'alpha=-1.5_beta=0.0/', $
          'alpha=-1.0_beta=0.0/', $
          'alpha=-0.5_beta=0.0/'];, $

sub_folders= ['n_depth=25_n_cells=500/', $
             'n_depth=25_n_cells=1000/', $
             'n_depth=50_n_cells=500/', $
             'n_depth=50_n_cells=1000/']  
folders=''       
TITLE_suffix_0=[' ND=25 NC=500', $
              ' ND=25 NC=1000', $
              ' ND=50 NC=500', $
              ' ND=50 NC=1000']
TITLE_suffix=''
for i=0ul, n_elements(P_L_dirs) -1ul do begin
    for j=0ul, n_elements(sub_folders) -1ul do begin
        folders=[folders,top_dir+P_L_dirs[i]+sub_folders[j]]
        TITLE_suffix=[TITLE_suffix,TITLE_suffix_0[j] ]
    endfor
endfor 
folders=folders[1:n_elements(folders)-1ul]
TITLE_suffix=TITLE_suffix[1:n_elements(folders)-1ul]

prefix='T'
suffix='.loop'
freq_out=30
;verbose=1
plot_dir=folders+'plots/'
scratchdir=folders+'movies/scratch/'
movie_dir=folders+'movies/'
gif_dir=folders+'gifs/'
Movie_name='hd_movie'

;stop     
;Make sure these folders exist.
for i=0ul, n_elements(movie_dir)-1ul do begin
    spawn, 'mkdir '+gif_dir[i]
    spawn, 'mkdir '+movie_dir[i]
    spawn, 'mkdir '+scratchdir[i]
    spawn, 'mkdir '+plot_dir[i]
    endfor

for i=0ul, n_elements(folders)-1ul do begin
    ps_name=''
    pmin=1d35
    pmax=0d0
    dmin=1d35
    dmax=0d0
    vmin=1d35
    vmax=0d0
    tmin=1d35
    tmax=0d0

    loop_files0=file_search(folders[i] ,$
                            prefix+'*'+suffix, $
                            COUNT=N_loops_0, $
                            /FULLY_QUALIFY_PATH)
    if N_loops_0 le 0 then goto, no_files

    for j=0ul, N_loops_0-1ul, freq_out do begin
        restore, loop_files0[j]
        
        p=get_loop_pressure(loop)
        t=get_loop_temp(loop)
        
        pmin<=min(p)
        pmax>=max(p)
        dmin<=min(loop.state.n_e)
        dmax>=max(loop.state.n_e)
        vmin<=min(loop.state.v)
        vmax>=max(loop.state.v)
        tmin<=min(t)
        tmax>=max(t)
        
        
    endfor

    PRANGE=[pmin,pmax]
    DRANGE=[dmin,dmax]
    VRANGE=[vmin,vmax]
    TRANGE=[tmin,tmax]
    
    ps_files=''
    gif_files=''
    index_str_array=''
    for j=0ul, N_loops_0-1ul, freq_out do begin
        
        restore, folders[i]+'startup_vars.sav'
        restore, loop_files0[j]
        gif_dir=folders+'gifs/'
        TITLE='!9a!3='+ALPHA_STRING+ $
              ' !9b!3='+Beta_STRING+ $
              TITLE_suffix[i]
        index_string= string(j,FORMAT= $  
                    '(I5.5)')
        POST=plot_dir[i]+'hd_plot'+ $
             '_'+index_string+'.ps'
        gif_file=gif_dir[i]+'hd_plot'+ $
                 '_'+index_string+'.gif'
        
       index_str_array=[index_str_array, index_string]
        stateplot3, loop, fname=POST,  verbose=verbose, $
                    LINESTYLE=LINESTYLE, VRANGE=VRANGE,$
                    XRANGE=XRANGE,TRANGE=TRANGE, DRANGE=DRANGE,PRANGE=PRANGE ,$
                    FONT=FONT,XSIZE=XSIZE, YSIZE=YSIZE ,$
                    CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK,$
                    PLOT_LINE=PLOT_LINE, TITLE=TITLE, LOG=LOG
        spawn, 'convert  '+POST+' '+gif_file
        spawn, "convert  -rotate '-90' "+ $
               gif_file+'  '+gif_file
        
        
        ps_files=[ps_files, POST]
        gif_files=[ gif_files,gif_file]
    endfor
    
    n_files=n_elements(ps_files)
    ps_files=ps_files[1:n_files-1ul]
    gif_files=gif_files[1:n_files-1ul]
    index_str_array=index_str_array[where(index_str_array ne '')]
    image2movie,gif_files, $
                movie_name=movie_dir[i]+movie_name,$
                /mpeg,$         ;/java,$
                scratchdir=scratchdir[i] ,$;nothumbnail=1,$
                /nodelete
    
    image2movie,gif_files, $
                movie_name=movie_dir[i]+movie_name,$
                /java,$
                scratchdir=scratchdir[i] ,$ ;nothumbnail=1,$
                /nodelete
    
    ;Remove these unwanted thumbnails.
    spawn,'rm -f  '+movie_dir[i]+'*micon* *mthumb*'
        

    no_files:
    endfor  ;i loop
     

end





