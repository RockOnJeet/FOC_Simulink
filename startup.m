% startup.m — initialize physical-system params (5010-360KV based)
% SOURCED values marked; GUESS values marked.
clc; close all; clearvars;

%% ---- GUESS values (verify if you get real datasheet) ----
motor.P     = 1;  %7                 % pole pairs (SOURCED)
motor.Rs    = 0.12;              % Ohm (GUESS; reference similar motors ~0.05-0.27 Ohm).
motor.Ld    = 200e-6;            % H (200 uH) (GUESS)
motor.Lq    = 200e-6;            % H (200 uH) (GUESS)
motor.L0    = 160e-6;            % H (160 uH) (GUESS) [Not Used]
motor.B     = 1e-5;              % N*m*s/rad (GUESS) [Damping]

% --- Motor (sourced + guessed) ---
motor.Kv    = 360;               % rpm/V (SOURCED).
motor.mass  = 0.080;             % kg (SOURCED ~80 g).
motor.d     = 0.050;             % mtrs (SOURCED typical for 5010).
motor.angle_Bemf_const = 2*pi/3/motor.P;    % rad (DERIVED) [back-emf constant angle]
motor.rotor_weight_ratio = 0.5;  % rotor/motor weight ratio (GUESS)
motor.back_emf_rpm = 600;        % RPM at which back-emf was measured (GUESS)
motor.V_peak_at_rpm = motor.back_emf_rpm / motor.Kv;    % Max back-emf at above RPM (IDEAL)
motor.J = motor.mass * motor.rotor_weight_ratio * ((motor.d / 2) ^ 2); % kg*m^2 (GUESS) [Moment of Inertia]

assignin('base','motor',motor);

%% --- Converter / DC ---
conv.Vdc    = 12;                % V (your chosen DC bus)
conv.Imax   = 30;                % A (practical limit within vendor ESC 20-40A).
conv.fsw    = 2e4;             % Hz (PWM switching; GUESS/practical)
conv.deadtime = 1e-6;            % s (GUESS) [Not Used]
assignin('base','conv',conv);

%% --- Simulation params ---
sim_in.Ts_pwm  = 1/conv.fsw;        % PWM period
sim_in.Ts_ctrl = 200e-6;            % controller sample (GUESS)
sim_in.t_stop  = 5.0;               % total sim time (GUESS)
sim_in.t_step  = 1.0;               % disturbance time (USER)
sim_in.setpoint = 2.5;              % rad/s (USER)

%% Mode 1 — Detailed switching (high-fidelity)  <<-- recommended for switch-level models
% sim_in.solver_fixed_step = sim.Ts_pwm/10;   % GUESS: 5e-6 (1/10th PWM period) - high res for switching. 
% sim_in.local_solver_ts    = sim.Ts_pwm;     % GUESS: 50e-6 - update Simscape network every PWM period (can be lowered).

%% Mode 2 — Faster / averaged (uncomment to use)
sim_in.solver_fixed_step = sim_in.Ts_pwm;    % GUESS: 50e-6 - one step per PWM cycle (faster). 
sim_in.local_solver_ts    = 100e-6;       % GUESS: 100e-6 - larger local solver step for averaged plant. 

%% Final Setup
assignin('base','sim_in',sim_in);

disp('startup.m: motor/conv/sim parameters loaded into base workspace.');
