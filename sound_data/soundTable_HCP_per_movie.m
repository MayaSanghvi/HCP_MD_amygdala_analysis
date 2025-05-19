%==================================================================
% Script to extract sound�?stats for AMY_HI/LO .mp4 clips for Movie N (set
% below)
% and save results as CSV
%==================================================================
%duncanlab='G:\Group\Duncan-lab';
duncanlab='G:\Duncan-lab';

warning off MATLAB:table:RowsAddedExistingVars

%% 0. Which movie(s) to process?
%moviesToProcess = 1;   % e.g., [1] or [1:4]

movienames={'MOVIE1_CC1','MOVIE1_CC1','MOVIE1_CC1','MOVIE1_CC1'};

for moviesToProcess = 1:4
    
    T2=table();
    
    %% 1. Load the soundTable
    % soundTableFile = fullfile(...
    %     'G:\Group\Duncan-lab\users\dm01\Ashley\HCPmovieData\Post_20140821_version', ...
    %     '7T_MOVIE1_CC1_v2_classifiedSounds.mat' );
    
    
    soundTableFile = fullfile(duncanlab,...
        'users\dm01\Ashley\HCPmovieData\Post_20140821_version', ...
        sprintf('7T_%s_v2_classifiedSounds.mat',movienames{moviesToProcess}) )
    S = load(soundTableFile, 'soundTable','sounds');
    soundTable = S.soundTable;  % must have .TimeStamps (156×2) and .Results (156×1 cell)
    
    %% 2. List only the .mp4 files in the clip folder
    clipDir = fullfile(duncanlab,'Maya\MD_saved\savedClips\Peaks_of_MD2020xYeo17_MD_vs_MD_16-10-4-4sPrePeak');
    files   = dir(fullfile(clipDir, sprintf('Movie%d*.mp4',moviesToProcess) ));
    
    fprintf('Found %d .mp4 files:\n', numel(files));
    for k = 1:numel(files)
        fprintf('  %s\n', files(k).name);
    end
    
    %% 3. Regex to parse only .mp4 names of the form:
    %   Movie<id>_<label>_<label>_<idx>_SIG_<start>to<end>s.mp4
    expr = ['^Movie(\d+)_([^_]+)_[^_]+_\d+_SIG_' ...
        '([0-9\.]+)to([0-9\.]+)s\.mp4$'];
    
    %% 4. Loop through files, filter by movie, extract 6 s segment, and pull overlaps
    outTables = {};
    
    for i = 1:numel(files)
        fname = files(i).name;
         tk = regexp(fname, expr, 'tokens', 'once');

%         if isempty(tk)
%             warning('Skipping (no match): %s', fname);
%             continue;
%         end
%         
%         movieID  = str2double(tk{1});  % token 1
%         if ~ismember(movieID, moviesToProcess)
%             continue;
%         end
        
        amLabel  = tk{2};              % token 2: 'AMY-HI' or 'AMY-LO'
        winStart = str2double(tk{3});  % token 3: e.g. 765.5
        winEnd   = str2double(tk{4});  % token 4: e.g. 777.5
        
        % last 6 s of the window:
        segStart = winStart + 6;
        segEnd   = winEnd;
        
        % find overlapping audio chunks
        ts   = soundTable.TimeStamps;    % [chunkStart, chunkEnd]
        hits = find(ts(:,1) < segEnd & ts(:,2) > segStart);
        
        if isempty(hits)
            warning(' No overlapping chunks for %s', fname);
            continue;
        end
        
        % extract each nested Results table and add metadata
        for j = hits'
            T = soundTable.Results{j};   % N×3 table
            n = height(T);
            
            T.MovieID    = repmat(movieID,   n, 1);
            T.AM_Label   = repmat({amLabel}, n, 1);
            T.SegStart   = repmat(segStart,  n, 1);
            T.SegEnd     = repmat(segEnd,    n, 1);
            T.ChunkStart = repmat(ts(j,1),   n, 1);
            T.ChunkEnd   = repmat(ts(j,2),   n, 1);
            
            outTables{end+1} = T;
            
           temp=sort([segStart, segEnd,  T.ChunkStart(1), T.ChunkEnd(1)]);
            for  n = 1:height(T)
                T2{fname,regexprep(T.Sounds{n},'\W','_')}=T.AverageScores(n) * (temp(3)-temp(2));
            end % next sound in this audio chunk
            
        end % next audio chunk
    end % next clip
    
    %% 5. Concatenate into one big table
    if isempty(outTables)
        warning('No data found for Movie %s.', mat2str(moviesToProcess));
        fullSoundData = table();
    else
        fullSoundData = vertcat(outTables{:});
    end
    
    %% 6. Inspect
    disp(fullSoundData);
    disp(T2)
    
    %% 7. Save to CSV in your desired folder
    outputDir = 'G:\Group\Duncan-lab\Maya\sound_labels';
%     if ~exist(outputDir, 'dir')
%         mkdir(outputDir);
%     end
%     csvName = sprintf('MD_fullSoundData_movie%s.csv', mat2str(moviesToProcess));
%     writetable(fullSoundData, fullfile(outputDir, csvName));
%     fprintf('Saved CSV to %s\n', fullfile(outputDir, csvName));
    
end % next movie