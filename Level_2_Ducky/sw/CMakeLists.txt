cmake_minimum_required ( VERSION 2.8 )

project ( ftdi_test )

find_package ( LibFTDI1 NO_MODULE REQUIRED )
include ( ${LIBFTDI_USE_FILE} )

add_executable ( ftdi_test ftdi_test.c kbinput.c )
target_link_libraries( ftdi_test ${LIBFTDI_LIBRARIES} )

install ( TARGETS ftdi_test
          DESTINATION bin )
          
