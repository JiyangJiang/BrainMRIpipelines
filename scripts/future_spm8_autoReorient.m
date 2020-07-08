% modified from http://www.nemotos.net/?p=281
% The reorientation was done through affine registering to avg152T1.nii template
% 
% July 8, 2020   Dr. Jiyang Jiang
%
% varargin{1} = vertical cell array with path to nii. spm_select will
%               be called if no arguments are input.

function future_spm8t_autoReorient(varargin)

if nargin==0
	p = cellstr(spm_select(inf,'image'));
elseif nargin==1
	p = varargin{1};
end

spmDir = which('spm');
spmDir = spmDir(1:end-5);
tmpl = fullfile(spmDir,'canonical','avg152T1.nii');
vg = spm_vol(tmpl);

flags.regtype='rigid';

for i=1:size(p,1)
	f=strtrim(p{i,1});
	spm_smooth(f,'temp.nii',[12 12 12]);
	vf=spm_vol('temp.nii');
	[M,scal] = spm_affreg(vg,vf,flags);
	M3=M(1:3,1:3);
	[u s v]=svd(M3);
	M3=u*v';
	M(1:3,1:3)=M3;
	N=nifti(f);
	N.mat=M*N.mat;
	create(N);
end