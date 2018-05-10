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
            EyelinkInit(0,0);
            disp('Is connected')
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

