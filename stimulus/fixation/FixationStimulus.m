classdef FixationStimulus < AbstractStimulus
    %TESTSTIMULUS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        edfFile@char = 'asd';
        fixWinSize@double = 50;
        fixationWindow
        timeFix@double=0.5;
        dotSize@double = 10;

    end
    
    methods
        
        function obj = FixationStimulus(args)
            
            obj.stimPk = args;
            obj.props = obj.stimPk.props;

        end
        
        function configureEDF(obj)
            disp('ConfigureEDF');
        end
        
        function runTrials(obj)
            disp('runTrials');
            trial = 1;
            numTrials = 25;
            index = 1;
            
            firstRun = 1;
            infix = 0;
            keyTicks = 0;
            keyHold = 1;



            % repeat until we have 3 sucessful trials

            %EyelinkDoDriftCorrection(el);

            stopTrial=false;

            while trial <= numTrials

                 fixationDot = [-obj.dotSize -obj.dotSize obj.dotSize obj.dotSize];
                 fixationDot = CenterRect(fixationDot, obj.wRect);   
               fixationOK = [-obj.dotSize+2 -obj.dotSize+2 obj.dotSize+2 obj.dotSize+2];
               fixationOK = CenterRect(fixationOK, obj.wRect);  
               obj.fixationWindow = [-obj.fixWinSize -obj.fixWinSize obj.fixWinSize obj.fixWinSize];
               obj.fixationWindow = CenterRect(obj.fixationWindow, obj.wRect);

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
                Eyelink('command', 'record_status_message "TRIAL %d/%d"', trial,numTrials);
                Eyelink('Command', 'set_idle_mode');
                % clear tracker display and draw box at center
                Eyelink('Command', 'clear_screen %d', 0);
                % draw fixation and fixation window shapes on host PC
                Eyelink('command', 'draw_cross %d %d 15', obj.winWidth/2,obj.winHeight/2);
                Eyelink('command', 'draw_box %d %d %d %d 15', obj.fixationWindow(1), obj.fixationWindow(2), obj.fixationWindow(3), obj.fixationWindow(4));

                % STEP 7.2
                % Do a drift correction at the beginning of each trial
                % Performing drift correction (checking) is optional for
                % EyeLink 1000 eye trackers. Drift correcting at different
                % locations x and y depending on where the ball will start
                % we change the location of the drift correction to match that of
                % the target start position


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
                Screen('FillRect', obj.window, obj.el.backgroundcolour);
                Screen('FillOval', obj.window,[255 255 255], fixationDot);
                Screen('Flip',obj.window);
                Eyelink('Message', 'SYNCTIME');

                sendTTL(1);

                % get screen image from the first display to use as Data Viewer
                % trial overlay. Note this call is very slow and will affect your
                % timing for the first screen blanking
                if firstRun
                    imageArray = Screen('GetImage', obj.window);
                    firstRun =0;
                end
                fixating=0;        
                % set fixation display to be randomly chose between 650 and 1500
                fixateTime = GetSecs + obj.timeFix + 200/1000;
                graceTime = GetSecs + 200/1000;
                while GetSecs < fixateTime

                    if obj.props.usingEyelink
                        error=Eyelink('CheckRecording');
                        if(error~=0)
                            break;
                        end

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
                    if obj.infixationWindow(mx,my) && ~infix

                        Eyelink('Message', 'Fixation Start');
                        %Beeper(el.calibration_success_beep(1), el.calibration_success_beep(2), el.calibration_success_beep(3));
                        infix = 1;
                    elseif ~obj.infixationWindow(mx,my) && infix && GetSecs > graceTime

                        %Screen('DrawTexture', obj.window, sad);
                        %Screen('Flip',obj.window);
                        disp('broke fix');
                        Eyelink('Message', 'Fixation broke or grace time ended');
                        sendTTL(2);
                        infix = 0;
                             fixating=1;
                        break;
                    end
                end

                if infix
                    Screen('FillOval', obj.window,[0 255 0], fixationOK);
                    Screen('Flip',obj.window);
                    disp('fixed success!!');
                    if obj.props.usingLabJack
                        timedTTL(lJack,0,rewardTime);
                    else
                        disp('Reward!');
                    end
                    sendTTL(3);
                    Eyelink('Message', 'Fixed Success :-)');
                    sprintf('Trial completed. Trial %d of %d\n', trial, numTrials);
                    timeNow=GetSecs;
                    res(trial,1)=trial;
                    res(trial,2)=timeNow-graceTime;
                    %res(trial,3)=obj.fixWinSize;
                    %res(trial,4)=fixateTime;
                    trial = trial + 1;
                        fixating=1;
                    WaitSecs(1);
                end        
                if fixating==0
                      disp('not fix');
                      sendTTL(3);
                end

                % STEP 7.5
                % add 100 msec of data to catch final events and blank display
                WaitSecs(0.1);
                Eyelink('StopRecording');

                index = index + 1;

                Screen('FillRect', obj.window, obj.el.backgroundcolour);
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

                timeEnd = GetSecs+1;

                while GetSecs<timeEnd

                  fInc = 150;
                  keyTicks = keyTicks + 1;  

                [keyIsDown, ~, keyCode] = KbCheck(-1); %#ok<*ASGLU>

                if keyIsDown == 1
                   pressKey = KbName(keyCode);   
                   switch pressKey
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

            end
        end
        
        function endExperiment(obj)
            disp('endExperiment');
        end
        
        function fix = infixationWindow(obj,mx,my)
            % determine if gx and gy are within fixation window
            fix = mx > obj.fixationWindow(1) &&  mx <  obj.fixationWindow(3) && ...
            my > obj.fixationWindow(2) && my < obj.fixationWindow(4) ;
        end
        
        
        
    end
    
end

