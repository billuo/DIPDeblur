function result = xcorr2_fft(a, b)

result = convnfft(a, rot90(conj(b), 2));

end
