%-----------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 10/04/23 for 2023_DAQ_final Vivado project
%-----------------------------------------------------------------------
% Main DAQ functions -- called from main_gui App when Start button is pressed
%-----------------------------------------------------------------------
% Inputs:   ui_params (user settings from GUI)
%           dbg_mode (T if loading existing data, F if running acq, set in GUI)
% Outputs:  sfile_loc (path to saved data)
%           ui_params (updated ui_params for GUI)
%-----------------------------------------------------------------------
function [sfile_loc, ui_params] = main_gui_functions(ui_params,dbg_mode)
%-----------------------------------------------------------------------
addpath mfiles
dbstop if error
%-----------------------------------------------------------------------
% Set up logging
%-----------------------------------------------------------------------
% Filenames and folders
save_log = ui_params(1).save_log;       % save console output to log file
logfile = ui_params(1).logfile;
sfolder = ui_params(1).sfolder;         % save to this folder
if ~(sfolder(end) == '/')
    sfolder = [sfolder '/'];            % correct string format for path
end
if ~isfolder(sfolder)
    mkdir(sfolder)          % create new folder if DNE
end
if save_log
    diary(logfile);         % turn on logging
    disp(['Saving console output to: ' logfile])
end

%-----------------------------------------------------------------------
% Default settings -- not in GUI
%-----------------------------------------------------------------------
% Settings for acquisition
pga_gains = [1 2 4 5 8 10 16 32];
pga_inds = [4 4 4];         % default pga gain +5 V/V -- indices used for DAQ command
pgs = pga_gains(pga_inds);  % default pga gain +5 V/V -- use for calcs;
ui_set_dds_divide = 1;      % divide digital output
dds_divide_val = 1;         % divide by 2^(dds_divide_val-1) (1:4)
%-----------------------------------------------------------------------
% Settings for data parsing/extraction
board_num = 3;      % mux board (50 Ohm Rsense, 2.4k Rgain)
parse_version = 2;  % 9 16-bit data packets, nsets x freq


%-----------------------------------------------------------------------
% Load GUI settings
%-----------------------------------------------------------------------
% Set path to where to save data
save_data = ui_params(1).save_data;     % save extracted data to...
sfolder = ui_params(1).sfolder;         %   this folder
sfile_pfx = ui_params(1).sfile_pfx;     %   and this file
sfile_loc = [sfolder sfile_pfx];        % (full path to data)
%-----------------------------------------------------------------------
% Set acq, parsing, and extraction parameters
parse_data = ui_params(1).parse_data;  
extract_data = ui_params(1).extract_data;

%-----------------------------------------------------------------------
% Load debug mode data
%-----------------------------------------------------------------------
if dbg_mode == 1
    % Save settings from debug panel to overwrite ui_params
    sig_set_use_full_fft = ui_params(1).use_full_fft;    % use full fft data for thd calc
    sig_use_fsig_bins = ui_params(1).use_fsig_bins;  % bins to use for extract_data (1: fk, 2: nfft-fk, 3: both)
    % Load dataset
    disp(['In debug mode, loading data from ' sfile_loc]);
    load(sfile_loc,'iis','vvs','fsigs','adc_data_struct','iivvs', ...
        'data_iivv','freq1_inds','ui_dbg_adc_num','ui_params', ...
        'nbram','navgs','nsets','parse_version','nfft','nfreqs', ...
        'dds_divide_val','use_dual','freq2_inds','pgs','eit_data');

    % Overwrite ui_params
    ui_params(1).use_full_fft = sig_set_use_full_fft;
    ui_params(1).use_fsig_bins = sig_use_fsig_bins;

    % Overwrite internal variables
    enable_freqsweep = ui_params(1).enable_freqsweep;

    run_acq = 0;        % don't run data acquisition
