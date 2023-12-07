# VHDL source code developed for the Artix 7 FPGA

Bitstream File: top_top_design.bit

Vivado Project (v2022.2)
- Project: 2023_DAQ_final.xpr
- Part: xc7a100tcsg324-2 (Trenz Electronics TE0711-01)
- Synthesis strategy: Flow_PerfOptimized_high
- Implementation strategy: Perfomance_ExtraTimingOpt

Design Sources (Hierarchy):
- top_top_design.vhd (Top level IO)
    - top_design.vhd (Top level controller)
        - adc_interface_x3.vhd (LVDS controller to/from ADCs)
        - blk_mem_gen_0.xci (Xilinx IP Core, ROM)
        - blk_mem_gen_2.xci (Xilinx IP Core, ROM)
        - clk_wiz_0.xci (Xilinx IP Core, MMCM)
        - dds_freq_demod_controller.vhd (Demodulation block for normal/high-speed acquisition)
            - blk_mem_gen_3.xci (Xilinx IP Core, BRAM)
            - fft_calcs.vhd (Computes sum of squared magnitudes from streaming FFT output)
            - fft_controller.vhd (Wrapper for FFT IP core)
                - xfft_0.xci (Xilinx IP Core, FFT)
            - fifo_generator_0.xci (Xilinx IP Core, FIFO)
            - uart_controller_8b.vhd (8-bit shift register)
                - uart_tx_8b.vhd (UART transmitter)
        - demod_controller.vhd (Demodulation block for debug mode, stores all samples and full FFT spectrum)
            - blk_mem_gen_1.xci (Xilinx IP Core, BRAM)
            - fft_controller.vhd (Wrapper for FFT IP core)
                - xfft_0.xci (Xilinx IP Core, FFT)
            - fifo_generator_0.xci (Xilinx IP Core, FIFO)
            - uart_controller_8b.vhd (8-bit shift register)
                - uart_tx_8b.vhd (UART transmitter)
        - dualtone_dds_controller.vhd (Dual-tone DDS controller)
            - dds_compiler_0.xci (Xilinx IP Core, DDS)
        - mux_controller.vhd (MUX DIO control)
        - pga_controller.vhd (PGA DIO/gain control)
            - spi_controller.vhd (SPI transmitter)
        - uart_ui_controller.vhd (UI controller, receives commands through USB UART)
            - uart_rx.vhd (UART receiver)

Memory Files:
- DDS phase bit LUT (blk_mem_gen_0.xci)
    - coe-dds__dds-lut_10bit-fft_24bit-phase_100M-dclk_div128_64freqs_prime-bins.coe
- FFT signal bin LUT (blk_mem_gen_2.xci)
    - coe-k__dds-lut_10bit-fft_24bit-phase_100M-dclk_div128_64freqs_prime-bins.coe

Contraints File:
- TE0703-TE0711-constraints.xdc

