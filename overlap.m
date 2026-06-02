f1 = fft_6sect.f;
P1_1 = fft_6sect.P1;

f2 = fft_foc.f;
P1_2 = fft_foc.P1;

figure
plot(f1, P1_1, 'LineWidth', 1.5); hold on
plot(f2, P1_2, '--', 'LineWidth', 1.5);

xlabel('Frequency (Hz)')
ylabel('Amplitude')

legend( ...
    sprintf('6-step (THD = %.2f%%)', fft_6sect.THD), ...
    sprintf('FOC (THD = %.2f%%)', fft_foc.THD) ...
)

xlim([0 15*fft_6sect.f0])
grid on
title('THD Comparison: Commutation Methods')