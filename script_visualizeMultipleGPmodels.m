function script_visualizeMultipleGPmodels()

vZ = linspace(0,120,1000)';
outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/newImages/gpx';
volID = 'squashed';
markers = {'+','o','*','s'};
markerSize = 7;
%% im 1
gpModelPath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/newImages/im01/x/gpModel.mat';
gpModel = importdata(gpModelPath);

[m,s2] = gp(gpModel.hyp, @infExact, gpModel.meanfunc, gpModel.covfunc,...
        gpModel.likfunc, gpModel.vX, gpModel.vY, vZ);

figure()
set(gca(), 'LineStyleOrder',markers)
set(gca, 'FontSize', 30)
% f = [m+2*sqrt(s2); flip(m-2*sqrt(s2),1)];
% fill([vZ; flip(vZ,1)], f, [7 7 7]/8);
% hold on; plot(vZ, m, 'LineWidth', 2); plot(gpModel.vX, gpModel.vY, '+', 'MarkerSize', 12),
% % axis([0,1,0,36]),
% grid on, xlabel('dissimilarity'), ylabel('distance (pixels)'); hold off;
hold on; 
p(1) = plot(vZ, m, 'Color', 'blue','LineWidth', 2); 
p(1) = plot(gpModel.vX, gpModel.vY, '+b', 'MarkerSize', markerSize);
p(1).Marker = markers{1};
%plot(vZ, mu, 'Color', 'black','LineWidth', 2);
axis([0,55,0,25]),
grid on;
xlabel('disimilarity (std. of pix diff.)','FontSize',35,'FontName','Times New Roman','FontWeight','bold');
ylabel('distance (pixels)','FontSize',35,'FontName','Times New Roman','FontWeight','bold');
% hold on

%% im 2
gpModelPath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/newImages/im02/x/gpModel.mat';
gpModel = importdata(gpModelPath);

[m,s2] = gp(gpModel.hyp, @infExact, gpModel.meanfunc, gpModel.covfunc,...
        gpModel.likfunc, gpModel.vX, gpModel.vY, vZ);

% f = [m+2*sqrt(s2); flip(m-2*sqrt(s2),1)];
% fill([vZ; flip(vZ,1)], f, [7 7 7]/8);
% hold on; plot(vZ, m, 'LineWidth', 2); plot(gpModel.vX, gpModel.vY, '+', 'MarkerSize', 12),
% % axis([0,1,0,36]),
% grid on, xlabel('dissimilarity'), ylabel('distance (pixels)'); hold off;
p(2) = plot(vZ, m, 'Color', [1.0,0.4,0.0],'LineWidth', 2); 
p(2) = plot(gpModel.vX, gpModel.vY, '+', 'MarkerSize', markerSize,'MarkerFaceColor',[1.0,0.4,0.0]);
p(2).Marker = markers{2};
%% im 3
gpModelPath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/newImages/im03/x/gpModel.mat';
gpModel = importdata(gpModelPath);

[m,s2] = gp(gpModel.hyp, @infExact, gpModel.meanfunc, gpModel.covfunc,...
        gpModel.likfunc, gpModel.vX, gpModel.vY, vZ);

% f = [m+2*sqrt(s2); flip(m-2*sqrt(s2),1)];
% fill([vZ; flip(vZ,1)], f, [7 7 7]/8);
% hold on; plot(vZ, m, 'LineWidth', 2); plot(gpModel.vX, gpModel.vY, '+', 'MarkerSize', 12),
% % axis([0,1,0,36]),
% grid on, xlabel('dissimilarity'), ylabel('distance (pixels)'); hold off;
p(3) = plot(vZ, m, 'Color', 'red','LineWidth', 2); 
p(3) = plot(gpModel.vX, gpModel.vY, '+r', 'MarkerSize', markerSize);
p(3).Marker = markers{3};
%% im 4
gpModelPath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/newImages/im04/x/gpModel.mat';
gpModel = importdata(gpModelPath);

[m,s2] = gp(gpModel.hyp, @infExact, gpModel.meanfunc, gpModel.covfunc,...
        gpModel.likfunc, gpModel.vX, gpModel.vY, vZ);

% f = [m+2*sqrt(s2); flip(m-2*sqrt(s2),1)];
% fill([vZ; flip(vZ,1)], f, [7 7 7]/8);
% hold on; plot(vZ, m, 'LineWidth', 2); plot(gpModel.vX, gpModel.vY, '+', 'MarkerSize', 12),
% % axis([0,1,0,36]),
% grid on, xlabel('dissimilarity'), ylabel('distance (pixels)'); hold off;
p(4) = plot(vZ, m, 'Color', 'green','LineWidth', 2); 
p(4) = plot(gpModel.vX, gpModel.vY, '+g', 'MarkerSize', markerSize);
p(4).Marker = markers{4};
titleStr = 'X direction';
title(titleStr,'FontSize',35,'FontName','Times New Roman','FontWeight','bold');
box off
hold off
%% markers

% p(1).Marker = markers{1};
% p(2).Marker = markers{2};
% p(3).Marker = markers{3};
% p(4).Marker = markers{4};
legend(p,'\gamma=1','\gamma=1.33','\gamma=2','\gamma=4','Location','southeast');
set(gca,'TickDir','out')