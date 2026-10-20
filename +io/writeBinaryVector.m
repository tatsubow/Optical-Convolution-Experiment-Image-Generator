function writeBinaryVector(filePath, dataVector, precision)
    % writeBinaryVector: バイナリ汎用書き出し
    fileId = fopen(filePath, "w");
    assert(fileId > 0, "Cannot open %s", filePath);
    cleanup = onCleanup(@() fclose(fileId));
    fwrite(fileId, dataVector, precision);
end