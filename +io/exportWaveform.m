function exportWaveform(cfg, waveformInt8, waveformUInt8)
    % exportWaveform: AWG波形の書き出しまとめ
    outputInt8Bin  = fullfile(cfg.io.outputDirectory, "tx_m8195a_waveform_i8.bin");
    outputUInt8Bin = fullfile(cfg.io.outputDirectory, "tx_m8195a_waveform_u8.bin");
    
    io.writeBinaryVector(outputInt8Bin, waveformInt8, "int8");
    io.writeBinaryVector(outputUInt8Bin, waveformUInt8, "uint8");
    
    fprintf("DONE. Signed AWG binary : %s\n", outputInt8Bin);
    fprintf("DONE. Unsigned AWG binary: %s\n", outputUInt8Bin);
end