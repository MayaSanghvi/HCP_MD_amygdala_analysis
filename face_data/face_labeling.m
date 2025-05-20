
% filterFaceStatsByAMYSegments.m
clearvars; clc;

%% 0. Which movie(s) to process?
moviesToProcess = 1;  % e.g. [1 2] or 1:4

%% 0b. Hard‐code the face‐stats CSV you want as input:
customFaceFile = '7T_MOVIE1_CC1_v2_faces.csv';  % exact name (include .csv)

%% 1. Clips folder & filename regex
clipDir = 'G:\Duncan-lab\Maya\MD_saved\savedClips\Peaks_of_MD2020xYeo17_MD_vs_MD_16-10-4-4sPrePeak';
clips   = dir(fullfile(clipDir,'Movie*.mp4'));
expr = ['^Movie(\d+)_([^_]+)_[^_]+_\d+_SIG_' ...
        '([0-9\.]+)to([0-9\.]+)s\.mp4$'];

%% 2. Face‐stats folder
faceDir = 'G:\Duncan-lab\Maya\HCP_faces';

%% 3. Loop over clips, extract & filter
out = {};
for i = 1:numel(clips)
    fn = clips(i).name;
    tk = regexp(fn, expr, 'tokens', 'once');
    if isempty(tk), continue; end
    
    movieID = str2double(tk{1});
    if ~ismember(movieID, moviesToProcess), continue; end
    
    amLabel = tk{2};            % 'AMY-HI' or 'AMY-LO'
    winStart = str2double(tk{3});  % e.g. 765.5
    
    % Define the 6-second window
    segStart = winStart + 6;
    segStop  = segStart + 6;   % half-open interval [segStart, segStop)
    
    % Load your hard-coded face CSV
    faceFile = fullfile(faceDir, customFaceFile);
    if ~exist(faceFile,'file')
        error('Cannot find face file: %s', faceFile);
    end
    
    Tface = readtable(faceFile);
    % Ensure 'sec' is numeric
    if ~isnumeric(Tface.sec)
        Tface.sec = str2double(string(Tface.sec));
    end
    
    % DEBUG: print the span of seconds in the file
    fprintf('Movie %d face file sec spans [%.1f → %.1f]\n', ...
            movieID, min(Tface.sec), max(Tface.sec));
    
    % Range‐based filter
    mask = (Tface.sec >= segStart) & (Tface.sec < segStop);
    Tf   = Tface(mask,:);
    if isempty(Tf)
        warning('No face rows in [%.1f,%.1f) for Movie %d', ...
                segStart, segStop, movieID);
        continue;
    end
    
    % Annotate
    Tf.MovieID  = repmat(movieID,  height(Tf), 1);
    Tf.AM_Label = repmat({amLabel}, height(Tf), 1);
    
    % Reorder columns: MovieID, AM_Label, then original ones
    Tf = Tf(:, [{'MovieID','AM_Label'}, Tface.Properties.VariableNames]);
    
    out{end+1} = Tf; %#ok<SAGROW>
end

%% 4. Concatenate & write out
if isempty(out)
    warning('No face data extracted for movies %s.', mat2str(moviesToProcess));
    fullFaceStats = table();
else
    fullFaceStats = vertcat(out{:});
end

outputDir = 'G:\Duncan-lab\Maya\faces_labels';
if ~exist(outputDir,'dir')
    mkdir(outputDir);
end

outName = sprintf('MD_faceStats_segments_movie%s.csv', mat2str(moviesToProcess));
writetable(fullFaceStats, fullfile(outputDir,outName));
fprintf('Wrote %d rows to %s\n', height(fullFaceStats), fullfile(outputDir,outName));
