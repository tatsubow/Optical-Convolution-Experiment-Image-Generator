function orderedPixelCodes = orderPixelCodes(quantizedImage, cfg)
    % orderPixelCodes: 画像のピクセル配列を1次元に並び替える
    
    if cfg.image.useConvolutionReorder
        % 任意のMxNサイズ（1x2, 2x1, 2x2など）の畳み込み順序で並び替え
        orderedPixelCodes = image.reorderForConvolution(...
            quantizedImage, ...
            cfg.image.convKernelHeight, ...
            cfg.image.convKernelWidth);
        return;
    end
    
    % 通常のラスタ順序（行から列へ）
    orderedPixelCodes = reshape(uint8(quantizedImage).', [], 1);
end