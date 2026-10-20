function orderedPixelCodes = reorderForConvolution(quantizedImage, kernelHeight, kernelWidth)
    % reorderForConvolution: 任意のMxNカーネルでのスライディングウィンドウ順序並び替え
    %
    % Inputs:
    %   quantizedImage - 量子化済みの2次元画像データ
    %   kernelHeight   - スライディングウィンドウの縦サイズ (例: 1, 2)
    %   kernelWidth    - スライディングウィンドウの横サイズ (例: 1, 2)
    
    quantizedImage = uint8(quantizedImage);
    [numberOfRows, numberOfColumns] = size(quantizedImage);
    
    % 画像サイズに対してカーネルが大きすぎないかチェック
    assert(numberOfRows >= kernelHeight, "カーネルの高さが画像の行数を超えています。");
    assert(numberOfColumns >= kernelWidth, "カーネルの幅が画像の列数を超えています。");
    
    % スライド可能な縦・横の回数を計算
    numVerticalWindows = numberOfRows - kernelHeight + 1;
    numHorizontalWindows = numberOfColumns - kernelWidth + 1;
    
    % メモリの事前割り当て（速度向上のため）
    totalPixels = kernelHeight * kernelWidth * numVerticalWindows * numHorizontalWindows;
    orderedPixelCodes = zeros(totalPixels, 1, 'uint8');
    
    writeIndex = 1;
    
    % ウィンドウを上から下へスライド
    for rowIndex = 1:numVerticalWindows
        % ウィンドウを左から右へスライド
        for columnIndex = 1:numHorizontalWindows
            
            % カーネル内のピクセルを順番に抽出 (列優先: column-major)
            for kw = 1:kernelWidth
                for kh = 1:kernelHeight
                    orderedPixelCodes(writeIndex) = quantizedImage(rowIndex + kh - 1, columnIndex + kw - 1);
                    writeIndex = writeIndex + 1;
                end
            end
            
        end
    end
end