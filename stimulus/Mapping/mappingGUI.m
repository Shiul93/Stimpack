function varargout = mappingGUI(varargin)
% MAPPINGGUI MATLAB code for mappingGUI.fig
%      MAPPINGGUI, by itself, creates a new MAPPINGGUI or raises the existing
%      singleton*.
%
%      H = MAPPINGGUI returns the handle to a new MAPPINGGUI or the handle to
%      the existing singleton*.
%
%      MAPPINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAPPINGGUI.M with the given input arguments.
%
%      MAPPINGGUI('Property','Value',...) creates a new MAPPINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mappingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mappingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mappingGUI

% Last Modified by GUIDE v2.5 29-May-2018 13:45:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mappingGUI_OpeningFcn, ...
    'gui_OutputFcn',  @mappingGUI_OutputFcn, ...
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


% --- Executes just before mappingGUI is made visible.
function mappingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mappingGUI (see VARARGIN)

% Choose default command line output for mappingGUI
handles.output = hObject;
if nargin > 3
    handles.stimpack = varargin{1};
    handles.stimulus = MappingStimulus(handles.stimpack);
end

% Common options
set(handles.fixationTimeField,'String',handles.stimulus.timeFix*1000);
set(handles.abortTimeField,'String',handles.stimulus.waitingFixationTime*1000);
set(handles.rewardTimeField,'String',handles.stimpack.props.rewardTime);
set(handles.trialNumberField,'String',handles.stimulus.numTrials);
set(handles.interTrialTimeField,'String',handles.stimulus.interTrialTime*1000);
set(handles.edfField,'String',handles.stimulus.edfFile);

% Fixation options
set(handles.dotSizeField,'String',handles.stimulus.dotSize);
set(handles.windowSizeField,'String',handles.stimulus.fixWinSize);
set(handles.dotColorField,'String', num2str(handles.stimulus.dotColour));
set(handles.bgColorField,'String', num2str(handles.stimulus.backgroundColour));

% Stimulus options
set(handles.stimTimeField,'String',handles.stimulus.stimulationTime*1000);
set(handles.stimColorField,'String',num2str(handles.stimulus.stimColor));
handles.currentQbutton = handles.stimulus.stimQuadrant;
handles.currentSQbutton =  handles.stimulus.stimSubQuadrant;
handles.qArray =[ handles.q1button handles.q2button handles.q3button handles.q4button];
handles.sqArray =[ handles.sq1button handles.sq2button handles.sq3button handles.sq4button];
set(handles.qArray(handles.currentQbutton),'ForegroundColor','red');
if (handles.currentSQbutton > 0)
    set(handles.qArray(handles.currentSQbutton),'ForegroundColor','red');
end

if (handles.stimulus.autoQ)
    set(handles.autoQbutton,'ForegroundColor','red');
end

if (handles.stimulus.autoSQ)
    set(handles.autoSQbutton,'ForegroundColor','red');
end
% set(handles.Field,'String',handles.stimulus);




% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mappingGUI wait for user response (see UIRESUME)
% uiwait(handles.TaskName);


% --- Outputs from this function are returned to the command line.
function varargout = mappingGUI_OutputFcn(hObject, eventdata, handles)
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
disp('Cancel Mapping')
close(mappingGUI);
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
disp('dotSize callback');
handles.stimulus.dotSize = str2double(hObject.String);
disp(handles.stimulus.dotSize)

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
handles.stimulus.interTrialTime = str2double(hObject.String)/1000;


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
handles.stimulus.edfFile = hObject.String;


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


function stimTimeField_Callback(hObject, eventdata, handles)
% hObject    handle to stimTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stimTimeField as text
%        str2double(get(hObject,'String')) returns contents of stimTimeField as a double
handles.stimulus.stimulationTime = str2double(hObject.String)/1000;


% --- Executes during object creation, after setting all properties.
function stimTimeField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function stimColorField_Callback(hObject, eventdata, handles)
% hObject    handle to stimColorField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stimColorField as text
%        str2double(get(hObject,'String')) returns contents of stimColorField as a double
handles.stimulus.stimColor = str2double(strsplit(hObject.String));


% --- Executes during object creation, after setting all properties.
function stimColorField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimColorField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in q1button.
function q1button_Callback(hObject, eventdata, handles)
% hObject    handle to q1button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.qArray(handles.currentQbutton),'ForegroundColor','black');
handles.currentQbutton = 1;
handles.stimulus.stimQuadrant = 1;
set(hObject,'ForegroundColor','red');
guidata(hObject, handles);




