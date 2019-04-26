%main script
addpath(genpath('(0) Common functions'));

%1) launch_process_REST.m
%processes the REST database
fprintf(1, '\n processes the REST database \n');
run('(A) Process DB files/launch_process_REST.m')

%2) launch_ROI_extract.m
%extract palmprint ROIs and fingers
fprintf(1, '\n extract palmprint ROIs and fingers \n');
run('(B) ROI extraction/launch_ROI_extract.m')

%3) launch_process_rightHandsREST.m
%processes right hands so that fingers have the same order as left hands
fprintf(1, '\n processes right hands so that fingers have the same order as left hands \n');
run('(A) Process DB files/launch_process_rightHandsREST.m')

%4) launch_PCANet_palm_finger_featureFusion.m
%processes right hands so that fingers have the same order as left hands
fprintf(1, '\n processes right hands so that fingers have the same order as left hands \n');
run('(C) PCANet_featureFusion/launch_PCANet_palm_finger_featureFusion.m')

