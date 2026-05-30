clc
close all
clear variables
%delete(gcp('nocreate'));
fclose('all');
warning('on', 'all')
warning('off', 'MATLAB:mir_warning_maybe_uninitialized_temporary');
warning('off', 'MATLAB:dispatcher:nameConflict');
warning('off', 'MATLAB:plot:IgnoreImaginaryXYPart');
addpath(genpath('./functions_PCANet'));
% run('./biometricUtil/calcoloROC/vlfeat/vlfeat-0.9.20/toolbox/vl_setup')

%--------------------------------------
%General parameters
plotta = 0;
savefile = 1;
log = 1;
fidLogs{1} = 1; %stdoutput
numCoresFeatExtr = 4;
numCoresKnn = 2; %ridurre all'aumentare del dataset
stepPrint = 100;
%PCA Params
run('./params/paramsPCA.m');

%Only for testing
%Balance samples with standard maximum number of individuals
%and maximum number of samples per individual
%%%%%%%%%%%%%%%%%%%%%
balanceDBs = 0;
maxNumInd = 20;
maxNumSampleInd = 2;
%350 x 5 in minimum common number
%%%%%%%%%%%%%%%%%%%%%


%--------------------------------------
%Dir DBs
dbname_All = { ...
    'REST_hand_database', ...
    };
%roi da fondere
dirProc_All = { ...
    'ROIs_possible', ...
    'ROIs_fing_1', ...
    'ROIs_fing_2', ...
    'ROIs_fing_3', ...
    'ROIs_fing_4', ...
    };
ext = 'jpg';
dirWorkspace = '../images/DB Fusion Palm-Knuckle (test)/';


