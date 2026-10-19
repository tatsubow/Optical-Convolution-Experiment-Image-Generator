function bits = generateMSequence(order)
    % generateMSequence: プレアンブル用M系列
    switch order
        case 8
            taps = [8 6 5 4];      % x^8 + x^6 + x^5 + x^4 + 1
        case 13
            taps = [13 12 11 8];   % x^13 + x^12 + x^11 + x^8 + 1
        otherwise
            error("Unsupported m-sequence order: %d", order);
    end
    sequenceLength = 2^order - 1;
    registerState = ones(1, order);
    bits = zeros(sequenceLength, 1, 'uint8');
    for sampleIndex = 1:sequenceLength
        bits(sampleIndex) = uint8(registerState(end));
        feedbackBit = 0;
        for tapIndex = 1:numel(taps)
            feedbackBit = xor(feedbackBit, registerState(order - taps(tapIndex) + 1));
        end
        registerState = [feedbackBit, registerState(1:end-1)];
    end
end