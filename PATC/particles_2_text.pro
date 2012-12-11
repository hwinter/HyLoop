;+
; NAME:
;	
;
; PURPOSE:
;	Output particle propoerties to a text file
;
; CATEGORY:
;	
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	
;
; OPTIONAL OUTPUTS:
;	
;
; COMMON BLOCKS:
;	
;
; SIDE EFFECTS:
;	
;
; RESTRICTIONS:
;	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by:	HDWIII 2012-Oct-04
;-


pro particles_2_text , nt_particles, filename
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if size(filename, /TYPE) eq 0 then filename='particle_file.csv'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check ot see if a file named filename already exists.  
  file_exist = FILE_TEST(filename)
;If filename exists then annotate to the file
  if file_exist ge 1 then openu, lun, filename, /get_lun, /append
;If filename does not exit add a descriptive header row to the file
  if file_exist lt 1 then  begin
     openw, lun, filename, /get_lun, /append

     header_string='ke_total'+','+$
             'mass'+' , '+$
             'PITCH_ANGLE'+' , '+$
             'x'+' , '+$
             'charge'+' , '+$
             'alive_time'+' , '+$
             'state'+' , '+$
             'mag_moment'+' , '+$
             'scale_factor'+' , '+$
             ;'position_index'+' , '+$
             ;'description'+' , '+$
             'version'
     printf, lun, strcompress(header_string, /remove)
  endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For every particle write out the value of each tag to a file
  for iii=0ul, n_elements(nt_particles)-1 do begin
     data_string=strcompress($
                 strcompress(string(nt_particles[iii].ke_total, format='(f30.10)'),/REMOVE)+ '  ,'+$
                 strcompress(string(nt_particles[iii].mass, format='(E30.10)'),/REMOVE)+ ' , '+$
                 strcompress(string(nt_particles[iii].PITCH_ANGLE, format='(f30.10)'),/REMOVE)+ ' , '+$
                 strcompress(string(nt_particles[iii].x, format='(f30.10)'),/REMOVE)+ ' , '+$
                 strcompress(string(nt_particles[iii].charge, format='(E30.10)'),/REMOVE)+ ' , '+$
                 strcompress(string(nt_particles[iii].alive_time, format='(f30.10)'),/REMOVE)+ ' , '+$
                 nt_particles[iii].state+ ' , '+$
                 strcompress(string(nt_particles[iii].mag_moment, format='(E30.10)'),/REMOVE)+ ' , '+$
                 strcompress(string(nt_particles[iii].scale_factor, format='(f50.10)'),/REMOVE)+ ' , '+$
                                ;nt_particles[iii].description+' , '+$
                 strcompress(string(nt_particles[iii].version, format='(F10.2)'),/REMOVE) ,$
                 /remove)
     printf, lun, data_string


  endfor



close, lun
free_lun, lun
END

