;This is the procedure for plotting all of the particles moving in time in 3-D. 
pro three_d_plot 

data_directory="/Volumes/Herschel/aegan/programs/HyLoop/aegan_programs/particles_programs/"
total_seconds=50

data_file=data_directory+"particle_out_"+string(0, '(I04)')+".txt"
readcol, data_file, x, y, z
;x=replicate(x, total_seconds+1)
;y=replicate(y, total_seconds+1)
;z=replicate(z, total_seconds+1)

for t=0, total_seconds do begin
data_file=data_directory+"particle_out_"+string(t, '(I04)')+".txt"
readcol, data_file, x, y, z
plot_3dbox,x,y,z, psym=5, background=0, color=1, xrange=[-10, 10], yrange=[-10,10], zrange=[0,40], thick=1.5
filename="png_"+string(t, '(I03)')+".png"

write_png, filename,tvrd(/true)
endfor

END
