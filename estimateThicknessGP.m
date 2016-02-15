function [thickness, thicknessSD] = estimateThicknessGP(...
        vZ,gpModel,outputSavePath,volID)

% gpModel.hyp = hyp;
% gpModel.meanfunc = meanfunc;
% gpModel.covfunc = covfunc;
% gpModel.likfunc = likfunc;
% gpModel.vX = vX;
% gpModel.vY = vY;

[m,s2] = gp(gpModel.hyp, @infExact, gpModel.meanfunc, gpModel.covfunc,...
        gpModel.likfunc, gpModel.vX, gpModel.vY, vZ);
    
thickness = m;
thicknessSD = sqrt(s2);

% % Plot the infered function and confidence intervals
% figure()
% set(gca, 'FontSize', 24)
% title('Similarity-Distance curve')
% f = [m+2*sqrt(s2); flip(m-2*sqrt(s2),1)];
% fill([vZ; flip(vZ,1)], f, [7 7 7]/8);
% % hold on; plot(vZ, m, 'LineWidth', 2); plot(gpModel.vX, gpModel.vY, '+', 'MarkerSize', 12),
% % % axis([0,1,0,36]),
% % grid on, xlabel('dissimilarity'), ylabel('distance (pixels)'); hold off;
% hold on; plot(vZ, m, 'Color', 'black','LineWidth', 2); 
% plot(gpModel.vX, gpModel.vY, '+r', 'MarkerSize', 5), hold on,
% %plot(vZ, mu, 'Color', 'black','LineWidth', 2);
% axis([0,55,0,25]),
% grid on, xlabel('disimilarity'), ylabel('distance (pixels)'); hold off;
% % save plot
% plotFileName = sprintf('thicknessEstimates_%s.svg',volID);
% plotFileName = fullfile(outputSavePath,plotFileName);
% print(plotFileName,'-dsvg')

