function varargout = stimGUI(varargin)
% STIMGUI MATLAB code for stimGUI.fig
%      STIMGUI, by itself, creates a new STIMGUI or raises the existing
%      singleton*.
%
%      H = STIMGUI returns the handle to a new STIMGUI or the handle to
%      the existing singleton*.
%
%      STIMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMGUI.M with the given input arguments.
%
%      STIMGUI('Property','Value',...) creates a new STIMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stimGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stimGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stimGUI

% Last Modified by GUIDE v2.5 31-May-2018 19:09:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stimGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @stimGUI_OutputFcn, ...
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


% --- Executes just before stimGUI is made visible.
function stimGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stimGUI (see VARARGIN)

% Choose default command line output for stimGUI
handles.output = hObject;
disp('STIMGUI');
disp(nargin)
if nargin > 3
    disp(varargin{1});
    handles.stimpack = varargin{1};
    handles.props = handles.stimpack.props;
end

set(handles.skypsyncCheckbox,'value',handles.props.ptbSkipSync);
set(handles.eyelinkCheckbox,'value',handles.props.usingEyelink);
set(handles.datapixxCheckbox,'value',handles.props.usingDataPixx);
set(handles.labjackCheckbox,'value',handles.props.usingLabJack);
set(handles.monitorField,'String',handles.props.stimScreen);

% Update handles structure


guidata(hObject, handles);

% UIWAIT makes stimGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = stimGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in fixationButton.
function fixationButton_Callback(hObject, eventdata, handles)
% hObject    handle to fixationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    disp('FIXATIONBUTTON')
    disp(handles.stimpack)
    close(stimGUI)
    fixationGUI(handles.stimpack)


% --- Executes on button press in mappingButton.
function mappingButton_Callback(hObject, eventdata, handles)
% hObject    handle to mappingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    disp('MAPPINGBUTTON')
    disp(handles.stimpack)
    close(stimGUI)
    mappingGUI(handles.stimpack)

% --- Executes on button press in skypsyncCheckbox.
function skypsyncCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to skypsyncCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of skypsyncCheckbox
if get(hObject,'Value')
    handles.props.ptbSkipSync = true;
else
    handles.props.ptbSkipSync =false;
end



function monitorField_Callback(hObject, eventdata, handles)
% hObject    handle to monitorField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of monitorField as text
%        str2double(get(hObject,'String')) returns contents of monitorField as a double
handles.props.stimScreen = str2double(get(hObject,'String'))

% --- Executes during object creation, after setting all properties.
function monitorField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to monitorField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in eyelinkCheckbox.
function eyelinkCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to eyelinkCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of eyelinkCheckbox
if get(hObject,'Value')
    handles.props.usingEyelink = true;
else
    handles.props.usingEyelink =false;
end

% --- Executes on button press in datapixxCheckbox.
function datapixxCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to datapixxCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of datapixxCheckbox
if get(hObject,'Value')
    handles.props.usingDataPixx = true;
else
    handles.props.usingDataPixx =false;
end

% --- Executes on button press in labjackCheckbox.
function labjackCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to labjackCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of labjackCheckbox
if get(hObject,'Value')
    handles.props.usingLabJack = true;
else
    handles.props.usingLabJack =false;
end


% --- Executes on button press in workingMemoryButton.
function workingMemoryButton_Callback(hObject, eventdata, handles)
% hObject    handle to workingMemoryButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    disp('MAPPINGBUTTON')
    disp(handles.stimpack)
    close(stimGUI)
    workingMemoryGUI(handles.stimpack)

