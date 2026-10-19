% =========================================================================
% 光通信用 AWG (Arbitrary Waveform Generator) 波形生成スクリプト
% =========================================================================

clear; close all; clc;

%% 1. 初期化と設定の読み込み
fprintf('--- 1. 設定の読み込み ---\n');
cfg = config.getDefaultConfig();
% 出力先ディレクトリが存在しない場合は作成
if ~isfolder(cfg.io.outputDirectory)
    mkdir(cfg.io.outputDirectory);
end


%% 2. プレアンブル（同期信号）の生成
fprintf('--- 2. プレアンブル波形の生成 ---\n');
% M系列のビット配列を生成
preambleBits = signal.generateMSequence(13); % 例: 次数13
% ビットを通信シンボルに変換
preambleSymbols = signal.bitsToBinarySymbols(preambleBits);
% シンボルをAWG出力用の振幅レベル(int8)にマッピング
preambleSamples = signal.binarySymbolsToInt8Levels(...
    preambleSymbols, ...
    cfg.hw.preambleMinimumInt8, ...
    cfg.hw.preambleMaximumInt8);


%% 3. 画像データの読み込みと前処理
fprintf('--- 3. 画像処理 ---\n');
% 画像読み込み
originalImage = imread(cfg.io.inputImageFile);

% グレースケール画像を量子化
quantizedImage = image.quantizeGrayscale(...
    originalImage, ...
    cfg.image.compressionBits, ...
    0.5); % binaryThreshold = 0.5

% ピクセル配列を1次元に並び替え（設定に応じてM×Nの畳み込み順序またはラスタ順序）
pixelCodes = image.orderPixelCodes(quantizedImage, cfg);


%% 4. ペイロード（データ本体）の波形生成
fprintf('--- 4. ペイロード波形の生成 ---\n');

% 必要に応じてピクセルコードをシリアライズする場合はここで実施
% 例: bits = signal.pixelCodesToBits(pixelCodes, 8, "msb");

% 多値のピクセルシンボルをAWG出力用の振幅レベル(int8)に直接マッピング
payloadSamples = signal.pixelSymbolsToInt8Levels(pixelCodes, cfg);


%% 5. フレーム結合とパディング（アライメント調整）
fprintf('--- 5. フレーム結合とパディング ---\n');
% プレアンブルとペイロードを結合して1フレームを構成
frameSamplesInt8 = [preambleSamples; payloadSamples];

% AWGの要求するアライメント（例: 128サンプルの倍数など）に合わせてパディング
% ※ cfg.hw.alignmentSize が設定ファイルにあると仮定（なければ任意の数字に変更してください）
alignmentSize = 128; 
[paddedSamplesInt8, numPadded] = signal.padSamples(frameSamplesInt8, alignmentSize, 0);

fprintf('追加されたパディングサンプル数: %d\n', numPadded);

% uint8形式（符号なしバイナリ）の波形も作成
% int8 を uint8 に型キャスト（ビットパターンは維持）
paddedSamplesUInt8 = typecast(paddedSamplesInt8, 'uint8');


%% 6. 波形ファイルとメタデータの出力
fprintf('--- 6. ファイル出力 ---\n');
io.exportWaveform(cfg, paddedSamplesInt8, paddedSamplesUInt8);

fprintf('\n==== 全ての処理が完了しました ====\n');