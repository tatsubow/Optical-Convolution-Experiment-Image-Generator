function symbols = bitsToBinarySymbols(bits)
    % bitsToBinarySymbols: ビット配列(0/1)を通信シンボル(uint16)として扱うための型変換
    
    symbols = uint16(bits(:));
end