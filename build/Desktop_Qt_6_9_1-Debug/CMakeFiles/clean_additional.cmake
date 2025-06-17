# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/apptiantiankupao_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/apptiantiankupao_autogen.dir/ParseCache.txt"
  "CMakeFiles/network_module_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/network_module_autogen.dir/ParseCache.txt"
  "CMakeFiles/network_moduleplugin_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/network_moduleplugin_autogen.dir/ParseCache.txt"
  "apptiantiankupao_autogen"
  "network_module_autogen"
  "network_moduleplugin_autogen"
  )
endif()
