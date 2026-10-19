function [paddedCodes, numPadded] = padPixelCodes(pixelCodes, multipleSize, padValue)
    % padPixelCodes: ピクセルコード配列が指定された倍数長になるようにパディングを追加する
    
    if nargin < 3
        padValue = 0; % デフォルトのパディング値は0
    end
    
    pixelCodes = pixelCodes(:);
    currentLength = numel(pixelCodes);
    remainder = mod(currentLength, multipleSize);
    
    if remainder == 0
        numPadded = 0;
        paddedCodes = pixelCodes;
    else
        numPadded = multipleSize - remainder;
        paddedCodes = [pixelCodes; repmat(uint8(padValue), numPadded, 1)];
    end
end