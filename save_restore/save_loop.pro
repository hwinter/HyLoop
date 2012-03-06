pro save_loop_xdr, loops,NT_BEAM,NT_BREMS,$
               FILENAME=FILENAME
               
loop=loops[0]
FILE_EXT='xdr.loop'
FILE_PREFIX='loop'
if not keyword_set(FILENAME) then $
  filename=strcompress(FILE_PREFIX $
                       +string(loop.state.time,FORMAT='(I05)') $
                       +'.'+FILE_EXT,/REMOVE_ALL)




version=1.0
N=n_elements(loop.state.e)
n_part=n_elements(nt_beam)
n_nt_brems_arrays=n_elements(nt_brems[0].n_photons)

openw, lun, filename,/GET_LUN, /XDR

writeu,lun,version, N, n_part, n_nt_brems_arrays

;Write the loop data
;Write the state data    
writeu,lun,loop.state.e
writeu,lun,loop.state.n_e
writeu,lun,loop.state.v
writeu,lun,loop.state.time

writeu,lun,loop.L           
writeu,lun,loop.L_HALF        
writeu,lun,loop.S              
writeu,lun,loop.S_ALT         
writeu,lun,loop.AXIS        
writeu,lun,loop.B             
writeu,lun,loop.G              
writeu,lun,loop.RAD           
writeu,lun,loop.A             
writeu,lun,loop.E_H           
writeu,lun,loop.T_MAX           
writeu,lun,loop.N_DEPTH        
writeu,lun,loop.DEPTH          
writeu,lun,loop.START_FILE     
writeu,lun,loop.VERSION        
writeu,lun,loop.TAG_NOTES      
writeu,lun,loop.NOTES          
writeu,lun,loop.SAFETY_GRID    
writeu,lun,loop.SAFETY_TIME     


;Write particle data
for i=0ul,n_part-1ul do begin
    writeu,lun,  nt_beam[i].KE_TOTAL    
    writeu,lun,  nt_beam[i].MASS           
    writeu,lun,  nt_beam[i].PITCH_ANGLE    
    writeu,lun,  nt_beam[i].X              
    writeu,lun,  nt_beam[i].CHARGE         
    writeu,lun,  nt_beam[i].ALIVE_TIME     
    writeu,lun,  nt_beam[i].STATE          
    writeu,lun,  nt_beam[i].MAG_MOMENT     
    writeu,lun,  nt_beam[i].SCALE_FACTOR   
    writeu,lun,  nt_beam[i].POSITION_INDEX 
    writeu,lun,  nt_beam[i].DESCRIPTION    
    writeu,lun,  nt_beam[i].VERSION        

endfor



;Write nt_brems data
;for i=0ul, N-3ul do begin
    writeu,lun, nt_brems.ph_energies, nt_brems.n_photons
;endfor 


close, lun
free_lun, lun

END

