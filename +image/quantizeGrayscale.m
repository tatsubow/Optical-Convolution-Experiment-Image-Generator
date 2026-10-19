function quantizedImage = quantizeGrayscale(grayscaleImage, compressionBits, binaryThreshold)
    % quantizeGrayscale: グレースケール画像を指定したビット深度に量子化する
    
    % 画像を 0.0 〜 1.0 に正規化（念のためのクランプ処理）
    normalizedImage = min(max(double(grayscaleImage), 0.0), 1.0);
    
    % 1-bit（2値化）の場合
    if compressionBits == 1
        quantizedImage = uint8(normalizedImage > binaryThreshold);
        return;
    end
    
    % 多値（2-bit以上）の場合
    maximumCode = 2^compressionBits - 1;
    quantizedImage = uint8(round(normalizedImage * maximumCode));
end