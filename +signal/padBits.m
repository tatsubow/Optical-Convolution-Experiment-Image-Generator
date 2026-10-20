function [paddedBits, numPadded] = padBits(bits, multipleSize, padValue)
    % padBits: ビット配列が指定された倍数長になるようにパディングを追加する
    
    if nargin < 3
        padValue = 0; % デフォルトのパディング値は0
    end
    
    bits = bits(:);
    currentLength = numel(bits);
    remainder = mod(currentLength, multipleSize);
    
    if remainder == 0
        numPadded = 0;
        paddedBits = bits;
    else
        numPadded = multipleSize - remainder;
        paddedBits = [bits; repmat(uint8(padValue), numPadded, 1)];
    end
end