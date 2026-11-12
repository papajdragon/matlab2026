# Simulink: sine wave -> FFT spectrum

A Simulink model that generates a sine wave (1 kHz, 2 kHz or 5 kHz), computes a
1024-point Hann-windowed FFT and shows the magnitude spectrum (dB) live while the
model runs. No DSP System Toolbox needed (the FFT is a MATLAB Function block).

| File | Purpose |
|---|---|
| `sine_fft_spectrum.slx` | The model. Open it and press **Run**. |
| `build_sine_fft_model.m` | Script that regenerates the model and runs it. |
| `show_spectrum.m` | Live spectrum plot, called from the FFT block once per frame. |
| `spectrum_1kHz.png` | Example result (1 kHz). |

## Usage

Open `sine_fft_spectrum.slx` and press Run (2 s). The time-domain sine appears in
the Scope, the spectrum in a separate window.

Signal frequency is the model-workspace variable `f_sig` [Hz]:

```matlab
mws = get_param('sine_fft_spectrum','ModelWorkspace');
mws.assignin('f_sig', 5000);   % 1000, 2000 or 5000
sim('sine_fft_spectrum');
```

## Parameters

- Sample rate 16 kHz, FFT length 1024 -> bin spacing 15.625 Hz, so 1, 2 and 5 kHz
  fall exactly on bins 64, 128 and 320.
- A 1 V sine peaks at 0 dB.

Tested with MATLAB R2026b.
