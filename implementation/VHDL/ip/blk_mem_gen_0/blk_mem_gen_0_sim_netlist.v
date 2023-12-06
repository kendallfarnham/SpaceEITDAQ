// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Thu Sep  7 14:09:39 2023
// Host        : Thinkpad_T14s_K running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {g:/Shared drives/KF PhD
//               Documents/Vivado/2023_DAQ/2023_DAQ.gen/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_sim_netlist.v}
// Design      : blk_mem_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_gen_0,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module blk_mem_gen_0
   (clka,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [5:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [23:0]douta;

  wire [5:0]addra;
  wire clka;
  wire [23:0]douta;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [23:0]NLW_U0_doutb_UNCONNECTED;
  wire [5:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [5:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [23:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "6" *) 
  (* C_ADDRB_WIDTH = "6" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "0" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     3.0424 mW" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "0" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "blk_mem_gen_0.mem" *) 
  (* C_INIT_FILE_NAME = "blk_mem_gen_0.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "64" *) 
  (* C_READ_DEPTH_B = "64" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "24" *) 
  (* C_READ_WIDTH_B = "24" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "64" *) 
  (* C_WRITE_DEPTH_B = "64" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "24" *) 
  (* C_WRITE_WIDTH_B = "24" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  blk_mem_gen_0_blk_mem_gen_v8_4_5 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[23:0]),
        .eccpipece(1'b0),
        .ena(1'b0),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[5:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[5:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[23:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(1'b0),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
VHPlDkoDlWlBfBMvPBmGYmaek3s9hXXhjF28kllYPnaNm3TSnzzpXHWHc8Ye9/2L2yiQfJ1hTWou
Ia/zeQ8h9/dtr6QB5YkyW4wlb/LbMgXb+DGIXPSllNl0IMsRQIcQDbcQm1bO/nlhb+2pjxiuaQrl
DbvxoDwPs7z3LunRxsg=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
lmIhoX8hXuc7tNV1sXY1K2/gXL7Y7Hq73qQF7+x03UWWTRd3uhGmVQtOMVbhIW+66UkWUHiD26zL
fzqGor8bgSNGpSFyS11k4TwLQT4OfAMGO8C9Qmmh4+VENBnpS9TW+wHzCv8oUwht7xYtYRZvOvYK
F3fMppz2sBkUd1lciw98ZE/UmNkhqBuMfIYF43j45DEJ55PBhOZNg91Ls4v3qBHyBAaYPFFoMry3
d5Fw1PZyFQSEOSSpwgyds2aN0g6oIwl7zm0LJrM9VDAOxBUE50hk+oHr4jj8J8UhHQJnlEHm1Idm
rvxKygNKRvfSpa90NYxZJFYgqnrMYg+19+9aZA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
VkyCjO2onoeZWEoYQ/4ue7X5mkHyTYVW9xjdoTsGS4GdP/Q64VaCZL/jr6R8DVDXPMnH7tRMrDpo
jpYBnyzSgOkfgqM+96ioC2fDyAaG4gYgGLmrBR6qK3/mxXwAZZX+GJ9R/eWXkc9h8xN+gsSSX6/M
jIQCgeT6q7PB4dWT6KY=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Iub91V+TnhVlZCSLu6iKmFjix71y6/l83OPTs8uewWvkE7WcqYxEKi9fonXEkzAtWzuKwEUqnOlN
VBsNJqPUdKcd22q523mrdt89mpdosWD+hvZdO7ELhJniY5u9h49FFkubpN2JiUTcIcKEYxVNlds4
wyvaYUqbPVH5v2ooJwDdimS4GVn9HerCOgPwfshvQDNlMTxLcYju4v8BHMc5Rub9Q/ihvpQU74v2
ouZ9XIwA+C6pBLwvaqS8jE7HXOokgqJilaX/W/t+KEgiFry/txRTMU9WMD7tCN7lcfjCydmS3Lq+
3u6Hsr0S8BwNjcaDpZDnBTygUJd4JSqREnk33w==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
U46EWFmKmpZGaWfyL+dokyQtJtaOYsa7HCW/+fdtw9/yHKTWFpmqKBZngBj5rPkNhtTDDCJkqsYj
tUXg1j4tgIBaCQn9B0q/aG+B3gPLrudp9hLL25mVbsfiTzdekiV2hJMmhuMoavKKPJHC6zyW7kZi
80er82OQy8h+Df/fe6TRjH9xEt3/b80tRKUMbxkLfnnkAyyf1KfOhB6/uyI4mwXuQR+DsAbzybKR
YtXpOiW72tGrXTFlzcwbHamWZefqsilVpBw6V5dh33vYKGx50xwWpj76maAkpQrOpB7zufeldJe4
W1UOEN84AZdRTLkVSxamWo/wp8nP9fiGS/ItRw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
qczgIJYpE/SzErzK7eWJBGcDFEzDLm8cKbwJbPXuM6YnJxx44W+E60R3war7K2QGFAkOoCDUtDC7
SghJGF32btaDLzeKm0tQ669sBtQmMIaBrlt7I9QBkNM8zN9GL92qxNC9o3UVWMOYy5BmH8nUPgcE
O6lRubeltlrTuDe7UJQ2nEPHcXjpUJJ8dxktyW+LovBy1OxW8g4GRAsmEJsoOEg0HuDdWcc4IshJ
PvwPJ7LblELAKsdkSt65y9VaklaEm7MlH4ImlgIa74TgRmutLUbWxM1QYhGE5rAzFhGU5i3RJOdx
L3N7GGGvLMW2z9NSHbIFX+/eNII9fNJ9nZbgLA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Ti1NUgDv8YPk90APMwfu/mRr38QYwAxZfv0T6zQ89YS55t2EquEGVqrEafYX6rTydLOw8le1Oucv
f2oERpSSSTih/ScZneSZmuPE/Zh2BU1Ajv0j+/+0uEWXU+5lLPbDJjnapTmJXih1MYPf0SHpZZmE
BKj2IEBI9MPZlh6bxpa5BWJnyPdAvHf+UNaMXU9+pmbtrzUVebql4mFJu45Z3+ehmFY4FBW3zXMF
44C4TlHACLwL3vHVMCVfeKhgdVDbpE+/IFhTStz7mZ9h9RKGanQcs6YDVM1R+2RKA1QT1fX4FiQc
1V+FGmrm1ujxmFGXwpfNKByVlfCY0oWhRJCYYQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
HuEXFK0NXt09xU2yxxjng1OLsT+ZEM4EhqBgpr9D2ljw2vDaMBrqEsRQTc2B9soDq3ewDduHJXBd
OGYxkPnoN6LhjULtB2nTgjcH6NxA4puZ1ZNcndDndVBo8rTW5W1OqHq6InAG0CqPpTIkuqz3ECPl
EysI++MCDfH6tIzlekxJFIJ1McJsTq5rFuLzMMcrmkBxgcayDpOcCFuzZzCczxmt/cCCIKmDybwT
OQXmOcLJoYLP4sFu6R9c6xO8i6p++crv2N3eIxZHKbek9xBBZqQM9EYuEtsbkqAs9XZpa16i5njR
BDFxTKcP6r7JgFALJE89AZhBbate5JXWp0v4ECZD18aEL17CipwcWPutNMdG1apzSPP5y59n7rMG
yxBPz1gKHc3Emkl4WcO0hjICxqmO6dMXoY8JvBSf6ry2l0sH9Ihr3Bq5WWmlhPHnoaNr5jl//vNe
KfToWtn97eoVSt1LnmXXnSpdigbHr0UIg8AdkpdkuNRaWdVicDdgSo49

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
mokwst2bn6UxD6V9UdIgCIG1QQ/d0FiJqYGOTI2eHPV6YElaLjnJ8DnQmZnGS95o3x93FDOoa58C
RwYsX1fVoVtXkj1LuZq0k7q9vEe4T8xMjpkeYtIHY9k0Xhy1Lq/xRlfzGAf9fvf9e+f4r7aR/Sb/
uCZxxugG5niTwLENY1n3NthYL0jvo8Fmdw4Qg0nTCGWlVCws+09K0g9/lx6I9EcuHHemcHO3fOZG
lMc4NaPNozKwnyDMoWUkwiVxyFEPFaQLNYqzjvR+CqrWfhFLo96JWhL+eaDoNuZoBVYQtNH5ZwBL
BoO27Pw10lgcReGlZBz3BLO7T4ddynCx0+eSnw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PiP7AjOQqqouyQMoBQqgWIDhUSViq94rIvGiIJ/UKMDspM/yXw1caE8AhWHTjYckC4yLpPAz5P6s
1Z6flzDPrzVwg4e59X2cc4IMCHhedna0rDO804njcc6amRDTeLsMLTkWfvomB4xwszm2AgT+PRnB
WHd09ZUDVFjiBXT+Oa9AicgGJHrX3w823yBPuAa704kje/SzgtiDpcTU1eLmLhLW7LpEd9KIHd9s
ER7Uk9Orws0Kq9PMTqMX4hMn5K5mFakOeOURiEbUjdv5RiIJ2g/PlQXSItM8fHsBTQa6fOaJwQTI
vHwK3a8ZBHpfT1YH+n7wNiNUZwD4SFXm1QVx4g==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Ul5ZfTHJwMctaNhYRortUZizYMPYRef7uYqPSuMkxsArnxI/cjGh+KRMwzV86hyp/6TXSJIjm5ec
2wX2UONdPN+DOJ84jYC4JbgJQrPnTj7ioD8uLX/WlyPcQzyF5keqFgj5eR5s13FskVWCuAWf5m9w
mhFEKFjVXDAr7gVgAJh/hL8P6Psrnf+LGfiM8JhnDepsHEYykGlpD3fzru2BGgqHWqPqFMcnyVGl
vysaIXiJz/eYKvO8RGcgd3DJAM/wPm9A0m/DWcmSnczOgTjoqkHcBg2H5uJMLvufzmjImi6LYEqq
v04ESDEN31cSUzqUYcayvMFOnI/WNsWbFIa5+Q==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 19120)
`pragma protect data_block
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
bQvBjgEsJYEBFYhKUqJYOsV+BCmN/9cN8A==
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
