
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# write_buffer_manager, read_mangment, MedianSorter, MedianSorter, MedianSorter

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a100tcsg324-1
   set_property BOARD_PART digilentinc.com:nexys-a7-100t:part0:1.3 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:util_reduced_logic:2.0\
xilinx.com:ip:proc_sys_reset:5.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
write_buffer_manager\
read_mangment\
MedianSorter\
MedianSorter\
MedianSorter\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set pixel_clk [ create_bd_port -dir I -type clk -freq_hz 10000000 pixel_clk ]
  set pixel_filtered_valid [ create_bd_port -dir O pixel_filtered_valid ]
  set filtered_pixel [ create_bd_port -dir O -from 11 -to 0 filtered_pixel ]
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset
  set pixel_in_0 [ create_bd_port -dir I -from 11 -to 0 pixel_in_0 ]

  # Create instance: line_buffer1, and set properties
  set line_buffer1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 line_buffer1 ]
  set_property -dict [list \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Enable_B {Always_Enabled} \
    CONFIG.Fill_Remaining_Memory_Locations {true} \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
    CONFIG.Write_Depth_A {640} \
    CONFIG.Write_Width_A {12} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $line_buffer1


  # Create instance: line_buffer2, and set properties
  set line_buffer2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 line_buffer2 ]
  set_property -dict [list \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Enable_B {Always_Enabled} \
    CONFIG.Fill_Remaining_Memory_Locations {true} \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
    CONFIG.Write_Depth_A {640} \
    CONFIG.Write_Width_A {12} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $line_buffer2


  # Create instance: line_buffer3, and set properties
  set line_buffer3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 line_buffer3 ]
  set_property -dict [list \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Enable_B {Always_Enabled} \
    CONFIG.Fill_Remaining_Memory_Locations {true} \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
    CONFIG.Write_Depth_A {640} \
    CONFIG.Write_Width_A {12} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $line_buffer3


  # Create instance: line_buffer4, and set properties
  set line_buffer4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 line_buffer4 ]
  set_property -dict [list \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Enable_B {Always_Enabled} \
    CONFIG.Fill_Remaining_Memory_Locations {true} \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
    CONFIG.Write_Depth_A {640} \
    CONFIG.Write_Width_A {12} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $line_buffer4


  # Create instance: clk_wiz_pll, and set properties
  set clk_wiz_pll [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_pll ]
  set_property -dict [list \
    CONFIG.CLKIN1_JITTER_PS {1000.0} \
    CONFIG.CLKOUT1_JITTER {933.258} \
    CONFIG.CLKOUT1_PHASE_ERROR {908.603} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {10} \
    CONFIG.CLKOUT2_JITTER {760.423} \
    CONFIG.CLKOUT2_PHASE_ERROR {908.603} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {30} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_JITTER {657.457} \
    CONFIG.CLKOUT3_PHASE_ERROR {908.603} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {90} \
    CONFIG.CLKOUT3_USED {true} \
    CONFIG.CLK_OUT1_PORT {clk_ram_10} \
    CONFIG.CLK_OUT2_PORT {clk_srl_30} \
    CONFIG.CLK_OUT3_PORT {clk_median_90} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {63.000} \
    CONFIG.MMCM_CLKIN1_PERIOD {100.000} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {63.000} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {21} \
    CONFIG.MMCM_CLKOUT2_DIVIDE {7} \
    CONFIG.NUM_OUT_CLKS {3} \
    CONFIG.PRIM_IN_FREQ {10} \
  ] $clk_wiz_pll


  # Create instance: write_buffer_manager_0, and set properties
  set block_name write_buffer_manager
  set block_cell_name write_buffer_manager_0
  if { [catch {set write_buffer_manager_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $write_buffer_manager_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: zero_rst, and set properties
  set zero_rst [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 zero_rst ]
  set_property CONFIG.CONST_VAL {0} $zero_rst


  # Create instance: read_mangment_0, and set properties
  set block_name read_mangment
  set block_cell_name read_mangment_0
  if { [catch {set read_mangment_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $read_mangment_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: MedianSorter_B, and set properties
  set block_name MedianSorter
  set block_cell_name MedianSorter_B
  if { [catch {set MedianSorter_B [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $MedianSorter_B eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: MedianSorter_G, and set properties
  set block_name MedianSorter
  set block_cell_name MedianSorter_G
  if { [catch {set MedianSorter_G [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $MedianSorter_G eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: MedianSorter_R, and set properties
  set block_name MedianSorter
  set block_cell_name MedianSorter_R
  if { [catch {set MedianSorter_R [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $MedianSorter_R eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: median_valid_concat, and set properties
  set median_valid_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 median_valid_concat ]
  set_property CONFIG.NUM_PORTS {3} $median_valid_concat


  # Create instance: bitwise_and, and set properties
  set bitwise_and [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 bitwise_and ]
  set_property CONFIG.C_SIZE {3} $bitwise_and


  # Create instance: color_merger, and set properties
  set color_merger [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 color_merger ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {4} \
    CONFIG.IN1_WIDTH {4} \
    CONFIG.IN2_WIDTH {4} \
    CONFIG.NUM_PORTS {3} \
  ] $color_merger


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]
  set_property -dict [list \
    CONFIG.RESET_BOARD_INTERFACE {reset} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $proc_sys_reset_0


  # Create port connections
  connect_bd_net -net MedianSorter_B_median [get_bd_pins MedianSorter_B/median] [get_bd_pins color_merger/In2]
  connect_bd_net -net MedianSorter_B_valid [get_bd_pins MedianSorter_B/valid] [get_bd_pins median_valid_concat/In1]
  connect_bd_net -net MedianSorter_G_median [get_bd_pins MedianSorter_G/median] [get_bd_pins color_merger/In1]
  connect_bd_net -net MedianSorter_G_valid [get_bd_pins MedianSorter_G/valid] [get_bd_pins median_valid_concat/In0]
  connect_bd_net -net MedianSorter_R_median [get_bd_pins MedianSorter_R/median] [get_bd_pins color_merger/In0]
  connect_bd_net -net MedianSorter_R_valid [get_bd_pins MedianSorter_R/valid] [get_bd_pins median_valid_concat/In2]
  connect_bd_net -net clk_wiz_0_clk_median_90 [get_bd_pins clk_wiz_pll/clk_median_90] [get_bd_pins MedianSorter_B/clk] [get_bd_pins MedianSorter_G/clk] [get_bd_pins MedianSorter_R/clk]
  connect_bd_net -net clk_wiz_0_clk_srl_30 [get_bd_pins clk_wiz_pll/clk_srl_30] [get_bd_pins read_mangment_0/clk_matrix]
  connect_bd_net -net clk_wiz_0_read_filt_clk [get_bd_pins clk_wiz_pll/clk_ram_10] [get_bd_pins line_buffer2/clkb] [get_bd_pins line_buffer1/clkb] [get_bd_pins line_buffer3/clkb] [get_bd_pins line_buffer4/clkb] [get_bd_pins line_buffer1/clka] [get_bd_pins line_buffer3/clka] [get_bd_pins line_buffer2/clka] [get_bd_pins line_buffer4/clka] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins read_mangment_0/clk_ram] [get_bd_pins write_buffer_manager_0/clk]
  connect_bd_net -net clk_wiz_pll_locked [get_bd_pins clk_wiz_pll/locked] [get_bd_pins write_buffer_manager_0/ce]
  connect_bd_net -net clka_0_1 [get_bd_ports pixel_clk] [get_bd_pins clk_wiz_pll/clk_in1]
  connect_bd_net -net line_buffer1_doutb [get_bd_pins line_buffer1/doutb] [get_bd_pins read_mangment_0/pixel_read_line1]
  connect_bd_net -net line_buffer2_doutb [get_bd_pins line_buffer2/doutb] [get_bd_pins read_mangment_0/pixel_read_line2]
  connect_bd_net -net line_buffer3_doutb [get_bd_pins line_buffer3/doutb] [get_bd_pins read_mangment_0/pixel_read_line3]
  connect_bd_net -net line_buffer4_doutb [get_bd_pins line_buffer4/doutb] [get_bd_pins read_mangment_0/pixel_read_line4]
  connect_bd_net -net pixel_in_0_1 [get_bd_ports pixel_in_0] [get_bd_pins write_buffer_manager_0/pixel_in]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins read_mangment_0/rst] [get_bd_pins write_buffer_manager_0/rst]
  connect_bd_net -net read_mangment_0_address_read [get_bd_pins read_mangment_0/address_read] [get_bd_pins line_buffer1/addrb] [get_bd_pins line_buffer3/addrb] [get_bd_pins line_buffer2/addrb] [get_bd_pins line_buffer4/addrb]
  connect_bd_net -net read_mangment_0_matrix_blue [get_bd_pins read_mangment_0/matrix_blue] [get_bd_pins MedianSorter_B/pixels]
  connect_bd_net -net read_mangment_0_matrix_green [get_bd_pins read_mangment_0/matrix_green] [get_bd_pins MedianSorter_G/pixels]
  connect_bd_net -net read_mangment_0_matrix_red [get_bd_pins read_mangment_0/matrix_red] [get_bd_pins MedianSorter_R/pixels]
  connect_bd_net -net read_mangment_0_ready [get_bd_pins read_mangment_0/ready] [get_bd_pins MedianSorter_B/enable] [get_bd_pins MedianSorter_G/enable] [get_bd_pins MedianSorter_R/enable]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net util_reduced_logic_0_Res [get_bd_pins bitwise_and/Res] [get_bd_ports pixel_filtered_valid]
  connect_bd_net -net write_buffer_manager_0_address [get_bd_pins write_buffer_manager_0/pixel_w] [get_bd_pins line_buffer1/dina] [get_bd_pins line_buffer2/dina] [get_bd_pins line_buffer3/dina] [get_bd_pins line_buffer4/dina]
  connect_bd_net -net write_buffer_manager_0_address1 [get_bd_pins write_buffer_manager_0/address] [get_bd_pins line_buffer1/addra] [get_bd_pins line_buffer2/addra] [get_bd_pins line_buffer3/addra] [get_bd_pins line_buffer4/addra]
  connect_bd_net -net write_buffer_manager_0_enable_read_srl [get_bd_pins write_buffer_manager_0/enable_read_srl] [get_bd_pins read_mangment_0/start_read]
  connect_bd_net -net write_buffer_manager_0_we_1 [get_bd_pins write_buffer_manager_0/we_1] [get_bd_pins line_buffer1/wea]
  connect_bd_net -net write_buffer_manager_0_we_2 [get_bd_pins write_buffer_manager_0/we_2] [get_bd_pins line_buffer2/wea]
  connect_bd_net -net write_buffer_manager_0_we_3 [get_bd_pins write_buffer_manager_0/we_3] [get_bd_pins line_buffer3/wea]
  connect_bd_net -net write_buffer_manager_0_we_4 [get_bd_pins write_buffer_manager_0/we_4] [get_bd_pins line_buffer4/wea]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins median_valid_concat/dout] [get_bd_pins bitwise_and/Op1]
  connect_bd_net -net xlconcat_1_dout [get_bd_pins color_merger/dout] [get_bd_ports filtered_pixel]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins zero_rst/dout] [get_bd_pins clk_wiz_pll/reset]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


