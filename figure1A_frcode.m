function    y=figura1A_frcode(stim);

% Copyright 2009, Hugo Gabriel Eyherabide
% (hugogabriel.eyherabide@gmail.com)

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.



% BURSTS GENERATES A NON-REDUCIBLE SPIKE PATTERN CODE
% Eyherabide H.G., Rokem A., Herz A.V.M., Samengo I.
% Front Neuroscience 3(1), doi: 10.3389/neuro.01.002.2009
% http://frontiersin.org/neuroscience/paper/10.3389/neuro.01/002.2009/

% ADDITIONAL MATERIAL
% FIRING RACE CODE - FIGURE 1A
% This function simulates the response of a neuron using a firing rate code.
% The firing rate is proportional to the stimulus intensity. When a threshold
% exists, it must be substracted previously for using this function.

% Abbreviations
% s     = seconds
% ms    = milliseconds

% PARAMETERS

% stim must be a vector containing the stimulus used. 

% Firing rate as if the absolute refractory period was null (spikes/s).
FR=20;

% Refractory period (milliseconds).
RP=1;

% Bin size (milliseconds).
binsize = 0.1;

% Number of trials
numtrials=20;

% Maximum reliability = maximum spike count in a psth bin
mincountrate = 0.15;

% Checking that stim is a vector and converting it to a column vector if
% necessary.
[strows,stcols]=size(stim);

if(strows<stcols)
    stim=stim';
    aux=stcols;
    stcols=strows;
    strows=aux;
end;

if(stcols~=1)
    error('stim is not a vector:\tstrows= %d\tstcols= %d',strows,stcols);
    return;
end;

% Inicialising spike matrix.
spikes=zeros(strows,numtrials);

% Discrete time absolute refractory period.
dtRP = floor(RP/binsize);

% Discrete time limit.
dtlimit=strows*binsize;

% Calculating the firing rate
% The calculation of the firing rate does not take into account that the
% actual firing rate will be lower due to the refractory period.

frtime=stim/sum(stim)*FR;

%%%%%%%%%%%%%%%%%%%%%%%%
% STATING THE SIMULATION
%%%%%%%%%%%%%%%%%%%%%%%%

for indtrial=1:1:numtrials
    
    indtime=1;
    while(indtime<strows)
        
        % If probsp<frtime(indtime) then there will a spike at indtime. 
        probsp=rand(1);             
        
        if(probsp<frtime(indtime))
            spikes(indtime,indtrial)=1;
            indtime=indtime+dtRP;
        else
            indtime=indtime+1;
        end;
    end;    
end;

% Calculating th peri-stimulus time histogram
psth=sum(spikes,2);

% Calculating actual firing rate and stddev
frmv=mean(sum(spikes));
frsd=std(sum(spikes));

% Creating the time vector
timevector=(1:1:strows)*binsize;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FINDING THE REQUIRED BINNING FOR THE PERI-STIMULUS TIME HISTOGRAM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

psthplot=psth;

% The minimum maximum count in a bin.
minbincount=mincountrate*numtrials;                    
% Discrete bin size used for the peri-stimulus time histogram (in bins).
dtbinpsth=1;

while(max(psthplot)<minbincount)
    dtbinpsth=dtbinpsth+1;
    maxtimepsth=floor(strows/dtbinpsth);
    
    % Calculating the psth to be plotted.
    psthplot=zeros(maxtimepsth,1);
    for indtime=1:1:maxtimepsth
        limsup=indtime*dtbinpsth;
        liminf=limsup-dtbinpsth+1;
        psthplot(indtime)=sum(psth(liminf:1:limsup));
    end;
end;

% Determining the new time vector for the x-axis of the plot.
if(dtbinpsth>1)
    timevectorpsth=(1:1:maxtimepsth)*dtbinpsth;
else
    timevectorpsth=timevector;
end;

% Changing the units of the peri-stimulus time histogram to spikes/s.
psthplot=1000*psthplot/binsize/dtbinpsth;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKING THE FIGURE WITH THE RESULTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Creating the figure.
figura=figure('PaperOrientation','Portrait','Visible','on');

% Plotting the stimulus
subplot(3,1,1);
plot(timevector,stim);
ylabel('Stimulus');
xlim([binsize dtlimit]);

% Plotting the raster plot.
subplot(3,1,2);
hold on;
for indtrial=1:1:numtrials
    for indtime=1:1:strows
        if(spikes(indtime,indtrial)==1)
            sptime(1)=indtime*binsize;
            sptime(2)=sptime(1);
            sprow(1)=indtrial-1;
            sprow(2)=indtrial;
            plot(sptime,sprow);
        end;
    end;
end;
ylabel('Spike matrix');
xlim([binsize dtlimit]);
xtext=['FR = ' num2str(frmv,'%4.02g') ' +/- ' num2str(frsd,'%4.02g') ' spikes/s'];
xlabel(xtext);

% Plotting the peri-stimulus time histogram.
subplot(3,1,3);
plot(timevectorpsth,psthplot);
ylabel('PSTH (spikes/s)');
xlim([binsize dtlimit]);
xlabel('Time (ms)');

return;    
    