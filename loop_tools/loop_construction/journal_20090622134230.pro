; IDL Version 7.0.6, Mac OS X (darwin x86_64 m64)
; Journal File for hwinter@flare
; Working directory: /data/jannah/hwinter/programs/PATC/loop_tools/loop_construction
; Date: Mon Jun 22 13:42:30 2009
 
restore, dialog_pickfile()
help,
; % Syntax error.
help
help, nt_beam
help, nt_beam, /str
help, loop, /str
stateplot4, loop
; % TOTAL: For input argument Q, Dimension must be 1.
stateplot3, loop
; % Expression must be a structure in this context: LOOP.
retall
stateplot3, loop
stateplot3, loop, /screen
