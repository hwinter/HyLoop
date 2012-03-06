;2008-APR-28 ;Changed to account for new log output of 
;            get_loop_em.pro

function get_sxt_emiss, loop,PER_VOL=PER_VOL


ssw_path,/SXT
file = CONCAT_DIR('$DIR_SXT_SENSITIVE','sra950419_01.genx')
restgen,file=file, str=area

volumes=get_loop_vol(loop[0].s,loop[0].a)

num_elements=n_elements(volumes)
num=n_elements(loop)

open=dblarr(num,num_elements)
thin_al=dblarr(num,num_elements)
dag=dblarr(num,num_elements)
be=dblarr(num,num_elements)
thick_al=dblarr(num,num_elements)
mg=dblarr(num,num_elements)

FOR n_lhist=0, num -1 DO BEGIN
    T=get_loop_temp(loop[n_lhist].state)
    em=get_loop_em(loop[n_lhist].state,$
                   loop[n_lhist].s,loop[n_lhist].a)
    ;Open Filter
    open[n_lhist,*]=sxt_flux(alog10(T[1:num_elements]),$
                             1,/noverbose,em=(em))
    ;Al 1265 A
    thin_al[n_lhist,*]=sxt_flux(alog10(T[1:num_elements]),$
                                     2,/noverbose,em=(em))
    ;Dag
    dag[n_lhist,*]=sxt_flux(alog10(T[1:num_elements]),$
                                     3,/noverbose,em=(em))
    ;Be 119 micro meter
    be[n_lhist,*]=sxt_flux(alog10(T[1:num_elements]),$
                                     4,/noverbose,em=(em))
    ;Al 12 micro meter
    thick_al[n_lhist,*]=sxt_flux(alog10(T[1:num_elements]),$
                                     5,/noverbose,em=(em))
    ;Mg 3  micro meter
    mg[n_lhist,*]=sxt_flux(alog10(T[1:num_elements]),$
                                     6,/noverbose,em=(em))

    if keyword_set(PER_VOL) then begin       
        volumes=get_loop_vol(loop[n_lhist].s,loop[n_lhist].a)
        open[n_lhist,*]=open[n_lhist,*]/volumes
        thin_al[n_lhist,*]=thin_al[n_lhist,*]/volumes
        dag[n_lhist,*]=dag[n_lhist,*]/volumes
        be[n_lhist,*]=be[n_lhist,*]/volumes
        thick_al[n_lhist,*]=thick_al[n_lhist,*]/volumes
        mg[n_lhist,*]=mg[n_lhist,*]/volumes
    endif

     


endfor                   
sxt_emiss={open:open,thin_al:thin_al,$
           dag:dag,be:be,thick_al:thick_al,$
           mg:mg}

return,sxt_emiss
end
