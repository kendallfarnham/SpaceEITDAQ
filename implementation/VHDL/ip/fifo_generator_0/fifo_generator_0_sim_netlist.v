// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sun Sep 24 19:30:11 2023
// Host        : Thinkpad_T14s_K running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {g:/Shared drives/KF PhD
//               Documents/Vivado/2023_DAQ_v04/2023_DAQ_v03.gen/sources_1/ip/fifo_generator_0/fifo_generator_0_sim_netlist.v}
// Design      : fifo_generator_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "fifo_generator_0,fifo_generator_v13_2_7,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_7,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module fifo_generator_0
   (rst,
    wr_clk,
    rd_clk,
    din,
    wr_en,
    rd_en,
    dout,
    full,
    overflow,
    empty,
    underflow);
  input rst;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 write_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME write_clk, FREQ_HZ 15000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input wr_clk;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 read_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME read_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input rd_clk;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_DATA" *) input [15:0]din;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_EN" *) input wr_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_EN" *) input rd_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_DATA" *) output [15:0]dout;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE FULL" *) output full;
  output overflow;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ EMPTY" *) output empty;
  output underflow;

  wire [15:0]din;
  wire [15:0]dout;
  wire empty;
  wire full;
  wire overflow;
  wire rd_clk;
  wire rd_en;
  wire rst;
  wire underflow;
  wire wr_clk;
  wire wr_en;
  wire NLW_U0_almost_empty_UNCONNECTED;
  wire NLW_U0_almost_full_UNCONNECTED;
  wire NLW_U0_axi_ar_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_overflow_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_full_UNCONNECTED;
  wire NLW_U0_axi_ar_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_underflow_UNCONNECTED;
  wire NLW_U0_axi_aw_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_overflow_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_full_UNCONNECTED;
  wire NLW_U0_axi_aw_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_underflow_UNCONNECTED;
  wire NLW_U0_axi_b_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_overflow_UNCONNECTED;
  wire NLW_U0_axi_b_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_b_prog_full_UNCONNECTED;
  wire NLW_U0_axi_b_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_underflow_UNCONNECTED;
  wire NLW_U0_axi_r_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_overflow_UNCONNECTED;
  wire NLW_U0_axi_r_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_r_prog_full_UNCONNECTED;
  wire NLW_U0_axi_r_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_underflow_UNCONNECTED;
  wire NLW_U0_axi_w_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_overflow_UNCONNECTED;
  wire NLW_U0_axi_w_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_w_prog_full_UNCONNECTED;
  wire NLW_U0_axi_w_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_underflow_UNCONNECTED;
  wire NLW_U0_axis_dbiterr_UNCONNECTED;
  wire NLW_U0_axis_overflow_UNCONNECTED;
  wire NLW_U0_axis_prog_empty_UNCONNECTED;
  wire NLW_U0_axis_prog_full_UNCONNECTED;
  wire NLW_U0_axis_sbiterr_UNCONNECTED;
  wire NLW_U0_axis_underflow_UNCONNECTED;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_m_axi_arvalid_UNCONNECTED;
  wire NLW_U0_m_axi_awvalid_UNCONNECTED;
  wire NLW_U0_m_axi_bready_UNCONNECTED;
  wire NLW_U0_m_axi_rready_UNCONNECTED;
  wire NLW_U0_m_axi_wlast_UNCONNECTED;
  wire NLW_U0_m_axi_wvalid_UNCONNECTED;
  wire NLW_U0_m_axis_tlast_UNCONNECTED;
  wire NLW_U0_m_axis_tvalid_UNCONNECTED;
  wire NLW_U0_prog_empty_UNCONNECTED;
  wire NLW_U0_prog_full_UNCONNECTED;
  wire NLW_U0_rd_rst_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_s_axis_tready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire NLW_U0_valid_UNCONNECTED;
  wire NLW_U0_wr_ack_UNCONNECTED;
  wire NLW_U0_wr_rst_busy_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_wr_data_count_UNCONNECTED;
  wire [9:0]NLW_U0_data_count_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_araddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_arburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_arlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_aruser_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_awaddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_awburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_awlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awuser_UNCONNECTED;
  wire [63:0]NLW_U0_m_axi_wdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_wstrb_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wuser_UNCONNECTED;
  wire [7:0]NLW_U0_m_axis_tdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tdest_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tid_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tkeep_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tstrb_UNCONNECTED;
  wire [3:0]NLW_U0_m_axis_tuser_UNCONNECTED;
  wire [9:0]NLW_U0_rd_data_count_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_ruser_UNCONNECTED;
  wire [9:0]NLW_U0_wr_data_count_UNCONNECTED;

  (* C_ADD_NGC_CONSTRAINT = "0" *) 
  (* C_APPLICATION_TYPE_AXIS = "0" *) 
  (* C_APPLICATION_TYPE_RACH = "0" *) 
  (* C_APPLICATION_TYPE_RDCH = "0" *) 
  (* C_APPLICATION_TYPE_WACH = "0" *) 
  (* C_APPLICATION_TYPE_WDCH = "0" *) 
  (* C_APPLICATION_TYPE_WRCH = "0" *) 
  (* C_AXIS_TDATA_WIDTH = "8" *) 
  (* C_AXIS_TDEST_WIDTH = "1" *) 
  (* C_AXIS_TID_WIDTH = "1" *) 
  (* C_AXIS_TKEEP_WIDTH = "1" *) 
  (* C_AXIS_TSTRB_WIDTH = "1" *) 
  (* C_AXIS_TUSER_WIDTH = "4" *) 
  (* C_AXIS_TYPE = "0" *) 
  (* C_AXI_ADDR_WIDTH = "32" *) 
  (* C_AXI_ARUSER_WIDTH = "1" *) 
  (* C_AXI_AWUSER_WIDTH = "1" *) 
  (* C_AXI_BUSER_WIDTH = "1" *) 
  (* C_AXI_DATA_WIDTH = "64" *) 
  (* C_AXI_ID_WIDTH = "1" *) 
  (* C_AXI_LEN_WIDTH = "8" *) 
  (* C_AXI_LOCK_WIDTH = "1" *) 
  (* C_AXI_RUSER_WIDTH = "1" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_AXI_WUSER_WIDTH = "1" *) 
  (* C_COMMON_CLOCK = "0" *) 
  (* C_COUNT_TYPE = "0" *) 
  (* C_DATA_COUNT_WIDTH = "10" *) 
  (* C_DEFAULT_VALUE = "BlankString" *) 
  (* C_DIN_WIDTH = "16" *) 
  (* C_DIN_WIDTH_AXIS = "1" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "1" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "16" *) 
  (* C_ENABLE_RLOCS = "0" *) 
  (* C_ENABLE_RST_SYNC = "1" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_ERROR_INJECTION_TYPE = "0" *) 
  (* C_ERROR_INJECTION_TYPE_AXIS = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WRCH = "0" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_FULL_FLAGS_RST_VAL = "0" *) 
  (* C_HAS_ALMOST_EMPTY = "0" *) 
  (* C_HAS_ALMOST_FULL = "0" *) 
  (* C_HAS_AXIS_TDATA = "1" *) 
  (* C_HAS_AXIS_TDEST = "0" *) 
  (* C_HAS_AXIS_TID = "0" *) 
  (* C_HAS_AXIS_TKEEP = "0" *) 
  (* C_HAS_AXIS_TLAST = "0" *) 
  (* C_HAS_AXIS_TREADY = "1" *) 
  (* C_HAS_AXIS_TSTRB = "0" *) 
  (* C_HAS_AXIS_TUSER = "1" *) 
  (* C_HAS_AXI_ARUSER = "0" *) 
  (* C_HAS_AXI_AWUSER = "0" *) 
  (* C_HAS_AXI_BUSER = "0" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_AXI_RD_CHANNEL = "1" *) 
  (* C_HAS_AXI_RUSER = "0" *) 
  (* C_HAS_AXI_WR_CHANNEL = "1" *) 
  (* C_HAS_AXI_WUSER = "0" *) 
  (* C_HAS_BACKUP = "0" *) 
  (* C_HAS_DATA_COUNT = "0" *) 
  (* C_HAS_DATA_COUNTS_AXIS = "0" *) 
  (* C_HAS_DATA_COUNTS_RACH = "0" *) 
  (* C_HAS_DATA_COUNTS_RDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WACH = "0" *) 
  (* C_HAS_DATA_COUNTS_WDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WRCH = "0" *) 
  (* C_HAS_INT_CLK = "0" *) 
  (* C_HAS_MASTER_CE = "0" *) 
  (* C_HAS_MEMINIT_FILE = "0" *) 
  (* C_HAS_OVERFLOW = "1" *) 
  (* C_HAS_PROG_FLAGS_AXIS = "0" *) 
  (* C_HAS_PROG_FLAGS_RACH = "0" *) 
  (* C_HAS_PROG_FLAGS_RDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WACH = "0" *) 
  (* C_HAS_PROG_FLAGS_WDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WRCH = "0" *) 
  (* C_HAS_RD_DATA_COUNT = "0" *) 
  (* C_HAS_RD_RST = "0" *) 
  (* C_HAS_RST = "1" *) 
  (* C_HAS_SLAVE_CE = "0" *) 
  (* C_HAS_SRST = "0" *) 
  (* C_HAS_UNDERFLOW = "1" *) 
  (* C_HAS_VALID = "0" *) 
  (* C_HAS_WR_ACK = "0" *) 
  (* C_HAS_WR_DATA_COUNT = "0" *) 
  (* C_HAS_WR_RST = "0" *) 
  (* C_IMPLEMENTATION_TYPE = "6" *) 
  (* C_IMPLEMENTATION_TYPE_AXIS = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WRCH = "1" *) 
  (* C_INIT_WR_PNTR_VAL = "0" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_MEMORY_TYPE = "4" *) 
  (* C_MIF_FILE_NAME = "BlankString" *) 
  (* C_MSGON_VAL = "1" *) 
  (* C_OPTIMIZATION_MODE = "0" *) 
  (* C_OVERFLOW_LOW = "0" *) 
  (* C_POWER_SAVING_MODE = "0" *) 
  (* C_PRELOAD_LATENCY = "1" *) 
  (* C_PRELOAD_REGS = "0" *) 
  (* C_PRIM_FIFO_TYPE = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_AXIS = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL = "5" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "6" *) 
  (* C_PROG_EMPTY_TYPE = "0" *) 
  (* C_PROG_EMPTY_TYPE_AXIS = "0" *) 
  (* C_PROG_EMPTY_TYPE_RACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "1017" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "1016" *) 
  (* C_PROG_FULL_TYPE = "0" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "10" *) 
  (* C_RD_DEPTH = "1024" *) 
  (* C_RD_FREQ = "100" *) 
  (* C_RD_PNTR_WIDTH = "10" *) 
  (* C_REG_SLICE_MODE_AXIS = "0" *) 
  (* C_REG_SLICE_MODE_RACH = "0" *) 
  (* C_REG_SLICE_MODE_RDCH = "0" *) 
  (* C_REG_SLICE_MODE_WACH = "0" *) 
  (* C_REG_SLICE_MODE_WDCH = "0" *) 
  (* C_REG_SLICE_MODE_WRCH = "0" *) 
  (* C_SELECT_XPM = "0" *) 
  (* C_SYNCHRONIZER_STAGE = "2" *) 
  (* C_UNDERFLOW_LOW = "0" *) 
  (* C_USE_COMMON_OVERFLOW = "0" *) 
  (* C_USE_COMMON_UNDERFLOW = "0" *) 
  (* C_USE_DEFAULT_SETTINGS = "0" *) 
  (* C_USE_DOUT_RST = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_ECC_AXIS = "0" *) 
  (* C_USE_ECC_RACH = "0" *) 
  (* C_USE_ECC_RDCH = "0" *) 
  (* C_USE_ECC_WACH = "0" *) 
  (* C_USE_ECC_WDCH = "0" *) 
  (* C_USE_ECC_WRCH = "0" *) 
  (* C_USE_EMBEDDED_REG = "0" *) 
  (* C_USE_FIFO16_FLAGS = "0" *) 
  (* C_USE_FWFT_DATA_COUNT = "0" *) 
  (* C_USE_PIPELINE_REG = "0" *) 
  (* C_VALID_LOW = "0" *) 
  (* C_WACH_TYPE = "0" *) 
  (* C_WDCH_TYPE = "0" *) 
  (* C_WRCH_TYPE = "0" *) 
  (* C_WR_ACK_LOW = "0" *) 
  (* C_WR_DATA_COUNT_WIDTH = "10" *) 
  (* C_WR_DEPTH = "1024" *) 
  (* C_WR_DEPTH_AXIS = "1024" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "15" *) 
  (* C_WR_PNTR_WIDTH = "10" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "10" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  (* is_du_within_envelope = "true" *) 
  fifo_generator_0_fifo_generator_v13_2_7 U0
       (.almost_empty(NLW_U0_almost_empty_UNCONNECTED),
        .almost_full(NLW_U0_almost_full_UNCONNECTED),
        .axi_ar_data_count(NLW_U0_axi_ar_data_count_UNCONNECTED[4:0]),
        .axi_ar_dbiterr(NLW_U0_axi_ar_dbiterr_UNCONNECTED),
        .axi_ar_injectdbiterr(1'b0),
        .axi_ar_injectsbiterr(1'b0),
        .axi_ar_overflow(NLW_U0_axi_ar_overflow_UNCONNECTED),
        .axi_ar_prog_empty(NLW_U0_axi_ar_prog_empty_UNCONNECTED),
        .axi_ar_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_prog_full(NLW_U0_axi_ar_prog_full_UNCONNECTED),
        .axi_ar_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_rd_data_count(NLW_U0_axi_ar_rd_data_count_UNCONNECTED[4:0]),
        .axi_ar_sbiterr(NLW_U0_axi_ar_sbiterr_UNCONNECTED),
        .axi_ar_underflow(NLW_U0_axi_ar_underflow_UNCONNECTED),
        .axi_ar_wr_data_count(NLW_U0_axi_ar_wr_data_count_UNCONNECTED[4:0]),
        .axi_aw_data_count(NLW_U0_axi_aw_data_count_UNCONNECTED[4:0]),
        .axi_aw_dbiterr(NLW_U0_axi_aw_dbiterr_UNCONNECTED),
        .axi_aw_injectdbiterr(1'b0),
        .axi_aw_injectsbiterr(1'b0),
        .axi_aw_overflow(NLW_U0_axi_aw_overflow_UNCONNECTED),
        .axi_aw_prog_empty(NLW_U0_axi_aw_prog_empty_UNCONNECTED),
        .axi_aw_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_prog_full(NLW_U0_axi_aw_prog_full_UNCONNECTED),
        .axi_aw_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_rd_data_count(NLW_U0_axi_aw_rd_data_count_UNCONNECTED[4:0]),
        .axi_aw_sbiterr(NLW_U0_axi_aw_sbiterr_UNCONNECTED),
        .axi_aw_underflow(NLW_U0_axi_aw_underflow_UNCONNECTED),
        .axi_aw_wr_data_count(NLW_U0_axi_aw_wr_data_count_UNCONNECTED[4:0]),
        .axi_b_data_count(NLW_U0_axi_b_data_count_UNCONNECTED[4:0]),
        .axi_b_dbiterr(NLW_U0_axi_b_dbiterr_UNCONNECTED),
        .axi_b_injectdbiterr(1'b0),
        .axi_b_injectsbiterr(1'b0),
        .axi_b_overflow(NLW_U0_axi_b_overflow_UNCONNECTED),
        .axi_b_prog_empty(NLW_U0_axi_b_prog_empty_UNCONNECTED),
        .axi_b_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_prog_full(NLW_U0_axi_b_prog_full_UNCONNECTED),
        .axi_b_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_rd_data_count(NLW_U0_axi_b_rd_data_count_UNCONNECTED[4:0]),
        .axi_b_sbiterr(NLW_U0_axi_b_sbiterr_UNCONNECTED),
        .axi_b_underflow(NLW_U0_axi_b_underflow_UNCONNECTED),
        .axi_b_wr_data_count(NLW_U0_axi_b_wr_data_count_UNCONNECTED[4:0]),
        .axi_r_data_count(NLW_U0_axi_r_data_count_UNCONNECTED[10:0]),
        .axi_r_dbiterr(NLW_U0_axi_r_dbiterr_UNCONNECTED),
        .axi_r_injectdbiterr(1'b0),
        .axi_r_injectsbiterr(1'b0),
        .axi_r_overflow(NLW_U0_axi_r_overflow_UNCONNECTED),
        .axi_r_prog_empty(NLW_U0_axi_r_prog_empty_UNCONNECTED),
        .axi_r_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_prog_full(NLW_U0_axi_r_prog_full_UNCONNECTED),
        .axi_r_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_rd_data_count(NLW_U0_axi_r_rd_data_count_UNCONNECTED[10:0]),
        .axi_r_sbiterr(NLW_U0_axi_r_sbiterr_UNCONNECTED),
        .axi_r_underflow(NLW_U0_axi_r_underflow_UNCONNECTED),
        .axi_r_wr_data_count(NLW_U0_axi_r_wr_data_count_UNCONNECTED[10:0]),
        .axi_w_data_count(NLW_U0_axi_w_data_count_UNCONNECTED[10:0]),
        .axi_w_dbiterr(NLW_U0_axi_w_dbiterr_UNCONNECTED),
        .axi_w_injectdbiterr(1'b0),
        .axi_w_injectsbiterr(1'b0),
        .axi_w_overflow(NLW_U0_axi_w_overflow_UNCONNECTED),
        .axi_w_prog_empty(NLW_U0_axi_w_prog_empty_UNCONNECTED),
        .axi_w_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_prog_full(NLW_U0_axi_w_prog_full_UNCONNECTED),
        .axi_w_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_rd_data_count(NLW_U0_axi_w_rd_data_count_UNCONNECTED[10:0]),
        .axi_w_sbiterr(NLW_U0_axi_w_sbiterr_UNCONNECTED),
        .axi_w_underflow(NLW_U0_axi_w_underflow_UNCONNECTED),
        .axi_w_wr_data_count(NLW_U0_axi_w_wr_data_count_UNCONNECTED[10:0]),
        .axis_data_count(NLW_U0_axis_data_count_UNCONNECTED[10:0]),
        .axis_dbiterr(NLW_U0_axis_dbiterr_UNCONNECTED),
        .axis_injectdbiterr(1'b0),
        .axis_injectsbiterr(1'b0),
        .axis_overflow(NLW_U0_axis_overflow_UNCONNECTED),
        .axis_prog_empty(NLW_U0_axis_prog_empty_UNCONNECTED),
        .axis_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_prog_full(NLW_U0_axis_prog_full_UNCONNECTED),
        .axis_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_rd_data_count(NLW_U0_axis_rd_data_count_UNCONNECTED[10:0]),
        .axis_sbiterr(NLW_U0_axis_sbiterr_UNCONNECTED),
        .axis_underflow(NLW_U0_axis_underflow_UNCONNECTED),
        .axis_wr_data_count(NLW_U0_axis_wr_data_count_UNCONNECTED[10:0]),
        .backup(1'b0),
        .backup_marker(1'b0),
        .clk(1'b0),
        .data_count(NLW_U0_data_count_UNCONNECTED[9:0]),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .int_clk(1'b0),
        .m_aclk(1'b0),
        .m_aclk_en(1'b0),
        .m_axi_araddr(NLW_U0_m_axi_araddr_UNCONNECTED[31:0]),
        .m_axi_arburst(NLW_U0_m_axi_arburst_UNCONNECTED[1:0]),
        .m_axi_arcache(NLW_U0_m_axi_arcache_UNCONNECTED[3:0]),
        .m_axi_arid(NLW_U0_m_axi_arid_UNCONNECTED[0]),
        .m_axi_arlen(NLW_U0_m_axi_arlen_UNCONNECTED[7:0]),
        .m_axi_arlock(NLW_U0_m_axi_arlock_UNCONNECTED[0]),
        .m_axi_arprot(NLW_U0_m_axi_arprot_UNCONNECTED[2:0]),
        .m_axi_arqos(NLW_U0_m_axi_arqos_UNCONNECTED[3:0]),
        .m_axi_arready(1'b0),
        .m_axi_arregion(NLW_U0_m_axi_arregion_UNCONNECTED[3:0]),
        .m_axi_arsize(NLW_U0_m_axi_arsize_UNCONNECTED[2:0]),
        .m_axi_aruser(NLW_U0_m_axi_aruser_UNCONNECTED[0]),
        .m_axi_arvalid(NLW_U0_m_axi_arvalid_UNCONNECTED),
        .m_axi_awaddr(NLW_U0_m_axi_awaddr_UNCONNECTED[31:0]),
        .m_axi_awburst(NLW_U0_m_axi_awburst_UNCONNECTED[1:0]),
        .m_axi_awcache(NLW_U0_m_axi_awcache_UNCONNECTED[3:0]),
        .m_axi_awid(NLW_U0_m_axi_awid_UNCONNECTED[0]),
        .m_axi_awlen(NLW_U0_m_axi_awlen_UNCONNECTED[7:0]),
        .m_axi_awlock(NLW_U0_m_axi_awlock_UNCONNECTED[0]),
        .m_axi_awprot(NLW_U0_m_axi_awprot_UNCONNECTED[2:0]),
        .m_axi_awqos(NLW_U0_m_axi_awqos_UNCONNECTED[3:0]),
        .m_axi_awready(1'b0),
        .m_axi_awregion(NLW_U0_m_axi_awregion_UNCONNECTED[3:0]),
        .m_axi_awsize(NLW_U0_m_axi_awsize_UNCONNECTED[2:0]),
        .m_axi_awuser(NLW_U0_m_axi_awuser_UNCONNECTED[0]),
        .m_axi_awvalid(NLW_U0_m_axi_awvalid_UNCONNECTED),
        .m_axi_bid(1'b0),
        .m_axi_bready(NLW_U0_m_axi_bready_UNCONNECTED),
        .m_axi_bresp({1'b0,1'b0}),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(1'b0),
        .m_axi_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rid(1'b0),
        .m_axi_rlast(1'b0),
        .m_axi_rready(NLW_U0_m_axi_rready_UNCONNECTED),
        .m_axi_rresp({1'b0,1'b0}),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(1'b0),
        .m_axi_wdata(NLW_U0_m_axi_wdata_UNCONNECTED[63:0]),
        .m_axi_wid(NLW_U0_m_axi_wid_UNCONNECTED[0]),
        .m_axi_wlast(NLW_U0_m_axi_wlast_UNCONNECTED),
        .m_axi_wready(1'b0),
        .m_axi_wstrb(NLW_U0_m_axi_wstrb_UNCONNECTED[7:0]),
        .m_axi_wuser(NLW_U0_m_axi_wuser_UNCONNECTED[0]),
        .m_axi_wvalid(NLW_U0_m_axi_wvalid_UNCONNECTED),
        .m_axis_tdata(NLW_U0_m_axis_tdata_UNCONNECTED[7:0]),
        .m_axis_tdest(NLW_U0_m_axis_tdest_UNCONNECTED[0]),
        .m_axis_tid(NLW_U0_m_axis_tid_UNCONNECTED[0]),
        .m_axis_tkeep(NLW_U0_m_axis_tkeep_UNCONNECTED[0]),
        .m_axis_tlast(NLW_U0_m_axis_tlast_UNCONNECTED),
        .m_axis_tready(1'b0),
        .m_axis_tstrb(NLW_U0_m_axis_tstrb_UNCONNECTED[0]),
        .m_axis_tuser(NLW_U0_m_axis_tuser_UNCONNECTED[3:0]),
        .m_axis_tvalid(NLW_U0_m_axis_tvalid_UNCONNECTED),
        .overflow(overflow),
        .prog_empty(NLW_U0_prog_empty_UNCONNECTED),
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_U0_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(rd_clk),
        .rd_data_count(NLW_U0_rd_data_count_UNCONNECTED[9:0]),
        .rd_en(rd_en),
        .rd_rst(1'b0),
        .rd_rst_busy(NLW_U0_rd_rst_busy_UNCONNECTED),
        .rst(rst),
        .s_aclk(1'b0),
        .s_aclk_en(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arid(1'b0),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlock(1'b0),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_aruser(1'b0),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awid(1'b0),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlock(1'b0),
        .s_axi_awprot({1'b0,1'b0,1'b0}),
        .s_axi_awqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awuser(1'b0),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_buser(NLW_U0_s_axi_buser_UNCONNECTED[0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_ruser(NLW_U0_s_axi_ruser_UNCONNECTED[0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wid(1'b0),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wuser(1'b0),
        .s_axi_wvalid(1'b0),
        .s_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tdest(1'b0),
        .s_axis_tid(1'b0),
        .s_axis_tkeep(1'b0),
        .s_axis_tlast(1'b0),
        .s_axis_tready(NLW_U0_s_axis_tready_UNCONNECTED),
        .s_axis_tstrb(1'b0),
        .s_axis_tuser({1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .sleep(1'b0),
        .srst(1'b0),
        .underflow(underflow),
        .valid(NLW_U0_valid_UNCONNECTED),
        .wr_ack(NLW_U0_wr_ack_UNCONNECTED),
        .wr_clk(wr_clk),
        .wr_data_count(NLW_U0_wr_data_count_UNCONNECTED[9:0]),
        .wr_en(wr_en),
        .wr_rst(1'b0),
        .wr_rst_busy(NLW_U0_wr_rst_busy_UNCONNECTED));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
uS/dIpDTldS7400uyLsI6bJxO+WmZJrKXsU8qB+wpyI+d4PWZVO6Cm0qMQFNUZb63p6zCI5fvnQy
SxjaSP1nCte/oQZc55w1rQbTqy54T9kryRoH26nDjSBVZvJ8hffw7NONwiKrqeB6I7HJKX5RKw73
wIJxNNH7BCiCEtRLIxc=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
L7q2sHnC0pU7uHs8shPm9nAcqyU+hUFnNkd6BPHl+ureEVBUvubWhEbLRLiFFJveufcmAfAXTzae
tWbKcVVt/zKzWEtv0onUXoSEgyS4+QaTAFeCPHR2bbnlP0aCCG2SYmC1dv16cFoAk/NLitClNXAv
h+UBGzod+suWv55DaNHeHtSZ/YLZxHdn/R47atTiQM+A1TWQkpa3faF/L9ANZISSe/OR6mPfQ/Zk
4AptHNmW/pWpd3JL4e06iK9P6ZLLRqSMR9mu6AFIeWYBVz+KkxgSIWgQO7/AHBUFjlIiMFhyQR5Y
UC1fo4CPZX7fMdUPwQiC+eZ7UtxMAUzovIzwEw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
KZhqqPnSEvcItoYRHrFT/Wt2IEXHe7pq5lmAOfYqAaaoY8mpIG3Kd8B/C4s9kNUbktSOX78NnnrJ
brxcu/1EAlI9itnDH8ahxble+2Nt/Lj3dQ1/wbDy3HOKlwBVuOvVDArOpgho+BAnoLUZXrpsw8EI
FSIPKmsETVzLzZDw6m0=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
WZbb0PsQl1vn7dY/rZzI8ZGsAP5Ad4C/d2cBXS49yTbQqKMTY7r1YHlrjBGteY6wrhKVmM92u/3/
/UJWPyNVqwcsrRAHhR/Lp3Mg87NIhYzETdNAOpnc7rWC9ieIeEiyPM734sI7QtAMVrZxXoUXnCjp
fjQhaMqv+HsuEWpFhDail+v8Ftwmr5xP1JSpqPfxLz5a6+q8/lTxRGeWZokM7vP2YFKg7L7Yoowh
gOm5w3JhR2fXZsksWxfQk7885JzsI4yZOrU8dY667YWWhkjZE/SKo2TMksiasL22T6CpyUbMwQm2
DJ+cMJbr9/8csBEifIsopc4V9zFbSU9eoxlqZA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Adid/GOKDljgmM7UpkmD6EVL+5rt6bnWK9P8RIZiI3EkLW96rM6eCs7jkLeKnEW/WPGRhlZrGw8p
C7Ni27oibJKJT5xUBJDymbO+yheaaTI0GaeDMIzks860gYA3qdvTPxTBotaOg6MIpnYd070NhTod
Qq5XNnxLuF7/s5rAZANJHyRQKwu4gVBfs5SU2FSjF546M5FvN7BX6G7B76ALW6vKqGyKxwoHkc52
Bm8/jGTxJ6zbwn2v31NEfjO6nM5m6yYwY0476QLXWI6+7/ILkSvDVTt7B9HpcaRg3n3T4AEQDMyX
8bBPgm0qFbWZue0dlr9ljYOl0dgwaO8G9uYe9g==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
tq2b3cw7fnIOEbRUxnQIgAjXwRE3aRwj2IBVmS0S998fvCLPMUtm5MVXAqk0TwuEzKG3br/oRham
Oe5KAx6FauTTVpRhLH5RY3832M9OVTSW/bNq12/dXnJyOfYS76FQtd9HNFrSkVPMONGMD0ZQXRic
Yr0MaeflUHQmU6QUCt5OJkbG4F8qJLMWJsg03K7dNzDfkvev3QVf72bmHTm4SF6/cs94NXQl/NPr
CzQorTZ5BgCzVAui7mM0eu3mu6OPkecNQ3Ih+1zsJuGkAHWC7aFgh7ii6xEj1upD365TzJUF1ZCe
0jZj/Ub1m5OgZMbjbLYn/Fh5nqi+fAmL7jDAHQ==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
S+EkimFGNL3D/SKyjUVYhIZzRbEoTqlnv2kHD0e4rYYCt/O4IYecNmch6HRfd2U/WSZPkAoJ+xa7
GKQSo51PL81HSvqURo2CxltObyTYiklnzGtbdWUMpOSCjDe8LpQjUNwhSksWjZjUQypyYXS4hbCR
VJy96ow8zi5m1XMzoLaVMDYoJYLtOVh7eaL7InaIL5gXJIHWkhoKYh9bR/O5HE6YTsgZl+Ofmx/3
0mQ/bL5ZKSY6gBEUD8f5+SoMIjfXrGkjMj1+fEAIv0fO/wKyJQMKnDOgWMvcUw56dOJ7FWkbNvbC
kzquuXhk5LuzZfXWmhyDSyMGBWK1wN7iyMKMUg==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
LQ4hjhkD/G9XJd+gVR5WF2vSll/p8/psR+nHjJ5/DHrtiRqVWFVc7B7T9XZuJBmTqrQV4iSBYWDo
zNaVdq26mGk6TTNo11Dcici0hEwC2Bg66k9kr1if+0iZo3VtB/ZuEOj2w7euhFo3ja1OovnDXxf0
8t4WMUK68mfUiMuKgVcbOFhm3Jdnbnz4u7SggH2/rkfOS8jbon9q9n0EXlK23tz2NzDLCS8B7ERx
dYvwqwBiySKoP1/EcfSwFNIWpr6p7kbRo7iM/JbP6UwBbkDHgE8HGS+3lTXIUXsmGmsx6EDSr/gY
i7lHwZTmDuhuIEJaf6gTJgtqMSxVyDVsrnba5umKgV8z5OOWUkM3FjVWIXOG7Ef2iKFCzBPmp2Lk
8XbrXk/bb9H/jr4UR3hgdbizISTysLTJd4n5uyeDhDgkxAc+1FudacmuZyBlA/VTR1f0i9+cOgLI
kdqbo1u5hQwnMphluBKjdTA3nZ8VnpDbdq5R7hIF61tIrUfdjwQw02je

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
JzhYMwmYowESMI19XNb+BEFcZw3IXZpwZO3gzrVg2CdSjbAR3tiIVbPHI5Rgu59SH7H8abU59Atd
+nrPiG37rmU6CD+cMV2mU8SHfCDLYsnrbd9YLZ1GEfqTovR0NZHQTHj+7c5dP7nqm30C/kg1adqd
DOV7F128PbmM5U45xRxOJKUgS/Waz0gvmYKKJejkiyFPOgGbN5f844mtysoOckLrAU/BzRs8SB9G
zzisK/a8hM5af8/opZ64TGhH44Npzy8kcP+gI+k+U0oF0SOqW7CjadKaJhr2oDkTScVVCbBqFEjc
2gH862vcCfZu5Cd0Sp2ALgoqVxA+91lAIHJp3Q==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ooNS+XjsaWLRgvcrNWVpR3ihKtIJNT1oT4D5ivD5mCfw+4/SAyx9P4cmdvOotLNPE1eqvx1Smd9Q
LDImL/GqS7Cq3KEUtEBbvQAOp+0SjiW74cC6nyOqCA8NQcn5JM+vUzGSsORPnM5qP96axGmyEvSi
p3uL9Gmx+3S3KUJuAzfuqZwJD7gdcA0Zv3hPRl+xhx8qFtkPCfT5uj7wpFVaaJ8tTl1SDd2uRUIx
rgVgV+oERCg71oEVN7PqPK1y7pFVgSW9uhP1wuvO/EsbyrLYZV6HtBn3tJDcxhTsQWrrou3F1kFQ
cFnl9tcL1wXJo/F3wvsbYM1W0UPHv69XAsEUhg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
d8YRbu+fllaHlNDedyRNDRtn9CBoVbO9fZCdhKpy0yf9dL6A08sFZuWVtVGljxF/L9volGB0IRjl
KbH2N/JBQA+tZWuh75kK5pjveAAKLVACS8A+Jmt/mrxzlolPWsruJ8o1Owrjq5tGWspdqmeDGS7U
/Ww7cN0C9ExUj4cjRDcKaqDS9MGwRtx4LfcQbQbRDZBk+cyRaWCchvmhjoum4uTizvqMq2u4oSym
t2zyKFjAuMO4zC2LbPbODeumm+FhlOKAHRyEBKA+VQeLB4apkMYparuD5AFWAuVvdWEbGq/L4cJ7
pEGz+6Hqi68CfF/4tMNiyHveP1lxnyAaiW6Kjg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 53808)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
