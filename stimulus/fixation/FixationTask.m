classdef FixationTask < AbstractTask
    %TESTSTIMULUS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
       
        edfFile@char = '';
        pathsave@char = '';
        taskname@char = 'FixationTask';
        results@double = [0 0 0];
        resultsLabels= {'Fixated', 'Not Fixated', 'Broken'};
        testvar@double = 0;
        
        
    end
    
    methods
        
        function obj = FixationTask(args)
            
            obj.stimPk = args;
            obj.props = obj.stimPk.props;
            
        end
        

        
        
       
        
        function runTrials(obj)
            
            disp('runTrials');
            obj.trial = 1;
            
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
            obj.externalControl = '';
            
            
            
            while (((obj.trial <= obj.numTrials) || obj.numTrials == 0) && stopTrial==false)
                
                % Stimulus dot
                % Size array ex:[-10   -10    10    10]
                
                obj.dotSize = angle2pix(obj.dotSizeDegrees, obj.stimPk.props.screenDistance, ...
                    obj.stimPk.props.realWidth, obj.winWidth);
                
                obj.fixWinSize = angle2pix(obj.fixWinSizeDegrees, obj.stimPk.props.screenDistance, ...
                    obj.stimPk.props.realWidth, obj.winWidth);
                
                obj.fixationDot = round([-obj.dotSize/2 -obj.dotSize/2 obj.dotSize/2 obj.dotSize/2]);
                % Position array ex:[1270  710  1290  730]
                obj.fixationDot = CenterRect(obj.fixationDot, obj.wRect);
                
                % Green dot when succesful trial
                fixationOK = [-obj.dotSize/2-2 -obj.dotSize/2-2 obj.dotSize/2+2 obj.dotSize/2+2];
                fixationOK = CenterRect(fixationOK, obj.wRect);
                
                % Set the fixation window on the center of the screen
                obj.fixationWindow = round([-obj.fixWinSize/2 -obj.fixWinSize/2 obj.fixWinSize/2 obj.fixWinSize/2]);
                obj.fixationWindow = CenterRect(obj.fixationWindow, obj.wRect);
                
                
                
                
                % While not indicated to stop run trials
                
                % STEP 7.1
                % Sending a 'TRIALID' message to mark the start of a trial in Data
                % Viewer.  This is different than the start of recording message
                % START that is logged when the trial recording begins. The viewer
                % will not parse any messages, events, or samples, that exist in
                % the data file prior to this message.
                
                obj.dataViewerTrialInfo(obj.trial);
                
                % STEP 7.3
                % start recording eye position (preceded by a short pause so that
                % the tracker can finish the mode transition)
                % The paramerters for the 'StartRecording' call controls the
                % file_samples, file_events, link_samples, link_events availability
                obj.eyelinkStartRecording();
                
                
                % STEP 7.4
                % Prepare and show the screen.
                obj.drawFixationPoint();
                Screen('Flip',obj.window);
                % Mark zero-plot time in data file
                Eyelink('Message', 'SYNCTIME');
                
                % TTL 1 -> Start of the trial
                sendTTLByte(1 , obj.stimPk.props.usingDataPixx);
                
                
                %Time to fixate
                fixateTime = GetSecs + obj.waitingFixationTime; % + 200/1000;
                
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
                    %obj.drawFixationPoint();

                    %Screen('DrawDots', obj.window, [mx my], 5, [255 0 0 255], [], 2);
                    %Screen('Flip',obj.window);
                    
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
                    reactionTimes(obj.trial) = GetSecs -startTime;
                end
                
                if ~infix
                    % Send message for fixation not achieved and cancel
                    % trial
                    sendTTLByte(4 , obj.stimPk.props.usingDataPixx);
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
                        %obj.drawFixationPoint();

                        %Screen('DrawDots', obj.window, [mx my], 5, [255 0 0 255], [], 2);
                        %Screen('Flip',obj.window);
                        if ~obj.infixationWindow(mx,my) && infix && mx && my
                            
                            %Screen('DrawTexture', obj.window, sad);
                            %Screen('Flip',obj.window);
                            %disp('broke fix');
                            Eyelink('Message', 'Fixation broke or grace time ended');
                            sendTTLByte(2 , obj.stimPk.props.usingDataPixx);
                            obj.results(3) = obj.results(3)+1;
                            infix = 0;
                            break;
                        end
                    end
                end
                
                
                
                %Si pasa el tiempo y sigue fijado
                if infix
                    Screen('FillOval', obj.window,[0 255 0], fixationOK);
                    Screen('Flip',obj.window);
                    %disp('fixed success!!');
                    if obj.props.usingLabJack
                        disp('Reward LJack!');

                        timedTTL(obj.lJack,0,obj.props.rewardTime);
                        % TTL 126 -> Reward
                        sendTTLByte(126 , obj.stimPk.props.usingDataPixx);
                    else
                        disp('Reward!');
                    end
                    sendTTLByte(3, obj.stimPk.props.usingDataPixx);
                    obj.results(1) = obj.results(1)+1;
                    
                    Eyelink('Message', 'Fixed Success :-)');
                    sprintf('Trial completed. Trial %d of %d\n', obj.trial, obj.numTrials);
                    timeNow=GetSecs;
                    %res(trial,1)=trial;
                    %res(trial,2)=timeNow-graceTime;
                    %res(trial,3)=obj.fixWinSize;
                    %res(trial,4)=fixateTime;
                    %trial = trial + 1;
                    WaitSecs(1);
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
                Eyelink('Message', '!V TRIAL_VAR index %d', obj.trial);
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
                timeEnd = GetSecs+obj.interTrialTime+randi([-obj.interTrialVariation*1000 obj.interTrialVariation*1000],1,1)/1000;
                
                txt = {'Fixated: ';'Not Fixated: ';'Broke Fixation: '}; % strings
                resultTxt ={ num2str(obj.results(1)); num2str(obj.results(2)); num2str(obj.results(3))};

                combinedtxt = strcat(txt,resultTxt);
                pie(obj.axes,obj.results,combinedtxt);

                while ((obj.paused)||(GetSecs<timeEnd))&&(~stopTrial)
                    drawnow
                    fInc = 150;
                    keyTicks = keyTicks + 1;
                    
                    stopTrial = obj.checkExternalCommand();

                    
                    
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
                                    timedTTL(obj.lJack,0,obj.props.rewardTime);
                                    % TTL 126 -> Reward
                                    sendTTLByte(126 , obj.stimPk.props.usingDataPixx);
                                    disp('reward!! (0.5 s)');
                                    keyHold = keyTicks + fInc;
                                end
                                
                        end
                    end
                    
                end % end of event check while
                
                
                
                obj.trial = obj.trial+1;
                
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
        
        
    end
    
    
    
end

