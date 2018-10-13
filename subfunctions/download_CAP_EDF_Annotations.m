function download_CAP_EDF_Annotations( varargin )
% This function downloads files from the CAP sleep database
%
% Inputs:
%  varargin    - number of eggs
%       -1st: data_folder to store files
%       -2nd: list of subjects to download
% --
% RBD Sleep Detection Toolbox, version 1.0, November 2018
% Released under the GNU General Public License
%
% Copyright (C) 2018  Navin Cooray
% Institute of Biomedical Engineering
% Department of Engineering Science
% University of Oxford
% navin.cooray@eng.ox.ac.uk
%
%
% Referencing this work
% Navin Cooray, Fernando Andreotti, Christine Lo, Mkael Symmonds, Michele T.M. Hu, & Maarten De % Vos (in review). Detection of REM Sleep Behaviour Disorder by Automated Polysomnography Analysis. Clinical Neurophysiology.
%
% Last updated : 15-10-2018
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Check if any argument is provided, and if it is, there is only one
% otherwise use the current directory to download data in to
if ~isempty(varargin)
    if length(varargin) > 2
        error('Unknown arguments - the function takes in only 2 optional argument')
    else
        download_dir = varargin{1};
        list_of_files = varargin{2};
    end
else
    download_dir = pwd;
end

% Create a destination directory if it doesn't exist
if exist(download_dir, 'dir') ~= 7
    fprintf('WARNING: Download directory does not exist. Creating new directory ...\n\n');
    mkdir(download_dir);
end


%current_dir = pwd;
fprintf('\nDownloading exemplary test data .. \n')

% URL to download data from
annotations_url = 'https://physionet.org/pn6/capslpdb/';
% Regular expression to match
regexp_string = '\[t\](........)\[\\t\]';

% Read list of tests from the source url
list_url = [annotations_url 'RECORDS'];
%edfx_webpage_source = urlread(list_url);
options = weboptions('ContentType','text');
edfx_webpage_source = webread(list_url,options);


test_names = strsplit(edfx_webpage_source,'\n') ;


% Initialise variable for success/failure counts
sc=0;
fc=0;

% Download gender-age info
path_of_file = fullfile([download_dir,'gender-age.xlsx']);
url_of_file = [annotations_url 'gender-age.xlsx'];
fprintf('Downloading: %s for test %s\n', 'gender-age.xlsx');
%[saved_file, status] = urlwrite(url_of_file,path_of_file);
if(~exist(path_of_file,'file'))
    [saved_file] = websave(path_of_file,url_of_file);
    fprintf('File saved: %s ... OK\n', saved_file);
    [num,txt,raw]  = xlsread(path_of_file);    
    M = table(txt(:,1),txt(:,2),num,'VariableNames',{'Pathology','Gender','Age'});
    writetable(M,[download_dir,'gender-age.csv']);
else
    disp(['File existed: ', path_of_file]);
end


% Loop through each test to get files
for i=1:length(list_of_files)
    
    % Add the annotation file specific for each test in the list
    this_test = list_of_files{i};
    folder_name = '';
    hyp_file = [this_test '.txt'];  
    files_to_download = {hyp_file};
    hyp_file = [this_test '.edf'];
    files_to_download = [files_to_download;{hyp_file}];
    
    % Check if test directory exists, create if it doesn't
    test_dir = fullfile(download_dir, folder_name);
    if exist(test_dir,'dir') ~= 7 
        mkdir(download_dir, folder_name);
    end
    

    
    % Download each file from the file_to_download list and display
    % progress and location of saved file
    for f=1:length(files_to_download)
        path_of_file = fullfile(download_dir, files_to_download{f});
        url_of_file = [annotations_url files_to_download{f}];
        fprintf('Downloading: %s for test %s\n', files_to_download{f}, this_test);
        %[saved_file, status] = urlwrite(url_of_file,path_of_file);
        if(~exist(path_of_file,'file'))
            [saved_file] = websave(path_of_file,url_of_file);
            fprintf('File saved: %s ... OK\n', saved_file);
        else
            disp(['File existed: ', path_of_file]);
        end
%         if status
%             fprintf('File saved: %s ... OK\n', saved_file);
%             sc=sc+1;
%         else
%             fprintf('ERROR DOWNLOADING FILE %s for test %s\n', files_to_download{f}, this_test);
%             fc=fc+1;
%         end
    end
end

% Print final summary of downloads
fprintf('\nDownload complete!\n')
% fprintf('\n%d files successfully downloaded ... %d files failed to download\n', sc, fc);

end
