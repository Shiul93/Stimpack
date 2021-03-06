classdef MappingTask < AbstractTask
    %TESTSTIMULUS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        
        
        
        % Stimulation duration
        stimulationTime@double = 0.1;
        
        
        
        
        stimColor@double = [255 255 255 255];
        
        stimQuadrant@double = 1;
        stimSubQuadrant@double = 0;
        
        edfFile@char = '';
        pathsave@char = '';
        taskname@char = 'MappingTask';
        % [Fixed Broken NotFixated]
        results@double = zeros(20,3);
        testvar@double = 0;
        
        index@double = 0;
        autoQ@logical = false;
        autoSQ@logical = false;
        
        repeatAborts@logical = false;
        
        
        
        
    end
    
    methods
        
        function obj = MappingTask(args)
            
            obj.stimPk = args;
            obj.props = obj.stimPk.props;
            
        end
        


        
        
        function runTrials(obj)
            
            disp('runTrials');
            keyTicks = 0;
            keyHold = 1;
            obj.results =zeros(20,3);
            obj.externalControl = '';
            if (obj.numTrials < Inf)
                reactionTimes = ones(1, obj.numTrials)*(-1);
            else
                reactionTimes = [];
            end
            
            
            
            % repeat until we have 3 sucessful trials
            
            %EyelinkDoDriftCorrection(obj.el);
            
            stopTrial=false;
            %experimentControlGUI(obj);
            obj.externalControl = '';
            
            
            obj.trial = 1;
            currentQ = 1;
            while (((obj.trial <= obj.numTrials) || obj.numTrials == 0) && stopTrial==false)
                success = false;
                lostFix = false;
                
                
                if obj.autoQ
                    currentQ = mod(obj.index,4)+1;
                elseif obj.autoSQ
                    currentQ = obj.computeR2Quadrant(obj.stimQuadrant,mod(obj.index,4)+1)+4;
                else
                    if obj.stimSubQuadrant
                        currentQ = obj.computeR2Quadrant(obj.stimQuadrant,obj.stimSubQuadrant)+4
                    else
                        currentQ = obj.stimQuadrant
                    end
                end
                    
                obj.dotSize = angle2pix(obj.dotSizeDegrees, obj.stimPk.props.screenDistance, ...
                    obj.stimPk.props.realWidth, obj.winWidth);
                obj.fixWinSize = angle2pix(obj.fixWinSizeDegrees, obj.stimPk.props.screenDistance, ...
                    obj.stimPk.props.realWidth, obj.winWidth);
                % Fixation dot
                % Size array ex:[-10   -10    10    10]
                obj.fixationDot =round( [-obj.dotSize/2 -obj.dotSize/2 obj.dotSize/2 obj.dotSize/2]);
                % Position array ex:[1270  710  1290  730]
                obj.fixationDot = CenterRect(obj.fixationDot, obj.wRect);

                % Green dot when succesful trial
                fixationOK = [-obj.dotSize/2-2 -obj.dotSize/2-2 obj.dotSize/2+2 obj.dotSize/2+2];
                fixationOK = CenterRect(fixationOK, obj.wRect);

                % Set the fixation window on the center of the screen
                obj.fixationWindow = round([-obj.fixWinSize/2 -obj.fixWinSize/2 obj.fixWinSize/2 obj.fixWinSize/2]);
                obj.fixationWindow = CenterRect(obj.fixationWindow, obj.wRect);
            
                % TTL 1 -> Start of the trial
                sendTTLByte(1 , obj.stimPk.props.usingDataPixx);
                
                
                drawnow
                
                
                
                
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
                % Draw the image buffer in the screen
                Screen('Flip',obj.window);
                % TTL 2 -> Show fixation point
                sendTTLByte(2 , obj.stimPk.props.usingDataPixx);
                
                % Mark zero-plot time in data file
                Eyelink('Message', 'SYNCTIME');
                
                
                
                
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
                        
                        % TTL 3 -> Fixation started
                        sendTTLByte(3 , obj.stimPk.props.usingDataPixx);
                        
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
                    % TTL 6 -> Fixation not achieved
                    sendTTLByte(6 , obj.stimPk.props.usingDataPixx);
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
                            % TTL 6 -> Fixation broken
                            sendTTLByte(5 , obj.stimPk.props.usingDataPixx);
                            Eyelink('Message', 'Fixation broken');
                            lostFix = true;
                            infix = 0;
                            break;
                        end
                    end
                end
                
                
                
                %Si pasa el tiempo y sigue fijado
                if infix
                    obj.drawFixationPoint();
                    % Draw the image buffer in the screen
                    %obj.drawStimulus([obj.stimCoords(1),obj.stimCoords(2)],obj.stimSize);
                    obj.drawStimulus();
                    Screen('Flip',obj.window);

                    % Send correspondent TTL for the shown stimulus
                    obj.sendStimulusTTL();
                    % Stimulation loop
                    startStimTime = GetSecs;
                    while ((GetSecs < startStimTime + obj.stimulationTime) && infix)
                        if obj.props.usingEyelink
                            error=Eyelink('CheckRecording');
                            if(error~=0)
                                break;
                            end
                        end
                        
                        [mx, my] = obj.getEyeCoordinates();
                        
                        if ~obj.infixationWindow(mx,my) && infix
                            
                            % TTL 5 -> Fixation broken
                            sendTTLByte(5 , obj.stimPk.props.usingDataPixx);
                            Eyelink('Message', 'Fixation broken');

                            disp('broke fix');
                            lostFix = true;

                            infix = 0;
                        end
                    end
                    
                    
                    if infix
                        Screen('FillOval', obj.window,[0 255 0], fixationOK);
                        %disp('fixed success!!');
                        % TTL 4 -> Succesful trial
                        sendTTLByte(4, obj.stimPk.props.usingDataPixx);
                        Screen('FillOval', obj.window,[0 255 0], fixationOK);
                        
                        success = true;
                        if obj.props.usingLabJack
                            
                            timedTTL(obj.lJack,0,obj.props.rewardTime);
                            % TTL 126 -> Reward
                            sendTTLByte(126 , obj.stimPk.props.usingDataPixx);
                        else
                            % TTL 126 -> Reward
                            sendTTLByte(126 , obj.stimPk.props.usingDataPixx);
                            disp('Reward!');
                        end
                        
                        Eyelink('Message', 'Trial completed succesfully');
                        
                    else
                        Screen('FillOval', obj.window,[255 0 0], fixationOK);
                    end
                    
                    Screen('Flip',obj.window);
                    
                    sprintf('Trial completed. Trial %d of %d\n', obj.trial, obj.numTrials);
                    
                    
                end
                
                
               
                if((~success)&& obj.repeatAborts)
                    obj.index = obj.index;
                else
                    obj.index = obj.index+1;
                end
                if success
                    obj.results(currentQ,1) = obj.results(currentQ,1)+1;
                elseif lostFix
                    obj.results(currentQ,2) = obj.results(currentQ,2)+1;
                else
                    obj.results(currentQ,3) = obj.results(currentQ,3)+1;
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
                
                txt = {'Fixated: ';'Broke Fixation: ';'Not Fixated: '}; % strings

                disp(obj.results)
                resultTxt ={ num2str(obj.results(currentQ,1)); num2str(obj.results(currentQ,2)); num2str(obj.results(currentQ,3))};

                combinedtxt = strcat(txt,resultTxt);
                pie(obj.axes,obj.results(currentQ,:),combinedtxt);
                title(sprintf('Quadrant: %d',currentQ));
                
                % Inter trial pause used for keyboard or gui commands
                timeEnd = GetSecs+obj.interTrialTime+randi([-obj.interTrialVariation*1000 obj.interTrialVariation*1000],1,1)/1000;
                while ((obj.paused)||(GetSecs<timeEnd))&&(~stopTrial)
                    drawnow
                    fInc = 150;
                    keyTicks = keyTicks + 1;
                    
                    stopTrial = obj.checkExternalCommand();
                    
                    
                    
                    [keyIsDown, ~, keyCode] = KbCheck(-1); 
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
        
        
        function drawStimulus(obj)
            %stimulus = [position(1)-size position(2)-size position(1)+size position(2)+size]
            %stimulus = CenterRect(stimulus, obj.wRect)
            %stimulus = [-size size size size]
            
            %stimulus = CenterRectOnPointd(stimulus, position(1), position(2))
            %Screen('FillOval', obj.window,[1,1,1,0], stimulus);
            
            x1 = 0;
            x2 = 0;
            y1 = 0;
            y2 = 0;
            
            
            if obj.stimSubQuadrant
                [x1, y1, x2, y2 ]= obj.computeQuadrantCoords(2,...
                    obj.computeR2Quadrant(obj.stimQuadrant,obj.stimSubQuadrant)) ;
            else
                [x1, y1, x2, y2 ]= obj.computeQuadrantCoords(1,obj.stimQuadrant) ;
            end
            
            if obj.autoQ
                [x1, y1, x2, y2 ]= obj.computeQuadrantCoords(1, mod(obj.index,4)+1) ;
            elseif obj.autoSQ
                [x1, y1, x2, y2 ]= obj.computeQuadrantCoords(2,...
                    obj.computeR2Quadrant(obj.stimQuadrant,mod(obj.index,4)+1)) ;
            end
            stimulus = [x1 y1 x2 y2];
            Screen('FillRect', obj.window, obj.stimColor, stimulus);
            
        end
        
        function q = computeR2Quadrant(obj , q , sq)
            q = ( 4 * q) + sq -4;
        end
        
        function [x1, y1, x2, y2] = computeQuadrantCoords(obj,res,quad)
            if res == 1
                switch quad
                    case 1
                        x1 = 0;
                        y1 = 0;
                        x2 = obj.winWidth/2;
                        y2 = obj.winHeight/2;
                    case 2
                        x1 = obj.winWidth/2;
                        y1 = 0;
                        x2 = obj.winWidth;
                        y2 = obj.winHeight/2;
                    case 3
                        x1 = 0;
                        y1 = obj.winHeight/2;
                        x2 = obj.winWidth/2;
                        y2 = obj.winHeight;
                    case 4
                        x1 = obj.winWidth/2;
                        y1 = obj.winHeight/2;
                        x2 = obj.winWidth;
                        y2 = obj.winHeight;
                        
                end
                
            elseif res == 2
                switch quad
                    case 1
                        x1 = 0;
                        y1 = 0;
                        x2 = obj.winWidth/4;
                        y2 = obj.winHeight/4;
                    case 2
                        x1 = obj.winWidth/4;
                        y1 = 0;
                        x2 = obj.winWidth/2;
                        y2 = obj.winHeight/4;
                    case 3
                        x1 = 0;
                        y1 = obj.winHeight/4;
                        x2 = obj.winWidth/4;
                        y2 = obj.winHeight/2;
                    case 4
                        x1 = obj.winWidth/4;
                        y1 = obj.winHeight/4;
                        x2 = obj.winWidth/2;
                        y2 = obj.winHeight/2;
                    case 5
                        x1 = obj.winWidth/2;
                        y1 = 0;
                        x2 = obj.winWidth*3/4;
                        y2 = obj.winHeight/4;
                    case 6
                        x1 = obj.winWidth*3/4;
                        y1 = 0;
                        x2 = obj.winWidth;
                        y2 = obj.winHeight/4;
                    case 7
                        x1 = obj.winWidth/2;
                        y1 = obj.winHeight/4;
                        x2 = obj.winWidth*3/4;
                        y2 = obj.winHeight/2;
                    case 8
                        x1 = obj.winWidth*3/4;
                        y1 = obj.winHeight/4;
                        x2 = obj.winWidth;
                        y2 = obj.winHeight/2;
                        
                    case 9
                        x1 = 0;
                        y1 = obj.winHeight/2;
                        x2 = obj.winWidth/4;
                        y2 = obj.winHeight*3/4;
                    case 10
                        x1 = obj.winWidth/4;
                        y1 = obj.winHeight/2;
                        x2 = obj.winWidth/2;
                        y2 = obj.winHeight*3/4;
                    case 11
                        x1 = 0;
                        y1 = obj.winHeight*3/4;
                        x2 = obj.winWidth/4;
                        y2 = obj.winHeight;
                    case 12
                        x1 = obj.winWidth/4;
                        y1 = obj.winHeight*3/4;
                        x2 = obj.winWidth/2;
                        y2 = obj.winHeight;
                    case 13
                        x1 = obj.winWidth/2;
                        y1 = obj.winHeight/2;
                        x2 = obj.winWidth*3/4;
                        y2 = obj.winHeight*3/4;
                    case 14
                        x1 = obj.winWidth*3/4;
                        y1 = obj.winHeight/2;
                        x2 = obj.winWidth;
                        y2 = obj.winHeight*3/4;
                    case 15
                        x1 = obj.winWidth/2;
                        y1 = obj.winHeight*3/4;
                        x2 = obj.winWidth*3/4;
                        y2 = obj.winHeight;
                    case 16
                        x1 = obj.winWidth*3/4;
                        y1 = obj.winHeight*3/4;
                        x2 = obj.winWidth;
                        y2 = obj.winHeight;
                        
                end
            else
                
            end
        end
        
        function sendStimulusTTL(obj)
            
            
            if obj.autoSQ
                
                sendTTLByte(obj.computeR2Quadrant(obj.stimQuadrant,mod(obj.index,4)+1),...
                    obj.props.usingDataPixx);
            elseif obj.autoQ
                sendTTLByte(mod(obj.index,4),...
                    obj.props.usingDataPixx)
                
            elseif obj.stimSubQuadrant
                sendTTLByte(obj.computeR2Quadrant(obj.stimQuadrant,...
                    obj.stimSubQuadrant)+10, obj.props.usingDataPixx);
            else
                sendTTLByte(obj.stimQuadrant+6, obj.props.usingDataPixx);
            end
        end
        
    end
    
    
    
end

