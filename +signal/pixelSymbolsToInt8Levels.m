function samples = pixelSymbolsToInt8Levels(symbols, cfg)
    % pixelSymbolsToInt8Levels: 多値シンボルをAWG振幅へ
    symbols = uint16(symbols(:));
    maximumPayloadCode = double(2^cfg.image.compressionBits - 1);
    minimumLevel = double(cfg.hw.pixelMinimumInt8);
    maximumLevel = double(cfg.hw.pixelMaximumInt8);
    
    if maximumPayloadCode == 0
        samples = repmat(cfg.hw.pixelMinimumInt8, numel(symbols), 1);
        return;
    end
    normalizedSymbols = double(symbols) / maximumPayloadCode;
    levelValues = round(minimumLevel + normalizedSymbols * (maximumLevel - minimumLevel));
    samples = int8(min(max(levelValues, -128), 127));
end