function plotDET(FMR, FNMR, curAxes, typScale, optPlot)

narginchk(2,5);
% set the graphics handler
if nargin == 2 
    curAxes = figure;
end
% number of bins for distributions plot
if nargin <= 3
    typScale = 'linear';
end
% color and type of line
if nargin <= 4
    optPlot = 'b-';
end
axes(curAxes);


hold on, grid on, axis square;

set(gca, 'XScale', typScale);
set(gca, 'YScale', typScale);
plot(FMR, FNMR, optPlot);
xlabel('FMR'), ylabel('FNMR');
axis([0. 0.1 0. 0.1]);