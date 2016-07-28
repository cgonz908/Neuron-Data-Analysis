function y = findPeakLag(zScores, nLags)
    %Function searches for peak lag given set of zscores and a limiting lag
    %nLags is the last lag to check for peak, typically 5
    %
    %Written by Christian Gonzalez-Capizzi
    %(christian.gonzalez.capizzi@gmail.com)
    zArray = 0;
    %Start at 2 because the first lag usually doesn't look good
    for zIter = 2:nLags
        zArray = [zArray zScores(zIter)];
    end

    [maxStdValue, peakLagIndex] = max(zArray);

    y = peakLagIndex;
end