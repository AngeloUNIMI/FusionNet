function TestCRCOutput = CRC_RLS_classifier(ftestCRCompCode_all, TestCRCompCodeLabels, numImagesTest, stepPrint, param)

TestCRCOutput = zeros(1, numImagesTest);
TestCRCompCodeLabels = parallel.pool.Constant(TestCRCompCodeLabels);
ftestCRCompCode_all = parallel.pool.Constant(ftestCRCompCode_all);
parfor c = 1 : numImagesTest
        
    %get id of current worker
    t = getCurrentTask();
    
    %display progress
    if mod(c, stepPrint) == 0
        fprintf(1, ['\t\tCore ' num2str(t.ID) ': ' num2str(c) ' / ' num2str(numImagesTest) '\n'])
    end %if mod(i, 100) == 0
    
    %probe feature vector
    featVec = ftestCRCompCode_all.Value(:,c);
    
    %remove vector from data
    %(Leave one out validation)
    testLabelsWithoutOne = [TestCRCompCodeLabels.Value(1:c-1); TestCRCompCodeLabels.Value(c+1:end)];
    ftestWithoutOne = [ftestCRCompCode_all.Value(:,1:c-1) ftestCRCompCode_all.Value(:,c+1:end)];
    
    %train transformation
    %with all but current vector
    Ptest = trainP(ftestWithoutOne, numImagesTest-1, param);
    
    %transformation
    featVec_P = Ptest * featVec;
    
    residual = 1e6 * ones(1, max(unique(testLabelsWithoutOne)));
    for classIndex = unique(testLabelsWithoutOne)'
        
        %partialDic = Dic(:, (classIndex-1)*10+1 : classIndex*10);
        %partialX0 = x0((classIndex-1)*10+1:classIndex*10);
        %residual(classIndex) = sum((partialDic*partialX0 - yFeatureVector).^2);
        
        iclass = find(testLabelsWithoutOne == classIndex);
        partialDic = ftestWithoutOne(:, iclass);
        partialX0 = featVec_P(iclass);
        residual(classIndex) = sum((partialDic * partialX0 - featVec).^2);
        
    end %for classIndex = 1:classNOs
    [~, classLabel] = min(residual);
    TestCRCOutput(c) = classLabel;
    
end %for c