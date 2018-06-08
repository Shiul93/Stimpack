function varargout = workingMemoryGUI(varargin)
% WORKINGMEMORYGUI MATLAB code for workingMemoryGUI.fig
%      WORKINGMEMORYGUI, by itself, creates a new WORKINGMEMORYGUI or raises the existing
%      singleton*.
%
%      H = WORKINGMEMORYGUI returns the handle to a new WORKINGMEMORYGUI or the handle to
%      the existing singleton*.
%
%      WORKINGMEMORYGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WORKINGMEMORYGUI.M with the given input arguments.
%
%      WORKINGMEMORYGUI('Property','Value',...) creates a new WORKINGMEMORYGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before workingMemoryGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to workingMemoryGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help workingMemoryGUI

% Last Modified by GUIDE v2.5 07-Jun-2018 19:42:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @workingMemoryGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @workingMemoryGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before workingMemoryGUI is made visible.
function workingMemoryGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to workingMemoryGUI (see VARARGIN)

% Choose default command line output for workingMemoryGUI
handles.output = hObject;
if nargin > 3
    handles.stimpack = varargin{1};
    handles.stimulus = WorkingMemoryStimulus(handles.stimpack);
end


% Common options
set(handles.fixationTimeField,'String',handles.stimulus.timeFix*1000);
set(handles.abortTimeField,'String',handles.stimulus.waitingFixationTime*1000);
set(handles.rewardTimeField,'String',handles.stimpack.props.rewardTime);
set(handles.trialNumberField,'String',handles.stimulus.numTrials);
set(handles.interTrialTimeField,'String',handles.stimulus.interTrialTime*1000);
set(handles.edfField,'String',handles.stimulus.edfFile);

% Fixation options
set(handles.dotSizeField,'String',handles.stimulus.dotSizeDegrees);
set(handles.windowSizeField,'String',handles.stimulus.fixWinSizeDegrees);
set(handles.dotColorField,'String', num2str(handles.stimulus.dotColour));
set(handles.bgColorField,'String', num2str(handles.stimulus.backgroundColour)); 

set(handles.s1TimeField,'String',handles.stimulus.s1Time*1000);
set(handles.gratingDelayField,'String',handles.stimulus.gratingDelay*1000);
set(handles.s2TimeField,'String',handles.stimulus.s2Time*1000);
set(handles.answerTimeField,'String', num2str(handles.stimulus.answerTime*1000));
set(handles.answerFixTimeField,'String', num2str(handles.stimulus.answerFixTime*1000));

set(handles.spatFreqField,'String',handles.stimulus.spatialFreq);
set(handles.tempFreqField,'String',handles.stimulus.temporalFreq);
set(handles.gratPosField,'String', num2str(handles.stimulus.gratPosDegrees));
set(handles.gratOriField,'String', handles.stimulus.gratingRotation);

handles.stimulus.axes = handles.axes;

if (handles.stimulus.showArrow)
    set(handles.arrowButton,'ForegroundColor','red');
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes workingMemoryGUI wait for user response (see UIRESUME)
% uiwait(handles.TaskName);


% --- Outputs from this function are returned to the command line.
function varargout = workingMemoryGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in runButton.
function runButton_Callback(hObject, eventdata, handles)

if ~handles.stimulus.running
    disp('Run Fixation');
    set(handles.trialNumberField, 'enable', 'off')

    handles.stimulus.runStimulus();
end

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
disp('Cancel Fixation')
set(handles.pauseButton,'string','PAUSE')
handles.stimulus.externalControl = 'q';
close(workingMemoryGUI);
handles.stimpack.initialiseGUI();



function fixationTimeField_Callback(hObject, eventdata, handles)
disp('fixationTime Callback');
disp(hObject.String)
handles.stimulus.timeFix = str2double(hObject.String)/1000;


% --- Executes during object creation, after setting all properties.
function fixationTimeField_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function abortTimeField_Callback(hObject, eventdata, handles)
disp('abortTime Callback');
disp(hObject.String)

handles.stimulus.waitingFixationTime = str2double(hObject.String)/1000;

% --- Executes during object creation, after setting all properties.
function abortTimeField_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rewardTimeField_Callback(hObject, eventdata, handles)
handles.stimpack.props.rewardTime = str2double(hObject.String);


% --- Executes during object creation, after setting all properties.
function rewardTimeField_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dotSizeField_Callback(hObject, eventdata, handles)
disp('fixationTime Callback');
disp(hObject.String)
handles.stimulus.dotSizeDegrees = str2double(hObject.String);


% --- Executes during object creation, after setting all properties.
function dotSizeField_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function windowSizeField_Callback(hObject, eventdata, handles)
disp('fixationTime Callback');
disp(hObject.String)
handles.stimulus.fixWinSizeDegrees = str2double(hObject.String);

% --- Executes during object creation, after setting all properties.
function windowSizeField_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dotColorField_Callback(hObject, eventdata, handles)
handles.stimulus.dotColour = str2double(strsplit(hObject.String));



% --- Executes during object creation, after setting all properties.
function dotColorField_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bgColorField_Callback(hObject, eventdata, handles)
handles.stimulus.backgroundColour = str2double(strsplit(hObject.String));



