
function  mk_loop_light_curves,map_name, $
                                      FILENAME=FILENAME, STRUCTURE=STRUCTURE,$
                                      
;
;+
; NAME:
;	mk_loop_light_curves
;
; PURPOSE:
;	To open a map file, define a submap, generate a light curve
;that is saved in a structure 
;
; CATEGORY:
;	
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	A map file to extract a light curve from. Can also extract a
;	light curve from a submap.
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	A structure 
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
; 	Written by:	Henry (Trae) D. Winter III 2009/10/28
version=0.1;Initial program/
;-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Section to restore the map

;Test to see if the file exists.  If not fail gracefully.

Result = FILE_TEST(map_name, /READ)
if result lt 1 then begin
   Text=['Error in  mk_loop_light_curves.pro.', $
         'No map file passed']
   MESSAGE, Text , /CONTINUE
   return, -1
   
   endif

restore,  map_name 
temp_map=map
tags=

             map1=time_bin_map(map,bin_size)
             map1.xc=XC
             map1.yc=YC       
             
             temp_map=map1
             temp_map=add_tag(temp_map, 0., 'ROLL')
             temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
             temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
             temp_map.xc=XC
             temp_map.yc=YC
             sub_map,temp_map,a_map1,xrange=apex_xr,yrange=apex_yr 
             sub_map, temp_map, fp_map1, xrange=fp_xr,yrange=fp_yr
             fp_map_t=fp_map1[0]
             fp_map_t.data=0.
             delvarx, map
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; n_maps=min([n_elements(fp),n_elements(map2)])
             n_maps=n_elements(map2)
             if size(n_images,/TYPE) eq 0 then n_images=n_maps
             n_images<=n_maps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             a_signal_1=dblarr(n_elements(map1))
             a_signal_2=a_signal_1
             a_signal_3=a_signal_1
             fp_signal_1=a_signal_1
             fp_signal_2=a_signal_1
             fp_signal_3=a_signal_1
             scl_1=a_signal_3
             scl_2=scl_1
             scl_3=scl_1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Return a structure or a curve?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Save the out
save,  a_signal_1,a_signal_2,a_signal_3,$
       fp_signal_1,fp_signal_2,fp_signal_3,$
       scl_1,scl_2,scl_3,times,$
       file=movie_dir+'sig_vars.sav'
end
