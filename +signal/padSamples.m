function [paddedSamples, numPadded] = padSamples(samples, multipleSize, padValue)
    % padSamples: 波形サンプル配列が指定された倍数長になるようにパディングを追加する
    
    if nargin < 3
        padValue = 0;
    end
    
    samples = samples(:);
    currentLength = numel(samples);
    remainder = mod(currentLength, multipleSize);
    
    if remainder == 0
        numPadded = 0;
        paddedSamples = samples;
    else
        numPadded = multipleSize - remainder;
        % 元のサンプル配列のデータ型(class)に合わせてパディング配列を作成
        padArray = repmat(cast(padValue, class(samples)), numPadded, 1);
        paddedSamples = [samples; padArray];
    end
end