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

% Last Modified by GUIDE v2.5 22-Mar-2018 17:51:48

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


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in runButton.
function runButton_Callback(hObject, eventdata, handles)
% hObject    handle to runButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function fixationTimeField_Callback(hObject, eventdata, handles)
% hObject    handle to fixationTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fixationTimeField as text
%        str2double(get(hObject,'String')) returns contents of fixationTimeField as a double


% --- Executes during object creation, after setting all properties.
function fixationTimeField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fixationTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stimulationTimeField_Callback(hObject, eventdata, handles)
% hObject    handle to stimulationTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stimulationTimeField as text
%        str2double(get(hObject,'String')) returns contents of stimulationTimeField as a double


% --- Executes during object creation, after setting all properties.
function stimulationTimeField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimulationTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function abortTimeField_Callback(hObject, eventdata, handles)
% hObject    handle to abortTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of abortTimeField as text
%        str2double(get(hObject,'String')) returns contents of abortTimeField as a double


% --- Executes during object creation, after setting all properties.
function abortTimeField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to abortTimeField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
