classdef MappingDotStimulus < AbstractStimulus
    %TESTSTIMULUS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        
        
        
        % Stimulation duration
        stimulationTime@double = 5;
        

        
        stimCoords@double = [0 0];
        
        stimSize@double = 50;
        
        stimColor@double = [255 255 255 255];
        
        
        edfFile@char = '';
        pathsave@char = '';
        taskname@char = 'MappingDotTask';
        
        results@double = [0 0 0];
        testvar@double = 0;
        
        
        
        
    end
    
    methods
        
        function obj = MappingDotStimulus(args)
            
            obj.stimPk = args;
            obj.props = obj.stimPk.props;
            
        end
        
        function configureEDF(obj)
            
            disp('ConfigureEDF');
            % Obtain filename
            
            if obj.stimPk.props.usingEyelink
                num = clock;
                folder = ['MappingDotTask_' num2str(num(1)) '_' num2str(num(2)) '_' num2str(num(3)) '_'...
                    num2str(num(4)) '_' num2str(num(5)) '_' num2str(floor(num(6)))];
                
                obj.pathsave=[obj.stimPk.props.path '/DATA/' folder];
                mkdir(obj.pathsave);
                rehash();
                
                if isempty(obj.edfFile)
                    obj.edfFile = 'MappingDotTask';
                end
            end
            
        end
        
        
      
        function runTrials(obj)
            
            disp('runTrials');
            trial = 1;
            index = 1;
            
            firstRun = 1;
            infix = 0;
            keyTicks = 0;
            keyHold = 1;
            obj.results = [0 0 0];
            obj.externalControl = '';
            if (obj.numTrials < Inf)
                reactionTimes = ones(1, obj.numTrials)*(-1);
            else
                reactionTimes = [];
            end
            
            
            
            % repeat until we have 3 sucessful trials
            
            %EyelinkDoDriftCorrection(obj.el);
            
            stopTrial=false;
            experimentControlGUI(obj);
            obj.externalControl = '';
            
            % Fixation dot
            % Size array ex:[-10   -10    10    10]
            obj.fixationDot = [-obj.dotSize -obj.dotSize obj.dotSize obj.dotSize];
            % Position array ex:[1270  710  1290  730]
            obj.fixationDot = CenterRect(obj.fixationDot, obj.wRect);

            % Green dot when succesful trial
            fixationOK = [-obj.dotSize-2 -obj.dotSize-2 obj.dotSize+2 obj.dotSize+2];
            fixationOK = CenterRect(fixationOK, obj.wRect);

            % Set the fixation window on the center of the screen
            obj.fixationWindow = [-obj.fixWinSize -obj.fixWinSize obj.fixWinSize obj.fixWinSize];
            obj.fixationWindow = CenterRect(obj.fixationWindow, obj.wRect);
            
            while (((trial <= obj.numTrials) || obj.numTrials == 0) && stopTrial==false)
                
                
                bar(reactionTimes);
                drawnow
                
                
                
                
                % While not indicated to stop run trials

                    % STEP 7.1 
                    % Sending a 'TRIALID' message to mark the start of a trial in Data
                    % Viewer.  This is different than the start of recording message
                    % START that is logged when the trial recording begins. The viewer
                    % will not parse any messages, events, or samples, that exist in
                    % the data file prior to this message.
                    
                    obj.dataViewerTrialInfo(trial);
                    
                    % STEP 7.3
                    % start recording eye position (preceded by a short pause so that
                    % the tracker can finish the mode transition)
                    % The paramerters for the 'StartRecording' call controls the
                    % file_samples, file_events, link_samples, link_events availability
                    obj.eyelinkStartRecording();
                    
                    
                    % STEP 7.4
                    % Prepare and show the screen.
                    obj.drawFixationPoint();
                    % Draw the image buffer in the screen
                    Screen('Flip',obj.window);

                    % Mark zero-plot time in data file
                    Eyelink('Message', 'SYNCTIME');
                    
                    % TTL 1 -> Start of the trial
                    sendTTL(1 , obj.stimPk.props.usingDataPixx);
               
                    
                    %Time to fixate
                    fixateTime = GetSecs + obj.waitingFixationTime; % + 200/1000;
                    graceTime = GetSecs; % + 200/1000;
                    
                    % Time of the fixation start
                    fixationTime = -1;
                    
                    infix = 0;
                    
                    startTime = GetSecs;
                    
                    % Fixate time of the trial, the subject has fixateTime
                    % millisconds to fixate the sight on the stimulus
                    while (GetSecs < fixateTime) && ~infix
                        if obj.props.usingEyelink
                            error=Eyelink('CheckRecording');
                            if(error~=0)
                                break;
                            end
                        end
                        
                        [mx, my] = obj.getEyeCoordinates();
                        
                        
                        %Si se fija por primera vez se envia un mensaje Fixation start
                        if obj.infixationWindow(mx,my) && ~infix
                            %disp('Fixed')
                            Eyelink('Message', 'Fixation Start');
                            fixationTime = GetSecs;
                            %Beeper(el.calibration_success_beep(1), el.calibration_success_beep(2), el.calibration_success_beep(3));
                            infix = 1;
                            
                        end
                    end
                    if (infix)
                        reactionTimes(trial) = GetSecs -startTime;
                    end
                    
                    if ~infix
                        % Send message for fixation not achieved and cancel
                        % trial
                        sendTTL(4 , obj.stimPk.props.usingDataPixx);
                        obj.results(2) = obj.results(2)+1;
                    else
                        
                        disp('Fixate loop');
                        while (GetSecs < fixationTime + obj.timeFix)
                            if obj.props.usingEyelink
                                error=Eyelink('CheckRecording');
                                if(error~=0)
                                    break;
                                end
                            end
                            
                            [mx, my] = obj.getEyeCoordinates();
                            
                            if ~obj.infixationWindow(mx,my) && infix
                                
                                %Screen('DrawTexture', obj.window, sad);
                                %Screen('Flip',obj.window);
                                %disp('broke fix');
                                Eyelink('Message', 'Fixation broke or grace time ended');
                                sendTTL(2 , obj.stimPk.props.usingDataPixx);
                                obj.results(3) = obj.results(3)+1;
                                infix = 0;
                                break;
                            end
                        end
                    end
                    
                    
                    
                    %Si pasa el tiempo y sigue fijado
                    if infix
                        obj.drawFixationPoint();
                        % Draw the image buffer in the screen
                        obj.drawStimulus([obj.stimCoords(1),obj.stimCoords(2)],obj.stimSize);
                        Screen('Flip',obj.window);
                        % Stimulation loop
                        startStimTime = GetSecs;
                        a = obj.stimulationTime
                        while ((GetSecs < startStimTime + obj.stimulationTime) && infix)
                            time = GetSecs <( startStimTime  + obj.stimulationTime)
                            if obj.props.usingEyelink
                                error=Eyelink('CheckRecording');
                                if(error~=0)
                                    break;
                                end
                            end
                            
                            [mx, my] = obj.getEyeCoordinates();
                            
                            if ~obj.infixationWindow(mx,my) && infix
                                
                               
                                disp('broke fix');                                
                                infix = 0;
                            end
                        end
                        
                        if infix
                            Screen('FillOval', obj.window,[0 255 0], fixationOK);
                        else
                            Screen('FillOval', obj.window,[255 0 0], fixationOK);
                        end

                        Screen('Flip',obj.window);
                        %disp('fixed success!!');
                        if obj.props.usingLabJack
                            
                            timedTTL(obj.lJack,0,obj.props.rewardTime);
                        else
                            disp('Reward!');
                        end
                        sendTTL(3, obj.stimPk.props.usingDataPixx);
                        obj.results(1) = obj.results(1)+1;
                        
                        Eyelink('Message', 'Fixed Success :-)');
                        sprintf('Trial completed. Trial %d of %d\n', trial, obj.numTrials);
                       
                       
                    end
                    
                    
                    
                    
                    
                    
                    
                    
                    % STEP 7.5
                    % add 100 msec of data to catch final events and blank display
                    WaitSecs(0.1);
                    Eyelink('StopRecording');
                    
                   
                    
                    Screen('FillRect', obj.window, obj.backgroundColour);
                    Screen('Flip', obj.window);
                    
                    %imwrite(imageArray, 'imgfile.jpg', 'jpg');
                    %Eyelink('Message', '!V IMGLOAD CENTER %s %d %d', 'imgfile.jpg', obj.winWidth/2, obj.winHeight/2);
                    
                    % STEP 7.6
                    % Send out necessary integration messages for data analysis
                    % Send out interest area information for the trial
                    % See "Protocol for EyeLink Data to Viewer Integration-> Interest
                    % Area Commands" section of the EyeLink Data Viewer User Manual
                    % IMPORTANT! Don't send too many messages in a very short period of
                    % time or the EyeLink tracker may not be ablwWe to write them all
                    % to the EDF file.
                    % Consider adding a short delay every few messages.
                    WaitSecs(0.001);
                    Eyelink('Message', '!V IAREA ELLIPSE %d %d %d %d %d %s', 1, floor(obj.winWidth/2-obj.dotSize), floor(obj.winHeight/2-obj.dotSize), floor(obj.winWidth/2+obj.dotSize), floor(obj.winHeight/2+obj.dotSize),'center');
                    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 2, floor(obj.winWidth/2-obj.fixWinSize), floor(obj.winHeight/2-obj.fixWinSize), floor(obj.winWidth/2+obj.fixWinSize), floor(obj.winHeight/2+obj.fixWinSize),'centerWin');
                    
                    
                    
                    % Send messages to report trial condition information
                    % Each message may be a pair of trial condition variable and its
                    % corresponding value follwing the '!V TRIAL_VAR' token message
                    % See "Protocol for EyeLink Data to Viewer Integration-> Trial
                    % Message Commands" section of the EyeLink Data Viewer User Manual
                    WaitSecs(0.001);
                    Eyelink('Message', '!V TRIAL_VAR index %d', trial);
                    %Eyelink('Message', '!V TRIAL_VAR imgfile %s', 'imgfile.jpg');
                    if infix
                        Eyelink('Message', '!V TRIAL_VAR trialOutcome %s', 'succesful');
                    else
                        Eyelink('Message', '!V TRIAL_VAR trialOutcome %s', 'recycled');
                    end
                    % STEP 9
                    % Sending a 'TRIAL_RESULT' message to mark the end of a trial in
                    % Data Viewer. This is different than the end of recording message
                    % END that is logged when the trial recording ends. The viewer will
                    % not parse any messages, events, or samples that exist in the data
                    % file after this message.
                    Eyelink('Message', 'TRIAL_RESULT 0');
                    
                    % Inter trial pause used for keyboard or gui commands
                    timeEnd = GetSecs+obj.interTrialTime;
                    
                    while (obj.paused)||(GetSecs<timeEnd)
                        drawnow
                        fInc = 150;
                        keyTicks = keyTicks + 1;
 
                        command = obj.externalControl;
                        
                        if ~strcmp( command,'' )
                            disp('External control:');
                            disp(command);
                            switch command
                                case 'p'
                                    disp('Paused change')
                                    obj.paused=~obj.paused;
                                  
                                case 'q'
                                    disp('End Experiment')
                                    stopTrial=true;
                                    obj.paused=false;
                                    
                                case 'r'
                                    disp('Reward')
                                    if obj.props.usingLabJack
                                        if keyTicks > keyHold
                                            timedTTL(lJack,0,500);
                                            disp('reward!! (0.5 s)');
                                            keyHold = keyTicks + fInc;
                                        end
                                    end
                                case 'm'
                                    disp('Mark')
                                    sendTTL(7,obj.props.usingDataPixx);
                                    
                        
                            end
                            obj.externalControl = '';

                        end
                        
                        
                        [keyIsDown, ~, keyCode] = KbCheck(-1); %#ok<*ASGLU>
                        if keyIsDown == 1
                            pressKey = KbName(keyCode);
                            switch pressKey
                                case 'p'
                                    
                                    obj.paused=~obj.paused;
                                case 'q' %quit
                                    stopTrial=true;
                                    obj.paused = false;

                                case 'space'
                                    if keyTicks > keyHold
                                        timedTTL(obj.lJack,0,500);
                                        disp('reward!! (0.5 s)');
                                        keyHold = keyTicks + fInc;
                                    end
                                    
                            end
                        end
                        
                    end % end of event check while
                    
                
                
                trial = trial+1;
                
            end
        end
        
        function endExperiment(obj)
            disp('endExperiment');
            % End of Experiment; close the file first
            % close graphics window, close data file and shut down tracker
            Screen('CloseAll');
            Eyelink('Command', 'set_idle_mode');
            WaitSecs(0.5);
            if obj.stimPk.props.usingEyelink
                Eyelink('CloseFile');
                
                % download data file
                
                try
                    fprintf('Receiving data file ''%s''\n', obj.edfFile );
                    status=Eyelink('ReceiveFile');
                    if status > 0
                        fprintf('ReceiveFile status %d\n', status);
                    end
                    if 2==exist(obj.edfFile, 'file')
                        fprintf('Data file ''%s'' can be found in ''%s''\n', obj.edfFile, pwd );
                        source=[obj.props.pathsave '/' obj.edfFile '.edf'];
                        destination = [obj.pathsave '/' obj.edfFile '.edf'];
                        movefile(source,destination);
                    end
                catch %#ok<*CTCH>
                    fprintf('Problem receiving data file ''%s''\n', obj.edfFile );
                end
            end
        end
        
        
        
        
        
        
        function sendCommand(obj, text)
            obj.externalControl = text;
            disp(obj.externalControl);
        end
        
        
       function drawStimulus(obj, position, size)
            %stimulus = [position(1)-size position(2)-size position(1)+size position(2)+size]
            %stimulus = CenterRect(stimulus, obj.wRect)
            %stimulus = [-size size size size]

            %stimulus = CenterRectOnPointd(stimulus, position(1), position(2))
            %Screen('FillOval', obj.window,[1,1,1,0], stimulus);
            Screen('DrawDots', obj.window, [position(1) position(2)], size, obj.stimColor, [], 2);
       end
        
       
    end
    
    
    
end

