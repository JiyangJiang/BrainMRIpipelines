% read data
table = readtable ('OW4_WMH_wholeBrain_2018_2019.xlsx');

data2018 = table2array(table (:,2));
data2019 = table2array(table (:,3));

% calculate pearson correlation
corr (data2018, data2019)

% scatter plot
scatter (data2018, data2019, 25, 'blue', 'filled')