% --- Executes during object creation, after setting all properties.
function bgColorField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bgColorField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function interTrialTimeField_Callback(hObject, eventdata, handles)
% hObject    handle to interTrialTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of interTrialTimeField as text
%        str2double(get(hObject,'String')) returns contents of interTrialTimeField as a double


% --- Executes during object creation, after setting all properties.
function interTrialTimeField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interTrialTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edfField_Callback(hObject, eventdata, handles)
% hObject    handle to edfField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edfField as text
%        str2double(get(hObject,'String')) returns contents of edfField as a double
handles.stimulus.edfFile = hObject.String


% --- Executes during object creation, after setting all properties.
function edfField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edfField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trialNumberField_Callback(hObject, eventdata, handles)
handles.stimulus.numTrials = floor(str2double(hObject.String)/2)*2;
set(hObject,'String',handles.stimulus.numTrials);


% --- Executes during object creation, after setting all properties.
function trialNumberField_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in scaButton.
function scaButton_Callback(hObject, eventdata, handles)
% hObject    handle to scaButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sca

% --- Executes on button press in sendMarkButton.
function sendMarkButton_Callback(hObject, eventdata, handles)
% hObject    handle to sendMarkButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stimulus.externalControl = 'm';


% --- Executes on button press in rewardButton.
function rewardButton_Callback(hObject, eventdata, handles)
% hObject    handle to rewardButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stimulus.externalControl = 'r';


% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stimulus.externalControl = 'p';
if handles.stimulus.paused
    set(hObject,'string','PAUSE')
else
    set(hObject,'string','RESUME')
end

% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pauseButton,'string','PAUSE')
set(handles.trialNumberField, 'enable', 'on')

handles.stimulus.externalControl = 'q';



function s1TimeField_Callback(hObject, eventdata, handles)
% hObject    handle to s1TimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of s1TimeField as text
%        str2double(get(hObject,'String')) returns contents of s1TimeField as a double
handles.stimulus.s1Time = str2double(strsplit(hObject.String))/1000;


% --- Executes during object creation, after setting all properties.
function s1TimeField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to s1TimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gratingDelayField_Callback(hObject, eventdata, handles)
% hObject    handle to gratingDelayField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gratingDelayField as text
%        str2double(get(hObject,'String')) returns contents of gratingDelayField as a double
handles.stimulus.gratingDelay = str2double(strsplit(hObject.String))/1000;


% --- Executes during object creation, after setting all properties.
function gratingDelayField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gratingDelayField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function s2TimeField_Callback(hObject, eventdata, handles)
% hObject    handle to s2TimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of s2TimeField as text
%        str2double(get(hObject,'String')) returns contents of s2TimeField as a double
handles.stimulus.s2Time = str2double(strsplit(hObject.String))/1000;


% --- Executes during object creation, after setting all properties.
function s2TimeField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to s2TimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function answerTimeField_Callback(hObject, eventdata, handles)
% hObject    handle to answerTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of answerTimeField as text
%        str2double(get(hObject,'String')) returns contents of answerTimeField as a double
handles.stimulus.answerTime = str2double(strsplit(hObject.String))/1000;


% --- Executes during object creation, after setting all properties.
function answerTimeField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to answerTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function answerFixTimeField_Callback(hObject, eventdata, handles)
% hObject    handle to answerFixTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of answerFixTimeField as text
%        str2double(get(hObject,'String')) returns contents of answerFixTimeField as a double
handles.stimulus.answerFixTime = str2double(strsplit(hObject.String))/1000;


% --- Executes during object creation, after setting all properties.
function answerFixTimeField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to answerFixTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in arrowButton.
function arrowButton_Callback(hObject, eventdata, handles)
% hObject    handle to arrowButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.stimulus.showArrow
    handles.stimulus.showArrow = false;
    set(handles.arrowButton,'ForegroundColor','black');

else
    handles.stimulus.showArrow = true;
    set(handles.arrowButton,'ForegroundColor','red');

end
    
    
    
    
    
    
    



function spatFreqField_Callback(hObject, eventdata, handles)
% hObject    handle to spatFreqField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spatFreqField as text
%        str2double(get(hObject,'String')) returns contents of spatFreqField as a double
handles.stimulus.spatialFreq = str2double(hObject.String);


% --- Executes during object creation, after setting all properties.
function spatFreqField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spatFreqField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tempFreqField_Callback(hObject, eventdata, handles)
% hObject    handle to tempFreqField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tempFreqField as text
%        str2double(get(hObject,'String')) returns contents of tempFreqField as a double
handles.stimulus.temporalFreq = str2double(hObject.String);


% --- Executes during object creation, after setting all properties.
function tempFreqField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tempFreqField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gratPosField_Callback(hObject, eventdata, handles)
% hObject    handle to gratPosField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gratPosField as text
%        str2double(get(hObject,'String')) returns contents of gratPosField as a double
handles.stimulus.gratPosDegrees = str2double(strsplit(hObject.String));


% --- Executes during object creation, after setting all properties.
function gratPosField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gratPosField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gratOriField_Callback(hObject, eventdata, handles)
% hObject    handle to gratOriField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gratOriField as text
%        str2double(get(hObject,'String')) returns contents of gratOriField as a double
handles.stimulus.gratingRotation = str2double(hObject.String);


% --- Executes during object creation, after setting all properties.
function gratOriField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gratOriField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
