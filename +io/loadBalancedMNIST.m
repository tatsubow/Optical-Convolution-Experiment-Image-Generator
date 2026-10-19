function [images, labels, originalIndices] = loadBalancedMNIST(cfg)
    % loadBalancedMNIST: MNISTデータから0〜9を均等に抽出し、再現性を担保する
    %
    % Inputs:
    %   cfg - 設定構造体 (+config/getDefaultConfig.m で生成したもの)
    % Outputs:
    %   images          - 抽出された画像データ (28x28x1xN)
    %   labels          - 抽出された画像のラベル (Nx1, uint8)
    %   originalIndices - 元のデータセットにおけるインデックス (Nx1)

    % 1. 乱数シードを固定し、実行ごとの「完全な再現性」を確保
    rng(cfg.image.shuffleSeed);

    % 2. MNISTテストデータの読み込み
    % XTest: 28x28x1x10000, YTest: 10000x1 categorical
    [XTest, YTest] = digitTest4DArrayData;
    
    numTotalFrames = cfg.image.numberOfFrames;
    numClasses = 10;
    
    % 1クラス（各数字）あたりの基本抽出枚数を計算
    framesPerClass = floor(numTotalFrames / numClasses);
    remainder = numTotalFrames - (framesPerClass * numClasses);
    
    selectedIndices = zeros(framesPerClass * numClasses, 1);
    idxCounter = 1;
    
    % 3. 0〜9の各数字を均等に抽出（層化抽出）
    for digit = 0:9
        % 対象ラベルのインデックスを全て取得
        digitIndices = find(YTest == categorical(digit));
        
        % インデックスをランダムにシャッフル
        shuffledIndices = digitIndices(randperm(length(digitIndices)));
        
        % 必要な枚数だけ取得
        startIdx = idxCounter;
        endIdx = idxCounter + framesPerClass - 1;
        selectedIndices(startIdx:endIdx) = shuffledIndices(1:framesPerClass);
        idxCounter = idxCounter + framesPerClass;
    end
    
    % 4. 端数がある場合（例: 1005枚指定）の補充処理
    if remainder > 0
        allIndices = (1:length(YTest))';
        remainingIndices = setdiff(allIndices, selectedIndices);
        remainingShuffled = remainingIndices(randperm(length(remainingIndices)));
        selectedIndices = [selectedIndices; remainingShuffled(1:remainder)];
    end
    
    % 5. 各数字が塊（0が100枚連続するなど）にならないよう、全体をもう一度シャッフル
    finalOrder = randperm(length(selectedIndices));
    transmitIndices = selectedIndices(finalOrder);
    
    % 6. 最終的なデータを出力変数に格納
    images = XTest(:, :, 1, transmitIndices);
    labels = uint8(str2double(string(YTest(transmitIndices))));
    originalIndices = transmitIndices;
end