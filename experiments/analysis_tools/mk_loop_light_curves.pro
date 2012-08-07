function  mk_loop_light_curves,map_name, $
                               FILENAME=FILENAME, STRUCTURE=STRUCTURE, $
                               TIME_BIN=TIME_BIN, SUB_COORDS=SUB_COORDS, $
                               SAVE_2_FILE=SAVE_2_FILE, XC=XC, YC=YC
                                      
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
version=0.1 ;Initial program/
;-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Section to restore the map
;First, determine if a filename or a map structure has been passed.

case 1 of 
   size(map_name, /TYPE) EQ 7: begin
;Test to see if the file exists.  If not fail gracefully.
      err_text_preamble='Error in  mk_loop_light_curves.pro. '
      Result = FILE_TEST(map_name, /READ)
      if result lt 1 then begin
         Text=err_text_preamble+'No map file passed'
         MESSAGE, Text , /CONTINUE
         return, -1
         
      endif
      
      restore,  map_name 
      if size(map, /TYPE) ne 8 then begin 
         Text=err_text_preamble+'There is not a map structure named map in '+ $
              map_name+'.'
         MESSAGE, Text , /CONTINUE
         return, -1
      endif
   end


   size(map_name, /TYPE) EQ 8: begin
      map=map_name
      map_name=map[0].id
   end
   
   else:begin 
         Text=err_text_preamble+'Either a map structure or a path to a save file is '+ $
             'required as an argument.'
         MESSAGE, Text , /CONTINUE
         return, -1
      end

endcase

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Now see if the map is in the proper format
temp_map=map
tags=strlowcase(tag_names(map))
test=where(tags eq 'roll')
if test eq -1 then $
   temp_map=add_tag(temp_map, 0., 'ROLL')
test=where(tags eq 'roll_angle')
if test eq -1 then $
   temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
test=where(tags eq 'roll_center')

if test eq -1 then $
   temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
test=valid_map(temp_map)
if test lt 1 then begin 
   MESSAGE, 'The routine vaild_map.pro claims that this is not a valid map.  Continuing' , /CONTINUE
   endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Are we time binning it?
if keyword_set(TIME_BIN) then $
   temp_map=time_bin_map(temp_map,bin_size)


;Are we adjusting the X or Y center point?
if keyword_set(XC) then temp_map.xc=XC
if keyword_set(YC) then temp_map.yc=YC


;Are we extracting a submap?
if keyword_set(SUB_COORDS) then begin
   sub_map,temp_map,a_map,$
           xrange=[SUB_COORDS[0], SUB_COORDS[2]],$
           yrange=[SUB_COORDS[1],SUB_COORDS[3]]
   temp_map=a_map
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Extract the lightcurve

sz=size(temp_map.data)

temp=reform(temp_map.data, sz[sz[0]-1]*sz[sz[0]-2], sz[sz[0]])
lc=total(temp,1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Return a structure or a curve?
if keyword_set(STRUCTURE) then begin
   if not keyword_set(SUB_COORDS) then sub_map=-1 else $
      sub_map=SUB_COORDS
   out={version:version, map_name:map_name, $
        map:temp_map, lc:lc}
   
endif else out=lc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Save the output to a file
if keyword_set(FILENAME) or keyword_set(SAVE_2_FILE) then $
   save, out , file=FILENAME
return, out
end
