function StatisticMWerteV01(auxdirpath)
%-----------------------------------------------------------
%% Statistische Betrachtung von Messwerten nach GUM Typ A
%-----------------------------------------------------------
% 03/12/2017    Author: Lichterfeld, Robert-Vincent
%               Build: Werte aus Excel lesen, Histogramm
% 16/12/2017    Author: Lichterfeld, Robert-Vincent
%               Edit: Messreihen mit Beschriftung
% ??/??/2017    Author: Lichterfeld, Robert-Vincent
%               Edit:
%               Edit:
%               Edit:


%   Link to MATLAB help about DOE
% https://de.mathworks.com/help/stats/design-of-experiments-1.html

%% Install missing packages
% -> Best Practice: Navigate to your download directory, then execute lines
%    for installation from command window
% pkg install -forge sockets
% pkg install sci_cosim_0.1.3.tar.gz
% pkg install symbolic-win-py-bundle-2.6.0.zip


%% Load packages
pkg load io;
pkg load statistics;
%pkg load control;
%pkg load signal;
%pkg load symbolic;
%pkg load geometry;
%pkg load socketes;
%pkg load sci_cosim;


%   Settings for Paging Screen Output
% To automatically flush stuff automatically, set:
page_output_immediately (0);

% and to send it to stdout without a pager, set:
page_screen_output (0);


%% Aufräumen
%close all;
%clear all;
%clc;

%===============================================
%%  Initialisieren von Konstanten
%===============================================
% Anzahl der Messwerte, die generiert werden
nGenW = 5;
% Anzahl der Messreihen bzw. Proben
nMR = 20;
%% ProzessObergrenze (Abweichung von 0)
%valPrzOGr = 0.5;
%% ProzessUbergrenze (Abweichung von 0)
%valPrzUGr = -0.5;
%   Anzahl der Klassen festlegen
% Faustregel: Mindestens fünf Messwerte je Klasse
%anzKl = round(nMR/3);
%anzKl = round(sqrt( nMR/3 ));
anzKl = round(sqrt( nMR/1 ));

% Aktuelles Verzeichnis speichern
wStrct = what();
currntdir = wStrct.path;

%-----------------------------------------------------------
%% Ordner für Hilfsdateien erstellen
% Prüfen ob Ordner bereits existiert, sonst Ornder erstellen

%% Namen des Orders erstellen
%dte = (strftime ("%Y-%m-%d", localtime (time ())));
%% Ordnernamen angeben
%dirNme = sprintf('DatenVrsPlng%s', dte);
%%dirNme = 'auxData';
%
%if dirNme(end) ~= '\', dirNme = [dirNme, '\']; end;

%% Arbeitsverzeichnis öffnen
%cd(auxdirpath);

