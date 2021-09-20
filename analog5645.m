%   Pre-emphasis and De-emphasis experiment
close all;
clear all;
clc;

%   reading audio file, with Fs = 48 KHz.
%   plotting signal spectrum

[y,Fs] = audioread('eric.wav');
y = y';
t = linspace(0,length(y)/Fs,length(y)); %time axis
Y = fftshift(fft(y)/Fs); % to get the fourier transform
f = linspace(-Fs/2,Fs/2,length(y)); % frequency axis

figure(1);
subplot(2, 1, 1), plot(t, y, 'r')
title('Audio signal in Time Domain'); xlabel('Time (sec)'); ylabel('Amplitude');
subplot(2,1,2),plot(f,abs(Y), 'b')
title('Audio spectrum in Frequency Domain'); xlabel('frequency(hz)'); ylabel('amplitude');

low_pass_filter = rectpuls(f, 4000);
Yf = low_pass_filter.*Y;

figure(2);
plot(f, abs(Yf), 'b');
title('Audio spectrum in Frequency Domain (After Filter)'); xlabel('frequency(hz)'); ylabel('amplitude');

yf = ifft(ifftshift(Yf))*Fs;

%   Pre-emphasis
% improvement factor I = 13 dB
% cutoff freq fo = 111 Hz
%   frequency response of a filter with differencial equation
% Hpe(f) = 1 + j(f/fo)
j = sqrt(-1);
H_pre= 1+ (j*4000/111); 
%   enhancement of a HIGH frequency signal and attenuation of a LOW frequency signal
Yf = Yf.*H_pre;

%FM modulation
Fc = 100000;
Fs_new = 5*Fc;
y_res = resample(y,Fs_new,Fs);
y_sum = cumsum(y_res);
t = linspace(0,length(y_sum)/Fs_new,length(y_sum));
Kf = 73.1;
y_sent = fmmod(y_res,Fc,Fs_new,Kf*max(y_sum));
Y_mod = fftshift(fft(y_sent)/Fs_new);
f = linspace(-Fs_new/2,Fs_new/2,length(Y_mod));

figure(3);
subplot(2, 1, 1), plot(t, y_sent, 'r')
title('Audio signal in Time Domain'); xlabel('Time (sec)'); ylabel('Amplitude');
subplot(2, 1, 2), plot(f, Y_mod, 'b');
title('Audio spectrum in Frequency Domain'); xlabel('frequency(hz)'); ylabel('amplitude');

%FM demodulation
snr = 30;
y_sent = awgn(y_sent, snr, 'measured');
y_rec = fmdemod(y_sent,Fc,Fs_new,Kf*max(y_sum));
y_rec_res = resample(y_rec,Fs,Fs_new);
t = linspace(0,length(y_rec_res)/Fs,length(y_rec_res));

figure(4);
plot(t, y_rec_res, 'r')
title('received demodulated signal'); xlabel('Time (sec)'); ylabel('Amplitude');

%   De-emphasis
%   improvement factor I = 13 dB
%   cuttoff frequency fo = 92934
%   frequency response of a filter with differencial equation
%   Hde(f) = 1/(1 + j(f/fo))
H_de = 1/(1+(j*Fs/92934));
%   enhancement of a HIGH frequency signal and attenuation of a LOW frequency signal
de_emphasis_signal = y_rec_res.*H_de;

%   final sound test
sound(real(de_emphasis_signal), Fs)
pause(8)