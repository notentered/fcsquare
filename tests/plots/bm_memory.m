sizes = ["(5,5)" "(10,10)" "(15,15)" "(20,20)" "(25,25)" "(30,30)" "(35,35)" "(40,40)" "(45,45)" "(50,50)"];
Y = 1:numel(sizes);

mem_mb = [ 1.7, 2.6, 2.7, 2.2, 40, 254, 851, 1900, 4200, 6000 ];

nlow_max = [2 27 24 228 243 304 768 4080 10224 8970];

figure('Color','w','Position',[10 10 1400 800]);

xlim_small = [0 1000];
xlim_large = [1000 6500];
idx_small = 1:7;
idx_large = 8:10;


% TOP AXIS (large memory)
axTop = axes('Position',[0.10 0.55 0.85 0.40]);
bTop = barh(axTop, Y(idx_large), mem_mb(idx_large), 'grouped');
grid(axTop,'on');
axTop.FontSize = 20;

yyaxis(axTop,'left')
axTop.YTick = Y(idx_large);
axTop.YTickLabel = sizes(idx_large);
% ylabel(axTop,'Matrix A size','FontSize',20);

yyaxis(axTop,'right')
axTop.YLim  = axTop.YAxis(1).Limits;
axTop.YTick = axTop.YAxis(1).TickValues;
axTop.YTickLabel = nlow_max(idx_large);
% ylabel(axTop,'Max \# lower solutions','FontSize',20);

yyaxis(axTop,'left')
xlabel(axTop,'Allocated memory (MB)','FontSize',20);
title(axTop,'Inverse Problem Resolution max alocated memory','FontSize',20);
xlim(axTop, xlim_large);

axTop.YAxis(2).Color = [0.3 0.3 0.3];

% BOTTOM AXIS (small memory)
axBot = axes('Position',[0.10 0.08 0.85 0.40]);
bBot = barh(axBot, Y(idx_small), mem_mb(idx_small), 'grouped');
grid(axBot,'on');
axBot.FontSize = 20;

yyaxis(axBot,'left')
axBot.YTick = Y(idx_small);
axBot.YTickLabel = sizes(idx_small);
ylabel(axBot,'Matrix A size','FontSize',20);

yyaxis(axBot,'right')
axBot.YLim  = axBot.YAxis(1).Limits;
axBot.YTick = axBot.YAxis(1).TickValues;
axBot.YTickLabel = nlow_max(idx_small);
ylabel(axBot,'Max \# lower solutions','FontSize',20);

yyaxis(axBot,'left')
xlabel(axBot,'Allocated memory (MB)','FontSize',20);
xlim(axBot, xlim_small);

axBot.YAxis(2).Color = [0.3 0.3 0.3];


hold(axTop,'on'); hold(axBot,'on');
ylT = axTop.YLim; ylB = axBot.YLim;
xT = axTop.XLim(2); xB = axBot.XLim(2);
