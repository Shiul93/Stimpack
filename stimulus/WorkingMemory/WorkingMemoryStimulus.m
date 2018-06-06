classdef WorkingMemoryStimulus < AbstractStimulus
    %TEMPLATESTIMULUS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        
        edfFile@char = '';
        pathsave@char = '';
        taskname@char = 'WorkingMemoryTask'; %%%%%CHANGE ME%%%%%%
        
        results@double = [0 0 0];
        testvar@double = 0;
        
        
        vbl@double = 0;
        xoffset@double = 0;
        cyclespersecond@double = 1;
        p@double = 32;
        gratingtex
        ifi@double = 0
        shiftperframe@double = 0;
        visiblesize@double = 256;
        waitframes@double = 1;
        xGratingPos@double = 0;
        yGratingPos@double  = 0;
        trialDirection;
        s1Time@double = 0.1;
        gratingDelay@double = 0.1;
        s2Time@double = 0.1;
        answerTime@double = 1.5;
        answerFixTime@double = 1.5;
        showArrow@logical = false;
        rightSelectionWindow
        leftSelectionWindow
        
        randdir@double = 0;
        
    end
    
    methods
        %%CONSTRUCTOR
        function obj = WorkingMemoryStimulus(args)
            
            obj.stimPk = args;
            obj.props = obj.stimPk.props;
            obj.numTrials = 24;
            
        end
        %%EDF FILE CONFIGURATION FUNCTION
        function configureEDF(obj)
            
            disp('ConfigureEDF');
            % Obtain filename
            
            if obj.stimPk.props.usingEyelink
                num = clock;
                folder = ['WorkingMemoryTask_' num2str(num(1)) '_' num2str(num(2)) '_' num2str(num(3)) '_'...
                    num2str(num(4)) '_' num2str(num(5)) '_' num2str(floor(num(6)))];
                
                obj.pathsave=[obj.stimPk.props.path '/DATA/' folder];
                mkdir(obj.pathsave);
                rehash();
                
                if isempty(obj.edfFile)
                    obj.edfFile = 'WorkingMemoryTask';
                end
            end
            
        end
        
        
        %%TRIAL EXECUTION FUNCTION
        function runTrials(obj)
            
            %%INITIALIZE VARIABLE VALUES AND CONFIGURE STIMULUS
            disp('runTrials');
            obj.trial = 1;
            
            directions = cat(1,ones(obj.numTrials/2,1),ones(obj.numTrials/2,1)*-1);
            obj.trialDirection = directions(randperm(length(directions)));
            disp(obj.trialDirection)
            
            keyTicks = 0;
            keyHold = 1;
            obj.results = [0 0 0];
            obj.externalControl = '';
            %%%%%CHANGE ME%%%%%%
            %%%%%DECLARE OWN EXPERIMENT RESULTS%%%%%%
            if (obj.numTrials < Inf)
                reactionTimes = ones(1, obj.numTrials)*(-1);
            else
                reactionTimes = [];
            end
            
            
            
            % repeat until we have 3 sucessful trials
            
            %EyelinkDoDriftCorrection(obj.el);
            
            stopTrial=false;
            obj.externalControl = '';
            obj.prepareGrating();
            
            
            %%TRIAL LOOP
            while (((obj.trial <= obj.numTrials) || obj.numTrials == 0) && stopTrial==false)
                
                obj.dotSize = angle2pix(obj.dotSizeDegrees, obj.stimPk.props.screenDistance, ...
                    obj.stimPk.props.realWidth, obj.winWidth);
                obj.fixWinSize = angle2pix(obj.fixWinSizeDegrees, obj.stimPk.props.screenDistance, ...
                    obj.stimPk.props.realWidth, obj.winWidth);
                
                % Stimulus dot
                % Size array ex:[-10   -10    10    10]
                obj.fixationDot =round( [-obj.dotSize/2 -obj.dotSize/2 obj.dotSize/2 obj.dotSize/2]);
                
                % Position array ex:[1270  710  1290  730]
                obj.fixationDot = CenterRect(obj.fixationDot, obj.wRect);
                
                % Green dot when succesful trial
                fixationOK = [-obj.dotSize/2-2 -obj.dotSize/2-2 obj.dotSize/2+2 obj.dotSize/2+2];
                fixationOK = CenterRect(fixationOK, obj.wRect);
                
                % Set the fixation window on the center of the screen
                obj.fixationWindow =round( [-obj.fixWinSize/2 -obj.fixWinSize/2 obj.fixWinSize/2 obj.fixWinSize/2]);
                obj.leftSelectionWindow = [(obj.winWidth/4)  - obj.fixWinSize/2 ...
                    (obj.winHeight/2) - obj.fixWinSize/2 ...
                    (obj.winWidth/4)  + obj.fixWinSize/2 ...
                    (obj.winHeight/2) + obj.fixWinSize/2];
                
                obj.rightSelectionWindow = [(obj.winWidth*3/4) - obj.fixWinSize/2 ...
                    (obj.winHeight/2) - obj.fixWinSize/2 ...
                    (obj.winWidth*3/4)+ obj.fixWinSize/2 ...
                    (obj.winHeight/2) + obj.fixWinSize/2];
                
                obj.fixationWindow = CenterRect(obj.fixationWindow, obj.wRect);
                
                
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
                
                %%START OF FIXATION PHASE %%
                % STEP 7.4
                % Prepare and show the screen.
                obj.drawFixationPoint();
                % Draw the image buffer in the screen
                Screen('Flip',obj.window);
                
                % Mark zero-plot time in data file
                Eyelink('Message', 'SYNCTIME');
                
                % TTL 1 -> Start of the trial
                sendTTLByte(1 , obj.stimPk.props.usingDataPixx);
                
                
                %Time to fixate
                fixateTime = GetSecs + obj.waitingFixationTime; % + 200/1000;
                graceTime = GetSecs; % + 200/1000;
                
                % Time of the fixation start
                fixationTime = -1;
                
                infix = 0;
                
                startTime = GetSecs;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%FIRST TASK STEP: ACHIEVE FIXATION
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Fixate time of the trial, the subject has fixateTime
                % millisconds to fixate the sight on the stimulus
                while (GetSecs < fixateTime) && ~infix
                    
                    if obj.checkErrorRecording()
                        break
                    end
                    
                    [mx, my] = obj.getEyeCoordinates();
                    
                    
                    % First moment of fixation
                    if obj.infixationWindow(mx,my) && ~infix
                        % TTL 1 -> Start of the trial
                        sendTTLByte(1 , obj.stimPk.props.usingDataPixx);
                        
                        Eyelink('Message', 'Fixation Start');
                        fixationTime = GetSecs;
                        
                        % The subject is now fixating its sight on the
                        % fixation dot
                        infix = 1;
                        
                    end
                end
                
                
                % If the time to fixate has passed and the subject didn't
                % fixate on the objective
                if ~infix
                    % Send message for fixation not achieved and cancel
                    % trial
                    
                    % TTL 3 -> Fixation not achieved
                    sendTTLByte(3 , obj.stimPk.props.usingDataPixx);
                    
                    
                else
                    disp('Fixate loop');
                    while (GetSecs < fixationTime + obj.timeFix)
                        if obj.checkErrorRecording()
                            break
                        end
                        
                        [mx, my] = obj.getEyeCoordinates();
                        
                        if ~obj.infixationWindow(mx,my) && infix
                            Eyelink('Message', 'Fixation broken');
                            % TTL 12 -> Fixation broken
                            sendTTLByte(12 , obj.stimPk.props.usingDataPixx);
                            infix = 0;
                            break;
                        end
                    end
                    
                    %If the subject is still fixating we send a TTL
                    %indicating the first phase is completed
                    if infix
                        % TTL 2 -> Fixation achieved
                        sendTTLByte(2 , obj.stimPk.props.usingDataPixx);
                    else
                        % Show red dot indicating the failure
                        Screen('FillOval', obj.window,[255 0 0], fixationOK);
                        Screen('Flip',obj.window);
                    end
                end
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%SECOND TASK STEP: SHOW S1 STIMULUS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Si pasa el tiempo y sigue fijado
                if infix
                    % Generate random direction for the grating, used when
                    % the arrow is active
                    obj.randdir = randi(2,1,1)-1;
                    
                    % Set starting time
                    startStimTime = GetSecs;
                    
                    % TTL 4 -> Show S1 stimulus
                    sendTTLByte(4 , obj.stimPk.props.usingDataPixx);
                    
                    % Stimulation loop
                    while ((GetSecs < startStimTime + obj.s1Time) && infix)
                        
                        % Draw the fixation point and the stimulus in the
                        % screen
                        obj.drawFixationPoint();
                        
                        % Drawstimulus contains the flip function call
                        obj.drawStimulus(obj.showArrow,1);
                        
                        
                        
                        if obj.checkErrorRecording()
                            break
                        end
                        
                        [mx, my] = obj.getEyeCoordinates();
                        
                        if ~obj.infixationWindow(mx,my) && infix
                            
                            Eyelink('Message', 'Fixation broken');
                            % TTL 12 -> Fixation broken
                            sendTTLByte(12 , obj.stimPk.props.usingDataPixx);
                            infix = 0;
                        end
                    end
                    
                    
                    if ~infix
                        % Show red dot indicating the failure
                        Screen('FillOval', obj.window,[255 0 0], fixationOK);
                        Screen('Flip',obj.window);
                        
                    end
                    
                    
                    
                    
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%THIRD TASK STEP: DELAY BETWEEN STIMULI
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if infix
                    startStimTime = GetSecs;
                    obj.drawFixationPoint();
                    
                    % TTL 5 -> S1 disappears, enter delay phase
                    sendTTLByte(12 , obj.stimPk.props.usingDataPixx);
                    Screen('Flip',obj.window);
                    
                    
                    while ((GetSecs < startStimTime + obj.gratingDelay) && infix)
                        
                        
                        if obj.checkErrorRecording()
                            break
                        end
                        [mx, my] = obj.getEyeCoordinates();
                        
                        if ~obj.infixationWindow(mx,my) && infix
                            
                            Eyelink('Message', 'Fixation broken');
                            % TTL 12 -> Fixation broken
                            sendTTLByte(12 , obj.stimPk.props.usingDataPixx);
                            infix = 0;
                        end
                    end
                    
                    
                    if ~infix
                        % Show red dot indicating the failure
                        Screen('FillOval', obj.window,[255 0 0], fixationOK);
                        Screen('Flip',obj.window);
                        
                    end
                    
                    
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%FOURTH TASK STEP: SHOW S2 STIMULUS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                if infix
                    % Generate random direction for the grating
                    obj.randdir = randi(2,1,1)-1;
                    
                    
                    % Set starting time
                    startStimTime = GetSecs;
                    
                    % TTL 6 -> Show S2 stimulus
                    sendTTLByte(6 , obj.stimPk.props.usingDataPixx);
                    
                    % Stimulation loop
                    while ((GetSecs < startStimTime + obj.s2Time) && infix)
                        
                        % Its needed to draw on every iteration to get
                        % the animation effect in the grating
                        obj.drawFixationPoint();
                        obj.drawStimulus(false,2);
                        
                        
                        if obj.checkErrorRecording()
                            break
                        end
                        
                        [mx, my] = obj.getEyeCoordinates();
                        
                        if ~obj.infixationWindow(mx,my) && infix
                            
                            Eyelink('Message', 'Fixation broken');
                            % TTL 12 -> Fixation broken
                            sendTTLByte(12 , obj.stimPk.props.usingDataPixx);
                            infix = 0;
                        end
                    end
                    
                    
                    if ~infix
                        % Show red dot indicating the failure
                        Screen('FillOval', obj.window,[255 0 0], fixationOK);
                        Screen('Flip',obj.window);
                        
                    end
                    
                    
                    
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%FIFTH TASK STEP: SHOW SELECTORS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if infix
                    infix = 0;
                    obj.drawSelectors();
                    Screen('Flip',obj.window);
                    % TTL 7 -> Selectors appear
                    sendTTLByte(7 , obj.stimPk.props.usingDataPixx);
                    
                    % Time to achieve fixation on the desired selector
                    fixateTime = GetSecs + obj.answerTime;
                    
                    % Fixed selector 0 -> none, -1 -> left, 1 -> right
                    selectorFix = 0;
                    
                    % Iterate until time is consumed or sight on selector
                    while (GetSecs < fixateTime) && ~selectorFix
                        if obj.checkErrorRecording()
                            break
                        end
                        
                        [mx, my] = obj.getEyeCoordinates();
                        
                        
                        % Check if sight is in any of the selectors
                        selectorFix = obj.checkSelectors(mx,my);
                        
                        
                    end
                    
                    if selectorFix
                        infix = 1;
                    end
                    
                    disp('Fixated on');
                    disp(selectorFix);
                    
                    
                    if ~infix
                        % TTL 11 -> Fixation on selector not achieved
                        sendTTLByte(11 , obj.stimPk.props.usingDataPixx);
                    else
                        % Set start time
                        fixateTime = GetSecs + obj.answerFixTime;
                        
                        while (GetSecs < fixateTime) && infix
                            if obj.checkErrorRecording()
                                break
                            end
                            
                            [mx, my] = obj.getEyeCoordinates();
                            
                            
                            answerFix = obj.checkSelectors(mx,my);
                            
                            % If the sight isn't on the selectors cancel
                            % trial
                            if  ~answerFix
                                % TTL 10 -> Broken selector fixation
                                sendTTLByte(10 , obj.stimPk.props.usingDataPixx);
                                infix = 0;
                            end
                            
                        end
                        
                        % If the answer is correct
                        if answerFix == obj.trialDirection(obj.trial)
                            % TTL 8 -> Succesful trial
                            sendTTLByte(8 , obj.stimPk.props.usingDataPixx);
                            Screen('FillOval', obj.window,[0 255 0], fixationOK);
                            if obj.props.usingLabJack
                                
                                timedTTL(obj.lJack,0,obj.props.rewardTime);
                            else
                                disp('Reward!');
                            end
                            
                        else
                            
                            % TTL 9 -> Wrong answer
                            sendTTLByte(9 , obj.stimPk.props.usingDataPixx);
                            Screen('FillOval', obj.window,[255 0 0], fixationOK);
                            
                        end
                        Screen('Flip',obj.window);
                        
                        
                    end
                    
                    
                    
                    
                end
                
                
                sprintf('Trial completed. Trial %d of %d\n', obj.trial, obj.numTrials);
                
                %%STOPPING EYE RECORDING AND CLEANING SCREEN
                % also send trial result data
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
                % Send out interest area information for the obj.trial
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
                    Eyelink('Message', '!V TRIAL_VAR trialOutcome %s', 'failed');
                end
                % STEP 9
                % Sending a 'TRIAL_RESULT' message to mark the end of a trial in
                % Data Viewer. This is different than the end of recording message
                % END that is logged when the trial recording ends. The viewer will
                % not parse any messages, events, or samples that exist in the data
                % file after this message.
                Eyelink('Message', 'TRIAL_RESULT 0');
                
                
                %%INTER TRIAL PAUSE --- MANAGE KEYBOARD AND CONTROL GUI EVENTS
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
                                sendTTLByte(7,obj.props.usingDataPixx);
                                
                                
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
                                    timedTTL(obj. lJack,0,500);
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
        
        
        function prepareGrating(obj)
            white=WhiteIndex(obj.props.stimScreen);
            black=BlackIndex(obj.props.stimScreen);
            obj.xGratingPos = obj.winWidth /2 -obj.visiblesize/2;
            obj.yGratingPos  = obj.winHeight/10;
            
            % Round gray to integral number, to avoid roundoff artifacts with some
            % graphics cards:
            gray=round((white+black)/2);
            if gray == white
                gray=white / 2;
            end
            inc=white-gray;
            
            % Calculate parameters of the grating:
            f=1/obj.p;
            fr=f*2*pi;    % frequency in radians.
            x=meshgrid(0:obj.visiblesize-1, 1);
            grating=gray + inc*cos(fr*x);
            obj.gratingtex=Screen('MakeTexture', obj.window, grating, [], 1);
            
            obj.ifi=Screen('GetFlipInterval', obj.window);
            obj.waitframes = 1;
            waitduration = obj.waitframes * obj.ifi;
            obj.shiftperframe= obj.cyclespersecond * obj.p * waitduration;
            obj.vbl=Screen('Flip', obj.window);
            obj.xoffset = 0;
            
            
        end
        
        function drawStimulus(obj,arrow,phase)
            % Shift the grating by "shiftperframe" pixels per frame:
            if (phase == 1)
                
                
                if arrow
                    if obj.trialDirection(obj.trial) > 0
                        rotation = 180;
                    else
                        rotation = 0;
                    end
                    drawArrow(obj.window, [obj.winWidth/2 obj.winHeight/3], rotation, [255 255 255 255], [100 100 100 100])
                    if (obj.randdir)
                        obj.xoffset = obj.xoffset - obj.shiftperframe;
                    else
                        obj.xoffset = obj.xoffset + obj.shiftperframe;
                        
                    end
                else
                    obj.xoffset = obj.xoffset - obj.shiftperframe*obj.trialDirection(obj.trial);
                    
                end
                
            else
                if (obj.randdir)
                    obj.xoffset = obj.xoffset - obj.shiftperframe;
                else
                    obj.xoffset = obj.xoffset + obj.shiftperframe;
                    
                end
            end
            
            % Define shifted srcRect that cuts out the properly shifted rectangular
            % area from the texture:
            srcRect=[obj.xoffset 0 obj.xoffset + obj.visiblesize obj.visiblesize];
            dstRect=[obj.xGratingPos obj.yGratingPos obj.xGratingPos+obj.visiblesize obj.yGratingPos+obj.visiblesize];
            % Draw grating texture: Only show subarea 'srcRect', center texture in
            % the onscreen window automatically:
            Screen('DrawTexture', obj.window, obj.gratingtex, srcRect, dstRect);
            
            % Flip 'waitframes' monitor refresh intervals after last redraw.
            obj.vbl = Screen('Flip', obj.window, obj.vbl + (obj.waitframes - 0.5) * obj.ifi);
        end
        
        function drawSelectors(obj)
            Screen('DrawDots', obj.window, [obj.winWidth/4 obj.winHeight/2], obj.dotSize, obj.dotColour, [], 2);
            Screen('DrawDots', obj.window, [obj.winWidth*3/4 obj.winHeight/2], obj.dotSize, obj.dotColour, [], 2);
        end
        
        function fix = checkSelectors(obj,mx,my)
            % determine if gx and gy are within fixation window
            if (mx > obj.leftSelectionWindow(1) && ...
                    mx <  obj.leftSelectionWindow(3) && ...
                    my > obj.leftSelectionWindow(2) && ...
                    my < obj.leftSelectionWindow(4))
                
                fix = -1;
                
            elseif (mx > obj.rightSelectionWindow(1) && ...
                    mx <  obj.rightSelectionWindow(3) && ...
                    my > obj.rightSelectionWindow(2) && ...
                    my < obj.rightSelectionWindow(4))
                
                fix = 1;
                
            else
                fix = 0;
            end
        end
        
        function sendCommand(obj, text)
            obj.externalControl = text;
            disp(obj.externalControl);
        end
        
        
        
    end
    
    
    
end

