// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Thu Sep  7 14:10:28 2023
// Host        : Thinkpad_T14s_K running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {g:/Shared drives/KF PhD
//               Documents/Vivado/2023_DAQ/2023_DAQ.gen/sources_1/ip/blk_mem_gen_2/blk_mem_gen_2_sim_netlist.v}
// Design      : blk_mem_gen_2
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_gen_2,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module blk_mem_gen_2
   (clka,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [5:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [15:0]douta;

  wire [5:0]addra;
  wire clka;
  wire [15:0]douta;
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
  wire [15:0]NLW_U0_doutb_UNCONNECTED;
  wire [5:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [5:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [15:0]NLW_U0_s_axi_rdata_UNCONNECTED;
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.7096 mW" *) 
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
  (* C_INIT_FILE = "blk_mem_gen_2.mem" *) 
  (* C_INIT_FILE_NAME = "blk_mem_gen_2.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "64" *) 
  (* C_READ_DEPTH_B = "64" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "16" *) 
  (* C_READ_WIDTH_B = "16" *) 
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
  (* C_WRITE_WIDTH_A = "16" *) 
  (* C_WRITE_WIDTH_B = "16" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  blk_mem_gen_2_blk_mem_gen_v8_4_5 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[15:0]),
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
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[15:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 19456)
`pragma protect data_block
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
42asY7Q00OoC8MZyyb56Ye3b1Q==
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