else
    run_acq = 1;        % run data acquisition

    %-----------------------------------------------------------------------
    % Mux channels (1:64)
    % PGA gain setting index (1:8)
    % DDS frequency settings (1:64)
    %-----------------------------------------------------------------------
    % Data acquisition settings
    %-----------------------------------------------------------------------
    navgs = ui_params(1).navgs;     % acquire multiple datasets for averaging
    nsets = ui_params(1).nsets;     % acquire multiple datasets for snr calcs
    mux_dly = ui_params(1).mux_delay;       % delay between mux switches
    ii_filename = ui_params(1).ii_filename; % path to file containing ii pairs
    %-----------------------------------------------------------------------
    % DDS/frequency settings
    enable_freqsweep = ui_params(1).enable_freqsweep;   % if true, run freqsweep
    freq1_inds = ui_params(1).freq1_inds;               % acquire these freqs if freqsweep is disabled
    use_dual = ui_params(1).use_dual;                   % enable second dds
    freq2_inds = ui_params(1).freq2_inds;               % set second dds if enabled

    %-----------------------------------------------------------------------
    % Debug panel settings
    %-----------------------------------------------------------------------
    ui_reset = ui_params(1).reset;               % reset before acquisition
    ui_disable_after_run = ui_params(1).disable_after_run;  % turn off system after running data acquisition
    ui_set_use_full_fft = ui_params(1).use_full_fft;        % use full fft data for thd calc
    use_fsig_bins = ui_params(1).use_fsig_bins;  % bins to use for extract_data (1: fk, 2: nfft-fk, 3: both)

    %-----------------------------------------------------------------------
    % Debug modes
    ui_dbg_adc_testpattern_on = ui_params(1).adc_testpattern_on; % turn on ADC testpat
    ui_dbg_enable_dds_to_fft = ui_params(1).enable_dds_to_fft;   % enable debug mode (dds to demod)
    ui_dbg_adc_num = ui_params(1).enable_adc_out;       % ADC number 1-3 (Is, V1, V2) for enable_adout cmd
    if ui_dbg_adc_num == 0
        ui_dbg_enable_adout = 0;    % disable
    else
        ui_dbg_enable_adout = 1;    % enable raw ADC data output from one adc
    end

    ui_set_debug_params = ui_dbg_adc_testpattern_on ... % set adc testpat, debug mode, etc
        || ui_dbg_enable_dds_to_fft == 1 ...
        || ui_dbg_enable_adout;


    %-----------------------------------------------------------------------
    % Mux switching parameters
    %-----------------------------------------------------------------------   
    if isfile(ii_filename)
        % Load ii pairs, use same channels for vpickup
        iis = load(ii_filename);  % source/sink pairs (vs+, vs-)
        ch_list = unique(iis);
        nchs = length(ch_list);
        vvs = unique(round(ch_list/2)); % channels in use, divided by 2 (vpickup channels are index 1:32)
    else
        % Individually choose source and pickup channels
        nskips = ui_params(1).nskips_ii;
        vsource = ui_params(1).vsource;
        vsink = ui_params(1).vsink;
        vpickup = ui_params(1).vpickup;
        if length(vsource)*length(vsink) == 1 % both arrays have 1 channel
            [iis,vvs] = get_ii_vv_channels(vsource,vsink,vpickup);
        else
            [iis,vvs] = get_ii_vv_channels(vsource,vsink,vpickup,nskips);
        end
        nchs = length(vpickup);
    end


    %-----------------------------------------------------------------------
    % Check system parameters
    %-----------------------------------------------------------------------
    if ui_set_debug_params
        nsets = 1;
        navgs = 1;
        enable_freqsweep = 0;
        if ui_dbg_enable_adout      % reading old demod block
            navgs = 0;              % no averaging
            extract_data = 0;       % data extraction is different
            parse_version = 0;
        end
    end

    %-----------------------------------------------------------------------
    % Data parameters
    %-----------------------------------------------------------------------
    % Load parameters from LUT mat file
    coe_filename = 'mfiles/dds-fft-freq-lut.mat';
    load(coe_filename,'nfft','fsig');
    %-----------------------------------------------------------------------
    % Set BRAM size
    if parse_version == 0           % reading old demod block
        nbram = nfft*4;             % number of data in bram
    elseif parse_version == 1
        bramwidth = 9;              % number of 16-bit data packets per bram addr
        nbram = bramwidth*navgs;    % number of 16-bit data in bram
    elseif parse_version == 2
        bramwidth = 9;              % number of 16-bit data packets per bram addr
        nbram = bramwidth*navgs;    % number of 16-bit data in bram
    elseif parse_version == 3
        nbram = 5;                  % number of 16-bit data sent per demod block
        navgs = 2^navgs;            % adjust number of averages
    else
        nbram = nfft*4;             % number of data in bram
    end
    %-----------------------------------------------------------------------
    % Set data read/parse variables
    nadcs = 3;                      % 3 adcs (Isense, Vpickup 1, Vpickup 2)
    if enable_freqsweep
        nfreqs = length(fsig);      % number of freqs in sweep
        freq1_inds = 1;             % set to 1 to run once
        fsigs = fsig;
        ndata = nadcs*nbram*nsets*nfreqs;   % number of 16-bit ints to read
    else
        nfreqs = length(freq1_inds);
        fsigs = fsig(freq1_inds);
        ndata = nadcs*nbram*nsets;  % run each freq separately
    end

    %-----------------------------------------------------------------------
    % Report settings to user
    %-----------------------------------------------------------------------
    % Get actual pga gains and mux channels selected (for user report)
    pgs = pga_gains(pga_inds);

    %-----------------------------------------------------------------------
    % Print to command window
    fprintf(['DAQ SETTINGS:\n' ...
        '  NFFT = %d, nAvgs = %d, nSets = %d, BRAM size = %dx16 bits\n' ...
        '  DDS: %d freqs, output divided by %d \n' ...
        '  Dual DDS: enabled = %d (1=T), freq index %d \n' ...
        '  PGA gains (Isense, V1, V2): %d, %d, %d \n' ...
        '  MUX: %d channels \n'], ...
        nfft,navgs,nsets,nbram,nfreqs, ...
        2^(dds_divide_val+1),use_dual,freq2_inds,pgs,nchs)
