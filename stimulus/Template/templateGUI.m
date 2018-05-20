function varargout = templateGUI(varargin)
% TEMPLATEGUI MATLAB code for templateGUI.fig
%      TEMPLATEGUI, by itself, creates a new TEMPLATEGUI or raises the existing
%      singleton*.
%
%      H = TEMPLATEGUI returns the handle to a new TEMPLATEGUI or the handle to
%      the existing singleton*.
%
%      TEMPLATEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEMPLATEGUI.M with the given input arguments.
%
%      TEMPLATEGUI('Property','Value',...) creates a new TEMPLATEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before templateGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to templateGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help templateGUI

% Last Modified by GUIDE v2.5 16-May-2018 18:05:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @templateGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @templateGUI_OutputFcn, ...
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


% --- Executes just before templateGUI is made visible.
function templateGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to templateGUI (see VARARGIN)

% Choose default command line output for templateGUI
handles.output = hObject;
if nargin > 3
    handles.stimpack = varargin{1};
    handles.stimulus = FixationStimulus(handles.stimpack);
end


% Common options
set(handles.fixationTimeField,'String',handles.stimulus.timeFix*1000);
set(handles.abortTimeField,'String',handles.stimulus.waitingFixationTime*1000);
set(handles.rewardTimeField,'String',handles.stimpack.props.rewardTime);
set(handles.trialNumberField,'String',handles.stimulus.numTrials);
set(handles.interTrialTimeField,'String',handles.stimulus.interTrialTime*1000);
set(handles.edfField,'String',handles.stimulusedfFile);

% Fixation options
set(handles.dotSizeField,'String',handles.stimulus.dotSize);
set(handles.windowSizeField,'String',handles.stimulus.fixWinSize);
set(handles.dotColorField,'String', num2str(handles.stimulus.dotColour));
set(handles.bgColorField,'String', num2str(handles.stimulus.backgroundColour)); 

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes templateGUI wait for user response (see UIRESUME)
% uiwait(handles.TaskName);


% --- Outputs from this function are returned to the command line.
function varargout = templateGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in runButton.
function runButton_Callback(hObject, eventdata, handles)
disp('Run Fixation');

handles.stimulus.runStimulus();

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
disp('Cancel Fixation')
close(fixationGUI);
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
handles.stimulus.dotSize = str2double(hObject.String)


% --- Executes during object creation, after setting all properties.
function dotSizeField_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function windowSizeField_Callback(hObject, eventdata, handles)
disp('fixationTime Callback');
disp(hObject.String)
handles.stimulus.fixWinSize = str2double(hObject.String)

% --- Executes during object creation, after setting all properties.
function windowSizeField_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stimulusColorField_Callback(hObject, eventdata, handles)
handles.stimulus.dotColour = str2double(strsplit(hObject.String));



% --- Executes during object creation, after setting all properties.
function stimulusColorField_CreateFcn(hObject, eventdata, handles)
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
handles.stimulus.numTrials = str2double(hObject.String);


% --- Executes during object creation, after setting all properties.
function trialNumberField_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function displayThis()
disp('Displaying this shit')
