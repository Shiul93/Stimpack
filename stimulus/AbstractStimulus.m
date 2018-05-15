classdef (Abstract) AbstractStimulus < handle
    %ABSTRACTSTIMULUS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        
        % Reference to global properties
        props@stimProps;
        % Reference to main class
        stimPk@stimpack;     
        
        lJack;

        el;
        paused@logical = false;
        
    end
    
    properties (Abstract = true)
        
        % EDF File to save experiment
        edfFile@char
        pathsave@char
        taskname@char
        
        
    end
    
    properties %(Access = protected)
        
        window
        wRect
        winWidth@double
        winHeight@double
        eyeUsed@double = 0
        
        
    end
    
    methods (Abstract)
        runTrials(obj);
        endExperiment(obj);
    end
    
    methods 
        
        

        function configureEDF(obj)
            disp('ConfigureEDF');
            % Obtain filename
           
            if obj.stimPk.props.usingEyelink
                num = clock;
                folder = [ obj.taskname '_' num2str(num(1)) '_' num2str(num(2)) '_' num2str(num(3)) '_'...
                          num2str(num(4)) '_' num2str(num(5)) '_' num2str(floor(num(6)))];  

                obj.pathsave=[obj.stimPk.props.path '/DATA/' folder];
                mkdir(obj.pathsave);
                rehash();

                if isempty(obj.edfFile)
                    obj.edfFile = obj.taskname;
                end
            end 
            
        end
            

        function setupDataPixxLabJack(obj)
            % labJack initializing
            if obj.props.usingLabJack
                obj.lJack = labJack('name','runinstance','openNow',1,'readResponse', false,'verbose',true);
            end
            % dataPixx initializing
            if obj.props.usingDataPixx
                Datapixx('Open');
                Datapixx('StopAllSchedules');
                Datapixx('RegWrRd');    % Synchronize Datapixx registers to local register cache
            end
        end
        function setupScreen(obj)
            % Open a graphics window on the main screen
            % using the PsychToolbox's Screen function.
            %screenNumber=max(Screen('Screens'));
            
            if obj.props.ptbSkipSync
                Screen('Preference', 'SkipSyncTests', 1);
            else
                Screen('Preference', 'SkipSyncTests', 0);
            end
            if isempty(obj.props.stimScreen)
                screenNumber=max(Screen('Screens'));
            else
                screenNumber = obj.props.stimScreen;
            end
            [obj.window, obj.wRect]=Screen('OpenWindow', screenNumber, 0,[],32,2);
            Screen(obj.window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            [obj.winWidth, obj.winHeight] = WindowSize(obj.window);
        end
        
        function configureEyelink(obj)
            % Close the connection if EyeLink is already connected
            if Eyelink('IsConnected')
                disp('Restarting connection to eyelink')
                Eyelink('Command', 'clear_screen %d', 0);
                Eyelink('Shutdown');            
            end

            % Provide Eyelink with details about the graphics environment
            % and perform some initializations. The information is returned
            % in a structure that also contains useful defaults
            % and control codes (e.g. tracker state bit and Eyelink key values).
            Eyelink('SetAddress', obj.stimPk.props.eyelinkIp);
            
            obj.el=EyelinkInitDefaults(obj.window);

            % We are changing calibration to a black background with white targets,
            % no sound and smaller targets
            
            % Colors of the initial eyelink window
            obj.el.backgroundcolour = BlackIndex(obj.el.window);
            obj.el.msgfontcolour  = WhiteIndex(obj.el.window);
            obj.el.imgtitlecolour = WhiteIndex(obj.el.window);
            obj.el.targetbeep = 0;
            obj.el.calibrationtargetcolour = WhiteIndex(obj.el.window);

            % for lower resolutions you might have to play around with these values
            % a little. If you would like to draw larger targets on lower res
            % settings please edit PsychEyelinkDispatchCallback.m and see comments
            % in the EyelinkDrawCalibrationTarget function
            obj.el.calibrationtargetsize= 1;
            obj.el.calibrationtargetwidth=0.5;
            % call this function for changes to the calibration structure to take
            % affect
            EyelinkUpdateDefaults(obj.el);
        end
        
        function connectToEyelink(obj)
            % Initialization of the connection with the Eyelink Gazetracker.
            % exit program if this fails.

            %if ~EyelinkInit(~obj.props.usingEyelink,1)
            %    fprintf('Eyelink Init aborted.\n');
            %    obj.cleanup;  % cleanup function
            %    return;
            %end
            
            if obj.props.usingEyelink
                % EyelinkInit(0,0);
                if ~EyelinkInit(0,1)
                    fprintf('Eyelink Init aborted.\n');
                    obj.cleanup;  % cleanup function
                    return;
                end
            elseif ~EyelinkInit(1,1)
                fprintf('Eyelink Init aborted.\n');
                obj.cleanup;  % cleanup function
                return;
            end
            disp('Is connected?')
            Eyelink('IsConnected')
            % open file to record data to
            i = Eyelink('Openfile', obj.edfFile);
            if i~=0
                fprintf('Cannot create EDF file ''%s'' ', obj.edfFile);
                obj.cleanup;
                return;
            end

            % make sure we're still connected.
            %if Eyelink('IsConnected')~=1 && obj.props.usingEyelink

            %if Eyelink('IsConnected') && obj.props.usingEyelink
            %    obj.cleanup;
            %    return;
            %end;
        end
        
        function configureTracker(obj)
            
            
            % SET UP TRACKER CONFIGURATION
            % Setting the proper recording resolution, proper calibration type,
            % as well as the data file content;
            Eyelink('command', 'add_file_preamble_text ''Recorded by stimpack''');

            % This command is crucial to map the gaze positions from the tracker to
            % screen pixel positions to determine fixation
            Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, obj.winWidth-1, obj.winHeight-1);

            Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, obj.winWidth-1, obj.winHeight-1);
            % set calibration type.
            Eyelink('command', 'calibration_type = HV9');
            Eyelink('command', 'generate_default_targets = YES');
            % set parser (conservative saccade thresholds)
            Eyelink('command', 'saccade_velocity_threshold = 35');
            Eyelink('command', 'saccade_acceleration_threshold = 9500');
            % set EDF file contents
                % 5.1 retrieve tracker version and tracker software version
            [v,vs] = Eyelink('GetTrackerVersion');
            fprintf('Running experiment on a ''%s'' tracker.\n', vs );
            vsn = regexp(vs,'\d','match');

            if v ==3 && str2double(vsn{1}) == 4 % if EL 1000 and tracker version 4.xx

                % remote mode possible add HTARGET ( head target)
                Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
                Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT,HTARGET');
                % set link data (used for gaze cursor)
                Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
                Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT,HTARGET');
            else
                Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
                Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
                % set link data (used for gaze cursor)
                Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
                Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
            end

            % calibration/drift correction target
            Eyelink('command', 'button_function 5 "accept_target_fixation"');
            
            obj.eyeUsed = Eyelink('EyeAvailable'); % get eye that's tracked  
            % returns 0 (LEFT_EYE), 1 (RIGHT_EYE) or 2 (BINOCULAR) depending on what data is
            if obj.eyeUsed == 2
                obj.eyeUsed = 1; % use the right_eye data
            end
            
        end
        
        function checkDummy(obj)
            if obj.props.usingEyelink
            % Hide the mouse cursor and setup the eye calibration window
            %Screen('HideCursorHelper', obj.window);
            end
            % enter Eyetracker camera setup mode, calibration and validation
            EyelinkDoTrackerSetup(obj.el);
            
        end
        
        function runStimulus(obj)

            obj.configureEDF()
            obj.setupDataPixxLabJack()
            obj.setupScreen()
            obj.configureEyelink()
            obj.connectToEyelink()
            obj.configureTracker()
            obj.checkDummy()
            obj.runTrials()
            obj.endExperiment()
            obj.cleanup()
                
        end
        
        function [mx, my] = getEyeCoordinates(obj)
            mx=0;
            my=0;
            if obj.props.usingEyelink
                                
                obj.eyeUsed = 1;
                if Eyelink( 'NewFloatSampleAvailable') > 0
                    % get the sample in the form of an event structure
                    evt = Eyelink( 'NewestFloatSample');
                    evt.gx;
                    evt.gy;

                    if obj.eyeUsed ~= -1 % do we know which eye to use yet?
                        % if we do, get current gaze position from sample
                        mx = evt.gx(obj.eyeUsed+1); % +1 as we're accessing MATLAB array
                        my = evt.gy(obj.eyeUsed+1);
                        % do we have valid data and is the pupil visible?
                        if mx~=obj.el.MISSING_DATA && my~=obj.el.MISSING_DATA && evt.pa(obj.eyeUsed+1)>0
                            mx=x;
                            my=y;
                        end
                    end
                end
            else

                % Query current mouse cursor position (our "pseudo-eyetracker") -
                % (mx,my) is our gaze position.
                [mx, my]=GetMouse(obj.window); %#ok<*NASGU>

            end
        end
        
        function fix = infixationWindow(obj,mx,my)
            % determine if gx and gy are within fixation window
            fix = mx > obj.fixationWindow(1) &&  mx <  obj.fixationWindow(3) && ...
            my > obj.fixationWindow(2) && my < obj.fixationWindow(4) ;
        end
        
        function eyelinkStartRecording(obj)
            % EYELINKSTARTRECORDING
            %
            % start recording eye position (preceded by a short pause so that
            % the tracker can finish the mode transition)
            % The paramerters for the 'StartRecording' call controls the
            % file_samples, file_events, link_samples, link_events availability
            
            Eyelink('Command', 'set_idle_mode');
            WaitSecs(0.05);
            Eyelink('StartRecording');
            
            % get eye that's being tracked
            % returns 0 (LEFT_EYE), 1 (RIGHT_EYE) or 2 (BINOCULAR)
            % depending on what data is
            obj.eyeUsed = Eyelink('EyeAvailable'); 
            
            if obj.eyeUsed == 2
                obj.eyeUsed = 1; % use the right_eye data
            end

            % record a few samples before we actually start displaying
            % otherwise you may lose a few msec of data
            WaitSecs(0.1);
        end
  
        function dataViewerTrialInfo(obj,trialNumber)
            % DATAVIEWERTRIALINFO 
            %
            % Sending a 'TRIALID' message to mark the start of a trial in Data
            % Viewer.  This is different than the start of recording message
            % START that is logged when the trial recording begins. The viewer
            % will not parse any messages, events, or samples, that exist in
            % the data file prior to this message.
            disp(sprintf('Trial nº%d',trialNumber));

            Eyelink('Message', 'TRIALID %d', trialNumber);
            % This supplies the title at the bottom of the eyetracker display
            if (obj.numTrials == Inf) || (obj.numTrials == 0)
                Eyelink('command', 'record_status_message "TRIAL %d/Infinite"', trialNumber);
            else
                Eyelink('command', 'record_status_message "TRIAL %d/%d"', trialNumber,obj.numTrials);
            end
            Eyelink('Command', 'set_idle_mode');
            % clear tracker display and draw box at center
            Eyelink('Command', 'clear_screen %d', 0);
            % draw fixation and fixation window shapes on host PC
            Eyelink('command', 'draw_cross %d %d 15', obj.winWidth/2,obj.winHeight/2);
            Eyelink('command', 'draw_box %d %d %d %d 15', obj.fixationWindow(1), obj.fixationWindow(2), obj.fixationWindow(3), obj.fixationWindow(4));
        end
        
        function drawFixationPoint(obj, fixationDot)

            Screen('BlendFunction', obj.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('FillRect', obj.window, obj.backgroundColour);
            Screen('FillOval', obj.window,obj.dotColour, fixationDot);
            Screen('Flip',obj.window);
        end
    end
    
    methods(Static)
        function cleanup()
            % Shutdown Eyelink:
            Eyelink('Command', 'clear_screen %d', 0);
            Eyelink('Shutdown');
            Screen('CloseAll');
        end
        
        
    end
end

