sizes = ["(5,5)" "(10,10)" "(15,15)" "(20,20)" "(25,25)" "(30,30)" "(35,35)" "(40,40)" "(45,45)" "(50,50)"];
Y = 1:numel(sizes);
t_full_mean = [ ...
    0.0042 0.0020 0.0036 0.0694 0.0907 ...
    0.1782 0.6928 59.3964 228.9673 285.5433 ];
t_full_max = [ ...
    0.0222 0.0102 0.0066 0.4579 0.5386 ...
    1.1205 5.0616 282.0821 1271.9905 1822.2744 ];

nlow_mean = [2.30 6.20 12.60 50.00 47.30 80.60 154.80 1269.90 1916.60 2492.20];
nlow_max  = [2 27 24 228 243 304 768 4080 10224 8970];
data2 = [t_full_mean(:), t_full_max(:)];

figure('Color','w','Position',[10 10 1400 800]);

xlim_small = [0 6];
xlim_large = [50 1900];

idx_small = 1:7;
idx_large = 8:10;


axTop = axes('Position',[0.10 0.55 0.85 0.40]);
bTop = barh(axTop, Y(idx_large), data2(idx_large,:), 'grouped');
grid(axTop,'on');
axTop.FontSize = 20;

yyaxis(axTop,'left')
axTop.YTick = Y(idx_large);
axTop.YTickLabel = sizes(idx_large);

yyaxis(axTop,'right')
axTop.YLim  = axTop.YAxis(1).Limits;
axTop.YTick = axTop.YAxis(1).TickValues;
axTop.YTickLabel = nlow_max(idx_large);


yyaxis(axTop,'left')
xlabel(axTop,'Execution time (seconds)','FontSize',20);
title(axTop,'Inverse Problem Resolution max/mean execution time','FontSize',20);
xlim(axTop, xlim_large);
axTop.YAxis(2).Color = [0.3 0.3 0.3];


axBot = axes('Position',[0.10 0.08 0.85 0.40]);
bBot = barh(axBot, Y(idx_small), data2(idx_small,:), 'grouped');
grid(axBot,'on');

axBot.FontSize = 20;

yyaxis(axBot,'left')
axBot.YTick = Y(idx_small);
axBot.YTickLabel = sizes(idx_small);
ylabel(axBot,'Matrix A size','FontSize',20);

yyaxis(axBot,'right')
axBot.YLim  = axBot.YAxis(1).Limits;
axBot.YTick = axBot.YAxis(1).TickValues;
axBot.YTickLabel = round(nlow_mean(idx_small));
ylabel(axBot,'# lower solutions','FontSize',20);

yyaxis(axBot,'left')
xlabel(axBot,'Execution time (seconds)','FontSize',20);
xlim(axBot, xlim_small);

lgd = legend(axBot, {'Mean time (10 instances / 10)', 'Max time (slowest instance)'}, 'Location','southeast');
lgd.FontSize = 18;

axBot.YAxis(2).Color = [0.3 0.3 0.3];