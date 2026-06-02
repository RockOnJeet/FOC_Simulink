%% ===================== INPUTS =====================
Ts = sim_in.local_solver_ts;
Fs = 1/Ts;

t = out.I_ph_6sect.Time(:);
D = out.I_ph_6sect.Data;
%t = out.I_ph_FOC.Time(:);
%D = out.I_ph_FOC.Data;

x = squeeze(D(1,1,:));   % Phase A

%% ===================== FUNDAMENTAL =====================
omega = out.speed.Data;          % rad/s
omega_ss_est = mean(omega(end-1000:end));  % rough steady estimate

P = motor.P;
f0 = (P/(2*pi)) * omega_ss_est;

fprintf('Estimated f0 = %.4f Hz\n', f0);

%% ===================== USER SETTINGS =====================
t_start = 3.5;          % AFTER torque transient settles
num_cycles = 8;         % enough for low frequency

T0 = 1/f0;
t_end = t_start + num_cycles*T0;

idx = (t >= t_start) & (t <= t_end);

t_ss = t(idx);
x_ss = x(idx);

N = numel(x_ss);

if N < 50
    error('Too few samples. Increase simulation time.');
end

%% ===================== WINDOW + FFT =====================
w = hann(N);
Nfft = 2^nextpow2(N);

X = fft(x_ss .* w, Nfft);

P2 = abs(X)/N;
P1 = P2(1:floor(Nfft/2)+1);
P1(2:end-1) = 2*P1(2:end-1);

% Window correction
P1 = P1 / (sum(w)/N);

f = (0:floor(Nfft/2)) * (Fs/Nfft);

%% ===================== FUNDAMENTAL BIN =====================
[~, idx_f0] = min(abs(f - f0));
A1 = P1(idx_f0);

%% ===================== HARMONIC SELECTION =====================
max_harmonic = 15;   % up to 15th harmonic

harm_power = 0;

for k = 2:max_harmonic
    fk = k * f0;
    [~, idx_k] = min(abs(f - fk));
    harm_power = harm_power + P1(idx_k)^2;
end

THD = sqrt(harm_power) / A1;
THD_percent = THD * 100;

fprintf('THD = %.2f %%\n', THD_percent);

%% ===================== SAVE =====================
results.f = f;
results.P1 = P1;
results.f0 = f0;
results.THD = THD_percent;

assignin('base','fft_6sect',results);   % for 6-step
%assignin('base','fft_foc',results);  % for FOC (run separately)

%% ===================== PLOT =====================
figure
plot(f, P1)
xlabel('Frequency (Hz)')
ylabel('Amplitude')
title(sprintf('FFT Spectrum (THD = %.2f%%)', THD_percent))
xlim([0 max_harmonic*f0])
grid on