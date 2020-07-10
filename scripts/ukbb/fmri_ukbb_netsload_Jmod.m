function [ts] = nets_load(infile,tr,varnorm,varargin);

Nruns=1;
if nargin>3
  Nruns=varargin{1};
end
ts.NtimepointsPerSubject=0;
if nargin>4
  ts.NtimepointsPerSubject=varargin{2};
end

startdir=pwd;
% cd(indir);

d=dir(infile);
cd (d(1).folder);
Nsubjects=size(d,1);
TS=[];
index = 1;
for i=1:Nsubjects
  grotALL=load(d(i).name);  gn=size(grotALL,1); GN=gn;
  grotALL=load(d(i).name);  gn=size(grotALL,1); GN=gn; gd=size(grotALL, 2);

  if i==1
    if ts.NtimepointsPerSubject==0
      ts.NtimepointsPerSubject=gn;
      TS=nan(Nsubjects * gn, gd);
    end
  end
  if gn < ts.NtimepointsPerSubject
    disp('Error: not all subjects have enough timepoints!');
  end
  gn=ts.NtimepointsPerSubject/Nruns; GN=GN/Nruns;

  for ii=1:Nruns
    grot=grotALL((ii-1)*GN+1:((ii-1)*GN+gn),:);
    grot=grot-repmat(mean(grot),size(grot,1),1); % demean
    if varnorm==1
      grot=grot/std(grot(:)); % normalise whole subject stddev
    elseif varnorm==2
      grot=grot ./ repmat(std(grot),size(grot,1),1); % normalise each separate timeseries from each subject
    end
    %TS=[TS; grot];
    len = size(grot, 1);
    TS(index:(index + len - 1), :) = grot;
    index = index + len;
  end
end

ts.ts=TS;
ts.tr=tr;
ts.Nsubjects=Nsubjects*Nruns;
ts.Nnodes=size(TS,2);
ts.NnodesOrig=ts.Nnodes;
ts.Ntimepoints=size(TS,1);
ts.NtimepointsPerSubject=ts.NtimepointsPerSubject/Nruns;
ts.DD=1:ts.Nnodes;
ts.UNK=[];

cd(startdir);