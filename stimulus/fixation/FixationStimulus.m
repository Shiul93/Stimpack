classdef FixationStimulus < AbstractStimulus
    %TESTSTIMULUS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fixWinSize@double = 50;
        fixationWindow
        timeFix@double=0.5;
        stimulationTime@double = 5000;
        dotSize@double = 10;
        dotColour@double = [255 255 255 255]
        backgroundColour@double = [0 0 0 255]
        interTrialTime@double = 1;
        abortTime@double = 0.5;
        edfFile@char = '';
        pathsave@char = '';
        taskname@char = 'FixationTask';
        numTrials = Inf;
        externalControl@char = '';
        results@double = [0 0 0];
        testvar@double = 0;


    end
    
    methods
        
        function obj = FixationStimulus(args)
            
            obj.stimPk = args;
            obj.props = obj.stimPk.props;

        end
        
        function configureEDF(obj)

            disp('ConfigureEDF');
            % Obtain filename
           
            if obj.stimPk.props.usingEyelink
                num = clock;
                folder = ['FixationTask_' num2str(num(1)) '_' num2str(num(2)) '_' num2str(num(3)) '_'...
                          num2str(num(4)) '_' num2str(num(5)) '_' num2str(floor(num(6)))];  

                obj.pathsave=[obj.stimPk.props.path '/DATA/' folder];
                mkdir(obj.pathsave);
                rehash();

                if isempty(obj.edfFile)
                    obj.edfFile = 'FixTask';
                end
            end 
            
        end
        
        
        function controlUI(obj)
            %create an annotation object 
                        figure;

            ellipse_position = [0.4 0.6 0.1 0.2];
            ellipse_h = annotation('ellipse',ellipse_position,...
                                'facecolor', [1 0 0]);

            %create an editable textbox object
            edit_box_h = uicontrol('style','edit',...
                                'units', 'normalized',...
                                'position', [0.3 0.4 0.4 0.1]);
            but_h = uicontrol('style', 'pushbutton',...
                    'string', 'Update Color',...
                    'units', 'normalized',...
                    'position', [0.3 0 0.4 0.2],...
                    'callback', {@obj.dispShit,edit_box_h, ellipse_h });
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
            



            % repeat until we have 3 sucessful trials

            %EyelinkDoDriftCorrection(obj.el);

            stopTrial=false;
            experimentControlGUI(obj);
            obj.externalControl = '';

            while (trial <= obj.numTrials) || obj.numTrials == 0
              bar(obj.results);
              drawnow
              
               disp(sprintf('Trial nº%d',trial));
               
               % Stimulus dot
               fixationDot = [-obj.dotSize -obj.dotSize obj.dotSize obj.dotSize];
               fixationDot = CenterRect(fixationDot, obj.wRect);   
               
               % Green dot when succesful trial
               fixationOK = [-obj.dotSize-2 -obj.dotSize-2 obj.dotSize+2 obj.dotSize+2];
               fixationOK = CenterRect(fixationOK, obj.wRect); 

               % Set the fixation window on the center of the screen
               obj.fixationWindow = [-obj.fixWinSize -obj.fixWinSize obj.fixWinSize obj.fixWinSize];
               obj.fixationWindow = CenterRect(obj.fixationWindow, obj.wRect);

               % While not indicated to stop run trials
               if stopTrial==false

                % wait a second between trials
                % WaitSecs(1);
                
                
                % STEP 7.1
                % Sending a 'TRIALID' message to mark the start of a trial in Data
                % Viewer.  This is different than the start of recording message
                % START that is logged when the trial recording begins. The viewer
                % will not parse any messages, events, or samples, that exist in
                % the data file prior to this message.       
                Eyelink('Message', 'TRIALID %d', trial);
                % This supplies the title at the bottom of the eyetracker display
                if (obj.numTrials == Inf) || (obj.numTrials == 0)
                    Eyelink('command', 'record_status_message "TRIAL %d/Infinite"', trial);
                else
                    Eyelink('command', 'record_status_message "TRIAL %d/%d"', trial,obj.numTrials);
                end
                Eyelink('Command', 'set_idle_mode');
                % clear tracker display and draw box at center
                Eyelink('Command', 'clear_screen %d', 0);
                % draw fixation and fixation window shapes on host PC
                Eyelink('command', 'draw_cross %d %d 15', obj.winWidth/2,obj.winHeight/2);
                Eyelink('command', 'draw_box %d %d %d %d 15', obj.fixationWindow(1), obj.fixationWindow(2), obj.fixationWindow(3), obj.fixationWindow(4));

                % STEP 7.3
                % start recording eye position (preceded by a short pause so that
                % the tracker can finish the mode transition)
                % The paramerters for the 'StartRecording' call controls the
                % file_samples, file_events, link_samples, link_events availability

                Eyelink('Command', 'set_idle_mode');
                WaitSecs(0.05);
                Eyelink('StartRecording');
                eye_used = Eyelink('EyeAvailable'); % get eye that's tracked  
                % returns 0 (LEFT_EYE), 1 (RIGHT_EYE) or 2 (BINOCULAR) depending on what data is
                if eye_used == 2
                    eye_used = 1; % use the right_eye data
                end
                
                % record a few samples before we actually start displaying
                % otherwise you may lose a few msec of data
                WaitSecs(0.1);

                % STEP 7.4
                % Prepare and show the screen.
                Screen('BlendFunction', obj.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('FillRect', obj.window, obj.backgroundColour);
                Screen('FillOval', obj.window,obj.dotColour, fixationDot);
                Screen('Flip',obj.window);
                % Mark zero-plot time in data file
                Eyelink('Message', 'SYNCTIME');

                % TTL 1 -> Start of the trial
                sendTTL(1 , obj.stimPk.props.usingDataPixx);

                % get screen image from the first display to use as Data Viewer
                % trial overlay. Note this call is very slow and will affect your
                % timing for the first screen blanking
                if firstRun
                    imageArray = Screen('GetImage', obj.window);
                    firstRun =0;
                end
                
                fixating=0;        
                
                %Time to fixate
                fixateTime = GetSecs + obj.abortTime; % + 200/1000;
                graceTime = GetSecs; % + 200/1000;
                
                % Time of the fixation start
                fixationTime = -1;
                
                infix = 0;
                
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
                
                (fixationTime-GetSecs)*1000
               
                %Si pasa el tiempo y sigue fijado
                if infix
                    Screen('FillOval', obj.window,[0 255 0], fixationOK);
                    Screen('Flip',obj.window);
                    %disp('fixed success!!');
                    if obj.props.usingLabJack
                        timedTTL(lJack,0,obj.props.barewardTime);
                    else
                        disp('Reward!');
                    end
                    sendTTL(3, obj.stimPk.props.usingDataPixx);
                    obj.results(1) = obj.results(1)+1;

                    Eyelink('Message', 'Fixed Success :-)');
                    sprintf('Trial completed. Trial %d of %d\n', trial, obj.numTrials);
                    timeNow=GetSecs;
                    res(trial,1)=trial;
                    res(trial,2)=timeNow-graceTime;
                    %res(trial,3)=obj.fixWinSize;
                    %res(trial,4)=fixateTime;
                    %trial = trial + 1;
                        fixating=1;
                    WaitSecs(1);
                end        


                
                
                
                
                
                
                % STEP 7.5
                % add 100 msec of data to catch final events and blank display
                WaitSecs(0.1);
                Eyelink('StopRecording');

                index = index + 1;

                Screen('FillRect', obj.window, obj.backgroundColour);
                Screen('Flip', obj.window);

                %imwrite(imageArray, 'imgfile.jpg', 'jpg');
                Eyelink('Message', '!V IMGLOAD CENTER %s %d %d', 'imgfile.jpg', obj.winWidth/2, obj.winHeight/2);

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
                Eyelink('Message', '!V TRIAL_VAR index %d', index);
                Eyelink('Message', '!V TRIAL_VAR imgfile %s', 'imgfile.jpg');
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

                % Inter trial pause used for keyboard commands 
                timeEnd = GetSecs+obj.interTrialTime;
                
                while (obj.paused)||(GetSecs<timeEnd)
                drawnow
                  fInc = 150;
                  keyTicks = keyTicks + 1;  

                [keyIsDown, ~, keyCode] = KbCheck(-1); %#ok<*ASGLU>
                
                
                command = obj.externalControl;
                  
                if ~strcmp( command,'' ) 
                    disp('External control:');
                    disp(command);
                    switch command
                        case 'p'
                            disp('Paused change')
                           obj.paused=~obj.paused;
                           obj.externalControl = '';
                           command = '';
                       case 'q'
                            disp('End Experiment')
                           stopTrial=true;
                           obj.externalControl = '';
                           command = '';
                       

                           break
                    end
                    
                end 
                
                if keyIsDown == 1
                   pressKey = KbName(keyCode);   
                   switch pressKey
                       case 'p'
                           
                           obj.paused=~obj.paused;
                           break;
                       case 'q' %quit
                           stopTrial=true;
                           break;
                       case 'space'
                           if keyTicks > keyHoldq
                              timedTTL(lJack,0,500);
                              disp('reward!! (0.5 s)');
                              keyHold = keyTicks + fInc;
                                 end
                          case 'a'
                                 if keyTicks > keyHold
                                 obj.props.rewardTime=obj.props.rewardTime+10;
                                 fprintf('the new reward time is %d\n',obj.props.rewardTime);
                           keyHold = keyTicks + fInc;
                                 end	
                          case 'z'
                                 if keyTicks > keyHold
                                 obj.props.rewardTime=obj.props.rewardTime-10;
                                 fprintf('the new reward time is %d\n',obj.props.rewardTime);
                           keyHold = keyTicks + fInc;
                                 end	
                          case 's'
                                 if keyTicks > keyHold
                                 obj.dotSize=obj.dotSize+5;
                                 fprintf('the new dot size (in pixels) is %d\n',obj.dotSize);
                           keyHold = keyTicks + fInc;
                                 end
                          case 'x'
                                 if keyTicks > keyHold
                                 obj.dotSize=obj.dotSize-5;
                                 if obj.dotSize<0
                                     obj.dotSize=0;
                                 end
                                 fprintf('the new dot size (in pixels) is %d\n',obj.dotSize);
                           keyHold = keyTicks + fInc;
                                 end
                          case 'd'
                                 if keyTicks > keyHold
                                 obj.fixWinSize=obj.fixWinSize+5;
                                 fprintf('the new fix window size (in pixels) is %d\n',obj.fixWinSize);
                           keyHold = keyTicks + fInc;
                                 end
                          case 'c'
                                 if keyTicks > keyHold
                                 obj.fixWinSize=obj.fixWinSize-5;
                                 fprintf('the new fix window size (in pixels) is %d\n',obj.fixWinSize);
                           keyHold = keyTicks + fInc;
                                 end
                          case 'f'
                                 if keyTicks > keyHold
                                 obj.timeFix=obj.timeFix+0.05;
                                 fprintf('the new fix time (in ms) is %d\n',obj.timeFix*1000);
                           keyHold = keyTicks + fInc;
                                 end
                          case 'v'
                                 if keyTicks > keyHold
                                     obj.timeFix=obj.timeFix-0.05;
                                     if obj.timeFix<0.05
                                        obj.timeFix=0.05;
                                     end
                                     fprintf('the new fix time (in ms) is %d\n',obj.timeFix*1000);
                                     keyHold = keyTicks + fInc;
                                 end
                   end
                end
                end

                else break;
                end
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
                        source=['/Users/opticka/Desktop/oRioN/protocols/' obj.edfFile '.edf'];
                        destination = [obj.pathsave '/' obj.edfFile '.edf'];
                        movefile(source,destination);
                    end
                catch %#ok<*CTCH>
                    fprintf('Problem receiving data file ''%s''\n', obj.edfFile );
                end
            end
        end
        
        function fix = infixationWindow(obj,mx,my)
            % determine if gx and gy are within fixation window
            fix = mx > obj.fixationWindow(1) &&  mx <  obj.fixationWindow(3) && ...
            my > obj.fixationWindow(2) && my < obj.fixationWindow(4) ;
        end
        
        
        function [mx, my] = getEyeCoordinates(obj)
            if obj.props.usingEyelink
                                

                                if Eyelink( 'NewFloatSampleAvailable') > 0
                                    % get the sample in the form of an event structure
                                    evt = Eyelink( 'NewestFloatSample');
                                    evt.gx;
                                    evt.gy;

                                    if eye_used ~= -1 % do we know which eye to use yet?
                                        % if we do, get current gaze position from sample
                                        mx = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                                        my = evt.gy(eye_used+1);
                                        % do we have valid data and is the pupil visible?
                                        if mx~=obj.el.MISSING_DATA && my~=obj.el.MISSING_DATA && evt.pa(eye_used+1)>0
                                            %mx=x;
                                            %my=y;
                                        end
                                    end
                                end
                            else

                                % Query current mouse cursor position (our "pseudo-eyetracker") -
                                % (mx,my) is our gaze position.
                                [mx, my]=GetMouse(obj.window); %#ok<*NASGU>

            end
        end
        
        function sendCommand(obj, text)
            obj.externalControl = text;
            disp(obj.externalControl);
        end
            
       
    end
    
    
    
end

