%
% DESCRIPTION:
%   To gunzip (uncompress) image
%
% INPUT:
%   inputImg = path to input image that will be uncompressed
%   varargin{1} = path to output (optional)
%   varargin{2} = 'FSL' -- use fslchfiletype
%
% USAGE:
%   bmp_misc_gunzipNiiMain (inputImg, pathToOutput)
%   bmp_misc_gunzipNiiMain (inputImg)
%

function bmp_misc_gunzipNiiMain (inputImg, varargin)

    % get scripts folder
    [scriptsFolder,~,~] = fileparts(which([mfilename '.m']));

    if nargin > 3
        error ('More arguments than expected. Usage: bmp_misc_gunzipNiiMain(inputImg) or bmp_misc_gunzipNiiMain(inputImg,outputImg).\n');
    end
    
    [parentFolder,filename,ext] = fileparts (inputImg);
    
    if nargin == 1
        if strcmpi(ext,'.gz')
            if exist ([parentFolder '/' filename], 'file') == 2
                system (['rm -f ' parentFolder '/' filename]);
            end
            system (['gunzip ' inputImg]);
        end
        
    elseif nargin == 2
        if strcmpi(ext,'.gz')
            if exist ([parentFolder '/' filename], 'file') == 2
                system (['rm -f ' parentFolder '/' filename]);
            end
            system (['gunzip ' inputImg]);
            
            if ~strcmpi (parentFolder, varargin{1})
                system (['mv ' parentFolder '/' filename ' ' varargin{1} '/.']);
            end
            
        elseif strcmpi(ext,'.nii') && ~strcmpi(inputImg, varargin{1})
            fprintf (['Warning: ' inputImg 'is not gzipped, but inputImg and outputImg are not identical. Therefore, inputImg is (moved and) renamed to outputImg.\n']);
            system (['mv ' parentFolder '/' filename ' ' varargin{1}]);
        end
        
    elseif nargin == 3 && strcmp (varargin{2}, 'FSL')
        if strcmpi(ext,'.gz')
            if exist ([parentFolder '/' filename], 'file') == 2
                system (['rm -f ' parentFolder '/' filename]);
            end
            system ([scriptsFolder '/bmp_misc_gunzipNiiWithFsl.sh ' inputImg]);
            
            if ~strcmpi (parentFolder, varargin{1})
                system (['mv ' parentFolder '/' filename ' ' varargin{1} '/.']);
            end
            
        elseif strcmpi(ext,'.nii') && ~strcmpi(inputImg, varargin{1})
            fprintf (['Warning: ' inputImg 'is not gzipped, but inputImg and outputImg are not identical. Therefore, inputImg is (moved and) renamed to outputImg.\n']);
            system (['mv ' parentFolder '/' filename ' ' varargin{1}]);
        end
    end