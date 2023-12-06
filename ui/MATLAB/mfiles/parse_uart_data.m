%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 6/30/23 for 2023_DAQ_64_v2 Vivado project
%       Updated: 8/19/23 for 2023_DAQ Vivado project 
%--------------------------------------------------------------------------
% Parse serial data from UART
%--------------------------------------------------------------------------
% Dependencies:
%       [success] = check_parsed_data(avgnum,navgs);
%--------------------------------------------------------------------------
% Inputs: sdata (serial data)
%       nbram (size of BRAM per ADC dataset)
%       navgs (number of averages) -- added 8/19/23, keeps old func working
%       version (choose project version for parsing logic) -- added 9/14/23, keeps old funcs working
% Outputs: adc_data (struct with extracted data and fft spectrums)
%       success (1 if data was parsed correctly, -1 if not)
%--------------------------------------------------------------------------
function [adc_data,success] = parse_uart_data(sdata,nbram,navgs,nsets,version)

%--------------------------------------------------------------------------
% Set system parameters
if ~exist('nsets','var')
    nsets = length(sdata)/nbram/3; % divide by 3 for 3 adcs     
end
success = 0; % initialize

%--------------------------------------------------------------------------
% Choose which parsing function to use:
% Check if navgs variable exists
%       if not, keep parsing and adc_struct for older code (2023_DAQ_64_v2)
%       if == 0, then using new project but sending raw data (2023_DAQ_v02)
if ~exist('navgs','var')
    parse_version = 0;      % parse re/im adc data, re/im fft spectrum, 3 adcs
elseif navgs == 0 || version == 0
    % parse_version = 1;      % parse re/im adc data, re/im fft spectrum, 1 adc
    parse_version = 0;      % parse re/im adc data, re/im fft spectrum, 3 adcs
elseif version == 1
    parse_version = 2;      % parse [SumMag2 Fk2ReIm Fk1ReIm FdcReIm nAvgSet] 
elseif version == 2
    parse_version = 3;      % parse [SumMag2 Fk2ReIm Fk1ReIm FdcReIm nAvgSet] 
elseif version == 3
    parse_version = 4;      % parse avg [SumMag2 Fk2Mag Fk1Mag FdcMag] 
else
    parse_version = 0;
end

%--------------------------------------------------------------------------
% Parse, save data to structure
%--------------------------------------------------------------------------
switch parse_version
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
case 0
%--------------------------------------------------------------------------
% Parse data - data from Vivado project 2023_DAQ_64_v2  
%--------------------------------------------------------------------------
idx = 1;    % index of this bram data (initialize value)
for m = 1:nsets
    for an = 1:3 % 3 ADC's
        bramdata = sdata(idx:idx+nbram-1);  % get this adc's bram data

        % Parse packet
        data_re(:,m,an) = bramdata(1:2:nbram/2);
        data_im(:,m,an) = bramdata(2:2:nbram/2);
        fft_re(:,m,an) = bramdata(nbram/2+1:2:nbram);
        fft_im(:,m,an) = bramdata(nbram/2+2:2:nbram);

        % increment index
        idx = idx + nbram;
    end
end

%--------------------------------------------------------------------------
% Save data to struct
adc_data = struct('data_re',data_re,'data_im',data_im,'fft_re',fft_re,'fft_im',fft_im);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
case 1
%--------------------------------------------------------------------------
% Parse data - data from Vivado project 2023_DAQ
%--------------------------------------------------------------------------
idx = 1;    % index of this bram data (initialize value)
an = 1;     % one ADC
nsets = length(sdata)/nbram;    % number of datasets acquired
for m = 1:nsets
    bramdata = sdata(idx:idx+nbram-1);  % get this adc's bram data

    % Parse packet
    data_re(:,m,an) = bramdata(1:2:nbram/2);
    data_im(:,m,an) = bramdata(2:2:nbram/2);
    fft_re(:,m,an) = bramdata(nbram/2+1:2:nbram);
    fft_im(:,m,an) = bramdata(nbram/2+2:2:nbram);

    % increment index
    idx = idx + nbram;
end

%--------------------------------------------------------------------------
% Save data to struct
adc_data = struct('data_re',data_re,'data_im',data_im,'fft_re',fft_re,'fft_im',fft_im);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
case 2
%--------------------------------------------------------------------------
% Parse data - data from Vivado project 2023_DAQ_v01-v03
% [SumMag2 Fk2ReIm Fk1ReIm FdcReIm nAvgSet] in 16-bits saved as int16
%--------------------------------------------------------------------------
bramwidth = 9; % number of 16-bit pieces of data...
nsets = length(sdata)/nbram/3; % divide by 3 for 3 adcs  
idx = 1;    % index of this bram data (initialize value)

