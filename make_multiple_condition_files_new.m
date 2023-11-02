%This code will parse over output files "run1" "run2" "run3" .azk
%It will find the subject ID in the output and create a "Multiple
%Conditions" .mat file of conditions onsets and durations to be used in the 1st level analysis in SPM

clear all 

% Specify the directory containing AZK files
azk_directory = '/home/batiah/dyslexia_morphology_thesis/experiment_logs_allruns';

% List of AZK files in the current directory
azk_files = dir(fullfile(azk_directory, '*.azk'));  % Use fullfile to specify the full path

% map typos to corrected subject code
subject_mapping = containers.Map({
    'subject 17', 'TAMA9561', 'HAAM1204', 'NOEP4037', 'ASMA7669'}, {
    'MAKA7424', 'TAKA9561', 'AGAM1204' , 'NOAP4037', 'OSMA7669'
});

% map subject codes to serial code
serial_mapping = containers.Map({
    'MOKE2256', 'NASH7723', 'SODI9399', 'TAKA9561', 'YACO9137', 'RORE4846', 'RAHA6432', 'SHMI3336', 'SAOD0525', 'TEBI3421', 'YOBU3279', 'MAKA7424', 'ROLE7127', 'SAKA4051', 'ALHA4472', 'OSMA7669', 'LIDO2337', 'YOAM4335', 'DABR1519', 'NOFL8002', 'ADFI6088', 'IDGA3388', 'RAPO4209', 'LISH1744', 'AGAM1204', 'BEFA2110', 'YAHA3451', 'NIRO8138', 'NOAP4037', 'ROCO7943', 'KEFR7018', 'SHGE8152', 'YOCO4919', 'MASE7392', 'ABBE9810', 'DAGR3081', 'DASH8783', 'SHGO2546', 'AYSA8325'
}, {
    'sub01', 'sub02', 'sub03', 'sub04', 'sub05', 'sub06', 'sub07', 'sub08', 'sub09', 'sub10', 'sub11', 'sub12', 'sub13', 'sub14', 'sub15', 'sub16', 'sub17', 'sub18', 'sub19', 'sub20', 'sub21', 'sub22', 'sub23', 'sub24', 'sub25', 'sub26', 'sub27', 'sub28', 'sub29', 'sub30', 'sub31', 'sub32', 'sub33', 'sub34', 'sub35', 'sub36', 'sub37', 'sub38', 'sub39'
});



% Map conditions to their codes
condition_mapping = containers.Map({
    '11','12','13','14','15','3'
    }, {
    'Identical','Root','Letter','Unrelated','Symbols','Question'
    });

%%%%%%%% End of mappings %%%%%%%

% Define the number of sessions
num_runs = length(azk_files);

% Loop through runs
for run = 1:num_runs
    azk_filename = fullfile(azk_directory, azk_files(run).name);  % Use fullfile to specify the full path
    file_counter = 0;
    % Read and process the AZK file
    fid = fopen(azk_filename, 'r');
    
    break_from_loop = false;
    % initialize constant variables
    names = {"Identical","Root","Letter","Unrelated","Symbols","Question"};
    durations = {12, 12, 12, 12, 12, 2.4};
    onsets = {}
  
    % Process the AZK file line by line
    while ~feof(fid)
        tline = fgetl(fid); % Get the current line. at the beginning of a file this will be an emptly line!
        % Initialize subject_code
        subject_code = 0;
        % Initialize onset cell array for this subject
        onsets = cell(1,6);
                        
        % Find subject code
        % Check for a subject identifier line
        while (subject_code == 0) % && end of file??
            if contains(tline, 'Subject ')
                if (run == 3) && (contains(tline, 'Subject 17'))
                    subject_code = 'MAKA7424';
                else
                    id_index = strfind(tline, ' ID ');
                    subject_code = tline(id_index + 4:id_index + 11);
                end
                %if subject is MAEY6328 skip to next subject because no data
                if strcmp(subject_code, 'MAEY6328')
                    %break_from_loop = true;
                    a = fseek(fid, 0, 'eof');%go to end of file
                    tline = fgetl(fid);
                    break;
                end
                
            else %if the line does not contain the subject code move to next
                tline = fgetl(fid);
            end
        end
        % If we are at the end skip all and go to  next file
        %if break_from_loop
        if feof(fid)
            break;
        end
               
        % Check and correct subject typos if necessary
        if isKey(subject_mapping, subject_code)
            subject_code = subject_mapping(subject_code);
        end

        % Get the serial number for the subject code
        subject_serial = serial_mapping(subject_code);
        % move on to data
        for i = 1:3
            tline = fgetl(fid);  % Read and discard the line
        end

        % Start collecting the data for the subject from the 3 columns
        block_counter = 0;
        while block_counter < 20
            % Initiate condition
            got_condition = 0;
            condition_name = 0;

            % Check if the line starts with a valid condition code
            % Extract the first value/s (the condition code)
            while got_condition == 0 % Until we find a relevant condition line
                % Extract the first two digits
                tline = strtrim(tline);
                firstTwoDigits = tline(1:2);
                if isKey(condition_mapping, firstTwoDigits)
                   condition_code = num2str(firstTwoDigits);
                   condition_name = condition_mapping(condition_code);
                   got_condition = 1;
                else
                   % Read the next line
                    tline = fgetl(fid);                                         
                end
            end

            % Find the column of the correct condition to add the data
            condition_index = find(cellfun(@(x) strcmpi(strtrim(x), strtrim(condition_name)), names));

            % Extract the onset (rightmost number)
            % Set the duration based on the condition code
            % Split the line based on spaces
            values = strsplit(tline);
            % Access the last column value (index end)
            lastColumnValue = str2double(values{end});
            % convert to seconds
            onset = lastColumnValue / 1000;

            % Add the onset, and duration to the respective cell arrays
            onsets{condition_index} = [onsets{condition_index}, onset];

            % Skip the next 5 lines to the question
            for i = 1:6
                tline = fgetl(fid);
            end

            % Make sure the condition is correct and log data for the Question
            % Remove spaces at the start of the line
            % Extract the first digit
            tline = strtrim(tline);
            if tline(1) == '3'
                condition_code = num2str(tline(1));
                condition_name = condition_mapping(condition_code);
                % Find the column of the question condition to add the
                % data. It should be {6}
                condition_index = find(cellfun(@(x) strcmpi(strtrim(x), strtrim(condition_name)), names));

                % Split the line based on spaces
                values = strsplit(tline);

                % Access the last column value (index end)
                lastColumnValue = str2double(values{end});
                onset = lastColumnValue / 1000;

                % Add the condition name, onset, and duration to the respective cell arrays
                onsets{condition_index} = [onsets{condition_index}, onset];

            else
                disp('Check for an error in the question condition');
            end
            block_counter = block_counter+1; % track 20 block per subject
        end


        % Save data to MAT files for the current subject and run
        mat_filename = sprintf('multiple_conditions_%s_run%d.mat', subject_serial, run);
        save(mat_filename, 'names', 'onsets', 'durations');
        file_counter = file_counter + 1;
        if file_counter == 39
            break;
        end %don't cont to parse or search for subjects If we're done with this file
    end
    
    fclose(fid);  % Close the AZK file
end % End of run in the number of runs/azk files
