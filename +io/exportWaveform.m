function exportWaveform(cfg, waveformInt8, waveformUInt8)
    % exportWaveform: AWG波形の書き出しまとめ
    
    % 設定が存在しない場合のデフォルト値フォールバック
    if ~isfield(cfg.io, 'outputFormat')
        cfg.io.outputFormat = "bin";
    end
    
    fmt = lower(string(cfg.io.outputFormat));
    
    %% --- BIN 出力 ---
    if fmt == "bin" || fmt == "both"
        outputInt8Bin  = fullfile(cfg.io.outputDirectory, "tx_m8195a_waveform_i8.bin");
        outputUInt8Bin = fullfile(cfg.io.outputDirectory, "tx_m8195a_waveform_u8.bin");
        
        io.writeBinaryVector(outputInt8Bin, waveformInt8, "int8");
        io.writeBinaryVector(outputUInt8Bin, waveformUInt8, "uint8");
        
        fprintf("DONE. Signed AWG binary : %s\n", outputInt8Bin);
        fprintf("DONE. Unsigned AWG binary: %s\n", outputUInt8Bin);
    end
    
    %% --- CSV 出力 ---
    if fmt == "csv" || fmt == "both"
        outputInt8Csv  = fullfile(cfg.io.outputDirectory, "tx_m8195a_waveform_i8.csv");
        outputUInt8Csv = fullfile(cfg.io.outputDirectory, "tx_m8195a_waveform_u8.csv");
        
        % MATLAB標準の writematrix を使用して書き出し
        writematrix(waveformInt8, outputInt8Csv);
        writematrix(waveformUInt8, outputUInt8Csv);
        
        fprintf("DONE. Signed AWG CSV    : %s\n", outputInt8Csv);
        fprintf("DONE. Unsigned AWG CSV  : %s\n", outputUInt8Csv);
    end
end