cmake_minimum_required ( VERSION 2.8 )

project ( simple )

find_package ( LibFTDI1 NO_MODULE REQUIRED )
include ( ${LIBFTDI_USE_FILE} )

add_executable ( simple simple.c )
target_link_libraries( simple ${LIBFTDI_LIBRARIES} )

install ( TARGETS simple
          DESTINATION bin )
          
