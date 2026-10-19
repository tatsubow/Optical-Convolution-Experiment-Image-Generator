function samples = binarySymbolsToInt8Levels(symbols, lowLevel, highLevel)
    % binarySymbolsToInt8Levels: 2値シンボルをAWG振幅へ
    symbols = uint16(symbols(:));
    samples = repmat(int8(lowLevel), numel(symbols), 1);
    samples(symbols > 0) = int8(highLevel);
end