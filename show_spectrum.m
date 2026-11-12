function show_spectrum(Ymag, Fs)
%SHOW_SPECTRUM  Live-updating spectrum plot, called from the MATLAB Function block.
%   Ymag : single-sided magnitude in dB (N/2+1 bins)
%   Fs   : sample rate [Hz]
%   The figure is created on the first call and only its data is updated afterwards.

    persistent hAx hLine
    N = 2 * (numel(Ymag) - 1);
    f = (0:N/2).' * Fs / N;

    if isempty(hAx) || ~isgraphics(hAx)
        fig   = figure('Name', 'FFT spectrum', 'NumberTitle', 'off', 'Color', 'w');
        hAx   = axes('Parent', fig);
        hLine = plot(hAx, f, Ymag, 'LineWidth', 1.2);
        grid(hAx, 'on');
        xlim(hAx, [0 Fs/2]); ylim(hAx, [-120 10]);
        xlabel(hAx, 'Frequency [Hz]');
        ylabel(hAx, 'Magnitude [dB]');
    else
        set(hLine, 'YData', Ymag);
    end

    [pk, k] = max(Ymag);
    title(hAx, sprintf('FFT spectrum (N = %d, Fs = %g kHz, Hann)   peak: %.1f Hz, %.1f dB', ...
        N, Fs/1e3, f(k), pk));
    drawnow limitrate;
end
