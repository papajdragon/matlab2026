%% run_three_freqs.m
% Runs sine_fft_spectrum.slx at 1, 2 and 5 kHz and plots the three spectra.
% Output: spectrum_1_2_5kHz.png

thisDir = fileparts(mfilename('fullpath'));
addpath(thisDir);
mdl   = 'sine_fft_spectrum';
Fs    = 16000;
freqs = [1000 2000 5000];

load_system(fullfile(thisDir, [mdl '.slx']));
mws = get_param(mdl, 'ModelWorkspace');

spec = cell(size(freqs));
for i = 1:numel(freqs)
    mws.assignin('f_sig', freqs(i));
    sim(mdl);
    h = findobj('Type', 'figure', 'Name', 'FFT spectrum');
    spec{i} = get(findobj(h, 'Type', 'line'), 'YData');   % last 1024-pt frame
end
close(findobj('Type', 'figure', 'Name', 'FFT spectrum'));
close_system(mdl, 0);

N = 2*(numel(spec{1}) - 1);
f = (0:N/2).' * Fs / N;

fig = figure('Name', 'Spectra 1/2/5 kHz', 'Color', 'w', 'Position', [100 100 900 800]);
for i = 1:numel(freqs)
    ax = subplot(numel(freqs), 1, i);
    plot(ax, f, spec{i}(:), 'LineWidth', 1.3, 'Color', [0 0.447 0.741]); grid(ax, 'on');
    set(ax, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.5 0.5 0.5]);
    xlim(ax, [0 Fs/2]); ylim(ax, [-120 10]);
    [pk, k] = max(spec{i});
    ylabel(ax, 'Magnitude [dB]');
    title(ax, sprintf('%g kHz sine  ->  peak %.1f Hz, %.1f dB', freqs(i)/1e3, f(k), pk), 'Color', 'k');
    text(ax, f(k), pk, sprintf('  %.0f Hz', f(k)), 'VerticalAlignment', 'bottom', 'Color', 'k');
end
xlabel(ax, 'Frequency [Hz]');
exportgraphics(fig, fullfile(thisDir, 'spectrum_1_2_5kHz.png'), 'Resolution', 120, 'BackgroundColor', 'w');