end

%-----------------------------------------------------------------------
% Append to file name if it already exists, overwrite ui_params
if isfile(sfile_loc) && save_data
    sfile_loc = [extractBefore(sfile_loc,'.mat') '_1.mat'];
    ui_params(1).sfile_pfx = [extractBefore(sfile_pfx,'.mat') '_1.mat'];
end
%-----------------------------------------------------------------------
% Run data acquisition
if run_acq
    %-----------------------------------------------------------------------
    % Set up data acquisition settings in hardware
    %-----------------------------------------------------------------------
    % Open serial port and load UI command set
    uart_port = setup_serial_port();
    cmdT = load_ui_commands();

    %-----------------------------------------------------------------------
    % Initialize DAQ -- optional startup commands and DAQ parameters
    %-----------------------------------------------------------------------
    if ui_reset                     % Reset system
        daq_reset(cmdT,uart_port)   % Reset
    end

    if ui_set_use_full_fft
        daq_use_full_fft(cmdT,uart_port)   % Set daq to use full fft data for thd
    end

    if ui_set_dds_divide            % Set dds divide value
        set_dds_divide(cmdT,uart_port,dds_divide_val);
    end

    %-----------------------------------------------------------------------
    % Set DAQ parameters -- required acquisition parameters
    %-----------------------------------------------------------------------
    % Set pga gains
    set_pga_gains(cmdT,uart_port,pga_inds(1),pga_inds(2),pga_inds(3));

    % Set number of averages to acquire
    set_naverages(cmdT,uart_port,navgs)

    % Set number of datasets to acquire
    set_ndatasets(cmdT,uart_port,nsets)

    % Set dds frequency(s)
    set_dds(cmdT,uart_port,enable_freqsweep,[freq1_inds freq2_inds],use_dual);

    %-----------------------------------------------------------------------
    % Debug parameters
    %-----------------------------------------------------------------------
    if ui_set_debug_params          % Set debug parameters
        set_adc_testpattern(cmdT,uart_port,ui_dbg_adc_testpattern_on)
        if ui_dbg_enable_adout      % Enable raw ADC data out
            set_debug_mode(cmdT,uart_port,ui_dbg_enable_dds_to_fft,ui_dbg_adc_num)
        else
            set_debug_mode(cmdT,uart_port,ui_dbg_enable_dds_to_fft)
        end
    end

    %-----------------------------------------------------------------------
    % Initialize struct
    %-----------------------------------------------------------------------
    data_iivv = struct('adc_data',[],'sdata',[]);

    %-----------------------------------------------------------------------
    % Start data acquisition
    %-----------------------------------------------------------------------
    disp('Data acquisition started...');
    tic
    %-----------------------------------------------------------------------
    % Loop through iivvs, run acquisition (read data)
    %-----------------------------------------------------------------------
    % Set mux channels
    for n_ii = 1:numel(iis)/2
        set_ii = 1; % set ii pair next time
        for n_vv = 1:length(vvs)
            mux_chs = [iis(n_ii,1) iis(n_ii,2) vvs(n_vv) vvs(n_vv)];    % [VS+ VS- V1 V2], note V1 and V2 are 1:32 (V1 odd ch's, V2 even ch's)
            set_muxes_iivv(cmdT,uart_port,mux_chs,set_ii);
            set_ii = 0; % clear, only set vv pair for rest of this loop

            %--------------------------------------------------------------------------
            % Run data acquisition
            %--------------------------------------------------------------------------
            if enable_freqsweep
                %----------------------------------------------------------------------
                % Read data
                pause(mux_dly)
                [sdata] = daq_read_data(cmdT,uart_port,ndata);
            else
                %--------------------------------------------------------------------------
                % Loop through frequencies
                for fi = 1:length(freq1_inds)
                    dds_freqs = [freq1_inds(fi) freq2_inds];
                    set_dds(cmdT,uart_port,enable_freqsweep,dds_freqs,use_dual);
                    %----------------------------------------------------------------------
                    % Read data
                    pause(mux_dly)
                    [sdata(:,fi)] = daq_read_data(cmdT,uart_port,ndata);
                end
            end

            % Save to struct
            data_iivv(n_ii,n_vv).sdata = sdata;
        end
        disp(['Finished ii pair (' num2str(iis(n_ii,1)) ', ' num2str(iis(n_ii,2)) ')']);
        % Save data incrementally
        if save_data
            save(sfile_loc,'data_iivv');
        end
    end
    disp('DAQ data transfer finished. Parsing serial data...');
    toc
    %--------------------------------------------------------------------------
    % Turn off DAQ if selected
    if ui_disable_after_run
        daq_disable(cmdT,uart_port);
    end

    %--------------------------------------------------------------------------
    % Delete port
    clearvars uart_port

    % Save data incrementally
    if save_data
        save(sfile_loc,'data_iivv','nbram','navgs','nsets','parse_version');
    end
