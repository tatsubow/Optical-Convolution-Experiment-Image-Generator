function bits = pixelCodesToBits(pixelCodes, bitsPerCode, bitOrder)
    % pixelCodesToBits: ピクセルからビットへのシリアライズ
    pixelCodes = uint16(pixelCodes(:));
    numberOfCodes = numel(pixelCodes);
    bits = zeros(numberOfCodes * bitsPerCode, 1, 'uint8');
    writeIndex = 1;
    for codeIndex = 1:numberOfCodes
        pixelCode = pixelCodes(codeIndex);
        for bitIndex = 1:bitsPerCode
            if bitOrder == "msb"
                shiftAmount = bitsPerCode - bitIndex;
            elseif bitOrder == "lsb"
                shiftAmount = bitIndex - 1;
            end
            bits(writeIndex) = uint8(bitand(bitshift(pixelCode, -shiftAmount), 1));
            writeIndex = writeIndex + 1;
        end
    end
end