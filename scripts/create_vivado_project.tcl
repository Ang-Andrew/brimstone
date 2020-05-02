set outputdir ./build
file mkdir $outputdir
create_project brimstone $outputdir \
  -part xc7k70tfbg676-2 -force

# add design sources
add_files -fileset sim_1 [glob ./test/*.*]
add_files [glob ./src/*.v]
# update_compile_order -fileset sources
# update_compile_order -fileset sim_1
