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

% Last Modified by GUIDE v2.5 18-Apr-2018 18:32:50

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
end
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