% --- Executes on button press in q2button.
function q2button_Callback(hObject, eventdata, handles)
% hObject    handle to q2button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.qArray(handles.currentQbutton),'ForegroundColor','black');
handles.currentQbutton = 2;
handles.stimulus.stimQuadrant = 2;
set(hObject,'ForegroundColor','red');
guidata(hObject, handles);




% --- Executes on button press in q3button.
function q3button_Callback(hObject, eventdata, handles)
% hObject    handle to q3button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.qArray(handles.currentQbutton),'ForegroundColor','black');
handles.currentQbutton = 3;
handles.stimulus.stimQuadrant = 3;
set(hObject,'ForegroundColor','red');
guidata(hObject, handles);



% --- Executes on button press in q4button.
function q4button_Callback(hObject, eventdata, handles)
% hObject    handle to q4button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.qArray(handles.currentQbutton),'ForegroundColor','black');
handles.currentQbutton = 4;
handles.stimulus.stimQuadrant = 4;
set(hObject,'ForegroundColor','red');
guidata(hObject, handles);


% --- Executes on button press in sq1button.
function sq1button_Callback(hObject, eventdata, handles)
% hObject    handle to sq1button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.currentSQbutton > 0
    set(handles.sqArray(handles.currentSQbutton),'ForegroundColor','black');
end

if handles.currentSQbutton == 1
    handles.stimulus.stimSubQuadrant = 0;
    handles.currentSQbutton = 0;
else
    handles.stimulus.stimSubQuadrant = 1;
    handles.currentSQbutton = 1;
    set(handles.sqArray(handles.currentSQbutton),'ForegroundColor','red');
end
guidata(hObject, handles);




% --- Executes on button press in sq2button.
function sq2button_Callback(hObject, eventdata, handles)
% hObject    handle to sq2button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.currentSQbutton > 0
    set(handles.sqArray(handles.currentSQbutton),'ForegroundColor','black');
end

if handles.currentSQbutton == 2
    handles.stimulus.stimSubQuadrant = 0;
    handles.currentSQbutton = 0;
else
    handles.stimulus.stimSubQuadrant = 2;
    handles.currentSQbutton = 2;
    set(handles.sqArray(handles.currentSQbutton),'ForegroundColor','red');
end
guidata(hObject, handles);



% --- Executes on button press in sq3button.
function sq3button_Callback(hObject, eventdata, handles)
% hObject    handle to sq3button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.currentSQbutton > 0
    set(handles.sqArray(handles.currentSQbutton),'ForegroundColor','black');
end

if handles.currentSQbutton == 3
    handles.stimulus.stimSubQuadrant = 0;
    handles.currentSQbutton = 0;
else
    handles.stimulus.stimSubQuadrant = 3;
    handles.currentSQbutton = 3;
    set(handles.sqArray(handles.currentSQbutton),'ForegroundColor','red');
end
guidata(hObject, handles);




% --- Executes on button press in sq4button.
function sq4button_Callback(hObject, eventdata, handles)
% hObject    handle to sq4button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.currentSQbutton > 0
    set(handles.sqArray(handles.currentSQbutton),'ForegroundColor','black');
end

if handles.currentSQbutton == 4
    handles.stimulus.stimSubQuadrant = 0;
    handles.currentSQbutton = 0;
else
    handles.stimulus.stimSubQuadrant = 4;
    handles.currentSQbutton = 4;
    set(handles.sqArray(handles.currentSQbutton),'ForegroundColor','red');
end
guidata(hObject, handles);





% --- Executes on button press in autoQbutton.
function autoQbutton_Callback(hObject, eventdata, handles)
% hObject    handle to autoQbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.stimulus.autoQ)
    handles.stimulus.autoQ = false;
    set(hObject,'ForegroundColor','black');
else
    handles.stimulus.autoQ = true;
    set(hObject,'ForegroundColor','red');
end

% --- Executes on button press in autoSQbutton.
function autoSQbutton_Callback(hObject, eventdata, handles)
% hObject    handle to autoSQbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.stimulus.autoSQ)
    handles.stimulus.autoSQ = false;
    set(hObject,'ForegroundColor','black');
else
    handles.stimulus.autoSQ = true;
    set(hObject,'ForegroundColor','red');
end
