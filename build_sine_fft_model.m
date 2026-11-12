%% build_sine_fft_model.m
% Builds the Simulink model "sine_fft_spectrum.slx":
%   1 kHz sine wave -> MATLAB Function (1024-pt FFT, Hann window, dB) -> spectrum
% The spectrum window is updated live by show_spectrum.m during Run.
%
% Run:  build_sine_fft_model      (creates the .slx in this folder and runs it)

Fs = 16000;          % sample rate [Hz]  -> bin spacing 15.625 Hz, 1 kHz falls exactly on bin 64
N  = 1024;           % FFT length
Ts = 1/Fs;

thisDir = fileparts(mfilename('fullpath'));
mdl     = 'sine_fft_spectrum';
mdlFile = fullfile(thisDir, [mdl '.slx']);

if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);

set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'FixedStepDiscrete', ...
    'FixedStep', sprintf('%.10g', Ts), 'StopTime', '2');

% Sine frequency lives in the model workspace: f_sig [Hz] (1000, 2000 or 5000 all work)
% Change it in Model Explorer > Model Workspace, or with:
%   mws = get_param('sine_fft_spectrum','ModelWorkspace'); mws.assignin('f_sig', 5000);
fSig = 1000;
mws = get_param(mdl, 'ModelWorkspace');
mws.assignin('f_sig', fSig);

% Make show_spectrum.m findable when the model is opened from any folder
set_param(mdl, 'PreLoadFcn', sprintf('addpath(''%s'');', thisDir));

% ---- 1 kHz sine source ----------------------------------------------------
sineP = [mdl '/Sine 1kHz'];
add_block('simulink/Sources/Sine Wave', sineP, 'Position', [40 80 90 120]);
set_param(sineP, 'Amplitude', '1', 'Bias', '0', ...
    'Frequency', '2*pi*f_sig', 'Phase', '0', 'SampleTime', sprintf('%.10g', Ts));

% ---- FFT as MATLAB Function block -----------------------------------------
fftP = [mdl '/FFT Spectrum'];
add_block('simulink/User-Defined Functions/MATLAB Function', fftP, 'Position', [170 65 300 135]);

fftCode = [ ...
'function Y = fft_spectrum(u)'                                                  newline ...
'% Sliding 1024-sample buffer; a new spectrum is computed every N samples.'     newline ...
'% Y: single-sided magnitude in dB (513 bins), 1 V sine peak -> 0 dB.'          newline ...
'coder.extrinsic(''show_spectrum'');   % plot runs as plain MATLAB during simulation' newline ...
'N = 1024;'                                                                     newline ...
'persistent buf cnt Ymag w'                                                     newline ...
'if isempty(buf)'                                                               newline ...
'    buf  = zeros(N,1);'                                                        newline ...
'    cnt  = 0;'                                                                 newline ...
'    Ymag = -200*ones(N/2+1,1);'                                                newline ...
'    w    = 0.5 - 0.5*cos(2*pi*(0:N-1)''/N);     % periodic Hann window'        newline ...
'end'                                                                           newline ...
'buf = [buf(2:end); u];'                                                        newline ...
'cnt = cnt + 1;'                                                                newline ...
'if cnt >= N'                                                                   newline ...
'    cnt = 0;'                                                                  newline ...
'    X   = fft(buf .* w);'                                                      newline ...
'    Ymag = 20*log10(abs(X(1:N/2+1)) * 2 / sum(w) + eps);'                      newline ...
'    show_spectrum(Ymag, 16000);          % live plot, once per FFT frame'      newline ...
'end'                                                                           newline ...
'Y = Ymag;'                                                                     newline ...
'end'                                                                           newline];

rt    = sfroot;
chart = rt.find('-isa', 'Stateflow.EMChart', 'Path', fftP);
chart.Script = fftCode;

% Declare the input / output of the MATLAB Function block explicitly
uD = chart.find('-isa', 'Stateflow.Data', 'Name', 'u');
if isempty(uD), uD = Stateflow.Data(chart); uD.Name = 'u'; end
uD.Scope = 'Input';  uD.DataType = 'double';  uD.Props.Array.Size = '1';

yD = chart.find('-isa', 'Stateflow.Data', 'Name', 'Y');
if isempty(yD), yD = Stateflow.Data(chart); yD.Name = 'Y'; end
yD.Scope = 'Output'; yD.DataType = 'double';  yD.Props.Array.Size = sprintf('[%d 1]', N/2+1);

% ---- Sinks ----------------------------------------------------------------
scopeP = [mdl '/Scope (time)'];
add_block('simulink/Sinks/Scope', scopeP, 'Position', [370 70 400 100]);
set_param(scopeP, 'NumInputPorts', '1');

% ---- Wiring ---------------------------------------------------------------
add_line(mdl, 'Sine 1kHz/1',    'Scope (time)/1');
add_line(mdl, 'Sine 1kHz/1',    'FFT Spectrum/1');

save_system(mdl, mdlFile);
fprintf('Model saved: %s\n', mdlFile);

% ---- Run ------------------------------------------------------------------
sim(mdl);