end  % end of run_acq
%-----------------------------------------------------------------------
% Loop through iivvs again, parse and store data
%-----------------------------------------------------------------------
tic
if parse_data
    for n_ii = 1:numel(iis)/2
        for n_vv = 1:length(vvs)
            clearvars adc_data sdata
            sdata = data_iivv(n_ii,n_vv).sdata;
            if enable_freqsweep
                [adc_data,~] = parse_uart_data(sdata,nbram,navgs,nsets,parse_version);
            else
                %--------------------------------------------------------------------------
                % Loop through frequencies
                for fi = 1:length(freq1_inds)
                    [adc_data(fi),~] = parse_uart_data(sdata(:,fi),nbram,navgs,nsets,parse_version);
                end
            end

            % Save to struct
            data_iivv(n_ii,n_vv).adc_data = adc_data;
        end
    end
    toc
    disp('Finished parsing data.');

    % Save data incrementally
    if save_data
        save(sfile_loc,'data_iivv','nbram','navgs','nsets','parse_version');
    end
end
%--------------------------------------------------------------------------
% Data extraction and save options
%--------------------------------------------------------------------------
if extract_data
    disp('Extracting ADC data.');
    clearvars adc_data_struct eit_data iivvs
    tic
    %--------------------------------------------------------------------------
    % Extract eit_data
    [eit_data, plt_var_struct] = extract_avg_eit_data(data_iivv,iis,vvs,fsigs, ...
        pgs,board_num,use_fsig_bins,ui_set_use_full_fft,navgs);

    adc_data_struct = eit_data(1).adc_data_struct;
    iivvs = eit_data(1).iivv;
    toc
    disp('Done data extraction');
end
%--------------------------------------------------------------------------
% Check variables, set to empty if DNE
%--------------------------------------------------------------------------
if ~exist('ui_dbg_adc_num','var');  ui_dbg_adc_num = 0;     end
if ~exist('eit_data','var');        eit_data = [];          end
if ~exist('adc_data_struct','var'); adc_data_struct = [];   end
if ~exist('iivvs','var');           iivvs = [];             end
if ~exist('plt_var_struct','var');  plt_var_struct = [];    end

%--------------------------------------------------------------------------
% Save data
%--------------------------------------------------------------------------
if save_data
    save(sfile_loc,'iis','vvs','fsigs','adc_data_struct','iivvs','pgs', ...
        'data_iivv','freq1_inds','ui_dbg_adc_num','ui_params','logfile', ...
        'eit_data','nbram','navgs','nsets','parse_version','plt_var_struct');
    disp(['Data saved to ' sfile_loc])
end