for m = 1:nsets
    for an = 1:3 % 3 ADC's
        
        for dn = 1:navgs % dataset number
            % Parse packet
            bramdata = sdata(idx:idx+bramwidth-1);  % get this line from bram 
            avgnum(dn,an,m) = bramdata(1);
            fft_dc(dn,an,m) = complex(bramdata(3),bramdata(2));
            fft_k1(dn,an,m) = complex(bramdata(5),bramdata(4));
            fft_k2(dn,an,m) = complex(bramdata(7),bramdata(6));

            % Combine bits for mag2 sum
            combbits = dec2bin(bramdata(8:9),16);  % 32 bits
            num32bit = [combbits(1,:), combbits(2,:)];
            mag2sum(dn,an,m) = bin2dec(num32bit);
            % mag2sum(dn,an,m) = double(typecast(uint32(bin2dec(num32bit)),'uint32'));

            % increment index
            idx = idx + bramwidth;
        end
    end
end

%--------------------------------------------------------------------------
% Save data to struct
adc_data = struct('fft_dc',fft_dc,'fft_k1',fft_k1,'fft_k2',fft_k2, ...
    'mag2sum',mag2sum,'avgnum',avgnum);

%--------------------------------------------------------------------------
% Check if parsing was successful. Function will print error if not.
[success] = check_parsed_data(avgnum,navgs);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
case 3
%--------------------------------------------------------------------------
% Parse data - data from Vivado project 2023_DAQ_v01-v03
% [SumMag2 Fk2ReIm Fk1ReIm FdcReIm nAvgSet] in 16-bits saved as int16
% Swap order of loop...
%--------------------------------------------------------------------------
bramwidth = 9; % number of 16-bit pieces of data...
idx = 1;    % index of this bram data (initialize value)
nfreqs = length(sdata)/nbram/nsets/3; % divide by 3 for 3 adcs  
for m = 1:nfreqs
    for an = 1:3 % 3 ADC's
        for dn = 1:navgs*nsets % dataset number
            % Parse packet
            bramdata = sdata(idx:idx+bramwidth-1);  % get this line from bram
            avgnum(dn,an,m) = bramdata(1);
            fft_dc(dn,an,m) = complex(bramdata(3),bramdata(2));
            fft_k1(dn,an,m) = complex(bramdata(5),bramdata(4));
            fft_k2(dn,an,m) = complex(bramdata(7),bramdata(6));

            % Combine bits for mag2 sum
            combbits = dec2bin(bramdata(8:9),16);  % 32 bits
            num32bit = [combbits(1,:), combbits(2,:)];
            mag2sum(dn,an,m) = bin2dec(num32bit);
            % mag2sum(dn,an,m) = double(typecast(uint32(bin2dec(num32bit)),'uint32'));

            % increment index
            idx = idx + bramwidth;
        end
        
    end
end

%--------------------------------------------------------------------------
% Save data to struct
adc_data = struct('fft_dc',fft_dc,'fft_k1',fft_k1,'fft_k2',fft_k2, ...
    'mag2sum',mag2sum,'avgnum',avgnum);

%--------------------------------------------------------------------------
% Check if parsing was successful. Function will print error if not.
[success] = check_parsed_data(avgnum,navgs*nsets);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
case 4
%--------------------------------------------------------------------------
% Parse data - data from Vivado project 2023_DAQ
% [SumMag2 Fk2Mag Fk1Mag FdcMag] in 16-bits saved as int16
%--------------------------------------------------------------------------
bramwidth = 5; % number of 16-bit pieces of data...
idx = 1;    % index of this bram data (initialize value)
for m = 1:nsets
    for an = 1:3 % 3 ADC's
        
            % Parse packet
            bramdata = sdata(idx:idx+bramwidth-1);  % get this line from bram 
            fft_dc(an,m) = bramdata(1);
            fft_k1(an,m) = bramdata(2);
            fft_k2(an,m) = bramdata(3);

            % Combine bits for mag2 sum
            combbits = dec2bin(bramdata(4:5),16);  % 32 bits
            num32bit = [combbits(1,:), combbits(2,:)];
            mag2sum(an,m) = bin2dec(num32bit);

            % increment index
            idx = idx + bramwidth;
    end
end

%--------------------------------------------------------------------------
% Save data to struct
adc_data = struct('fft_dc',fft_dc,'fft_k1',fft_k1,'fft_k2',fft_k2, ...
    'mag2sum',mag2sum);
end

end