%--------------------------------------
%Loop on dbs
for db = 1 : numel(dbname_All)
    
    %DB selection
    dbname = dbname_All{db};
    
    %--------------------------------------
    %Folder creation
    %RESULTS: dirs net
    dirResults = ['./Results/' dbname '/'];
    mkdir_pers(dirResults, savefile);
    fileSaveNet = [dirResults 'PCANet_palm.mat'];
    fileSaveTest = [dirResults 'PCANet_test.mat'];
    fileSaveResults = [dirResults 'PCANet_results.mat'];
    %RESULTS: log file
    timeStampRaw = datestr(datetime);
    timeStamp = strrep(timeStampRaw, ':', '-');
    if savefile && log
        logFile = [dirResults dbname '_log_' timeStamp '.txt'];
        fidLog = fopen(logFile, 'w');
        fidLogs{2} = fidLog;
    end %if savefile && log
    
    
    %--------------------------------------
    %LOOP ON ITERATIONS
    %Init
    genuinesNorm_iter = cell(param.numIterations, 1);
    impostorsNorm_iter = cell(param.numIterations, 1);
    fprNorm_iter = cell(param.numIterations, 1);
    fnrNorm_iter = cell(param.numIterations, 1);
    genuinesAggr_iter = cell(param.numIterations, 1);
    impostorsAggr_iter = cell(param.numIterations, 1);
    fprAggr_iter = cell(param.numIterations, 1);
    fnrAggr_iter = cell(param.numIterations, 1);
    accuracy_knnAll = zeros(param.numIterations, 1);
    accuracy_crcAll = 0;
    EERNormIter = zeros(param.numIterations, 1);
    EERAggrIter = zeros(param.numIterations, 1);
    FMR1000NormIter = zeros(param.numIterations, 1);
    FMR1000AggrIter = zeros(param.numIterations, 1);
    %Loop
    for r = 1 : param.numIterations
        
        %init
        ftestPCA_all = cell(numel(dirProc_All), 1);
        numFeatures = cell(numel(dirProc_All), 1);
        
        %--------------------------------------
        %Display
        fprintf_pers(fidLogs, ['Iteration N. ' num2str(r) '\n']);
        
        
        %--------------------------------------
        %File save info
        [C, indC] = strsplit(fileSaveTest, '.');
        fileSaveTest_iter = [indC{1} C{1:end-1} '_iter_' num2str(r) '.mat'];
        [C, indC] = strsplit(fileSaveNet, '.');
        fileSaveNet_iter = [indC{1} C{1:end-1} '_iter_' num2str(r) '.mat'];
        
        
        %--------------------------------------
        %Display
        fprintf_pers(fidLogs, '\n');
        fprintf_pers(fidLogs, '---------------\n');
        fprintf_pers(fidLogs, 'PCANet\n');
        if param.useDynamicNumFilters
            fprintf_pers(fidLogs, 'Automatic number of filters\n');
        end %param.useDynamicNumFilters
        fprintf_pers(fidLogs, [dbname '\n']);
        fprintf_pers(fidLogs, '---------------\n');
        fprintf_pers(fidLogs, '\n');
        
        
        %--------------------------------------
        %DB processing
        %Extract samples
        dirDB = [dirWorkspace dbname '/' dirProc_All{1} '/'];
        files = dir([dirDB '*.' ext]);
        %Check that there is at least one sample for each individual
        files = checkMinNumSamplePerInd(files);
        %Only for testing
        %Balance samples with standard maximum number of individuals
        %and maximum number of samples per individual
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if balanceDBs
            [files, errorBalance] = balanceDB(files, maxNumInd, maxNumSampleInd);
            if errorBalance == -1
                fprintf_pers(fidLogs, 'Not enough samples in database\n');
                break;
            end %if errorBalance == -1
        end %if balanceDBs
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Compute labels
        [labels, numImagesAll] = computeLabels(files);
        %Compute number of individuals
        numInd = numel(unique(labels));
        %compute number of sample per individual
        numSamplePerInd = getNumSamplePerInd(files);
        
        
        %--------------------------------------
        %Display
        fprintf_pers(fidLogs, 'Extracting samples...\n');
        fprintf_pers(fidLogs, ['\t' num2str(numInd) ' individuals\n']);
        fprintf_pers(fidLogs, ['\t' num2str(round(mean(numSamplePerInd))) ' samples per individual, on average\n']);
        fprintf_pers(fidLogs, ['\t' num2str(numImagesAll) ' images in total\n']);
        fprintf_pers(fidLogs, '\n');
        
        
        %--------------------------------------
        %Compute random person-fold indexes
        [indexesFold, allIndexes, indImagesTrain, indImagesTest, numImagesTrain, numImagesTest] = computeIndexesPersonFold(numImagesAll, labels, param);
        %Corresponding labels
        TrnPCALabels = labels(indImagesTrain);
        TestPCALabels = labels(indImagesTest);
        
        
        %--------------------------------------
        %Display output number of images
        fprintf_pers(fidLogs, ['\t' num2str(numImagesTrain) ' images are chosen for PCANet training \n']);
        fprintf_pers(fidLogs, ['\t\t' num2str(numel(unique(TrnPCALabels))) ' individuals for PCANet training \n']);
        fprintf_pers(fidLogs, ['\t' num2str(numImagesTest) ' images are chosen for PCANet testing \n']);
        fprintf_pers(fidLogs, ['\t\t' num2str(numel(unique(TestPCALabels))) ' individuals for PCANet testing \n']);
        
        fprintf_pers(fidLogs, '\n');
        
        %loop on ROI types
        for dirProcInd = 1 : numel(dirProc_All)
            %for dirProcInd = 1
            
            %Close
            close all
            pause(0.2);
            
            %display
            fprintf_pers(fidLogs, [dirProc_All{dirProcInd} '\n']);
        
            %roi selection
            dirDB = [dirWorkspace dbname '/' dirProc_All{dirProcInd} '/'];
            
            
            %--------------------------------------
            %Load images for training
            fprintf_pers(fidLogs, '\tLoading images for training... \n')
            [imagesCellTrain, filenameTrnPCA] = loadImagesTraining(files, dirDB, allIndexes, indImagesTrain, numImagesTrain, param);
            
            %pause
            
            %--------------------------------------
            %PCANet Training
            [ftrain, numFeatures{dirProcInd}, V, PCANet] = trainPCANet(imagesCellTrain, PCANet, fidLogs, param, numCoresFeatExtr);
            fprintf_pers(fidLogs, ['\tNum. of features: ' num2str(numFeatures{dirProcInd}) '\n'])
            %Save
            if savefile
                save(fileSaveNet_iter, 'V', 'PCANet', 'ftrain', 'numFeatures');
            end %if savefile
            %Puliamo
            clear ftrain imagesCellTrain
            
            
            %--------------------------------------
            %PCANet Feature extraction
            fprintf_pers(fidLogs, '\tPCANet feature extraction from test images... \n')
            tic
            [ftestPCA_all{dirProcInd}, filenameTestPCA] = ...
                featExtrPCANet(files, dirDB, V, PCANet, numFeatures{dirProcInd}, numImagesTest, allIndexes, indImagesTest, numCoresFeatExtr, stepPrint, param);
            %numero samples test
            sizeTest = size(ftestPCA_all{dirProcInd}, 2);
            %Time for feature extraction
            timeFeatExtr = toc;
            fprintf_pers(fidLogs, ['\t\tTime for feature extraction: ' num2str(timeFeatExtr) ' s\n']);
            
            fprintf_pers(fidLogs, '\n');
            
        end %for dbproc
        
        
        %--------------------------------------
        %Fusione feature level
        fprintf_pers(fidLogs, '\tFusion feature level... \n')
        fprintf_pers(fidLogs, ['\t\tNormalizzazione: ' param.fusion.type '\n']);
        numFeaturesFusion = sum([numFeatures{:}]);
        ftestPCA_all_Fusion = sparse(zeros(numFeaturesFusion, numImagesTest));
        %ftestPCA_all_Fusion = zeros(numFeaturesFusion, numImagesTest);
        count_ftestPCA_all_Fusion = 1;
        for dirProcInd = 1 : numel(dirProc_All)
            
            %normalizzazione
            if strcmp(param.fusion.type, 'min-max')
                normFeatVec = normalizzaImg(ftestPCA_all{dirProcInd});
            end %if strcmp
            
            %normalizzazione
            if strcmp(param.fusion.type, 'none')
                normFeatVec = ftestPCA_all{dirProcInd};
            end %if strcmp
            
            ftestPCA_all_Fusion(count_ftestPCA_all_Fusion : count_ftestPCA_all_Fusion + numFeatures{dirProcInd} - 1, :) = normFeatVec;
            count_ftestPCA_all_Fusion = count_ftestPCA_all_Fusion + numFeatures{dirProcInd};
        end %for dirProcInd = 1 : numel(dirProc_All)
        
        
        %pause
        
        
        
        %--------------------------------------
        %Save features
        if savefile
            save(fileSaveTest_iter, 'TrnPCALabels', 'TestPCALabels', 'filenameTrnPCA', 'filenameTestPCA', 'ftestPCA_all', 'ftestPCA_all_Fusion');
        end %if savefile
        %Puliamo
        clear imagesCellTest
        
        
        
        %--------------------------------------
        %Verification performance
        %EER computation
        fprintf_pers(fidLogs, 'FPR and FNR computation\n');
        %time
        tic
        [distMatrix, genuineInd, impostorInd, genuinesNorm, impostorsNorm, genuinesAggr, impostorsAggr, fprNorm, fnrNorm, fprAggr, fnrAggr, ...
            EERNorm, EERAggr, FMR1000Norm, FMR1000Aggr] = ...
            computeVerificationPerformance(numImagesTest, ftestPCA_all_Fusion, [], filenameTestPCA, stepPrint, param);
        %put in iteration data struct
        genuinesNorm_iter{r} = genuinesNorm;
        impostorsNorm_iter{r} = impostorsNorm;
        fprNorm_iter{r} = fprNorm;
        fnrNorm_iter{r} = fnrNorm;
        genuinesAggr_iter{r} = genuinesAggr;
        impostorsAggr_iter{r} = impostorsAggr;
        fprAggr_iter{r} = fprAggr;
        fnrAggr_iter{r} = fnrAggr;
        EERNormIter(r) = EERNorm;
        EERAggrIter(r) = EERAggr;
        FMR1000NormIter(r) = FMR1000Norm;
        FMR1000AggrIter(r) = FMR1000Aggr;
        %Time for FPR FNR computation
        timeFPRFNR = toc;
        fprintf_pers(fidLogs, ['\tTime for FPR and FNR computation: ' num2str(timeFPRFNR) ' s\n']);
        fprintf_pers(fidLogs, ['\tEER at iteration n. ' num2str(r) ': %s%%\n'], num2str(EERNormIter(r)*100));
        fprintf_pers(fidLogs, ['\tFMR1000 at iteration n. ' num2str(r) ': %s%%\n'], num2str(FMR1000NormIter(r)*100));
        fprintf_pers(fidLogs, ['\tEER (aggregated over ' num2str(param.numScoreAggregate) ' scores) at iteration n. ' num2str(r) ': %s%%\n'], ...
            num2str(EERAggrIter(r)*100));
        fprintf_pers(fidLogs, ['\tFMR1000 (aggregated over ' num2str(param.numScoreAggregate) ' scores) at iteration n. ' num2str(r) ': %s%%\n'], ...
            num2str(FMR1000AggrIter(r)*100));
        
        
        %--------------------------------------
        %Save verification error measures
        if savefile
            save(fileSaveTest_iter, 'distMatrix', 'genuineInd', 'impostorInd', 'genuinesNorm', 'impostorsNorm', 'genuinesAggr', 'impostorsAggr', ...
                'fprNorm', 'fnrNorm', 'fprAggr', 'fnrAggr', 'EERNorm', 'EERAggr', 'FMR1000Norm', 'FMR1000Aggr', '-append');
        end %if savefile
        %Puliamo
        clear genuines impostors genuinesAggr impostorsAggr
        
        %plot scores for each individual
        if 0
            fsfigure
            boxplot(genuineInd(1:end,:)');
            axis([0 numImagesTest+2 0 max(distMatrix(:))+10])
            title('Plot Genuines for sample');
            xlabel('Sample');
            ylabel('Score (Distance)');
            export_fig([dirResults 'boxPlotGenuineInd_iter_' num2str(r) '.jpg']);
            saveas(gcf, [dirResults 'boxPlotGenuineInd_iter_' num2str(r) '.fig']);
            fsfigure
            boxplot(impostorInd(1:end,:)');
            axis([0 numImagesTest+2 0 max(distMatrix(:))+10])
            title('Plot Impostors for sample');
            xlabel('Sample');
            ylabel('Score (Distance)');
            export_fig([dirResults 'boxPlotImpostorInd_iter_' num2str(r) '.jpg']);
            saveas(gcf, [dirResults 'boxPlotImpostorInd_iter_' num2str(r) '.fig']);
        end %if plotta
        
        
        %--------------------------------------
        %Classification performance
        %1-NN classifier (Nearest Neighbor)
        fprintf_pers(fidLogs, 'Classification... \n');
        %display
        fprintf_pers(fidLogs, ['\tNumber of features: ' num2str(numFeaturesFusion) '\n']);
        fprintf_pers(fidLogs, ['\tNumber of samples: ' num2str(sizeTest) '\n']);
        %time
        tic
        TestPCAOutput = computekNNClassificationPerformance(ftestPCA_all_Fusion, [], TestPCALabels, sizeTest, distMatrix, stepPrint, numCoresKnn, param);
        %Time for feature extraction
        timeClass = toc;
        fprintf_pers(fidLogs, ['\tTime for classification: ' num2str(timeClass) ' s\n']);
        %Confusion matrix
        C_knn = confusionmat(TestPCALabels, TestPCAOutput);
        %Error metrics
        err_knn = getNumberMisclassifiedSamples(C_knn);
        accuracy_knn = (sum(C_knn(:)) - err_knn) / sum(C_knn(:));
        accuracy_knnAll(r) = accuracy_knn;
        %Display
        fprintf_pers(fidLogs, ...
            ['\t\tAccuracy (perc. of correctly classified samples, at iteration n. ' num2str(r) '): %s%%\n'], num2str(accuracy_knn*100));
        
        
        %--------------------------------------
        if param.useCRC_RLS
            %CRC_RLS classification
            fprintf_pers(fidLogs, 'CRC_RLS Classification... \n');
            %display
            fprintf_pers(fidLogs, ['\tNumber of features: ' num2str(numFeaturesFusion) '\n']);
            fprintf_pers(fidLogs, ['\tNumber of samples: ' num2str(sizeTest) '\n']);
            %time
            tic
            clear TestCRCOutput
            TestCRC_RLS_Output = CRC_RLS_classifier(ftestPCA_all_Fusion, TestPCALabels, numImagesTest, stepPrint, param);
            timeClass = toc;
            fprintf_pers(fidLogs, ['\tTime for CRC_RLS classification: ' num2str(timeClass) ' s\n']);
            %Confusion matrix
            C_crc = confusionmat(TestPCALabels, TestCRC_RLS_Output');
            %Error metrics
            err_crc = getNumberMisclassifiedSamples(C_crc);
            accuracy_crc = (sum(C_crc(:)) - err_crc) / sum(C_crc(:));
            accuracy_crcAll = accuracy_crcAll + accuracy_crc;
            %Display
            fprintf_pers(fidLogs, ...
                ['\tCRC_RLS Accuracy (perc. of correctly classified samples, at iteration n. ' num2str(r) '): %s%%\n'], num2str(accuracy_crc*100));
        end %if param.useCRC_RLS
        
        %Puliamo
        clear ftestPCA_all
        
        
        %--------------------------------------
        %Save
        if savefile
            save(fileSaveTest_iter, 'TestPCAOutput', 'C_knn', 'err_knn', 'accuracy_knn', '-append');
            if param.useCRC_RLS
                save(fileSaveTest_iter, 'TestCRC_RLS_Output', 'C_crc', 'err_crc', 'accuracy_crc', '-append');
            end %param.useCRC_RLS
        end %if savefile
        
        
        %--------------------------------------
        %Display progress
        fprintf_pers(fidLogs, '\n');
        
        
    end %for r = 1 : param.numIterations
    
    
    %--------------------------------------
    %Average verification performance
    %EER
    %Normal
    %Compute average fpr e fnr
    EERNormMean = mean(EERNormIter);
    EERNormStd = std(EERNormIter);
    FMR1000NormMean = mean(FMR1000NormIter);
    FMR1000NormStd = std(FMR1000NormIter);
    %Display
    fprintf_pers(fidLogs, ['Mean EER (computed from FPR and FNR, averaged over ' num2str(param.numIterations) ' iterations): %s%%\n'], num2str(EERNormMean*100));
    fprintf_pers(fidLogs, ['Mean FMR1000 (computed from FPR and FNR, averaged over ' num2str(param.numIterations) ' iterations): %s%%\n'], num2str(FMR1000NormMean*100));
    fprintf_pers(fidLogs, ['Std EER (computed from FPR and FNR, averaged over ' num2str(param.numIterations) ' iterations): %s%%\n'], num2str(EERNormStd*100));
    fprintf_pers(fidLogs, ['Std FMR1000 (computed from FPR and FNR, averaged over ' num2str(param.numIterations) ' iterations): %s%%\n'], num2str(FMR1000NormStd*100));
    %Aggr
    EERAggrMean = mean(EERAggrIter);
    EERAggrStd = std(EERAggrIter);
    FMR1000AggrMean = mean(FMR1000AggrIter);
    FMR1000AggrStd = std(FMR1000AggrIter);
    %Compute average fpr e fnr
    %Display
    fprintf_pers(fidLogs, ['Mean EER (computed from FPR and FNR, averaged over ' num2str(param.numIterations) ...
        ' iterations, aggregated over ' num2str(param.numScoreAggregate) ' scores): %s%%\n'], num2str(EERAggrMean*100));
    fprintf_pers(fidLogs, ['Mean FMR1000 (computed from FPR and FNR, averaged over ' num2str(param.numIterations) ...
        ' iterations, aggregated over ' num2str(param.numScoreAggregate) ' scores): %s%%\n'], num2str(FMR1000AggrMean*100));
    fprintf_pers(fidLogs, ['Std EER (computed from FPR and FNR, averaged over ' num2str(param.numIterations) ...
        ' iterations, aggregated over ' num2str(param.numScoreAggregate) ' scores): %s%%\n'], num2str(EERAggrStd*100));
    fprintf_pers(fidLogs, ['Std FMR1000 (computed from FPR and FNR, averaged over ' num2str(param.numIterations) ...
        ' iterations, aggregated over ' num2str(param.numScoreAggregate) ' scores): %s%%\n'], num2str(FMR1000AggrStd*100));
    
    
    %--------------------------------------
    %Average classification performance
    %Error metrics
    accuracy_knnMean = mean(accuracy_knnAll);
    accuracy_knnStd = std(accuracy_knnAll);
    accuracy_crcMean = accuracy_crcAll / param.numIterations;
    %Display
    fprintf_pers(fidLogs, '\n');
    %knn
    fprintf_pers(fidLogs, ...
        ['k-NN Mean accuracy (perc. of correctly classified samples, averaged over ' num2str(param.numIterations) ' iterations): %s%%\n'], ...
        num2str(accuracy_knnMean*100));
    fprintf_pers(fidLogs, ...
        ['k-NN Std accuracy (std of perc. of correctly classified samples, averaged over ' num2str(param.numIterations) ' iterations): %s%%\n'], ...
        num2str(accuracy_knnStd*100));
    if param.useCRC_RLS
        %crc
        fprintf_pers(fidLogs, ...
            ['CRC_RLS Mean accuracy (perc. of correctly classified samples, averaged over ' num2str(param.numIterations) ' iterations): %s%%\n'], ...
            num2str(accuracy_crcMean*100));
    end %param.useCRC_RLS
    
    
    %--------------------------------------
    %Save
    if savefile
        save(fileSaveResults, 'accuracy_knnMean', 'accuracy_knnStd', 'EERNormMean', 'EERNormStd', 'FMR1000NormMean', 'FMR1000NormStd', ...
            'EERAggrMean', 'EERAggrStd', 'FMR1000AggrMean', 'FMR1000AggrStd', 'param');
        if param.useCRC_RLS
            save(fileSaveResults, 'accuracy_crcMean', '-append');
        end %if param.useCRC_RLS
    end %if savefile
    
    
    %--------------------------------------
    %Display progress
    fprintf_pers(fidLogs, '\n');
    
    
    %--------------------------------------
    %Close file log
    if savefile && log
        fclose(fidLog);
    end %if savefile && log
    %         delete(gcp('nocreate'));
    fclose('all');
    
    
    
end %for db



