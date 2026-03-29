
% Inputs
Ts = sim_in.local_solver_ts;           % sample time (s)
Fs = 1/Ts;                             % sampling frequency (Hz)
t = out.I_ph_6sect.Time(:);            % time vector (optional, for checks)
D = out.I_ph_6sect.Data;               % size 1x3xN
% t = out.I_ph_FOC.Time(:);            % time vector (optional, for checks)
% D = out.I_ph_FOC.Data;               % size 1x3xN

% Extract channel (change second index for other channels)
x = squeeze(D(1,1,:));                 % column vector length N
N = numel(x);

% Optional: verify uniform sampling
if max(abs(diff(t) - Ts)) > 1e-6*Ts, warning('Nonuniform sampling'); end

% Window and FFT settings
w = hann(N);                           % window to reduce leakage
Nfft = 2^nextpow2(N);                  % zero-pad to next power of two
X = fft(x .* w, Nfft);

% Single-sided amplitude spectrum (compensate for window energy)
P2 = abs(X)/N;
P1 = P2(1:floor(Nfft/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
winGain = sum(w)/N;
P1 = P1 / winGain;                     % correct amplitude reduction by window

% Frequency axis
f = (0:floor(Nfft/2)) * (Fs / Nfft);

% Calculate THD
THD = thd(x, Fs);
THD_percent = 100 * 10^(THD/20);

% Plot
figure
plot(f, P1)
xlabel('Frequency (Hz)')
ylabel('Amplitude')
title(sprintf('Channel 1 - THD: %.2f%%', THD_percent))
xlim([0 Fs/2])
grid on