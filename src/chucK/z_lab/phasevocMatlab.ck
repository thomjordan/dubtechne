/*

factor=2;

[signal,Fs]=wavread('ederwander.wav');


winsize=4096;
fftsize=winsize;
window=hann(winsize);
shop=winsize/4;
ahop=floor(shop/factor);

SignalLen=length(signal);
num_win = floor((SignalLen-winsize)/ahop);

OutLen=(num_win-1)*shop+winsize;
Out=zeros(OutLen,1);

TWOPI=2*pi;
CENTERFREQ = [0:fftsize-1]*TWOPI*ahop/fftsize; %Piece of equation showed in q
first=1;
PosIn=1;
PosOut=1;

for win_count=1:num_win
   if first==1
      framed=signal(1:winsize).*window;
      X=fft(fftshift(framed),fftsize);
      Mag=abs(X);
      Pha=angle(X);
      PhaSy=Pha;            
      first=0;
   else
      framed = signal(PosIn:PosIn+winsize-1) .* window; %framed and windowed / current position analysis
      X=fft(fftshift(framed),fftsize);  %Apply FFT whith circular shift
      Mag=abs(X); % Get the Magnitude
      Pha=angle(X); %Get the Phase
      phaseDiff = Pha - old_pha; %Difference between the current and previous phase 
      phaseDiff = phaseDiff - CENTERFREQ'; %Expected phase (unwrapped phase)
      dphi = phaseDiff - TWOPI * round(phaseDiff /TWOPI); %principal argument, MAP phase to +/- pi
      freq = (CENTERFREQ + dphi') /ahop; %true frequency
      PhaSy = old_PhaSy + shop*freq'; %Phase synthesis

   end

   Y = Mag .* ( cos(PhaSy) + sqrt(-1) *(sin(PhaSy)) ); %Resynthesis
   y_out = fftshift(real(ifft(Y,fftsize))).*window; %back to time domain 
   
   Out(PosOut:PosOut+winsize-1)= Out(PosOut:PosOut+winsize-1) + y_out; %Overlap and add

   old_pha=Pha;
   old_PhaSy=PhaSy;
   PosIn = PosIn + ahop;
   PosOut=PosOut+shop;
end

%Play
sound(Out,Fs);

*/