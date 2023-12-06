%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Compute averages across parsed demodulated data from main_2023_DAQ_v03
%--------------------------------------------------------------------------
% Inputs: adc_data (struct with parsed demodulated ADC data)
%         navgs (number of averages acquired/to compute)
% Output: avg_demod_data (struct with averaged data)
%--------------------------------------------------------------------------
function [avg_demod_data] = calc_avg_demod_data(adc_data,navgs)
%--------------------------------------------------------------------------
% Default number of averages if not provided/incorrect
if ~exist('navgs','var')
    navgs = size(adc_data(1).fft_dc,1);
end
%--------------------------------------------------------------------------
% Check dimensions
%--------------------------------------------------------------------------
nsets = size(adc_data(1).fft_dc,1)/navgs;    % number of datasets acquired
nadcs = size(adc_data(1).fft_dc,2);
nfreqs = size(adc_data(1).fft_dc,3);    % number of freqs

if nadcs ~= 3
    disp(['Dimensions are incorrect. nADCs = ' num2str(nadcs) ...
        ', nSets = ' num2str(nsets) ', nFreqs = ' num2str(nfreqs)'])
end

% if nsets*nadcs*nfreqs == 3 % single dataset and single freq acquired
%     ndim = 1;
% elseif nsets == 1 || nfreqs == 1
%     ndim = 2;
% else
%     ndim = 3;
% end


%--------------------------------------------------------------------------
% Extract data per ADC, compute average
for n = 1:length(adc_data)        % n is usually 1
    %------------------------------------------------------------------
    % get reference phase
    if nfreqs > 1 % 3rd dimension
        % get ref phase (isense adc)
        phfdc_ref = angle(adc_data(n).fft_dc(:,1,:));
        phfk1_ref = angle(adc_data(n).fft_k1(:,1,:));
        phfk2_ref = angle(adc_data(n).fft_k2(:,1,:));
    else
        phfdc_ref = angle(adc_data(n).fft_dc(:,1));
        phfk1_ref = angle(adc_data(n).fft_k1(:,1));
        phfk2_ref = angle(adc_data(n).fft_k2(:,1));
    end
    %------------------------------------------------------------------
    % % unwrap phase
    % if nfreqs > 1 % 3rd dimension
    %     % get ref phase (isense adc)
    %     phfdc_ref = unwrap(angle(adc_data(n).fft_dc(:,1,:)));
    %     phfk1_ref = unwrap(angle(adc_data(n).fft_k1(:,1,:)));
    %     phfk2_ref = unwrap(angle(adc_data(n).fft_k2(:,1,:)));
    % else
    %     phfdc_ref = unwrap(angle(adc_data(n).fft_dc(:,1)));
    %     phfk1_ref = unwrap(angle(adc_data(n).fft_k1(:,1)));
    %     phfk2_ref = unwrap(angle(adc_data(n).fft_k2(:,1)));
    % end
    % extract data
    for an = 1:nadcs                    % 3 adcs (isense, vpickup1, vpickup2)
        clearvars fdc fk1 fk2 sumF2 avg_n phfdc phfk1 phfk2 dV
        %------------------------------------------------------------------
        % Extract adc data, reshape to 2d (navgs*nsets x nfreqs) or 1d if 1 freq
        if nfreqs > 1
            fdc(:,:) = abs(adc_data(n).fft_dc(:,an,:)); % take magnitude
            fk1(:,:) = abs(adc_data(n).fft_k1(:,an,:)); % take magnitude
            fk2(:,:) = abs(adc_data(n).fft_k2(:,an,:)); % take magnitude
            sumF2(:,:) = adc_data(n).mag2sum(:,an,:);
            avg_n(:,:) = adc_data(n).avgnum(:,an,:);
        else
            fdc = abs(adc_data(n).fft_dc(:,an)); % take magnitude
            fk1 = abs(adc_data(n).fft_k1(:,an)); % take magnitude
            fk2 = abs(adc_data(n).fft_k2(:,an)); % take magnitude
            sumF2 = adc_data(n).mag2sum(:,an);
            avg_n = adc_data(n).avgnum(:,an);
        end

        if an == 1 % use absolute phase (ref phase)
            phfdc(:,:) = phfdc_ref; % get phase
            phfk1(:,:) = phfk1_ref; % get phase
            phfk2(:,:) = phfk2_ref; % get phase
        elseif nfreqs > 1 % use relative phase for vpickup channels
            phfdc(:,:) = angle(adc_data(n).fft_dc(:,an,:)) - phfdc_ref; % get phase
            phfk1(:,:) = angle(adc_data(n).fft_k1(:,an,:)) - phfk1_ref; % get phase
            phfk2(:,:) = angle(adc_data(n).fft_k2(:,an,:)) - phfk2_ref; % get phase
        else
            phfdc(:,:) = angle(adc_data(n).fft_dc(:,an)) - phfdc_ref; % get phase
            phfk1(:,:) = angle(adc_data(n).fft_k1(:,an)) - phfk1_ref; % get phase
            phfk2(:,:) = angle(adc_data(n).fft_k2(:,an)) - phfk2_ref; % get phase
            % elseif nfreqs > 1 % use relative phase for vpickup channels
            %     phfdc(:,:) = unwrap(angle(adc_data(n).fft_dc(:,an,:))) - phfdc_ref; % get phase
            %     phfk1(:,:) = unwrap(angle(adc_data(n).fft_k1(:,an,:))) - phfk1_ref; % get phase
            %     phfk2(:,:) = unwrap(angle(adc_data(n).fft_k2(:,an,:))) - phfk2_ref; % get phase
            % else
            %     phfdc(:,:) = unwrap(angle(adc_data(n).fft_dc(:,an))) - phfdc_ref; % get phase
            %     phfk1(:,:) = unwrap(angle(adc_data(n).fft_k1(:,an))) - phfk1_ref; % get phase
            %     phfk2(:,:) = unwrap(angle(adc_data(n).fft_k2(:,an))) - phfk2_ref; % get phase
        end

        %------------------------------------------------------------------
        % Calculate average - save as nadc x nsets x nfreqs
        if navgs == 1 % no averaging
            if size(fdc,1) > 1 && size(fdc,2) > 1
                fft_dc(an,:,:) = fdc;
                fft_k1(an,:,:) = fk1;
                fft_k2(an,:,:) = fk2;
                fft_dc_phase(an,:,:) = phfdc;
                fft_k1_phase(an,:,:) = phfk1;
                fft_k2_phase(an,:,:) = phfk2;
                mag2sum(an,:,:) = sumF2;
            else
                fft_dc(an,:) = fdc;
                fft_k1(an,:) = fk1;
                fft_k2(an,:) = fk2;
                fft_dc_phase(an,:) = phfdc;
                fft_k1_phase(an,:) = phfk1;
                fft_k2_phase(an,:) = phfk2;
                mag2sum(an,:) = sumF2;
            end
        elseif nfreqs > 1 &&  nsets > 1                 % navgs x nsets x nfreqs

            % Reshape dimension 1 to navg x nsets (dim 2 is already nfreqs)

            fdc = reshape(fdc,navgs,nsets,nfreqs);
            fk1 = reshape(fk1,navgs,nsets,nfreqs);
            fk2 = reshape(fk2,navgs,nsets,nfreqs);
            phfdc = reshape(phfdc,navgs,nsets,nfreqs);
            phfk1 = reshape(phfk1,navgs,nsets,nfreqs);
            phfk2 = reshape(phfk2,navgs,nsets,nfreqs);
            sumF2 = reshape(sumF2,navgs,nsets,nfreqs);
            avg_n = reshape(avg_n,navgs,nsets,nfreqs);

            fft_dc(an,:,:) = mean(fdc);
            fft_k1(an,:,:) = mean(fk1);
            fft_k2(an,:,:) = mean(fk2);
            fft_dc_phase(an,:,:) = mean(phfdc);
            fft_k1_phase(an,:,:) = mean(phfk1);
            fft_k2_phase(an,:,:) = mean(phfk2);
            mag2sum(an,:,:) = mean(sumF2);
        else
            fft_dc(an,:) = mean(fdc);
            fft_k1(an,:) = mean(fk1);
            fft_k2(an,:) = mean(fk2);
            fft_dc_phase(an,:) = mean(phfdc);
            fft_k1_phase(an,:) = mean(phfk1);
            fft_k2_phase(an,:) = mean(phfk2);
            mag2sum(an,:) = mean(sumF2);

        end

        %------------------------------------------------------------------
        % Calculate SNR = 20log10(mean/stddev) - Save as nadc x nfreqs
        %------------------------------------------------------------------
        % Calculate precision = sqrt(sum(xi-mean(x))/N) - Save as nadc x nfreqs
        if nsets > 1
            mean_fft_dc(an,:) = mean(mean(fdc));
            mean_fft_k1(an,:) = mean(mean(fk1));
            mean_fft_k2(an,:) = mean(mean(fk2));
            mean_mag2sum(an,:) = mean(mean(sumF2));
            stdev_fft_dc(an,:) = std(mean(fdc));
            stdev_fft_k1(an,:) = std(mean(fk1));
            stdev_fft_k2(an,:) = std(mean(fk2));
            stdev_mag2sum(an,:) = std(mean(sumF2));
            precision_dc(an,:) = sqrt(sum(abs(mean(fdc)-mean(mean(fdc))).^2)/nsets);
            precision_k1(an,:) = sqrt(sum(abs(mean(fk1)-mean(mean(fk1))).^2)/nsets);
            precision_k2(an,:) = sqrt(sum(abs(mean(fk2)-mean(mean(fk2))).^2)/nsets);
            precision_mag2sum(an,:) = sqrt(sum(abs(mean(sumF2)-mean(mean(sumF2))).^2)/nsets);

        else
            mean_fft_dc(an,:) = mean(fdc);
            mean_fft_k1(an,:) = mean(fk1);
            mean_fft_k2(an,:) = mean(fk2);
            mean_mag2sum(an,:) = mean(sumF2);
            stdev_fft_dc(an,:) = std(fdc);
            stdev_fft_k1(an,:) = std(fk1);
            stdev_fft_k2(an,:) = std(fk2);
            stdev_mag2sum(an,:) = std(sumF2);
            precision_dc(an,:) = sqrt(sum(abs(fdc-mean(fdc)).^2)/nsets);
            precision_k1(an,:) = sqrt(sum(abs(fk1-mean(fk1)).^2)/nsets);
            precision_k2(an,:) = sqrt(sum(abs(fk2-mean(fk2)).^2)/nsets);
            precision_mag2sum(an,:) = sqrt(sum(abs(sumF2-mean(sumF2)).^2)/nsets);

        end
        %--------------------------------------------------------------------------
        % Save non-averaged data
        fft_struct(an).fft_dc = fdc;
        fft_struct(an).fft_k1 = fk1;
        fft_struct(an).fft_k2 = fk2;
        fft_struct(an).mag2sum = sumF2;
        fft_struct(an).fft_dc_phase = phfdc;
        fft_struct(an).fft_k1_phase = phfk1;
        fft_struct(an).fft_k2_phase = phfk2;

    end
    %--------------------------------------------------------------------------
    % Calculate SNR = 20log10(mean/stddev)
    snr_dc = 20*log10(mean_fft_dc./stdev_fft_dc);
    snr_k1 = 20*log10(mean_fft_k1./stdev_fft_k1);
    snr_k2 = 20*log10(mean_fft_k2./stdev_fft_k2);
    snr_mag2sum = 20*log10(mean_mag2sum./stdev_mag2sum);

    %------------------------------------------------------------------
    % Calculate precision = sqrt(sum(xi-mean(x))/N) - Save as nadc x nfreqs
    % ndata = nsets*navgs;
    % precision_dc = sqrt(sum(abs(fft_dc-mean(fft_dc)).^2)/ndata);
    % precision_k1 = sqrt(sum(abs(fft_k1-mean(fft_k1)).^2)/ndata);
    % precision_k2 = sqrt(sum(abs(fft_k2-mean(fft_k2)).^2)/ndata);
    % precision_mag2sum = sqrt(sum(abs(mag2sum-mean(mag2sum)).^2)/ndata);

    %------------------------------------------------------------------
    % Calculate snr and precision of Vload = ||V1|-|V2|| data - Save as nRload x nfreqs
    dV(:,:) = abs(adc_data(n).fft_k1(:,2,:)) - abs(adc_data(n).fft_k1(:,3,:)); % delta V = V1 - V2
    mean_vload = mean(dV);
    stdev_vload = std(dV);
    % if  nsets > 1
    %     dV = reshape(dV,navgs,nsets,nfreqs); % Reshape dimension 1 to navg x nsets
    %     mean_vload = mean(mean(dV));
    %     stdev_vload = std(mean(dV));
    % end
    snr_vload = 20*log10(mean(mean(dV))./std(mean(dV)));


    %--------------------------------------------------------------------------
    % Save data to struct
    avg_demod_data(n) = struct('fft_struct',fft_struct, ...
        'fft_dc',fft_dc,'fft_k1',fft_k1,'fft_k2',fft_k2, ...
        'fft_dc_phase',fft_dc_phase,'fft_k1_phase',fft_k1_phase,'fft_k2_phase',fft_k2_phase, ...
        'mean_fft_dc',mean_fft_dc,'mean_fft_k1',mean_fft_k1,'mean_fft_k2',mean_fft_k2, ...
        'stdev_fft_dc',stdev_fft_dc, 'stdev_fft_k1',stdev_fft_k1, 'stdev_fft_k2',stdev_fft_k2, ...
        'snr_dc',snr_dc,'snr_k1',snr_k1,'snr_k2',snr_k2, ...
        'precision_dc',precision_dc,'precision_k1',precision_k1,'precision_k2',precision_k2, ...
        'mag2sum',mag2sum,'mean_mag2sum',mean_mag2sum,'stdev_mag2sum',stdev_mag2sum, ...
        'snr_mag2sum',snr_mag2sum,'precision_mag2sum',precision_mag2sum, ...
        'mean_vload',mean_vload,'stdev_vload',stdev_vload,'snr_vload',snr_vload,'data_n',avg_n);

end
