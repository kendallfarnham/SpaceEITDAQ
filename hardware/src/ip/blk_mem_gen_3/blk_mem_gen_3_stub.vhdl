-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
-- Date        : Sun Sep 24 19:30:27 2023
-- Host        : Thinkpad_T14s_K running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub {g:/Shared drives/KF PhD
--               Documents/Vivado/2023_DAQ_v04/2023_DAQ_v03.gen/sources_1/ip/blk_mem_gen_3/blk_mem_gen_3_stub.vhdl}
-- Design      : blk_mem_gen_3
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blk_mem_gen_3 is
  Port ( 
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 10 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 143 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 143 downto 0 )
  );

end blk_mem_gen_3;

architecture stub of blk_mem_gen_3 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,wea[0:0],addra[10:0],dina[143:0],douta[143:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_5,Vivado 2022.2";
begin
end;
