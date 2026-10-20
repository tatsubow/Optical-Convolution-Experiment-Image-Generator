function cfg = getDefaultConfig()
    % getDefaultConfig: TX波形生成用のデフォルト設定構造体を生成する
    
    %% --- IO (入出力) 設定 ---
    cfg.io.outputDirectory = fullfile('data', 'output');
    cfg.io.outputFormat    = "csv"; % 出力形式: "bin", "csv", または "both"
    
    %% --- 画像・ペイロード設定 ---
    cfg.image.numberOfFrames = 1000;         % 送信する総フレーム（画像）数
    cfg.image.shuffleSeed    = 42;           % 抽出時の乱数シード（固定することで再現性を担保）
    
    % 画像の前処理
    cfg.image.doFlipLeftRight  = false;
    cfg.image.doFlipUpDown     = false;
    cfg.image.invertPayloadBits = false;     % "serialNrz" モード専用
    cfg.image.invertPixelCodes  = false;     % "pixelSymbol" モード専用
    
    % 圧縮・ペイロード順序
    cfg.image.compressionBits         = 1;       % 1..8 (2なら4階調)
    cfg.image.binaryThreshold         = 0.5;     % compressionBits == 1 の場合に使用
    cfg.image.payloadBitOrder         = "msb";   % "msb" または "lsb" ("serialNrz"用)
    cfg.image.useConvolutionReorder   = true;    % true: 2x2畳み込み用27行順序, false: 通常のラスタ順序
    cfg.image.convKernelHeight        = 2;       % 縦のウィンドウサイズ（2x1なら2, 1x2なら1）
    cfg.image.convKernelWidth         = 1;       % 横のウィンドウサイズ（2x1なら1, 1x2なら2）
    cfg.image.payloadPadMultipleBits  = 16;      % "serialNrz"用パディング (1でパディングなし)
    cfg.image.payloadPadMultipleSymbols = 1;     % "pixelSymbol"用パディング (1でパディングなし)
    
    %% --- 信号・通信レート設定 ---
    cfg.signal.outputMode = "pixelSymbol";       % "serialNrz" または "pixelSymbol"
    cfg.signal.symbolRateHz = 8e9;               % 受信側のシンボルレート
    cfg.signal.awgSampleRateHz = 64e9;           % M8195Aのサンプルレート
    cfg.signal.requireIntegerSamplesPerSymbol = true;
    
    % samplesPerSymbol の自動計算と検証
    rawSamplesPerSymbol = cfg.signal.awgSampleRateHz / cfg.signal.symbolRateHz;
    cfg.signal.samplesPerSymbol = max(1, round(rawSamplesPerSymbol));
    if cfg.signal.requireIntegerSamplesPerSymbol && abs(rawSamplesPerSymbol - cfg.signal.samplesPerSymbol) > 1e-9
        error('AWGサンプルレート / シンボルレート は整数である必要があります。');
    end

    % プレアンブル設定
    cfg.signal.superPreambleOrder = 13;          % 8191 symbols/bits
    cfg.signal.framePreambleOrder = 8;           % 255 symbols/bits
    cfg.signal.appendFramePreambleDummyBit = true; % ダミービットを追加して256に
    
    %% --- ハードウェア (AWG振幅) 設定 ---
    cfg.hw.lowLevelInt8     = int8(-100);        % 論理0レベル（プレアンブル・NRZ）
    cfg.hw.highLevelInt8    = int8(100);         % 論理1レベル（プレアンブル・NRZ）
    cfg.hw.pixelMinimumInt8 = int8(-100);        % ピクセルシンボルの最低振幅
    cfg.hw.pixelMaximumInt8 = int8(100);         % ピクセルシンボルの最高振幅
    cfg.hw.awgGranularitySamples = 256;          % M8195Aのセグメント粒度
    cfg.hw.padWaveformWithLowLevel = true;
    
end