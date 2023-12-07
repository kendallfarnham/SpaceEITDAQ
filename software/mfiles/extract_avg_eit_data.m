%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Extract data saved from main_gui_functions
%       Compute averages across parsed demodulated data
%       Compute voltages, currents, and impedance data
%--------------------------------------------------------------------------
% Output: ret_struct (struct with Vmeas per Vs+/Vs- pair)
%--------------------------------------------------------------------------
function [ret_struct,plt_var_struct] = extract_avg_eit_data(data_iivv,iis,vvs,freqs, ...
    pgs,board_num,use_fsig_bins,ui_set_use_full_fft,navgs)
%--------------------------------------------------------------------------
% Get circuit parameters
afe_params = get_circuit_parameters(board_num);
Rsense = afe_params.Rsense;
nfft = 1024;    % length of FFT

vv_pairs(:,1) = 2*vvs-1;    % odd channels
vv_pairs(:,2) = 2*vvs;      % even channels
%--------------------------------------------------------------------------
% Check data dimensions
%--------------------------------------------------------------------------
adc_data = data_iivv(1,1).adc_data;
nsets = size(adc_data(1).fft_dc,1);     % number of datasets acquired
nadcs = size(adc_data(1).fft_dc,2);     % number of ADCs (check this is 3)
nfreqs = size(adc_data(1).fft_dc,3);    % number of freqs

if nadcs ~= 3
    disp(['ERROR in extract_avg_eit_data(). ' ...
        'Dimensions (nadcs) are incorrect. nADCs = ' num2str(nadcs) ...
        ', nSets = ' num2str(nsets) ', nFreqs = ' num2str(nfreqs)])
end
if nfreqs*length(adc_data) ~= length(freqs)
    disp(['WARNING in extract_avg_eit_data(). ' ...
        'Dimensions (nfreqs) are incorrect. nADCs = ' num2str(nadcs) ...
        ', nSets = ' num2str(nsets) ', nFreqs = ' num2str(nfreqs)])
end
if nsets == 1
    disp(['nSets = ' num2str(nsets) ', no averaging.'])
end
if ~exist('navgs','var')
    navgs = nsets;  % average the datasets
    nsets = 1;      % set to 1
elseif navgs > 1
    nsets = nsets/navgs;
end

