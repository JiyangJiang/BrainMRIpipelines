
% validate BIDS
% docker run -ti --rm -v /data_int/jiyang/work/asl/ASL-BIDS/asl_001:/data:ro bids/validator /data

% mkdir /path/to/DatasetRoot/rawdata
% cp -r /data_int/jiyang/work/asl/ASL-BIDS/asl_001/* /path/to/DatasetRoot/rawdata/.
DatasetRoot = '/data_int/jiyang/work/asl/test';
addpath('/data_int/jiyang/software/ExploreASL');
% ExploreASL path = '/data_int/jiyang/software/ExploreASL'

x = ExploreASL (DatasetRoot,[0,0,0],[0,1,0]);