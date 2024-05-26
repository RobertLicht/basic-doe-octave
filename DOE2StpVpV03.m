function DOE2StpVpV03(auxdirpath)
%-----------------------------------------------------------
%% DOE - Aufstellung eines Mehrstufigen Versuchsplanes
%-----------------------------------------------------------
% 18/12/2017    Author: Lichterfeld, Robert-Vincent
%               Build: Versuchsplan erstellen, als .csv speichern
% 19/12/2017    Author: Lichterfeld, Robert-Vincent
%               Edit: Darstellung Versuchsraum
% 26/12/2017    Author: Lichterfeld, Robert-Vincent
%               Edit: Wertebereich in Excel selektieren
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
%pkg load stk;
%pkg load financial;
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


% Aufräumen
%close all;
%clear all;
%clc;


%===============================================
%%  Initialisieren von Konstanten
%===============================================


%.............................................................
%% Dialog Speichern
% Verzeichnis wechseln
% Aktuelles Verzeichnis speichern
wStrct = what();
currntdir = wStrct.path;
% Nutzerverzeichnis öffnen
cd(auxdirpath);

% Speichern der Daten
%.................................................................
% Funktion zum speichern der Datei aufrufen
%[filenameS, pathnameS, fltidx] = uiputfile({'*.csv;*.xls;*.xlsx', 'Save as'});
%[filenameS, pathnameS, fltidx] = uiputfile({'*.csv', 'Comma-separated values';...
%                                            '*.xls', 'Excel97-2003';...
%                                            '*.xlsx', 'Excel2007+'}, 'Save as');
[filenameS, pathnameS, fltidx] = uiputfile({'*.csv', 'Comma-separated values'},...
                                            'Versuchsplan speichern');

% Pfad und Dateinamen ermitteln
sveDatadir = sprintf('%s',pathnameS,filenameS);

% Pfad zum Arbeitsverzeichnis angeben
pathname = pathnameS;

clear fltidx;

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

% Arbeitsverzeichnis öffnen
cd(pathname);

%% Verzeichnis erstellen falls nötig
%if (exist(dirNme, 'dir') == 0); mkdir(dirNme); end;

