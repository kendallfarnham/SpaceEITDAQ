%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 6/30/23 for 2023_DAQ_64_v2 Vivado project
%       Updated: 10/5/23 for 2023_DAQ_final Vivado project
%--------------------------------------------------------------------------
% Run data acquisition (read serial data from FPGA through UART)
%--------------------------------------------------------------------------
% Inputs: cmdT (UI command set)
%       uart_port (serial port to FPGA)
%       ndata (number of 16-bit ints to read)
% Outputs: sdata (all data acquired, converted to double format)
%--------------------------------------------------------------------------
function [sdata] = daq_read_data(cmdT,uart_port,ndata)
    % Read data
    flush(uart_port,'input')
    write(uart_port,cmdT.UI_EN_TX,'uint8')  % Enable transfer to MATLAB
    datab = read(uart_port,ndata,'uint16'); % read all data
    write(uart_port,cmdT.UI_DIS_TX,'uint8') % stop transfer to MATLAB
    flush(uart_port,'input')

    % Convert bits to double
    nbits = 16;     % number of bits per data packet
    data16b = dec2bin(datab,nbits);
    sdata = double(typecast(uint16(bin2dec(data16b)),'int16'));

%--------------------------------------------------------------------------