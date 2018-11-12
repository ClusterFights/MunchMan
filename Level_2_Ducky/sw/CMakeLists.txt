cmake_minimum_required ( VERSION 2.8 )

project ( ftdi_test )

find_package ( LibFTDI1 NO_MODULE REQUIRED )
include ( ${LIBFTDI_USE_FILE} )

add_executable ( ice_cat ice_cat.c munchman.c )
target_link_libraries( ice_cat ${LIBFTDI_LIBRARIES} )

add_executable ( ftdi_test ftdi_test.c kbinput.c )
target_link_libraries( ftdi_test ${LIBFTDI_LIBRARIES} )

add_executable ( md5 md5.c )

add_executable ( md5_tb md5_tb.c munchman.c )
target_link_libraries( md5_tb ${LIBFTDI_LIBRARIES} )

add_executable ( find find.c munchman.c )
target_link_libraries( find ${LIBFTDI_LIBRARIES} )

install ( TARGETS ftdi_test ice_cat md5 md5_tb find
          DESTINATION bin )
          
