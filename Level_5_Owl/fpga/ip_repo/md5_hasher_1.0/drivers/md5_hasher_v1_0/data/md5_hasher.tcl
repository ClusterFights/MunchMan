

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "md5_hasher" "NUM_INSTANCES" "DEVICE_ID"  "C_S_CTRL_AXI_BASEADDR" "C_S_CTRL_AXI_HIGHADDR"
}
