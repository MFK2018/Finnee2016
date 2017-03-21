%% DESCRIPTION
% DATASET is the class of the Finnee2016 toolbox that contain all 
% information associated to one run (i.e. the list of scan as a 
% function of time). The Dataset class contains a list of 
% properties to describe and organise the information and specific method 
% to explore, display or transform those
% data.
%
%% LIST OF THE CLASS'S PROPERTIES
% *Log*            : A log of all data transformation that were performed
% *DateOfCreation* :
% *Format*         : The format of the dataset ('centroid' or 'profile')
% *BPP*            : The base peak profile
% *TIP*            : The total ion profile
% *TIS*            : The total ion spectrum
% *FIS*            : The frequency ion spectrum
% *BIS*            : The base ion spectrum
% *LAST*           : A blank trace
% *ListOfScans*    : All the MS scans that make the dataset
% *Option4crt*     : (Hidden) Options for the creation of this dataset
% *Path2Dat*       : (Hidden) A list of all the dat files 
% *AxisX*          : Information about the time axis
% *AxisY*          : Information about the m/z axis
% *AxisZ*          : Information about the intensity axis
% *tol4MZ*         : m/z tolerance
%
%% LIST OF THE CLASS'S METHODS:
% *Dataset*        : The constructor method.
% *xpend*          : Allows to expend the m/z axis of a scan to the
%   Axis of reference
% *getSpectra*     : Calculate, from this dataset, a MS spectrum made by all
%   the spectra between an interval of time
% *getProfile*     : Calculate, from this dataset, a profile from every
%   ions with a set m/z interval
%
%% COPYRIGHT
% Copyright BSD 3-Clause License Copyright 2016-2017 G. Erny
% (guillaume@fe.up.pt), FEUP, Porto, Portugal
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


classdef Dataset
    
    properties
        Title          % Title for dataset      
    end
    
    properties (SetAccess = immutable) 
        Log            % Log of transformation
        DateOfCreation % Date of creation
        Format         % Format (i.e. 'centroid' or 'profile')
        BPP            % Base peak profile
        TIP            % Total ions profile
        TIS            % Total ions spectrum
        FIS            % Frequency ions profile
        BIS            % Base ions spectrum
        LAST           % blank trace
        ListOfScans    % List of scans that make the dataset
    end
    
    properties (Hidden = true) 
        Option4crt     % How the dataset was created
        Path2Dat       % Link to the binary data files
        AxisX           % Axis time
        AxisY           % Axis m/z
        AxisZ           % Axis intensity
        tol4MZ         % tolerance for comparing MZAxes
    end
    
     properties (Dependent)
         InfoDts       % Get back the data of the axis
    end
    
    methods
        
        function obj = Dataset(infoDts)
            obj.DateOfCreation = datetime;
            
            if nargin == 0
                obj.Title       = '';
                obj.Format      = '';
                obj.Option4crt  = {};
                obj.Path2Dat    = {};
                obj.BPP         = Trace;
                obj.TIP         = Trace;
                obj.TIS         = Trace;
                obj.FIS         = Trace;
                obj.BIS         = Trace;
                obj.LAST        = Trace;
                obj.ListOfScans = {};
                obj.Log         = '';
                obj.AxisX        = Axis;
                obj.AxisY        = Axis;
                obj.AxisZ        = Axis;
                obj.tol4MZ      = NaN;
                
            elseif nargin == 1
                obj.Title       = infoDts.Title;
                obj.Format      = infoDts.Format;
                obj.Option4crt  = infoDts.Option4crt;
                obj.Path2Dat    = infoDts.Path2Dat;
                obj.BPP         = infoDts.BPP;
                obj.TIP         = infoDts.TIP;
                obj.TIS         = infoDts.TIS;
                obj.FIS         = infoDts.FIS;
                obj.BIS         = infoDts.BIS;
                obj.LAST        = infoDts.LAST;
                obj.ListOfScans = infoDts.ListOfScans;
                obj.Log         = infoDts.Log;
                obj.AxisX        = infoDts.AxisX;
                obj.AxisY        = infoDts.AxisY;
                obj.AxisZ        = infoDts.AxisZ;
                obj.tol4MZ      = infoDts.tol4MZ;
            end
        end
        
        function infoDts = get.InfoDts(obj)
                infoDts.Title          = obj.Title;
                infoDts.Format         = obj.Format;
                infoDts.Option4crt     = obj.Option4crt;
                infoDts.Path2Dat       = obj.Path2Dat;
                infoDts.BPP            = Trace(obj.BPP.InfoTrc);
                infoDts.TIP            = Trace(obj.TIP.InfoTrc);
                infoDts.TIS            = Trace(obj.TIS.InfoTrc);
                infoDts.FIS            = Trace(obj.FIS.InfoTrc);
                infoDts.BIS            = Trace(obj.BIS.InfoTrc);
                infoDts.LAST           = Trace(obj.LAST.InfoTrc);
                infoDts.ListOfScans{1} = Trace(obj.ListOfScans{1}.InfoTrc);
                infoDts.Log            = obj.Log;
                infoDts.AxisX           = Axis(obj.AxisX.InfoAxis);
                infoDts.AxisY           = Axis(obj.AxisY.InfoAxis);
                infoDts.AxisZ           = Axis(obj.AxisZ.InfoAxis);
                infoDts.tol4MZ         = obj.tol4MZ;
        end
        
        function XMS = xpend(obj, MS, AxisOr)
            if ~strcmp(obj.Format, 'profile')
                error('xpend is only possible with profile''s type dataset')
            end
            if nargin == 2, AxisOr = true; end
            cst = 0;
            infoMS = MS.InfoTrc;
                
            XMS(:,1) = obj.AxisY.Data;
            if isempty(MS.Data)
                XMS(:,2) = 0;
                
            else
                cst = findValue('AxisMZ normalisation', infoMS.AdiPrm{:});
                if isempty(cst), cst = 0; end
                axe = MS.Data(:,1)/(1-cst);
                tol = obj.tol4MZ;
                [tf, loc] = ismember(round(axe*10^tol)/10^tol, ...
                    round(XMS(:,1)*10^tol)/10^tol);
                indZeros = find(tf == 0);
                if ~isempty(indZeros)
                    [~, locc] = ismember(ceil(axe*10^tol)/10^tol, ...
                        ceil(XMS(:,1)*10^tol)/10^tol);
                    loc(indZeros) = locc(indZeros);
                end
                
                indNotNull = loc ~= 0;
                XMS(loc(indNotNull), 2) = MS.Data(indNotNull,2);
            end
            
            if ~AxisOr
                XMS(:,1) = XMS(:,1)*(1-cst);
            end
            
            infoMS.Title = ['XMS- ', infoMS.Title];
            infoMS.Loc = 'intrace';
            XMS = Trace(infoMS, XMS);
        end
        
    end
end
