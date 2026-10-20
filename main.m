% =========================================================================
% 光通信用 AWG (Arbitrary Waveform Generator) 波形生成スクリプト
% =========================================================================

clear; close all; clc;

%% 1. 初期化と設定の読み込み
fprintf('--- 1. 設定の読み込み ---\n');
cfg = config.getDefaultConfig();

%% 2. MNISTデータの均等抽出 (Task 2で作成した関数)
fprintf('--- 2. MNISTテストデータのロード（層化抽出） ---\n');
[images, transmitLabels, transmitIndices] = io.loadBalancedMNIST(cfg);

%% 3. プレアンブルの生成
fprintf('--- 3. プレアンブル波形の生成 ---\n');
% スーパープレアンブルとフレームプレアンブルのビット生成
superPreambleBits = signal.generateMSequence(cfg.signal.superPreambleOrder);
framePreambleBits = signal.generateMSequence(cfg.signal.framePreambleOrder);
if cfg.signal.appendFramePreambleDummyBit
    framePreambleBits = [framePreambleBits; uint8(0)];
end

% シンボル化
superPreambleSymbols = signal.bitsToBinarySymbols(superPreambleBits);
framePreambleSymbols = signal.bitsToBinarySymbols(framePreambleBits);

% AWG振幅レベルへ変換
superPreambleLevels = signal.binarySymbolsToInt8Levels(superPreambleSymbols, cfg.hw.lowLevelInt8, cfg.hw.highLevelInt8);
framePreambleLevels = signal.binarySymbolsToInt8Levels(framePreambleSymbols, cfg.hw.lowLevelInt8, cfg.hw.highLevelInt8);

% 全体の波形配列（初期状態はスーパープレアンブルを指定回数繰り返したもの）
allSymbolLevelsInt8 = repmat(superPreambleLevels, cfg.signal.preambleRepeats, 1);

%% 4. 画像データ（ペイロード）の波形生成
fprintf('--- 4. ペイロード波形の生成（全 %d フレーム） ---\n', cfg.image.numberOfFrames);

for i = 1:cfg.image.numberOfFrames
    % 1フレーム（1画像）を取り出し
    img = images(:, :, 1, i);

    % 画像パッケージでの処理：量子化と並び替え (M×Nカーネル対応版)
    qImg = image.quantizeGrayscale(img, cfg.image.compressionBits, cfg.image.binaryThreshold);
    orderedCodes = image.orderPixelCodes(qImg, cfg);

    % 出力モードに応じた信号処理
    if cfg.signal.outputMode == "serialNrz"
        payloadBits = signal.pixelCodesToBits(orderedCodes, cfg.image.compressionBits, cfg.image.payloadBitOrder);
        if cfg.image.invertPayloadBits
            payloadBits = uint8(1 - payloadBits);
        end
        payloadBits = signal.padBits(payloadBits, cfg.image.payloadPadMultipleBits);
        payloadSymbols = signal.bitsToBinarySymbols(payloadBits);
        payloadLevels = signal.binarySymbolsToInt8Levels(payloadSymbols, cfg.hw.lowLevelInt8, cfg.hw.highLevelInt8);
        
    elseif cfg.signal.outputMode == "pixelSymbol"
        payloadPixelCodes = orderedCodes;
        if cfg.image.invertPixelCodes
            maxCode = uint8(2^cfg.image.compressionBits - 1);
            payloadPixelCodes = maxCode - payloadPixelCodes;
        end
        payloadPixelCodes = signal.padPixelCodes(payloadPixelCodes, cfg.image.payloadPadMultipleSymbols);
        payloadLevels = signal.pixelSymbolsToInt8Levels(payloadPixelCodes, cfg);
    else
        error("Unsupported outputMode: %s", cfg.signal.outputMode);
    end

    % フレームプレアンブルと画像ペイロードを全体の波形配列に追加
    allSymbolLevelsInt8 = [allSymbolLevelsInt8; framePreambleLevels; payloadLevels];

    % 進捗の表示
    if mod(i, 100) == 0
        fprintf('  built %d / %d frames\n', i, cfg.image.numberOfFrames);
    end
end

%% 5. AWGサンプルレートへのアップサンプリングとパディング
fprintf('--- 5. サンプルレート変換とパディング ---\n');
% シンボルレートからAWGサンプルレートへリピート（Zero-Order Hold）
waveformInt8 = repelem(allSymbolLevelsInt8, cfg.signal.samplesPerSymbol);

% M8195Aのセグメント粒度（256など）に合わせて末尾をパディング
if cfg.hw.padWaveformWithLowLevel
    waveformInt8 = signal.padSamples(waveformInt8, cfg.hw.awgGranularitySamples, cfg.hw.lowLevelInt8);
end

% 符号なし8bit（オフセットバイナリ）形式も作成
waveformUInt8 = uint8(int16(waveformInt8) + 128);

%% 6. 波形ファイル出力
fprintf('--- 6. ファイル出力 ---\n');
io.exportWaveform(cfg, waveformInt8, waveformUInt8);

fprintf('\n==== 全ての処理が完了しました ====\n');