%% Verzeichnis erstellen falls nötig
%if (exist(dirNme, 'dir') == 0); mkdir(dirNme); end;
%
%% Pfad zum Hilfsverzeichnis aufbauen
%auxdirpath = sprintf('%s%s%s', pathname, '\', dirNme);
%% Hilfsverzeichnis öffnen
%cd(auxdirpath);

%- - - - - - - - - - - - - - - - - - - - - - - - - - -
%%% Diary aktivieren
%% Datei mit Meldungen des CommandWindows schreiben
%diary on; diary auxLogFile.txt;
%- - - - - - - - - - - - - - - - - - - - - - - - - - -

%% Zurück in aktuelles Verzeichnis wechseln
%cd(currntdir);
%.............................................................

% Zeitstempel für das diary erzeugen
tstmpDiary = (strftime ("%Y-%m-%d_%H:%M:%S", localtime (time ())));
txtProg = 'Messdaten auswerten';
txtToDiary = fprintf('\n---------\nLogfile: %s | %s\n---------\n', tstmpDiary, txtProg);
clear txtToDiary;

%===============================================
%%  Dialog mit Nutzer
%===============================================
% btn = questdlg (msg, title, btn1, btn2, default)
msgImpData = sprintf('Werte aus Datei importieren?');
btnChoice = questdlg (msgImpData, 'Werte', 'JA', 'NEIN', 'NEIN');
%   Reaktion auf Entscheidung des Nutzers
if strcmp(btnChoice, 'JA')
  %===============================================
  %%  Daten aus Datei lesen
  %===============================================

  % Nutzerverzeichnis öffnen
  cd();

  %   Datei auswaehlen
  [fname, fpath, fltidx] = uigetfile ({"*.xlsx", "Excel2007+"; ...
                                      "*.xls", "Excel97-2003"; ...
                                      "*.ods", "OpenOffice"}, "Select File");

  %   Build absolute path
  fullpath = sprintf('%s%s', fpath, fname);

  % In das Ursprungsverzeichnis wechseln
  cd(currntdir);

  %= = = = = = = = = =
  % Open an external file with an external program
  try
    open(fullpath);
  catch ME;
    txtME = fprintf('%s',ME);
  end_try_catch
  clear txtME ME;
  %= = = = = = = = = =

  %= = = = = = = = = =
  % Nutzereingabe
  txtWSNmbr = sprintf('Tabellenblattnummer eingeben:');
  nbrWrkSht = str2double(inputdlg (txtWSNmbr, 'Tabellenblatt auswaehlen'));
  clear txtWSNmbr;
  %------------------
  %   Nutzereigabe prüfen
  % Testen auf leer
  if isempty(nbrWrkSht);
    % Standardwert vorgeben
    nbrWrkSht = 1;
    %   Information an Nutzer
    % Informationstext
    sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %1.0d', nbrWrkSht);
    mb1 = msgbox(sprnt1, 'Eingabefehler', "help");

  else
    % Keine Aktion
  endif

  % Testen auf Zeichen
  if ischar(nbrWrkSht);
    % Standardwert vorgeben
    nbrWrkSht = 1;
    %   Information an Nutzer
    % Informationstext
    sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %1.0d', nbrWrkSht);
    mb1 = msgbox(sprnt1, 'Eingabefehler', "help");
  else
    % Keine Aktion
  endif

  % Testen auf NaN
  if isnan(nbrWrkSht);
    % Standardwert vorgeben
    nbrWrkSht = 1;
    %   Information an Nutzer
    % Informationstext
    sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %1.0d', nbrWrkSht);
    mb1 = msgbox(sprnt1, 'Eingabefehler', "help");
  else
    % Keine Aktion
  endif
  %
%===============================================
%%  Dialog mit Nutzer
%===============================================
% btn = questdlg (msg, title, btn1, btn2, default)
msgSelData = sprintf('Wertebereich selektieren?');
btnChoice = questdlg (msgSelData, 'Werte', 'JA', 'NEIN', 'NEIN');
clear msgSelData;
%   Reaktion auf Entscheidung des Nutzers
if strcmp(btnChoice, 'JA')
  %===============================================
  %%  Wertebereich ermitteln
  %===============================================
  %prompt = {"Width", "Height", "Depth"};
  %          defaults = {"1.10", "2.20", "3.30"};
  %          rowscols = [1,10; 2,20; 3,30];
  %          dims = inputdlg (prompt, "Enter Box Dimensions", rowscols, defaults);

  prmptExcel = {'|-|Startspalte', '|->Startzeile', '|_|Endspalte', '->| Endzeile'};
               defaults = {"A", "1", "H", "8"};
               rowscols = [1.1; 1.2; 1.8; 1.9];
               dims = inputdlg (prmptExcel, "Wertebereich angeben", rowscols, defaults);

  %.....................................
  % Eingegebene Dimensionen durchlaufen
  %.....................................
  %= = = = = = = = = =
  for nDim = 1:size(dims,1);
    %   Nutzereigabe prÜfen
    % Testen auf leer
    if isempty(dims{nDim});
      % Standardwert vorgeben
      dims{nDim} = 0;
      %   Information an Nutzer
      % Informationstext
      sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %d', dims{nDim});
      mb1 = msgbox(sprnt1, 'Eingabefehler', "help");
      clear sprnt1;
      %
    else
      % Keine Aktion
    endif

%   % Testen auf Zeichen
%   if ischar(dims{nDim});
%      % Eingabe in Grossschreibung umwandeln
%     inpt = toupper(dims{nDim});
%     % Eingabe in double wandeln
%     if isnan(str2double(inpt));
%        % Zeichen in ascii-Werte Überführen
%        dims{nDim} = (toascii(inpt) - 64);
%     else
%       % Zahlen vom Typ String zu Double wandeln
%       dims{nDim} = str2double(inpt);
%     endif
%     %
%   else
%     % Keine Aktion
%   endif

    % Testen auf NaN
    if isnan(dims{nDim});
      % Standardwert vorgeben
      dims{nDim} = 0;
      %   Information an Nutzer
      % Informationstext
      sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %1.3f', dims{nDim});
      mb1 = msgbox(sprnt1, 'Eingabefehler', "help");
      clear sprnt1;
      %
    else
      % Keine Aktion
    endif
    %
    %----------------

  endfor
  clear mb1 sprnt1 txtTtl txtEFmin txtEFmax;
  %= = = = = = = = = =
  %   Read from selected File
  selArea = sprintf('%s%s:%s%s', dims{1}, dims{2}, dims{3}, dims{4});
  DataINr = xlsread (fullpath, nbrWrkSht, selArea);

else
  %.........................
  % Keine Daten selektieren
  %.........................
  %   Read from selected File
  DataINr = xlsread (fullpath, nbrWrkSht, []);
endif
  %   Read from selected File
%  DataIN = xlsread (fullpath, nbrWrkSht, [], 'OCT');
  % Daten aus Tabelle lesen
  xMessR = DataINr;
  %   Daten sortieren
  % Vektor der Messwerte aufsteigend sortiert
  %xMessR = sort(DataIN(:,:));
  %............
  %   Daten analysieren
  % Anzahl der Messwerte pro Messreihe bzw. Probe
  nGenW = size(xMessR,1);
  % Anzahl der Messreihen bzw. Proben
  nMR = size(xMessR,2);
  %............
  % Legende erstellen
   for nMess = 1:nMR
    % Beschriftung für Legende erstellen
    if nMess < 10;
      txtLegndSV(nMess, :) = sprintf('Messreihe 00%d', nMess);
    elseif nMess < 100;
      txtLegndSV(nMess, :) = sprintf('Messreihe 0%d', nMess);
    else
      txtLegndSV(nMess, :) = sprintf('Messreihe %d', nMess);
    endif
   endfor
   clear nMess szeChar;
  %............
  %= = = = = = = = = =
else
  %===============================================
  %%  Daten generieren
  %===============================================
  %  Messwerte durch interne Funktion erstellen
%  xMess = sort([10*rand(1, nGenW)]');
%  xMess = sort([10*abs(rand(1, nGenW))]');
%  xMess = sort( (5 + [10*randn(1, nGenW)]') );
   % Speicherplatz reservieren
   xMessR = zeros(nGenW, nMR);
   % Werte der Messreihen generieren
   for nMess = 1:nMR
    xMessR(:, nMess) = ( [(2*randn(1))*randn(1, nGenW)]');
    % Beschriftung für Legende erstellen
    if nMess < 10;
      txtLegndSV(nMess, :) = sprintf('Messreihe 00%d', nMess);
    elseif nMess < 100;
      txtLegndSV(nMess, :) = sprintf('Messreihe 0%d', nMess);
    else
      txtLegndSV(nMess, :) = sprintf('Messreihe %d', nMess);
    endif
   endfor
   clear nMess szeChar;
endif

%===============================================
%%  Dialog mit Nutzer: Toleranzgrenzen
%===============================================
%= = = = = = = = = =
%% User input
txtPrzOGr = sprintf('Wert der Prozess-Obergrenze eingeben:');
valPrzOGr = (str2double(inputdlg (txtPrzOGr, 'Toleranzgrenzen')));
clear txtPrzOGr;
%% User input
txtPrzUGr = sprintf('Wert der Prozess-Untergrenze eingeben:');
valPrzUGr = (str2double(inputdlg (txtPrzUGr, 'Toleranzgrenzen')));
clear txtPrzUGr;
% Eingaben auf Vektor speichern
inptVal = [valPrzOGr; valPrzUGr];
%= = = = = = = = = =
%   Nutzereigabe prüfen
% Default-Korrekturwerte vorgeben
corrVal = [0.5; -0.5];

for nDlg = 1:length(inptVal)
% Testen auf leer
if isempty(inptVal(nDlg));
  % Standardwert vorgeben
  inptVal(nDlg) = corrVal(nDlg);
  %   Information an Nutzer
  % Informationstext
  sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %d', inptVal(nDlg));
  mb1 = msgbox(sprnt1, 'Eingabefehler', "warn");
  clear sprnt1;
  %
else
  % Keine Aktion
endif

% Testen auf Zeichen
if ischar(inptVal(nDlg));
  % Standardwert vorgeben
  inptVal(nDlg) = corrVal(nDlg);
  %   Information an Nutzer
  % Informationstext
  sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %d', inptVal(nDlg));
  mb1 = msgbox(sprnt1, 'Eingabefehler', "warn");
  clear sprnt1;
  %
else
  % Keine Aktion
endif

% Testen auf NaN
if isnan(inptVal(nDlg));
  % Standardwert vorgeben
  inptVal(nDlg) = corrVal(nDlg);
  %   Information an Nutzer
  % Informationstext
  sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %d', inptVal(nDlg));
  mb1 = msgbox(sprnt1, 'Eingabefehler', "warn");
  clear sprnt1;
  %
else
  % Keine Aktion
endif
%
endfor
%
% Eingegebene und ggf. korrigierte Werte zuordnen
valPrzOGr = inptVal(1);
valPrzUGr = inptVal(2);
clear mb1 nDlg inptVal;
%
clear mb1 sprnt1;
%------------------

%%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
% Erstellen eines figure windows und dieses auf handle referenzieren
fg08 = figure(08);
% Eigenschaften zum handle antragen, durch den Befehl set(...)
set(fg08,'Name','Werte der Messreihen','NumberTitle','on');
% relative Angabe [left bottom width height]
set(fg08,'Units','normalized','Position',[0.55 0.35 0.35 0.5]);
if size(xMessR,1) < 2;
  for nM = 1:size(xMessR,2);
    plt08 = plot((xMessR(nM).^0), xMessR(nM), 'x', 'LineWidth', 2);
    hold on;
  endfor
  grid on; hold off;
  clear nM;
else
  plt08 = plot(xMessR, 'x', 'LineWidth', 2); hold on; grid on; hold off;
endif
title('Messwerte');
xlabel('# Messung'); ylabel('Wert');
%   Legende
lg08 = legend(txtLegndSV);
set(lg08, 'Location', 'Westoutside','Orientation','Vertical');
%%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
%%===============================================
%%%  Ausreißer nach 3*SIGMA-Regel aussortieren
%%===============================================
%% Beträge der Abweichungen berechnen
%BetrAbW = abs(xMessR - ( mean(xMessR, "all")) );
%% Abweichungen im Betrag aussortieren wenn größer als Standardabweichung
%for nS = 1:size(BetrAbW,2);
%  for nZ = 1:size(BetrAbW,1);
%    if BetrAbW(nZ, nS) < ( std(xMessR, 0) );
%      xMessSort((end+1), (end+1)) = BetrAbW(nZ, nS);
%    else
%      % Messreihe aussortieren
%    endif
%  endfor
%endfor
%clear nZ nS;
%% Bereinigte Werte der Ausgangsvariable zuweisen
%xMessR = xMessSort;

%===============================================
%%  Mittelwerte der Messreihen
%===============================================
% Mitttelwerte zu den Messreihen bilden
for nMess = 1: size(xMessR,2)
  xMess(nMess, 1) = mean(xMessR(:,nMess), "all");
endfor
%%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
% Erstellen eines figure windows und dieses auf handle referenzieren
fg10 = figure(10);
% Eigenschaften zum handle antragen, durch den Befehl set(...)
set(fg10,'Name','Mittelwerte der Messreihen','NumberTitle','on');
% relative Angabe [left bottom width height]
set(fg10,'Units','normalized','Position',[0.55 0.15 0.35 0.5]);
plt10 = plot(xMess, 'o', 'LineWidth', 2); hold on; grid on; hold off;
title('Mittelwerte');
xlabel('# Messreihe'); ylabel('Wert');
%%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

%===============================================
%%  Statistische Betrachtungen
%===============================================
fprintf('\n===============================================\n');
fprintf('Statistische Betrachtungen\n');
fprintf('===============================================\n');
% Arithmetischer Mittelwert
empMW = mean(xMess, "all");
fprintf('\nArithmetischer Mitttelwert der Messreihen: %1.3f\n', empMW);
% Median-Wert
mediW = median(xMess);
fprintf('\nMedian der Messreihen: %1.3f\n', empMW);
% Empierische Standardabweichung
empStd = std(xMess, 0);
fprintf('\nEmpierische Standardabweichung der Messreihen: %1.3f\n', empStd);
% Mittelwert-Varianz (Schßtzwert für die Schwankungsbreite des Mittelwertes)
if size(xMess,1) < 4;
  fprintf('\n>> Sehr wenige Stichproben! (Possionverteilung?)\n');
  varMW = sqrt(empMW);
  fprintf('Mittelwert-Varianz (Schwankungsbreite des Mittelwertes): %1.3f\n', varMW);
elseif 4 <= size(xMess,1) || size(xMess,1) <= 10;
  fprintf('\n>> Wenige Stichproben -> Erwartungswert nach t-Verteilung\n');
  varMW = sqrt((size(xMess,1)-1)/(size(xMess,1)-3))*(empStd/(sqrt(size(xMess,1))));
  fprintf('Mittelwert-Varianz (Schwankungsbreite des Mittelwertes): %1.3f\n', varMW);
else 10 < size(xMess,1);
  fprintf('\n>> Genügend Stichproben -> Erwartungswert nach Normalverteilung\n');
  varMW = ( empStd/sqrt(length(xMess)) );
  fprintf('Mittelwert-Varianz (Schwankungsbreite des Mittelwertes): %1.3f\n', varMW);
endif
% Empirische Streuung bzw. Varianz der Messreihen
empStr = var(xMess, 0);
fprintf('\nEmpirische Streuung bzw. Varianz der Messreihen: %1.3f\n', empStr);
% Schiefe der Verteilung
schiefe = skewness (xMess);
fprintf('\nSchiefe der Verteilung: %1.3f\n', schiefe);
fprintf('\n\n');

%===============================================
%%  Klassen für Messwerte Bilden und Häufigkeit bestimmen
%===============================================
%   Spannweite der Messwerte
%xSp = max(xMess) - min(xMess);
xSp = range(xMess);

%   Stufe je Klasse
stpKl = xSp/anzKl;

%%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
%%   Werte in die jeweilige Klasse einordnen
%% Speicherplatz reservieren
%KLxM = zeros((length(xMess)), anzKl);
%%KLxM(:,:) = NaN;
%for nKl = 1: anzKl
%  %   Messwerte durchsehen
%  % Initialisieren und Rücksetzen von Werten
%  nFreq = 0;
%  for nx = 1 : (length(xMess))
%    %   Messwerte der entsprechenden Klasse zuordnen
%    if (min(xMess)+(stpKl*(nKl-1))) <= xMess(nx) && xMess(nx) < (min(xMess)+(stpKl * nKl))
%      % Klassenmatrix aufbauen
%      KLxM(nx, nKl) = xMess(nx);
%      % Häufigkeit in der Klasse
%      nFreq = (nFreq + 1);
%    else
%      % do nothing
%
%      %
%    endif
%
%    %
%  endfor
%  % Klassenmittelwert bestimmen
%  KlMitlw = ( ((min(xMess)+(stpKl * nKl))-(stpKl*(nKl-1)) ) / nFreq);
%  % Mittelwert in Matrix speichern
%  KLfreq(1, nKl) = KlMitlw;
%  % Häufigkeit in Matrix speichern
%  KLfreq(2, nKl) = int16(nFreq);
%  %
%endfor
%%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

%===============================================
%%  Histogramm der Messwerte
%===============================================
%% Werte aufbereiten
%   Interne Histogrammfunktion nutzen
[freqKLr, valKL] = hist(xMess, anzKl);
% Häufigkeitswerte normieren
freqKL = freqKLr/(max(freqKLr));

%-.-.-.-.-.-.-.-.-.-
%   Werte der Wahrscheinlichkeitsdichte berechnen
%pDnsity(1, 1) = abs( freqKL(1) / (min(xMess) - valKL(1)) );
pDnsityR(1, 1) = abs( freqKLr(1) / (min(xMess)) );
for fj = 1 : (length(valKL)-1)
  % Häufigkeit durch Intervallbreite teilen min(xMess)
  pDnsityR((fj+1), 1) = abs( freqKLr(fj+1) / (valKL(fj) - valKL(fj+1)) );

endfor
% Wahrscheinlichkeitsdichte-Werte normieren
pDnsity = pDnsityR/(max(pDnsityR));
%-.-.-.-.-.-.-.-.-.-

%   Markierung: empierischer Mittelwert
empMWplt = [empMW, (1.25*max(freqKL))];
%   Markierung: empierische Standardabweichung
empStdplt = [empStd, (1.25*max(freqKL))];
%   Markierung: Mittelwert-Varianz (Schwankungsbreite des Mittelwertes)
varMWplt = [varMW, (0.5*max(freqKL))];


%%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
% Erstellen eines figure windows und dieses auf handle referenzieren
fg11 = figure(11);
% Eigenschaften zum handle antragen, durch den Befehl set(...)
set(fg11,'Name','Histogramm der Messwerte','NumberTitle','on');
% relative Angabe [left bottom width height]
set(fg11,'Units','normalized','Position',[0.05 0.2 0.45 0.6]);
%   Histogramm darstellen
%hist (xMess, anzKl); colormap(spring());
%hist (xMess, anzKl, "facecolor", rand(1,3), "edgecolor", rand(1,3));
%bplt01 = bar(valKL, freqKL, "facecolor", rand(1,3), "edgecolor", rand(1,3));
bplt01 = bar(valKL, freqKL, 'facecolor', rand(1,3));
hold on; grid on;
%%
%%.................................
%   Wahrscheinlichkeitsdichte darstellen
%%.................................
% compute the probability density function
%prpDnsW1 = stdnormal_cdf(freqKL);
% Wahrscheinlichkeitsdichte darstellen
%plt0361 = plot(valKL, prpDnsW1, '-sg', 'LineWidth', 1.5);
%%  Wahrscheinlichkeitsdichte darstellen
plt0361 = plot(valKL, pDnsity, '-sg', 'LineWidth', 1.5);
%
%   Empierischen Mittelwert darstellen
plt01 = plot([empMWplt(1), empMWplt(1)], [0, empMWplt(2)], '-k', 'LineWidth', 4);
%txtplt01 = text(empMWplt(1,1), empMWplt(1,2), num2str(empMWplt(1,1)));
%   Formatierung: Text empierischer Mittelwert
txtMWplt01 = sprintf('\\mu: %1.3f', empMWplt(1));
%   Beschriftung zum empierischen Mittelwert erstellen
txtplt01 = text((1.0*empMWplt(1)), (1.01*empMWplt(2)), txtMWplt01);
%
%   Empierische Standardabweichung darstellen
% Postive empirische Standardabweichung
plt02 = plot([(empMWplt(1)+empStdplt(1)), (empMWplt(1)+empStdplt(1))], ...
            [0, empStdplt(2)], '--k', 'LineWidth', 2);
%   Beschriftung zur positiven Standardabweichung
txtplt02 = text(((empMWplt(1)+empStdplt(1))), (1.01*empStdplt(2)), '\sigma');
% Negative empirische Standardabweichung
plt03 = plot([(empMWplt(1)-empStdplt(1)), (empMWplt(1)-empStdplt(1))], ...
            [0, empStdplt(2)], '--k', 'LineWidth', 2);
%   Beschriftung zur negativen Standardabweichung
txtplt03 = text(((empMWplt(1)-empStdplt(1))), (1.01*empStdplt(2)), '-\sigma');
%%
%
sig2col = rand(1,3);
%   2-Sigma: Empierische Standardabweichung darstellen
% Postive 2-Sigma Standardabweichung
plt321 = plot([(empMWplt(1)+(2*empStdplt(1))), (empMWplt(1)+(2*empStdplt(1)))], ...
            [0, empStdplt(2)], ':', 'Color', sig2col, 'LineWidth', 2);
%   2-Sigma: Beschriftung zur positiven Standardabweichung
txtplt321 = text(((empMWplt(1)+(2*empStdplt(1)))), (1.01*empStdplt(2)), '2*\sigma');
% Negative 2-Sigma Standardabweichung
plt0322 = plot([(empMWplt(1)-(2*empStdplt(1))), (empMWplt(1)-(2*empStdplt(1)))], ...
            [0, empStdplt(2)], ':', 'Color', sig2col, 'LineWidth', 2);
%   2-Sigma: Beschriftung zur negativen Standardabweichung
txtplt322 = text((empMWplt(1)-(2*empStdplt(1))), (1.01*empStdplt(2)), '-2*\sigma');
%%
%
sig3col = rand(1,3);
%   3-Sigma: Empierische Standardabweichung darstellen
% Postive 3-Sigma Standardabweichung
plt331 = plot([(empMWplt(1)+(3*empStdplt(1))), (empMWplt(1)+(3*empStdplt(1)))], ...
            [0, empStdplt(2)], '-.', 'Color', sig3col, 'LineWidth', 2);
%   3-Sigma: Beschriftung zur positiven Standardabweichung
txtplt331 = text(((empMWplt(1)+(3*empStdplt(1)))), (1.01*empStdplt(2)), '3*\sigma');
% Negative 3-Sigma Standardabweichung
plt0332 = plot([(empMWplt(1)-(3*empStdplt(1))), (empMWplt(1)-(3*empStdplt(1)))], ...
            [0, empStdplt(2)], '-.', 'Color', sig3col, 'LineWidth', 2);
%   3-Sigma: Beschriftung zur negativen Standardabweichung
txtplt332 = text((empMWplt(1)-(3*empStdplt(1))), (1.01*empStdplt(2)), '-3*\sigma');
%%
%
sig4col = rand(1,3);
%   4-Sigma: Empierische Standardabweichung darstellen
% Postive 4-Sigma Standardabweichung
plt341 = plot([(empMWplt(1)+(4*empStdplt(1))), (empMWplt(1)+(4*empStdplt(1)))], ...
            [0, empStdplt(2)], ':', 'Color', sig4col, 'LineWidth', 2);
%   4-Sigma: Beschriftung zur positiven Standardabweichung
txtplt341 = text(((empMWplt(1)+(4*empStdplt(1)))), (1.01*empStdplt(2)), '4*\sigma');
% Negative 4-Sigma Standardabweichung
plt0342 = plot([(empMWplt(1)-(4*empStdplt(1))), (empMWplt(1)-(4*empStdplt(1)))], ...
            [0, empStdplt(2)], ':', 'Color', sig4col, 'LineWidth', 2);
%   4-Sigma: Beschriftung zur negativen Standardabweichung
txtplt342 = text((empMWplt(1)-(4*empStdplt(1))), (1.01*empStdplt(2)), '-4*\sigma');
%%
%   Mittelwert-Varianz darstellen
txtvarMWplt01 = sprintf('%1.3f', (empMWplt(1)+varMWplt(1)));
% Postive Mittelwert-Varianz
plt0351 = plot([(empMWplt(1)+varMWplt(1)), (empMWplt(1)+varMWplt(1))], ...
            [0, varMWplt(2)], ':k', 'LineWidth', 2);
% Beschriftung zur positiven Mittelwert-Varianz
txtplt0351 = text(((empMWplt(1)+varMWplt(1))), (1.02*varMWplt(2)), txtvarMWplt01);
% Negative Mittelwert-Varianz
plt0352 = plot([(empMWplt(1)-varMWplt(1)), (empMWplt(1)-varMWplt(1))], ...
            [0, varMWplt(2)], ':k', 'LineWidth', 2);
% Beschriftung zur positiven Mittelwert-Varianz
txtvarMWplt02 = sprintf('%1.3f', (empMWplt(1)-varMWplt(1)));
txtplt0352 = text(((empMWplt(1)-(2*varMWplt(1)))), (1.02*varMWplt(2)), txtvarMWplt02);
%%.................................
%   Prozessgrenzen darstellen
%%.................................
% Postive Prozessgrenze
plt381 = plot([valPrzOGr, valPrzOGr], [0, (1.1*empStdplt(2))], '-r', 'LineWidth', 4);
%   Beschriftung zur positiven Prozessgrenze
txtplt381 = text((valPrzOGr), (1.11*empStdplt(2)), ['OG: ', num2str(valPrzOGr)]);
% Negative Prozessgrenze
plt0382 = plot([valPrzUGr, valPrzUGr], [0, (1.1*empStdplt(2))], '-r', 'LineWidth', 4);
%   Beschriftung zur negativen Prozessgrenze
txtplt382 = text((valPrzUGr), (1.11*empStdplt(2)), ['UG: ', num2str(valPrzUGr)]);
%%
%%
%
hold off;
title('Histogramm', 'FontSize', 14);
xlabel('Wert', 'FontSize', 12); ylabel('Häufigkeit und Dichte', 'FontSize', 12);
%   Legende
lg11 = legend('Häufigkeitsverteilung', 'Wahrscheinlichkeitsdichte', ...
              'Mittelwert (arithmetisch)', ...
              'Location', 'Southoutside', 'Orientation', 'Horizontal');
% Hinweis zum Prozentualen Anteil der Werte im Bereich der Std.-Abweichungen
txtplt381 = text((empMWplt(1)-(3.03*empStdplt(1))),(empStdplt(2)-0.1*empStdplt(2)),...
           '68,27 % der Messwerte liegen im Bereich \mu+\sigma bis \mu-\sigma',...
           'Color', [1, 0.5, 0]);
txtplt382 = text((empMWplt(1)-(3.03*empStdplt(1))),(empStdplt(2)-0.15*empStdplt(2)),...
           '95,45 % der Messwerte liegen im Bereich \mu+2*\sigma bis \mu-2*\sigma',...
           'Color', [1, 0.5, 0]);
txtplt383 = text((empMWplt(1)-(3.03*empStdplt(1))),(empStdplt(2)-0.2*empStdplt(2)),...
           '99,73 % der Messwerte liegen im Bereich \mu+3*\sigma bis \mu-3*\sigma',...
           'Color', [1, 0.5, 0]);
%
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

% ENDE

endfunction
