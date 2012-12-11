;+
; NAME:
;    loop_2_text.pro	
;
; PURPOSE:
;    Save the information in a loop structure to a save file	
;
; CATEGORY:
;	
;
; CALLING SEQUENCE:
;	loop_2_text, loop, filename
;
; INPUTS:
;	Loop:  A structure containing the information about the
;	plasma.  
;       filename: path and name of a text file to save the information to.
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	A csv text file containing the information about the loop 
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
; 	Written by:	Henry "Trae" D. Winter III 2012-Nov-8

;-

pro loop_2_text , loop, filename
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if size(filename, /TYPE) eq 0 then filename='loop_file.csv'

  if n_elements(loop) ne 1 then  print, "Need a single loop input."

  loop_in=loop[0]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check ot see if a file named filename already exists.  
  file_exist = FILE_TEST(filename)
;If filename exists then warn the user
  if file_exist eq 1 then print, 'File filename exists. Overwriting.'  
;If filename does not exit add a descriptive header column to the file
     openw, lun, filename, /get_lun
     
     header_string='N_vol'+','+$
                   'Length'+','+$
                   's'+','+ $
                   'axis.x'+','+$
                   'axis.y'+','+$
                   'axis.z'+','+$                 
                   'state.e'+' , '+$
                   'state.n_e'+' , '+$
                   'state.v'+' , '+$
                   'B'+' , '+$
                   'g'+' , '+$
                   'area'+' , '+$
                   'e_h'+' , '+$
                   'N_Depth'+' , '+$
                   'Depth'+' , '+$
                   'start_file'+' , '+$
                   'safety_grid'+' , '+$ 
                   'safety_time'+' , '+$ 
                   'Notes'+' , '+$ 
                   'version'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For every tag we write a row to the file
     
      data_string='N_vol'+','+$
                  strcompress(string(n_elements(loop.state.e), format='(f30.10)'),/REMOVE)
      printf, lun,data_string

      data_string='Length'+','+$
                  strcompress(string(loop.l, format='(e30.10)'),/REMOVE)
      printf, lun,data_string
      
      data_string='s'+','
      for iii=0ul, n_elements(loop.s)-1 do begin
         data_string+=strcompress(string(loop.s[iii], format='(f30.10)'),/REMOVE)
         if iii ne n_elements(loop.s)-1 then data_string+= '  ,'
      endfor
      printf, lun,data_string  

      data_string='axis.x'+','
      for iii=0ul, n_elements(loop.axis[0,*])-1 do begin
         data_string+=strcompress(string(loop.axis[0,iii], format='(f30.10)'),/REMOVE)
         if iii ne n_elements(loop.axis[0,*])-1 then data_string+= '  ,'
      endfor
      printf, lun,data_string   
   
      data_string='axis.y'+','
      for iii=0ul, n_elements(loop.axis[1,*])-1 do begin
         data_string+=strcompress(string(loop.axis[1,iii], format='(f30.10)'),/REMOVE)
         if iii ne n_elements(loop.axis[1,*])-1 then data_string+= '  ,'
      endfor
      printf, lun,data_string  
    
      data_string='axis.z'+','
      for iii=0ul, n_elements(loop.axis[2,*])-1 do begin
         data_string+=strcompress(string(loop.axis[2,iii], format='(f30.10)'),/REMOVE)
         if iii ne n_elements(loop.axis[2,*])-1 then data_string+= '  ,'
      endfor
      printf, lun,data_string  
   
      data_string='state.e'+','
      for iii=0ul, n_elements(loop.state.e)-1 do begin
         data_string+=strcompress(string(loop.state.e[iii], format='(f30.10)'),/REMOVE)
         if iii ne n_elements(loop.state.e)-1 then data_string+= '  ,'
      endfor
      printf, lun,data_string    
   
      data_string='state.n_e'+','
      for iii=0ul, n_elements(loop.state.n_e)-1 do begin
         data_string+=strcompress(string(loop.state.n_e[iii], format='(f30.10)'),/REMOVE)
         if iii ne n_elements(loop.state.n_e)-1 then data_string+= '  ,'
      endfor
      printf, lun,data_string    
   
      data_string='loop.state.v'+','
      for iii=0ul, n_elements(loop.state.v)-1 do begin
         data_string+=strcompress(string(loop.state.v[iii], format='(f30.10)'),/REMOVE)
         if iii ne n_elements(loop.state.v)-1 then data_string+= '  ,'
      endfor
      printf, lun,data_string    
   
      data_string='state.time'+','+$
                  strcompress(string(loop.state.time, format='(f30.10)'),/REMOVE)
      printf, lun,data_string

      data_string='B'+','
      for iii=0ul, n_elements(loop.B)-1 do begin
         data_string+=strcompress(string(loop.B[iii], format='(f30.10)'),/REMOVE)
         if iii ne n_elements(loop.B)-1 then data_string+= '  ,'
      endfor
      printf, lun,data_string    
   
      data_string='g'+','
      for iii=0ul, n_elements(loop.g)-1 do begin
         data_string+=strcompress(string(loop.g[iii], format='(f30.10)'),/REMOVE)
         if iii ne n_elements(loop.g)-1 then data_string+= '  ,'
      endfor
      printf, lun,data_string    
   
      data_string='area'+','
      for iii=0ul, n_elements(loop.A)-1 do begin
         data_string+=strcompress(string(loop.A[iii], format='(f30.10)'),/REMOVE)
         if iii ne n_elements(loop.A)-1 then data_string+= '  ,'
      endfor
      printf, lun,data_string    
   
      data_string='e_h'+','
      for iii=0ul, n_elements(loop.e_h)-1 do begin
         data_string+=strcompress(string(loop.e_h[iii], format='(f30.10)'),/REMOVE)
         if iii ne n_elements(loop.e_h)-1 then data_string+= '  ,'
      endfor
      printf, lun,data_string  

      data_string='N_Depth'+','+$
                  strcompress(string(loop.N_Depth, format='(f30.10)'),/REMOVE)
      printf, lun,data_string

      data_string='Depth'+','+$
                  strcompress(string(loop.Depth, format='(f30.10)'),/REMOVE)
      printf, lun,data_string

      data_string='start_file'+','+$
                  loop.start_file
      printf, lun,data_string

      data_string='safety_grid'+','+$
                  strcompress(string(loop.safety_grid, format='(f30.10)'),/REMOVE)
      printf, lun,data_string

      data_string='safety_time'+','+$
                  strcompress(string(loop.safety_time, format='(f30.10)'),/REMOVE)
      printf, lun,data_string
      
      data_string='notes'+','
      for iii=0ul, n_elements(loop.notes)-1 do begin
         data_string+=loop.notes[iii]
         if iii ne n_elements(loop.notes)-1 then data_string+= '  ,'
      endfor
      
      data_string='safety_time'+','+$
                  strcompress(string(loop.safety_time, format='(f30.10)'),/REMOVE)
      printf, lun,data_string
    
         

close, lun
free_lun, lun
END

