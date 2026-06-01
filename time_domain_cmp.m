%% ===================== SIGNALS =====================
t = out.speed.Time(:);
omega = out.speed.Data(:);

i6 = squeeze(out.I_ph_6sect.Data(1,1,:));
% i_foc = squeeze(out.I_ph_FOC.Data(1,1,:));

%% ===================== SETTINGS =====================
t_start = 3.5;                  % steady-state start (for ripple)
t_step  = sim_in.t_step;        % disturbance time
tol     = 0.02;                 % 2% settling band

%% ===================== STEADY-STATE REGION =====================
idx_ss = t >= t_start;

omega_ss = omega(idx_ss);
i6_ss = i6(idx_ss);
% i_foc_ss = i_foc(idx_ss);

%% ===================== SPEED METRICS =====================
omega_mean = mean(omega_ss);

% RMS ripple
omega_ripple_rms = rms(omega_ss - omega_mean);

% Peak-normalized ripple (robust)
omega_peak = max(abs(omega_ss));
omega_ripple_pct = (omega_ripple_rms / omega_peak) * 100;

% Peak-to-peak
omega_pp = max(omega_ss) - min(omega_ss);

%% ===================== SETTLING + OVERSHOOT =====================
x = omega;

upper = omega_mean * (1 + tol);
lower = omega_mean * (1 - tol);

% --- Post-disturbance region ---
idx0 = find(t >= t_step, 1);

t_settle = NaN;

for i = idx0:length(t)
    if all(x(i:end) >= lower & x(i:end) <= upper)
        t_settle = t(i) - t_step;   % settling after disturbance
        break;
    end
end

% Overshoot (use post-step region)
x_post = x(idx0:end);

x_peak = max(x_post);
overshoot = (x_peak - omega_mean)/abs(omega_mean) * 100;

%% ===================== CURRENT RIPPLE =====================

% --- 6-step ---
i6_mean = mean(i6_ss);
i6_ripple = rms(i6_ss - i6_mean);

i6_peak = max(abs(i6_ss));   % FIXED normalization
i6_ripple_pct = (i6_ripple / i6_peak) * 100;

% --- FOC ---
% i_foc_mean = mean(i_foc_ss);
% i_foc_ripple = rms(i_foc_ss - i_foc_mean);

% i_foc_peak = max(abs(i_foc_ss));
% i_foc_ripple_pct = (i_foc_ripple / i_foc_peak) * 100;
i_foc_mean = 0.0;
i_foc_ripple = 0.0;

i_foc_peak = 0.0;
i_foc_ripple_pct = 0.0;

%% ===================== RESULTS TABLE =====================
results = table( ...
    [fft_6sect.THD; fft_foc.THD], ...
    [i6_ripple_pct; i_foc_ripple_pct], ...
    'VariableNames', {'THD_percent','CurrentRipple_percent'}, ...
    'RowNames', {'6-step','FOC'} ...
);

%% ===================== PRINT =====================
fprintf('\n===== SPEED PERFORMANCE =====\n');
fprintf('Settling time (post-step): %.3f s\n', t_settle);
fprintf('Overshoot: %.2f %%\n', overshoot);
fprintf('Speed ripple (RMS): %.4f (%.2f %%)\n', ...
    omega_ripple_rms, omega_ripple_pct);

fprintf('\n===== CURRENT RIPPLE =====\n');
fprintf('6-step ripple: %.4f (%.2f %%)\n', ...
    i6_ripple, i6_ripple_pct);
fprintf('FOC ripple:    %.4f (%.2f %%)\n', ...
    i_foc_ripple, i_foc_ripple_pct);

fprintf('\n===== THD =====\n');
fprintf('6-step THD: %.2f %%\n', fft_6sect.THD);
fprintf('FOC THD:    %.2f %%\n', fft_foc.THD);

disp(' ');
disp('===== SUMMARY TABLE =====');
disp(results);

%% ===================== PLOTS =====================

% --- Current comparison ---
figure
plot(t, i6, 'LineWidth', 1); hold on
% plot(t, i_foc, '--', 'LineWidth', 1);
xlim([t_start t_start+1])
xlabel('Time (s)')
ylabel('Current')
title('Current Comparison (Zoomed)')
legend('6-step','FOC')
grid on

% --- Speed with settling band ---
figure
plot(t, omega); hold on
yline(omega_mean, 'k--', 'SS');
yline(upper, 'r--', '+2%');
yline(lower, 'r--', '-2%');

if ~isnan(t_settle)
    xline(t_settle + t_step, 'g--', 'Settling');
end

xlabel('Time (s)')
ylabel('Speed (rad/s)')
title('Speed Response & Settling')
grid on