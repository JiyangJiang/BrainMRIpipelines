function normalize_DARTEL(mod,space,template)

% REF = http://brainmap.wisc.edu/pages/8-Normalizing-DARTEL-Templates-to-MNI-Space

%% normalize_DARTEL(mod,space)
% This script will apply an affine transformation to warped DARTEL images.
% The default option is not to modulate the result. If you wish to apply
% modulation, then use normalize_DARTEL(1).
%
% The output files are not resampled, but instead have modified headers.
% This is done to avoid the effect of smoothing during the resampling
% process.
%
% Output space must be MNI152 or 112RM-SL. Use 112RM-SL for the rhesus
% macaque space. Additional space options require that the code be changed 
% at line 40. MNI152 is the default option. If you want to change the 
% space, you must also specify the modulation option of 0 or 1.
%
% Now will allow the application of an affine transformation to template 
% images without resampling the image. Use normalize_DARTEL(0,'MNI152',1) or  
% normalize_DARTEL(0,'112RM-SL',0) to apply the transform to the template.  
%
% Version 2 -- 1/18/2010
% Created by Donald McLaren (dm10@medicine.wisc.edu)

%% Check for modulation option
if nargin>3
   disp('Too many inputs. This program only takes 1 input.')
   disp('Program will now exit.')
   exit
elseif nargin==0
   disp('Defaulting to no modulation.')
   mod=0;
   space='MNI152';
tempalte=0;
elseif nargin==1
   space='MNI152';
   template=0;
elseif nargin==2;
   template=0;
else
end
if (mod~=0) & (mod~=1)
    disp('Modulation option not set correctly.')
    disp('Program will now exit.')
    return
end

%% Check Space
% To add another space add "| (strcmp(space,'newspace'))" to end of line 40
if (strcmp(space,'MNI152')) | (strcmp(space,'112RM-SL'))
else
    disp('Not a valid space. Space must be MNI152 or 112RM-SL')
    disp('Program will not exit.')
    return
end

%% Select files
PN = spm_select(1,'.*_sn.mat','Select sn.mat file');
PI = spm_select;  %(inf,'nifti','Select images');
sn=load(deblank(PN));

%% Determine affine transform from header
M     = sn.VG(1).mat/(sn.VF(1).mat*sn.Affine);

%% Scaling by inverse of Jacobian determinant, so that
% total tissue volumes are preserved.
scale = 1/abs(det(M(1:3,1:3)));

%% Set up file structures (and change header, etc.)
for i=1:size(PI,1),

   % Read header
   delimit=regexp(deblank(PI(i,:)),'/');
   if isempty(delimit)
      delimit=regexp(deblank(PI(i,:)),'\');
      if isempty(delimit)
          delimit=0;
      end
   end
   filename=deblank(PI(i,delimit(1,end)+1:end));
   filepath=deblank(PI(i,1:delimit(1,end)));
   clear delimit
   
   if strncmp('mwmwr',filename,4)
       if mod==1
         Ni     = nifti(deblank(PI(i,:)));
         if sn.VF.mat~=Ni.mat
             disp('Header already modified.')
             disp('Program will exit.')
             return
         end
       else
         disp('ERROR: You selected files that are modulated after the')
         disp('affine normalization process, but did not specify to')
         disp('modulate the images.')
         disp('Program will now exit.')
         return
       end
   elseif strncmp('wwr',filename,3)
      if mod==0 
         Ni     = nifti(deblank(PI(i,:)));
         if sn.VF.mat~=Ni.mat
             disp('Header already modified.')
             disp('Program will exit.')
             return
         end
      else
         disp('ERROR: You selected files that are not modulated after the')
         disp('affine normalization process, but specified to')
         disp('modulate the images.')
         disp('Program will now exit.')
         return
      end
   elseif strncmp('mwr',filename,3)
      if mod==0 
         [SUCCESS,MESSAGE,MESSAGEID]=copyfile(deblank(PI(i,:)),strcat(filepath,'w',filename),'f');
         if SUCCESS==0
            disp(MESSAGE)
            disp(['Error ID:' MESSAGEID])
            return
         end
         Ni     = nifti(strcat(filepath,'w',filename));
      else
         [SUCCESS,MESSAGE,MESSAGEID]=copyfile(deblank(PI(i,:)),strcat(filepath,'mw',filename),'f');
         if SUCCESS==0
            disp(MESSAGE)
            disp(['Error ID:' MESSAGEID])
            return
         end
         Ni     = nifti(strcat(filepath,'mw',filename));
      end
   elseif strncmp('wr',filename,2)
       if mod==0
         [SUCCESS,MESSAGE,MESSAGEID]=copyfile(deblank(PI(i,:)),strcat(filepath,'w',filename),'f');
         if SUCCESS==0
           disp(MESSAGE)
           disp(['Error ID:' MESSAGEID])
           return
         end
         Ni     = nifti(strcat(filepath,'w',filename));
       else
         disp('ERROR: You can not try to modulate this input image')
         disp('because it appears that it is unmodulated during DARTEL.')
         disp('Program will now exit.')
         return
       end
   elseif template==1;
       mod=0;
       [SUCCESS,MESSAGE,MESSAGEID]=copyfile(deblank(PI(i,:)),strcat(filepath,'w',filename),'f');
       if SUCCESS==0
           disp(MESSAGE)
           disp(['Error ID:' MESSAGEID])
           return
       end
       Ni     = nifti(strcat(filepath,'w',filename));
   else
       disp(' ')
       disp('ERROR')
       disp('You have selected at least one file that is not warped or not modulated and warped')
       disp(['Problem File 1 is: ' deblank(PI(i,:))]) 
       disp('ERROR')
       disp(' ')
       return
   end
 
   %% Pre-multiply existing header by affine transform
   Ni.mat = M*Ni.mat;
   if strcmp(space,'MNI152')
      Ni.mat_intent=space;
   else
      Ni.mat_intent='Aligned';
   end
   Ni.descrip=['DARTEL warped to ' space]; 
   
   %% Change the scalefactor.  This is like doing a "modulation"
   if mod == 1;
       Ni.dat.scl_slope = Ni.dat.scl_slope*scale;
   end
   
   %% Write the header
   create(Ni);
   disp (' ')
   disp(['Finished: ' deblank(PI(i,:))])
   disp (' ')
end