%--------------------------------------------------------------------------
% Loop through mux channels
%--------------------------------------------------------------------------
for n_ii = 1:size(data_iivv,1)        % loop through iis
    for n_vv = 1:size(data_iivv,2)    % loop through vvs

        %------------------------------------------------------------------
        % Extract FFT data per ADC, average datasets
        %------------------------------------------------------------------
        clearvars adc_data fft_struct

        %------------------------------------------------------------------
        % Get parsed data
        adc_data_tmp = data_iivv(n_ii,n_vv).adc_data;
        if length(adc_data_tmp) > 1 % datasets separated by frequency
            for ai = 1:length(adc_data_tmp)     % combine into single struct
                adc_data(1).fft_dc(:,:,ai) = adc_data_tmp(ai).fft_dc;
                adc_data(1).fft_k1(:,:,ai) = adc_data_tmp(ai).fft_k1;
                adc_data(1).fft_k2(:,:,ai) = adc_data_tmp(ai).fft_k2;
                adc_data(1).mag2sum(:,:,ai) = adc_data_tmp(ai).mag2sum;
                adc_data(1).avgnum(:,:,ai) = adc_data_tmp(ai).avgnum;
            end
        else
            adc_data = adc_data_tmp;
        end

        % Calculate average and extract SNR/THD/amplitudes
        if navgs > 1
            adc_data = calc_avg_demod_data(adc_data,navgs);
        end

        %------------------------------------------------------------------
        for n = 1:length(adc_data)        % n should be 1
            %------------------------------------------------------------------
            % extract sum for thd calc and average number
            avgnum = data_iivv(n_ii,n_vv).adc_data(n).avgnum;
            mag2sum = adc_data(n).mag2sum;
            %------------------------------------------------------------------
            % get magnitude and phase for DC and signal(s)
            fdc = abs(adc_data(n).fft_dc)/nfft;
            fk1 = 2*abs(adc_data(n).fft_k1)/nfft;
            fk2 = 2*abs(adc_data(n).fft_k2)/nfft;
            % if bins k1 and k2 are for the same signal (k and nfft-k)
            fkk = (abs(adc_data(n).fft_k1) + abs(adc_data(n).fft_k2))/nfft;

            phfdc = angle(adc_data(n).fft_dc);
            phfk1 = angle(adc_data(n).fft_k1);
            phfk2 = angle(adc_data(n).fft_k2);
            phfkk = (abs(phfk1)+abs(phfk2))/2; % get average phase

            %------------------------------------------------------------------
            % Rearrange matrix if multidimension
            if nfreqs > 1 && nsets > 1
                if size(fdc,2) == nsets && size(fdc,1) == nadcs % swap dimensions to be nsets x nadcs x nfreqs
                    % disp(['INFO (extract_avg_eit_data): swapping dimensions' ...
                    %     ' to [2 1 3]. Old dimensions [1 2 3] = ' num2str(size(fdc))])
                    fdc = permute(fdc,[2 1 3]);
                    fk1 = permute(fk1,[2 1 3]);
                    fk2 = permute(fk2,[2 1 3]);
                    fkk = permute(fkk,[2 1 3]);
                    phfdc = permute(phfdc,[2 1 3]);
                    phfk1 = permute(phfk1,[2 1 3]);
                    phfk2 = permute(phfk2,[2 1 3]);
                    phfkk = permute(phfkk,[2 1 3]);
                    mag2sum = permute(mag2sum,[2 1 3]);
                    avgnum = permute(avgnum,[2 1 3]);
                elseif size(fdc,2) ~= nadcs
                    disp(['Warning in extract_avg_eit_data: dimensions of fft ' ...
                        'data matrix = ' num2str(size(fdc)) '. Expected size is ' ...
                        'nsets x nadcs x nfreqs = ' num2str(nsets) 'x3x' num2str(length(freqs)) ...
                        '. First dim should be nsets = ' num2str(nsets)])
                end
            elseif size(fdc,1) == nadcs && size(fdc,2) ~= nadcs
                % disp(['INFO (extract_avg_eit_data): swapping dimensions (transpose). ' ...
                %     'Old dimensions = ' num2str(size(fdc))])
                % Transpose
                fdc = fdc';
                fk1 = fk1';
                fk2 = fk2';
                fkk = fkk';
                phfdc = phfdc';
                phfk1 = phfk1';
                phfk2 = phfk2';
                phfkk = phfkk';
                mag2sum = mag2sum';

            end
            %------------------------------------------------------------------
            % Calculate voltage and phase from fft data
            %------------------------------------------------------------------
            % Choose which fft signal bins to use for voltage calcs
            switch use_fsig_bins
                case 1      % use bin k1
                    fksig = fk1;
                    fft_phase = phfk1;
                case 2      % use bin k2 = NFFT-k1
                    fksig = fk2;
                    fft_phase = phfk2;
                case 3      % use both, take average
                    fksig = fkk;
                    % fft_phase = phfkk;
                    fft_phase = phfk1;
            end

            %------------------------------------------------------------------
            % Get signal half spectrum magnitude for thd and voltage functions
            fksig = fksig*nfft/2; % reverse amplitude calc from above
            fdcsig = fdc*nfft;

            %------------------------------------------------------------------
            % Calculate thd
            half_spectrum = ~ui_set_use_full_fft;
            thd = calc_thd_from_fft(fksig,mag2sum,half_spectrum);

            %------------------------------------------------------------------
            % Calculate voltage and phase, get reference from isense ADC (1st one)
            if size(fdc,3) > 1 % nfreqs > 1 % data has 3rd dimension
                [vpp_i(:,:),~,vdc_i(:,:)] = calc_voltage_from_fft(fksig(:,1,:),fdcsig(:,1,:),1,pgs(1),board_num);
                [vpp_v1(:,:),~,vdc_v1(:,:)] = calc_voltage_from_fft(fksig(:,2,:),fdcsig(:,2,:),2,pgs(2),board_num);
                [vpp_v2(:,:),~,vdc_v2(:,:)] = calc_voltage_from_fft(fksig(:,3,:),fdcsig(:,3,:),3,pgs(3),board_num);
                zphase_v1(:,:) = fft_phase(:,2,:) - fft_phase(:,1,:);
                zphase_v2(:,:) = fft_phase(:,3,:) - fft_phase(:,1,:);

                thd_i(:,:) = calc_thd_from_fft(fksig(:,1,:),mag2sum(:,1,:),half_spectrum);
                thd_v1(:,:) = calc_thd_from_fft(fksig(:,2,:),mag2sum(:,2,:),half_spectrum);
                thd_v2(:,:) = calc_thd_from_fft(fksig(:,3,:),mag2sum(:,3,:),half_spectrum);
            else
                [vpp_i,~,vdc_i] = calc_voltage_from_fft(fksig(:,1),fdcsig(:,1),1,pgs(1),board_num);
                [vpp_v1,~,vdc_v1] = calc_voltage_from_fft(fksig(:,2),fdcsig(:,2),2,pgs(2),board_num);
                [vpp_v2,~,vdc_v2] = calc_voltage_from_fft(fksig(:,3),fdcsig(:,3),3,pgs(3),board_num);
                zphase_v1 = fft_phase(:,2) - fft_phase(:,1);
                zphase_v2 = fft_phase(:,3) - fft_phase(:,1);

                thd_i = calc_thd_from_fft(fksig(:,1),mag2sum(:,1),half_spectrum);
                thd_v1 = calc_thd_from_fft(fksig(:,2),mag2sum(:,2),half_spectrum);
                thd_v2 = calc_thd_from_fft(fksig(:,3),mag2sum(:,3),half_spectrum);
            end
            %------------------------------------------------------------------
            % Compute impedance, Z = V/I, I = Visense/Rsense
            zmag_v1 = vpp_v1./(vpp_i/Rsense);
            zmag_v2 = vpp_v2./(vpp_i/Rsense);

            %--------------------------------------------------------------------------
            % Save non-averaged data
            fft_struct(1).fft_dc = fdc;
            fft_struct(1).fft_k1 = fk1;
            fft_struct(1).fft_k2 = fk2;
            fft_struct(1).fft_kk = fkk;
            fft_struct(1).mag2sum = mag2sum;
            fft_struct(1).avgnum = avgnum;
            fft_struct(1).thd = thd;
            fft_struct(1).fft_dc_phase = phfdc;
            fft_struct(1).fft_k1_phase = phfk1;
            fft_struct(1).fft_k2_phase = phfk2;
            fft_struct(1).fft_kk_phase = phfkk;
            fft_struct(1).zmag_v1 = zmag_v1;
            fft_struct(1).zmag_v2 = zmag_v2;
            fft_struct(1).zphase_v1 = zphase_v1;
            fft_struct(1).zphase_v2 = zphase_v2;
            fft_struct(1).vpp_i = vpp_i;
            fft_struct(1).vpp_v1 = vpp_v1;
            fft_struct(1).vpp_v2 = vpp_v2;
            fft_struct(1).vdc_i = vdc_i;
            fft_struct(1).vdc_v1 = vdc_v1;
            fft_struct(1).vdc_v2 = vdc_v2;
            fft_struct(1).fsigs = freqs;
            %------------------------------------------------------------------
            % Save it
            avg_adc_data(n).fft_struct = fft_struct;
            avg_adc_data(n).fsigs = freqs;

            %------------------------------------------------------------------
            % Compute averages and snr
            if nsets > 1
                avg_adc_data(n).fft_dc = mean(fdc);
                avg_adc_data(n).fft_k1 = mean(fk1);
                avg_adc_data(n).fft_k2 = mean(fk2);
                avg_adc_data(n).fft_kk = mean(fkk);
                avg_adc_data(n).mag2sum = mean(mag2sum);
                avg_adc_data(n).thd = mean(thd);
                avg_adc_data(n).fft_dc_phase = mean(phfdc);
                avg_adc_data(n).fft_k1_phase = mean(phfk1);
                avg_adc_data(n).fft_k2_phase = mean(phfk2);
                avg_adc_data(n).fft_kk_phase = mean(phfkk);
                avg_adc_data(n).zmag_v1 = mean(zmag_v1);
                avg_adc_data(n).zmag_v2 = mean(zmag_v2);
                avg_adc_data(n).zphase_v1 = mean(zphase_v1);
                avg_adc_data(n).zphase_v2 = mean(zphase_v2);
                avg_adc_data(n).vpp_i = mean(vpp_i);
                avg_adc_data(n).vpp_v1 = mean(vpp_v1);
                avg_adc_data(n).vpp_v2 = mean(vpp_v2);
                avg_adc_data(n).vdc_i = mean(vdc_i);
                avg_adc_data(n).vdc_v1 = mean(vdc_v1);
                avg_adc_data(n).vdc_v2 = mean(vdc_v2);
            elseif n == 1
                avg_adc_data = fft_struct; % use non-averaged data
            else
                avg_adc_data(n) = fft_struct; % use non-averaged data
            end

            %------------------------------------------------------------------
            % Calculate snr and precision of voltages
            avg_adc_data(n).snr_i = 20*log10(mean(vpp_i)./std(vpp_i));
            avg_adc_data(n).snr_v1 = 20*log10(mean(vpp_v1)./std(vpp_v1));
            avg_adc_data(n).snr_v2 =20*log10(mean(vpp_v2)./std(vpp_v2));
            avg_adc_data(n).precision_i = std(vpp_i);
            avg_adc_data(n).precision_v1 = std(vpp_v1);
            avg_adc_data(n).precision_v2 = std(vpp_v2);

            %------------------------------------------------------------------
            % Calculate SNR = 20log10(mean/stddev)
            avg_adc_data(n).snr_dc = 20*log10(mean(fdc)./std(fdc));
            avg_adc_data(n).snr_k1 = 20*log10(mean(fk1)./std(fk1));
            avg_adc_data(n).snr_k2 = 20*log10(mean(fk2)./std(fk2));
            avg_adc_data(n).snr_kk = 20*log10(mean(fkk)./std(fkk));
            avg_adc_data(n).snr_mag2sum = 20*log10(mean(mag2sum)./std(mag2sum));
            %------------------------------------------------------------------
            % Calculate precision = standard deviation
            avg_adc_data(n).precision_dc = std(fdc);
            avg_adc_data(n).precision_k1 = std(fk1);
            avg_adc_data(n).precision_k2 = std(fk2);
            avg_adc_data(n).precision_kk = std(fkk);
            avg_adc_data(n).precision_mag2sum = std(mag2sum);

            %------------------------------------------------------------------
            % Get mux channels for vs+/- vpu1/2 associated with this set
            mux_chs = [iis(n_ii,1) iis(n_ii,2) vv_pairs(n_vv,1) vv_pairs(n_vv,2)];
            avg_adc_data(n).mux_chs = mux_chs; % Save channel numbers to structs
            iivvs(n_ii,n_vv,:) = mux_chs;


            %--------------------------------------------------------------------------
            vload_vpp = vpp_v1-vpp_v2;
            rload = zmag_v1-zmag_v2;
            [rload_cal, ~, ~] = calibrate_rload(rload,freqs,board_num);


            %--------------------------------------------------------------------------
            % Save data used for extract_plot_variables function
            pltvars(n).vpp_i = vpp_i;
            pltvars(n).vpp_v1 = vpp_v1;
            pltvars(n).vpp_v2 = vpp_v2;
            pltvars(n).thd_i = thd_i;
            pltvars(n).thd_v1 = thd_v1;
            pltvars(n).thd_v2 = thd_v2;
            pltvars(n).snr_i = 20*log10(mean(vpp_i)./std(vpp_i));
            pltvars(n).snr_v1 = 20*log10(mean(vpp_v1)./std(vpp_v1));
            pltvars(n).snr_v2 = 20*log10(mean(vpp_v2)./std(vpp_v2));
            pltvars(n).freqs = freqs;
            pltvars(n).rload = rload;
            pltvars(n).rload_cal = rload_cal;
            pltvars(n).vload_vpp = vload_vpp;
            pltvars(n).avg_adc_data = avg_adc_data;


        end
        %------------------------------------------------------------------
        % Save extracted data
        %------------------------------------------------------------------
        ret_struct(1).adc_data_struct(n_ii,n_vv) = avg_adc_data;
        plt_var_struct(n_ii,n_vv) = pltvars;

        %------------------------------------------------------------------
        % Pull out EIT voltages
        %------------------------------------------------------------------
        if n > 1
            % disp(['ERROR in extract_avg_eit_data(). ' ...
            %     ['Parsed adc_data struct has multiple elements. ' ...
            %     'length(adc_data) =  '] num2str(n) '. Using last set.'])

            % Done by frequency....
            for n = 1:length(adc_data)
                %------------------------------------------------------------------
                % Pull out EIT voltages
                %------------------------------------------------------------------
                Visense(n_ii,n_vv,n) = avg_adc_data(n).vpp_i;
                Vpickup1(n_ii,n_vv,n) = avg_adc_data(n).vpp_v1;
                Vpickup2(n_ii,n_vv,n) = avg_adc_data(n).vpp_v2;

                %------------------------------------------------------------------
                % Save all Vpickup channels in one array
                Vmeas(n_ii,2*n_vv-1,n) = avg_adc_data(n).vpp_v1;
                Vmeas(n_ii,2*n_vv,n) = avg_adc_data(n).vpp_v2;
                %------------------------------------------------------------------
                % Combine measured impedances into single matrix
                Zmag(n_ii,2*n_vv-1,n) = avg_adc_data(n).zmag_v1;
                Zmag(n_ii,2*n_vv,n) = avg_adc_data(n).zmag_v2;
                Zphase(n_ii,2*n_vv-1,n) = avg_adc_data(n).zphase_v1;
                Zphase(n_ii,2*n_vv,n) = avg_adc_data(n).zphase_v2;
            end

        else

            Visense(n_ii,n_vv,:) = avg_adc_data(n).vpp_i;
            Vpickup1(n_ii,n_vv,:) = avg_adc_data(n).vpp_v1;
            Vpickup2(n_ii,n_vv,:) = avg_adc_data(n).vpp_v2;

            %------------------------------------------------------------------
            % Save all Vpickup channels in one array
            Vmeas(n_ii,2*n_vv-1,:) = avg_adc_data(n).vpp_v1;
            Vmeas(n_ii,2*n_vv,:) = avg_adc_data(n).vpp_v2;
            %------------------------------------------------------------------
            % Combine measured impedances into single matrix
            Zmag(n_ii,2*n_vv-1,:) = avg_adc_data(n).zmag_v1;
            Zmag(n_ii,2*n_vv,:) = avg_adc_data(n).zmag_v2;
            Zphase(n_ii,2*n_vv-1,:) = avg_adc_data(n).zphase_v1;
            Zphase(n_ii,2*n_vv,:) = avg_adc_data(n).zphase_v2;
        end
    end
end
%--------------------------------------------------------------------------
% Save extracted data to return struct
%--------------------------------------------------------------------------
% eit_data_struct(1).adc_data_struct = ad_struct;
Isense = Visense/Rsense; % calculate current
[R,X] = pol2cart(Zphase,Zmag);

%--------------------------------------------------------------------------
% Save voltage, current, impedance, and iivvs to return struct
%--------------------------------------------------------------------------
ret_struct(1).Isense = Isense;
ret_struct(1).Visense = Visense;
ret_struct(1).Vpickup1 = Vpickup1;
ret_struct(1).Vpickup2 = Vpickup2;
ret_struct(1).iivv = iivvs;
ret_struct(1).iis = iis;
ret_struct(1).vvs = unique(vv_pairs); % list of vmeas chs
ret_struct(1).f = freqs;
ret_struct(1).Vmeas = Vmeas;
ret_struct(1).Zmag = Zmag;
ret_struct(1).Zphase = Zphase;
ret_struct(1).R = R;
ret_struct(1).X = X;
% ret_struct(1).plt_var_struct = plt_var_struct;

end

