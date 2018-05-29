function varargout = experimentControlGUI(varargin)
% EXPERIMENTCONTROLGUI MATLAB code for experimentControlGUI.fig
%      EXPERIMENTCONTROLGUI, by itself, creates a new EXPERIMENTCONTROLGUI or raises the existing
%      singleton*.
%
%      H = EXPERIMENTCONTROLGUI returns the handle to a new EXPERIMENTCONTROLGUI or the handle to
%      the existing singleton*.
%
%      EXPERIMENTCONTROLGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPERIMENTCONTROLGUI.M with the given input arguments.
%
%      EXPERIMENTCONTROLGUI('Property','Value',...) creates a new EXPERIMENTCONTROLGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before experimentControlGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to experimentControlGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help experimentControlGUI

% Last Modified by GUIDE v2.5 14-May-2018 17:45:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @experimentControlGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @experimentControlGUI_OutputFcn, ...
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


% --- Executes just before experimentControlGUI is made visible.
function experimentControlGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to experimentControlGUI (see VARARGIN)

% Choose default command line output for experimentControlGUI
handles.output = hObject;
if nargin > 3
    disp('Stimulus:');
    disp(varargin{1});
    handles.stimulus =varargin{1}
end

% Update handles structure
guidata(hObject, handles);
handles.comm = '';

handles.stimulus.axes = handles.axes;

%//set the current figure handle to main application data
setappdata(0,'figureHandle',gcf);

%//set the axes handle to figure's application data
setappdata(gcf,'commHandle',handles.comm);



% UIWAIT makes experimentControlGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = experimentControlGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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
handles.stimulus.externalControl = 'q';


% --- Executes on button press in scaButton.
function scaButton_Callback(hObject, eventdata, handles)
% hObject    handle to scaButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sca


% --- Executes on button press in rewardButton.
function rewardButton_Callback(hObject, eventdata, handles)
% hObject    handle to rewardButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stimulus.externalControl = 'r';

% --- Executes on button press in sendMarkButton.
function sendMarkButton_Callback(hObject, eventdata, handles)
% hObject    handle to sendMarkButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stimulus.externalControl = 'm';

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function updateGUI(handles)
