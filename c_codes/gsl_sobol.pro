;+
; NAME:
; gsl_sobol
;
;
; PURPOSE:
; call the GSL routine for sobol sequences (gsl_qrng) using a C
; wrapper I wrote
;
;
; CATEGORY:
; Monte Carlo
;
;
; INPUTS:
; num: number of points in the series to construct (i.e. dblarr(num,dims))
; dims: the number of dimensions to use (i.e. dblarr(num,dims))
;
;
; KEYWORD PARAMETERS:
; CLEAN: Remove the *.so library and build it again
; VERBOSE: print a lot of debug information
;
; OUTPUTS:
; a double array (dblarr(num,dims)) of the dims-dimension Sobol sequence
;
;
; SIDE EFFECTS:
; Creates the *.so library file in the current directory
;
;
; RESTRICTIONS:
; One much have GSL installed and in the path.  I wrote this on a MAC
; (10.5.2) and have no idea if it will function elsewhere.  Also one
; must have gsl_sobol.c and idl_export.h in the current directory.
;
;
; EXAMPLE:
; IDL> print, gsl_sobol(5,2) 
; 0.50000000  0.75000000  0.25000000  0.37500000  0.87500000
; 0.50000000  0.25000000  0.75000000  0.37500000  0.87500000
;
;
;
; MODIFICATION HISTORY:
;
;       Fri Apr 4 16:47:44 2008, Brian Larsen
;       <balarsen <at> bu <dot> edu>
;
;		written and tested
;
;-
FUNCTION gsl_sobol, num, dims,  CLEAN = clean, VERBOSE = verbose
  
  IF n_elements(num) EQ 0 THEN $
     message, /ioerror, 'Must input the number to create'
  num = long(num)               ; this has to be along for the C

  IF n_elements(dims) EQ 0 THEN $
     dims = 1


  IF keyword_set(clean) THEN $ 
     FILE_DELETE, 'gsl_sobol.so', /ALLOW_NONEXISTENT
  
  IF file_test('gsl_sobol.so') NE 1 THEN BEGIN  
     make_dll, 'gsl_sobol', 'gsl_sobol', 'gsl_sobol',  $
               compile_directory = '.', $
               extra_lflags = '-lgslcblas -lm -lgsl',  $
               VERBOSE = verbose
  ENDIF 
  
  arr = dblarr(num, dims)
  
  IF n_elements(verbose) EQ 1 THEN $
     show_all_output = 1
  ans = call_external('gsl_sobol.so', 'gsl_sobol', $
                      long(n_elements(arr[*, 0])), arr, dims, /auto_glue, $
                      /unload,  SHOW_ALL_OUTPUT = show_all_output,  $
                      /ignore_existing_glue,  value = [1b, 0b, 1b]) 


  RETURN, arr
END