%% Pfad zum Hilfsverzeichnis aufbauen
%auxdirpath = sprintf('%s%s%s', pathname, '\', dirNme);
%% Hilfsverzeichnis öffnen
%cd(auxdirpath);

%- - - - - - - - - - - - - - - - - - - - - - - - - - -
%%% Diary aktivieren
%%if strcmp((get(0,'diary')), ('off')); diary on; end
%% Datei mit Meldungen des CommandWindows schreiben
%diary on; diary auxLogFile.txt;
%- - - - - - - - - - - - - - - - - - - - - - - - - - -
%--------------------------------------------------

% Zurück in aktuelles Verzeichnis wechseln
cd(currntdir);
%.............................................................

% Zeitstempel für das diary erzeugen
tstmpDiary = (strftime ("%Y-%m-%d_%H:%M:%S", localtime (time ())));
txtProg = 'Versuchsplan erstellen';
txtToDiary = fprintf('\n---------\nLogfile: %s | %s\n---------\n', tstmpDiary, txtProg);
clear txtToDiary;

%===============================================
%%  Dialog mit Nutzer: Anzahl Faktoren
%===============================================
%= = = = = = = = = =
%% User input
txtAnzFktr = sprintf('Anzahl der Einflussfaktoren eingeben:');
nFktr = round(str2double(inputdlg (txtAnzFktr, 'Mehrstufiger Versuchsplan')));
clear txtAnzFktr;
%% User input
txtAnzStp = sprintf('Anzahl der Stufen eingeben:');
nStp = round(str2double(inputdlg (txtAnzStp, 'Mehrstufiger Versuchsplan')));
clear txtAnzStp;
% Eingaben auf Vektor speichern
inptVal = [nFktr; nStp];
%= = = = = = = = = =
%   Nutzereigabe prüfen
% Default-Korrekturwerte vorgeben
corrVal = [3; 2];

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
nFktr = inptVal(1);
nStp = inptVal(2);
clear mb1 nDlg inptVal;
% Mindest-Anzahl der Einflussfaktoren prüfen
if nFktr > 1;
  % do nothing
else
  % Eingabe korrigieren
  nFktr = 2;
  sprnt1 = sprintf('Mindestens 2 Einflussfaktoren noetig!\nSetze Wert zu: %d', nFktr);
  mb1 = msgbox(sprnt1, 'Eingabefehler', "warn");
endif
% Anzahl der Stufen begrenzen
if nStp < 1 || nStp > 3
  nStp = 2;
  sprnt1 = sprintf('Es sind nur 1 bis 3 Stufen moeglich!\nSetze Wert zu: %d', nStp);
  mb1 = msgbox(sprnt1, 'Eingabefehler', "warn");
else
  % do nothing
endif
%
clear mb1 sprnt1;
%------------------

%===============================================
%%  Dialog mit Nutzer: Min/Max-Werte je Faktor
%===============================================
% Einflussfaktoren durchlaufen
%= = = = = = = = = =

for nEF = 1:nFktr;
  % Text zum aktuellen Einflussfaktor
  txtTtl = sprintf('Einflussfaktor %d ', nEF);
  %% User input
  % Minimalwert
  txtEFmin = sprintf('Minimalwert zum EinflussFaktor %d eingeben:', nEF);
  EFmin(nEF) = str2double(inputdlg (txtEFmin, txtTtl));
  %   Nutzereigabe prüfen
  % Testen auf leer
  if isempty(EFmin(nEF));
    % Standardwert vorgeben
    EFmin(:, nEF) = 0;
    %   Information an Nutzer
    % Informationstext
    sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %1.3f', EFmin(nEF));
    mb1 = msgbox(sprnt1, 'Eingabefehler', "help");
    clear sprnt1;
    %
  else
    % Keine Aktion
  endif

  % Testen auf Zeichen
  if ischar(EFmin(nEF));
    % Standardwert vorgeben
    EFmin(nEF) = 0;
    %   Information an Nutzer
    % Informationstext
    sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %1.3f', EFmin(nEF));
    mb1 = msgbox(sprnt1, 'Eingabefehler', "help");
    clear sprnt1;
    %
  else
    % Keine Aktion
  endif

  % Testen auf NaN
  if isnan(EFmin(nEF));
    % Standardwert vorgeben
    EFmin(nEF) = 0;
    %   Information an Nutzer
    % Informationstext
    sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %1.3f', EFmin(nEF));
    mb1 = msgbox(sprnt1, 'Eingabefehler', "help");
    clear sprnt1;
    %
  else
    % Keine Aktion
  endif
  %
  clear mb1;
  %----------------
  %%%
  % Maximalwert
  txtEFmax = sprintf('Maximalwert zum EinflussFaktor %d eingeben:', nEF);
  EFmax(nEF) = str2double(inputdlg (txtEFmax, txtTtl));
  %   Nutzereigabe prüfen
  % Testen auf leer
  if isempty(EFmax(nEF));
    % Standardwert vorgeben
    EFmax(nEF) = 0;
    %   Information an Nutzer
    % Informationstext
    sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %1.3f', EFmax(nEF));
    mb1 = msgbox(sprnt1, 'Eingabefehler', "help");
    clear sprnt1;
    %
  else
    % Keine Aktion
  endif

  % Testen auf Zeichen
  if ischar(EFmax(nEF));
    % Standardwert vorgeben
    EFmax(nEF) = 0;
    %   Information an Nutzer
    % Informationstext
    sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %1.3f', EFmax(nEF));
    mb1 = msgbox(sprnt1, 'Eingabefehler', "help");
    clear sprnt1;
    %
  else
    % Keine Aktion
  endif

  % Testen auf NaN
  if isnan(EFmax(nEF));
    % Standardwert vorgeben
    EFmax(nEF) = 0;
    %   Information an Nutzer
    % Informationstext
    sprnt1 = sprintf('Ungueltige Eingabe!\nSetze Wert zu: %1.3f', EFmax(nEF));
    mb1 = msgbox(sprnt1, 'Eingabefehler', "help");
    clear sprnt1;
    %
  else
    % Keine Aktion
  endif
  %
  clear mb1;
  %----------------
  %= = = = = = = = = = = = = = = = = = = = = = =
  % Mid-Werte zu den Einflussfaktoren berechnen
  %= = = = = = = = = = = = = = = = = = = = = = =
  EFmid(nEF) = mean([EFmin(nEF) ,EFmax(nEF)], "all");




%  %......................................
%  % Mittelwerte zu den Einflussfaktoren
%  %......................................
%  mwEF(:,nEF) = mean([EFmin(:,nEF), EFmax(:,nEF)]);
%
%  %..........................................................
%  %   Normierung und Zentrierung Werte zu den Einflussgrößen
%  %..........................................................
%  % Normierung der Werte
%  nrmEF(1,nEF) = (( EFmin(:, nEF)-mwEF(:,nEF) )/( EFmax(:, nEF)-mwEF(:,nEF)) );
%  nrmEF(2,nEF) = (( EFmid(:, nEF)-mwEF(:,nEF) )/( EFmid(:, nEF)-mwEF(:,nEF)) );
%  nrmEF(3,nEF) = (( EFmax(:, nEF)-mwEF(:,nEF) )/( EFmax(:, nEF)-mwEF(:,nEF)) );


endfor
clear txtTtl txtEFmin txtEFmax;
%= = = = = = = = = =

%= = = = = = = = = = = = = = = = = = = = = =
%   Vollfaktoriellen Versuchsplan erstellen
%= = = = = = = = = = = = = = = = = = = = = =
% Aufbauen der Vektoren mit den Faktoren
vecVpln = ones(1, nFktr);
% Unterscheidung der Stufen
if nStp == 1;
  % Versuchsplan für eine Stufe
  Vpln = fullfact(nStp * vecVpln);
  % Text zur Stufe des Versuchsplans
  txtVplnStp = 'einstufige';

elseif nStp == 2;
  % Versuchsplan für zwei Stufen
  Vpln = fullfact(nStp * vecVpln);
  % Text zur Stufe des Versuchsplans
  txtVplnStp = 'zweistufige';

else
  % Versuchsplan für drei Stufe
  Vpln = fullfact(nStp * vecVpln);
  % Text zur Stufe des Versuchsplans
  txtVplnStp = 'dreistufige';

endif
%

%.............................................................
%   Min-Mid-Max-Werte in Vollfaktoriellen Versuchsplan eintragen
%.............................................................
%= = = = = =
% Speicher reservieren
VplnVal = zeros(size(Vpln));
% Einflussfaktoren durchsuchen
for nC = 1:size(Vpln,2);
  % Versuche nach Stufen durchsuchen
  for nR = 1:size(Vpln,1);
    % Werte nach Stufe zuordnen
    if Vpln(nR,nC) == 1;
      % Minimalwerte zuordnen
      VplnVal(nR,nC) = EFmin(nC);
    elseif Vpln(nR,nC) == (nStp-1);
      % Mittelwerte zuordnen
      VplnVal(nR,nC) = EFmid(nC);
   else
      % Maximalwerte zuordnen
      VplnVal(nR,nC) = EFmax(nC);
   endif
    %
  endfor
    %
endfor
  %
clear nC nR;
%= = = = = =

%.............................................................
%   Normierte-Werte in Vollfaktoriellen Versuchsplan eintragen
%.............................................................
%= = = = = =
% Speicher reservieren
VplnValNorm = zeros(size(Vpln));
% Einflussfaktoren durchsuchen
for nC = 1:size(Vpln,2);
  % Versuche nach Stufen durchsuchen
  for nR = 1:size(Vpln,1);
    % Werte nach Stufe zuordnen
    if Vpln(nR,nC) == 1;
      % Minimalwerte zuordnen
      VplnValNorm(nR,nC) = -1;
    elseif Vpln(nR,nC) == (nStp-1);
      % Mittelwerte zuordnen
      VplnValNorm(nR,nC) = 0;
   else
      % Maximalwerte zuordnen
      VplnValNorm(nR,nC) = 1;
   endif
    %
  endfor
    %
endfor
  %
clear nC nR;
%= = = = = =

%------------------
%   Versuchsfolge in Datei schreiben
%------------------
%.................
%% Ausgabe der Min-Max-Werte
%.................
% Bezeichnung der Exportdatei aufbauen
dtetme = (strftime ("%Y-%m-%d_%H%M%S_", localtime (time ())));
datName = sprintf('%s%s', dtetme, filenameS);
%datName = input('\nDateiname angeben:\n','s');

%.................
%% Ausgabe der normierten Werte
%.................
% Bezeichnung der Exportdatei aufbauen
datNameNorm = sprintf('%sNorm_%s', dtetme, filenameS);


%------------------
%............................
%%    Header aufbauen
%............................
% Speicherplatz reservieren
hdrVpln = num2str( zeros(1, (4*(size(VplnVal,2)))) );
%   Text der ersten Spalte schreiben
% Text generieren
txtVpln = sprintf('Versuch ;');
hdrVpln(1,(1:size(txtVpln,2))) = txtVpln;
%   Header vorbereiten
for nC = 1 : (size(VplnVal,2));
  % Text der nöchsten Spalte
  txtNxtCol = sprintf('Faktor %s;', num2str(nC));
  % Zeichenkette aufbauen
  hdrVpln(1,((nC*size(txtNxtCol,2)+1):((nC*size(txtNxtCol,2)) + size(txtNxtCol,2)))) = txtNxtCol;

endfor
  %
clear nC txtNxtCol;
%%------------------
%%% Daten schreiben
%for nR = 1 : (size(VplnVal,1) + 1);
%  % Header schreiben
%  if nR == 1;
%    dlmwrite(datName, hdrVpln, 'delimiter', '');
%  else
%    % Werte der aktuellen Zeile sammeln
%    valZle = sprintf('%d;', [(nR-1), VplnVal((nR-1),:)]);
%    % Werte der aktuellen Zeile schreiben
%    dlmwrite(datName, valZle, '-append', 'delimiter', '');
%%    dlmwrite(datName, valZele, '-append', 'precision', '%.9f' ,...
%%             'roffset', 0, 'delimiter', '','newline', 'pc');
%  endif
%    %
%endfor
%  %
%clear nR valZle;
%%------------------


% In Arbeitsverzeichnis wechseln
cd(pathname);   % Verzeichnis der Arbeitsdatei öffnen

%% Ordner für Hilfsdateien erstellen
% Prüfen ob Ordner bereits existiert, sonst Ornder erstellen
if (exist(auxdirpath, 'dir') == 0)
  % Namen des Orders erstellen
  dte = (strftime ("%Y-%m-%d", localtime (time ())));
  % Ordnernamen angeben
  dirNme = sprintf('DatenVrsPlng%s', dte);
  %dirNme = 'auxData';

  if dirNme(end) ~= '\', dirNme = [dirNme, '\'];else; endif;

  % Arbeitsverzeichnis öffnen
  cd(pathname);

  % Verzeichnis erstellen falls nötig
  if (exist(dirNme, 'dir') == 0); mkdir(dirNme);else; endif;

  % Pfad zum Hilfsverzeichnis aufbauen
  auxdirpath = sprintf('%s%s%s', pathname, '\', dirNme);

else
  % Hilfsverzeichnis öffnen
  cd(auxdirpath);

endif


%%------------------
% Min-mid-Max-Daten in Datei schreiben
for nR = 1 : (size(VplnVal,1) + 1);
  % Header schreiben
  if nR == 1;
    dlmwrite(datName, hdrVpln, 'delimiter', '');
  else
    % Werte der aktuellen Zeile sammeln
    valZle = sprintf('%1.6f;', [(nR-1), VplnVal((nR-1),:)]);
    % Werte der aktuellen Zeile schreiben
    dlmwrite(datName, valZle, '-append', 'delimiter', '');
%    dlmwrite(datName, valZele, '-append', 'precision', '%.9f' ,...
%             'roffset', 0, 'delimiter', '','newline', 'pc');
  endif
    %
endfor
  %
clear nR valZle;
%------------------

%%------------------
%%% Normierte Daten in Datei schreiben
%for nR = 1 : (size(VplnValNorm,1) + 1);
%  % Header schreiben
%  if nR == 1;
%    dlmwrite(datNameNorm, hdrVpln, 'delimiter', '');
%  else
%    % Werte der aktuellen Zeile sammeln
%    valZle = sprintf('%d;', [(nR-1), VplnValNorm((nR-1),:)]);
%    % Werte der aktuellen Zeile schreiben
%    dlmwrite(datNameNorm, valZle, '-append', 'delimiter', '');
%%    dlmwrite(datName, valZele, '-append', 'precision', '%.9f' ,...
%%             'roffset', 0, 'delimiter', '','newline', 'pc');
%  endif
%    %
%endfor
%  %
%clear nR valZle;
%%------------------

%% Informationsdatei durch Systemprogramm öffnen lassen
%winopen('auxInfoAbout.txt'); <- Nur in MATLAB möglich

%= = = = = = = = = =
% Open an external file with an external program
try
  open(datName);
catch ME
  txtME = fprintf(ME);
end_try_catch
%= = = = = = = = = =

% Zurück in aktuelles Verzeichnis wechseln
cd(currntdir);

%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Datenstruktur erstellen und Darstellen
%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
% Anzahl der Einflussfaktoren und Stufen prüfen
if nFktr == 2 && nStp == 2;
  % Datenstruktur erstellen
  vRm = rEck(EFmin, EFmax);
  % Darstellen der Datenstruktur
  show2D(vRm, VplnVal);
elseif nFktr == 2 && nStp == 3;
  % Datenstruktur erstellen
  vRm = rEckZP(EFmin, EFmax, EFmid);
  % Darstellen der Datenstruktur
  show2D(vRm, VplnVal);
elseif nFktr == 3 && nStp == 2;
  % Datenstruktur erstellen
  vRm = quader(EFmin, EFmax);
  % Darstellen der Datenstruktur
  show(vRm, VplnVal);
elseif nFktr == 3 && nStp == 3;
  % Datenstruktur erstellen
  vRm = quaderZP(EFmin, EFmax, EFmid);
  % Darstellen der Datenstruktur
  show(vRm, VplnVal);
else
  % do nothing
endif
%


%%% Speichern der Daten
%% Variablen initialisieren
%content = D; % Tabelle in LaTeX-Formatierung
%texfile = SaveDatadir; % Speicherort der *.tex-Datei
%
%% Schreiben in Datei
%% dlmwrite(texfile, content,'delimiter','');
%dlmwrite(texfile, content,'delimiter', '','newline', 'pc');
%..............................................................

%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Funktion: Erstellung der Datenstruktur
%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
function vRm = rEck(EFmin, EFmax)
%% Datenstruktur des Quaders
% Nach den Unterlagen zur Vorlesung Ingenieurwissenschaftliche
% Softwarewerkzeuge (IWSW):
% Abschnitte entlang der entsprechenden Raumrichtungen
% Die Daten-Punkte der Struktur in einem STRUCT ablegen
%
% 4 Punkte der Struktur (Eckpunkte)
%            1  2  3  4
%vRm.p = [[ -x  x  x -x ]; ...
%         [ -y -y  y  y ]];
%          1        2        3        4
vRm.p = [[ EFmin(1) EFmax(1) EFmax(1) EFmin(1)]; ...
         [ EFmin(2) EFmin(2) EFmax(2) EFmax(2)]];

% 4 Linien (Drähte) der Struktur
%    Draht 1 2 3 4
%vRm.l = [[1 2 3 4]; ...
%         [2 3 4 1]];

vRm.l = [[1 2 3 4]; ...
         [2 3 4 1]];

endfunction

%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Funktion: Erstellung der Datenstruktur mit Zentralpunkt
%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
function vRm = rEckZP(EFmin, EFmax, EFmid)
%% Datenstruktur des Quaders
% Nach den Unterlagen zur Vorlesung Ingenieurwissenschaftliche
% Softwarewerkzeuge (IWSW):
% Abschnitte entlang der entsprechenden Raumrichtungen
% Die Daten-Punkte der Struktur in einem STRUCT ablegen
%
% 4 Punkte der Struktur (Eckpunkte)
%            1  2  3  4  5  6  7  8  9
%vRm.p = [[ -x  x  x -x  0  0  x  0 -x ]; ...
%         [ -y -y  y  y  0 -y  0  y  0 ]];
%          1        2        3        4        5        6        7        8        9
vRm.p = [[ EFmin(1) EFmax(1) EFmax(1) EFmin(1) EFmid(1) EFmid(1) EFmax(1) EFmid(1) EFmin(1) ]; ...
         [ EFmin(2) EFmin(2) EFmax(2) EFmax(2) EFmid(2) EFmin(2) EFmid(2) EFmax(2) EFmid(2) ]];

% 4 Linien (Drähte) der Struktur
%    Draht 1 2 3 4 5 6 7 8
%vRm.l = [[1 2 3 4 1 2 3 4]; ...
%         [2 3 4 1 5 5 5 5]];

%   Draht 0 0 0 0 0 0 0 0 0 1 1 1
%   Draht 1 2 3 4 5 6 7 8 9 0 1 2
vRm.l = [[1 2 3 4 1 2 3 4 1 2 3 4]; ...
         [2 3 4 1 5 5 5 5 6 7 8 9]];

endfunction

%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Funktion: Erstellung des Quaders
%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
function vRm = quader(EFmin, EFmax)
%% Datenstruktur des Quaders
% Nach den Unterlagen zur Vorlesung Ingenieurwissenschaftliche
% Softwarewerkzeuge (IWSW):
% Abschnitte entlang der entsprechenden Raumrichtungen
% Die Daten-Punkte der Struktur in einem STRUCT ablegen
%
% 8 Punkte der Struktur (Eckpunkte)
%         1  2  3  4  5  6  7  8
%vRm.p = [[ -x  x  x -x -x  x  x -x]; ...
%         [ -y -y  y  y -y -y  y  y]; ...
%         [ -z -z -z -z  z  z  z  z]];
%          1        2        3        4        5        6        7        8
vRm.p = [[ EFmin(1) EFmax(1) EFmax(1) EFmin(1) EFmin(1) EFmax(1) EFmax(1) EFmin(1)]; ...
         [ EFmin(2) EFmin(2) EFmax(2) EFmax(2) EFmin(2) EFmin(2) EFmax(2) EFmax(2)]; ...
         [ EFmin(3) EFmin(3) EFmin(3) EFmin(3) EFmax(3) EFmax(3) EFmax(3) EFmax(3)]];

% 12 Linien (Drähte) der Struktur
% Draht 0 0 0 0 0 0 0 0 0 1 1 1
% Draht 1 2 3 4 5 6 7 8 9 0 1 2
%vRm.l = [[1 2 3 4 5 6 7 8 1 2 3 4]; ...
%       [2 3 4 1 6 7 8 5 5 6 7 8]];

%   Draht 0 0 0 0 0 0 0 0 0 1 1 1
%   Draht 1 2 3 4 5 6 7 8 9 0 1 2
vRm.l = [[1 2 3 4 5 6 7 8 1 2 3 4]; ...
         [2 3 4 1 6 7 8 5 5 6 7 8]];

endfunction

%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Funktion: Erstellung des Quaders mit Zentralpunkt
%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
function vRm = quaderZP(EFmin, EFmax, EFmid)
%% Datenstruktur des Quaders
% Nach den Unterlagen zur Vorlesung Ingenieurwissenschaftliche
% Softwarewerkzeuge (IWSW):
% Abschnitte entlang der entsprechenden Raumrichtungen
% Die Daten-Punkte der Struktur in einem STRUCT ablegen
%

%            1  2  3  4  5  6  7  8  9
%vRm.p = [[ -x  x  x -x  0  0  x  0 -x ]; ...
%         [ -y -y  y  y  0 -y  0  y  0 ]];


% 8 Punkte der Struktur (Eckpunkte)
%            0  0  0  0  0  0  0  0  0  1  1  1  1  1  1  1  1  1  1  2  2
%            1  2  3  4  5  6  7  8  9  0  1  2  3  4  5  6  7  8  9  0  1
%vRm.p = [[ -x  x  x -x -x  x  x -x  0  0  x  0 -x -x  x  x -x  0  x  0 -x]; ...
%         [ -y -y  y  y -y -y  y  y  0 -y  0  y  0 -y -y  y  y -y  0  y  0]; ...
%         [ -z -z -z -z  z  z  z  z  0 -z -z -z -z  0  0  0  0  z  z  z  z]];

%          1        2        3        4        5        6        7        8        9        10       11       12       13       14       15       16       17       18       19       20       21
vRm.p = [[ EFmin(1) EFmax(1) EFmax(1) EFmin(1) EFmin(1) EFmax(1) EFmax(1) EFmin(1) EFmid(1) EFmid(1) EFmax(1) EFmid(1) EFmin(1) EFmin(1) EFmax(1) EFmax(1) EFmin(1) EFmid(1) EFmax(1) EFmid(1) EFmin(1)]; ...
         [ EFmin(2) EFmin(2) EFmax(2) EFmax(2) EFmin(2) EFmin(2) EFmax(2) EFmax(2) EFmid(2) EFmin(2) EFmid(2) EFmax(2) EFmid(2) EFmin(2) EFmin(2) EFmax(2) EFmax(2) EFmin(2) EFmid(2) EFmax(2) EFmid(2)]; ...
         [ EFmin(3) EFmin(3) EFmin(3) EFmin(3) EFmax(3) EFmax(3) EFmax(3) EFmax(3) EFmid(3) EFmin(3) EFmin(3) EFmin(3) EFmin(3) EFmid(3) EFmid(3) EFmid(3) EFmid(3) EFmax(3) EFmax(3) EFmax(3) EFmax(3)]];


%vRm.p = [[ EFmin(1) EFmax(1) EFmax(1) EFmin(1) EFmin(1) EFmax(1) EFmax(1) ...
%           EFmin(1) EFmid(1) EFmid(1) EFmax(1) EFmid(1) EFmin(1) EFmid(1) ...
%           EFmax(1) EFmid(1) EFmin(1) EFmid(1) EFmax(1) EFmid(1) EFmin(1)]; ...
%         [ EFmin(2) EFmin(2) EFmax(2) EFmax(2) EFmin(2) EFmin(2) EFmax(2) ...
%           EFmax(2) EFmid(2) EFmin(2) EFmid(2) EFmax(2) EFmid(2) EFmin(2) ...
%           EFmid(2) EFmax(2) EFmid(2) EFmin(2) EFmid(2) EFmax(2) EFmid(2)]; ...
%         [ EFmin(3) EFmin(3) EFmin(3) EFmin(3) EFmax(3) EFmax(3) EFmax(3) ...
%           EFmax(3) EFmid(3) EFmin(3) EFmin(3) EFmin(3) EFmin(3) EFmid(3) ...
%           EFmid(3) EFmid(3) EFmid(3) EFmax(3) EFmax(3) EFmax(3) EFmax(3)]];

% 12 Linien (Drähte) der Struktur
%    Draht 0 0 0 0 0 0 0 0 0 1 1 1 1
%    Draht 1 2 3 4 5 6 7 8 9 0 1 2 3
%vRm.l = [[1 2 3 4 5 6 7 8 1 2 3 4 1]; ...
%         [2 3 4 1 6 7 8 5 5 6 7 8 9]];

%   Draht 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 2  2  2  2  2  2  2  2  2  2  3  3  3
%   Draht 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0  1  2  3  4  5  6  7  8  9  0  1  2
vRm.l = [[1 2 3 4 5 6 7 8 1 2 3 4 1 2 3 4 5 6 7 8  1  2  3  4  5  6  7  8  5  6  7  8]; ...
         [2 3 4 1 6 7 8 5 5 6 7 8 9 9 9 9 9 9 9 9 10 11 12 13 14 15 16 17 18 19 20 21]];

endfunction


%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Funktion: 2-D Darstellung des Versuchsplans
%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
function show2D(b, VplnVal)
%% IWSW Uebung 5
%
% Nach den Unterlagen zur Vorlesung Ingenieurwissenschaftliche
% Softwarewerkzeuge (IWSW):
% Funktion zum erstellen eines Koordinatenkreuzes

% Achsenlänge des Koordinatenkreuzes
kl = 1.25*(max(max(VplnVal)));

% Koordinatenkreuz als Platzhalter und zur Orientierung erzeugen
k2=kl/2;
% Eselsbrücke "RGB" für Farben der Achsen X, Y, Z
%
% Erstellen eines figure windows und dieses auf handle referenzieren
fg212 = figure(212);
% Eigenschaften zum handle antragen, durch den Befehl set(...)
set(fg212,'Name','Darstellung der Versuchspunkte','NumberTitle','off');
% relative Angabe [left bottom width height]
set(fg212,'Units','normalized','Position',[0.2 0.26 0.45 0.6]);

hold on;

% Plotfunktionen
plot3([0 k2],  [0 0],   [0 0], 'r', 'Linewidth', 1.5);
plot3([0 0],   [0 k2],  [0 0], 'g', 'Linewidth', 1.5);
plot3([0 0],   [0 0],   [0 k2], 'b', 'Linewidth', 1.5);
plot3([0 -k2], [0 0],   [0 0], 'r:', 'Linewidth', 1.5);
plot3([0 0],   [0 -k2], [0 0], 'g:', 'Linewidth', 1.5);
plot3([0 0],   [0 0],   [0 -k2], 'b:', 'Linewidth', 1.5);


%% Darstellung
%
% Nach den Unterlagen zur Vorlesung Ingenieurwissenschaftliche
% Softwarewerkzeuge (IWSW):
% Darstellung des übermittelten Körpers
hold on;

% Darstellung des übermittelten Körpers b
for k = (1:size(b.l,2)) % bis Anzahl der Spalten der Matrix b.l
    plot3([b.p(1,b.l(1,k)) b.p(1,b.l(2,k))],...
          [b.p(2,b.l(1,k)) b.p(2,b.l(2,k))],'ko-', 'MarkerFaceColor', 'r');
end

% Weitere Einstellungen zur Darstellung
grid on;
title('Darstellung der Versuchspunkte in der Ebene', 'FontSize', 12)
xlabel('Faktor: X_{1}');
ylabel('Faktor: X_{2}');
axis auto;%square equal
% Einstellungen zur Ansicht
view(0, 90); %view(3);
% Einfügen der Legende
hlg01 = legend('X_{1}','X_{2}','Location','Eastoutside',...
                'Orientation', 'Vertical');
set(hlg01, 'FontSize',12);


endfunction

%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Funktion: 3-D Darstellung des Versuchsplans
%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
function show(b, VplnVal)
%% IWSW Uebung 5
%
% Nach den Unterlagen zur Vorlesung Ingenieurwissenschaftliche
% Softwarewerkzeuge (IWSW):
% Funktion zum erstellen eines Koordinatenkreuzes

% Achsenlänge des Koordinatenkreuzes
kl = 1.25*(max(max(VplnVal)));

% Koordinatenkreuz als Platzhalter und zur Orientierung erzeugen
k2=kl/2;
% Eselsbrücke "RGB" für Farben der Achsen X, Y, Z
%
% Erstellen eines figure windows und dieses auf handle referenzieren
fg212 = figure(212);
% Eigenschaften zum handle antragen, durch den Befehl set(...)
set(fg212,'Name','Darstellung der Versuchspunkte','NumberTitle','off');
% relative Angabe [left bottom width height]
set(fg212,'Units','normalized','Position',[0.2 0.26 0.45 0.6]);

hold on;

% Plotfunktionen
plot3([0 k2],  [0 0],   [0 0], 'r', 'Linewidth', 1.5);
plot3([0 0],   [0 k2],  [0 0], 'g', 'Linewidth', 1.5);
plot3([0 0],   [0 0],   [0 k2], 'b', 'Linewidth', 1.5);
plot3([0 -k2], [0 0],   [0 0], 'r:', 'Linewidth', 1.5);
plot3([0 0],   [0 -k2], [0 0], 'g:', 'Linewidth', 1.5);
plot3([0 0],   [0 0],   [0 -k2], 'b:', 'Linewidth', 1.5);


%% Darstellung
%
% Nach den Unterlagen zur Vorlesung Ingenieurwissenschaftliche
% Softwarewerkzeuge (IWSW):
% Darstellung des übermittelten Körpers
hold on;

% Darstellung des übermittelten Körpers b
for k = (1:size(b.l,2)) % bis Anzahl der Spalten der Matrix b.l
    plot3([b.p(1,b.l(1,k)) b.p(1,b.l(2,k))],...
          [b.p(2,b.l(1,k)) b.p(2,b.l(2,k))],...
          [b.p(3,b.l(1,k)) b.p(3,b.l(2,k))],'ko-', 'MarkerFaceColor', 'r');
end

% Weitere Einstellungen zur Darstellung
grid on;
title('Darstellung der Versuchspunkte im Raum', 'FontSize', 12)
xlabel('Faktor: X_{1}');
ylabel('Faktor: X_{2}');
zlabel('Faktor: X_{3}');
axis auto;%square equal
% Einstellungen zur Ansicht
view(350, 60); %view(3);
% Einfügen der Legende
hlg01 = legend('X_{1}','X_{2}','X_{3}','Location','Eastoutside',...
                'Orientation', 'Vertical');
set(hlg01, 'FontSize',12);


endfunction


%%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
%%% Funktion: Erstellung und Ausgabe des Logfiles
%%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
%function showLogfile(pathname, currntdir, dirNme)
%% Funktion zum anzeigen des LogFiles
%
%% Aktuelles Verzeichnis speichern
%
%% Ordnernamen angeben
%%dirpath = 'auxData2LaTeXtabular';
%if dirNme(end) ~= '/', dirNme = [dirNme '/']; end;
%
%% Arbeitsverzeichnis öffnen
%cd(pathname);
%
%% Prüfen ob der Hilfsordner bereits existiert
%if (exist(dirNme, 'dir') > 0);
%    % Pfad zum Hilfsverzeichnis aufbauen
%    auxdirpath = sprintf('%s%s', pathname, dirNme);%
%    % Hilfsverzeichnis der Logdatei öffnen
%    cd(auxdirpath);
%    % Prüfen ob LogFile bereits existiert
%    if (exist('auxLogFile.txt','file') > 0);
%        % Logdatei durch Systemprogramm öffnen lassen
%        %winopen('auxLogFile.txt'); <- Nur in MATLAB möglich
%        %= = = = = = = = = =
%        % Open an external file with an external program
%        open('auxLogFile.txt');
%        %= = = = = = = = = =
%    end%file
%end%dirpath
%
%% Zurück in aktuelles Verzeichnis wechseln
%cd(currntdir);
%
%endfunction
%%%..............................................................


%= = = = = = = = = =
%%    ENDE
%= = = = = = = = = =

%--------------
% Info to user
txtToUser = fprintf('\n\nDer %s Versuchsplan wurde erstellt!\n', txtVplnStp);
%--------------

% Mitschreiben des diary beenden
%diary off;

%% ENDE
endfunction
