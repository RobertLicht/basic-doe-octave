%% Generelle Informationen
%
%   Copyright (c) Lichterfeld Robert-Vincent, 2017
%
%   Dieses Werk ist lizenziert unter einer
%   Creative Commons Namensnennung -
%   Weitergabe unter gleichen Bedingungen
%   4.0 International Lizenz.
%
%   https://creativecommons.org/licenses/by-sa/4.0/
%
% Beschreibung
%
% Dieses GUI-Script dient zur Verwaltung von Unterprogrammen.
% Das Paket an Programmen dient zur Erstellung von Versuchsplänen,
% der Auswertung von Messwerten und der Berechnung eines Regresionspolynoms.
%
%......................................................................
% Änderungslog
%
% 28/12/2017  Robert-Vincent Lichterfeld
%             Erstellung: Dieses GUI
% 02/01/2018  Author: Lichterfeld, Robert-Vincent
%             Anpassung: Demo-Version mit begrenzten Unterprogrammen


% Aufräumen
close all;
%clear all;
% Alle Variablen ausser fg02 löschen
%clear -x fg02;
clc;

%   Settings for Paging Screen Output
% To automatically flush stuff automatically, set:
page_output_immediately (0);

% and to send it to stdout without a pager, set:
page_screen_output (0);


try
      close (fg02);
catch ME
      disp(ME);
end
%
clear ME;

%% Quelle: https://octave.sourceforge.io/octave/function/uicontrol.html
%%% create a new figure and panel on it
%%f = figure;
%%% create a button (default style)
%%b1 = uicontrol (f, "string", "A Button", "position",[10 10 150 40]);
%%% create an edit control
%%e1 = uicontrol (f, "style", "edit", "string", "editable text", "position",[10 60 300 40]);
%%% create a checkbox
%%c1 = uicontrol (f, "style", "checkbox", "string", "a checkbox", "position",[10 120 150 40]);


%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
% Aktuelles Verzeichnis speichern
wStrct = what();
currntdir = wStrct.path;
% Nutzerverzeichnis öffnen
cd();

% Speichern der Daten
%.................................................................
% Funktion zum speichern der Datei aufrufen
%[filenameS, pathnameS, fltidx] = uiputfile({'*.csv;*.xls;*.xlsx', 'Save as'});
%[filenameS, pathnameS, fltidx] = uiputfile({'*.csv', 'Comma-separated values';...
%                                            '*.xls', 'Excel97-2003';...
%                                            '*.xlsx', 'Excel2007+'}, 'Save as');
[filenameS, pathnameS, fltidx] = uiputfile({'*.txt',...
                                           'text'},'Projektverzeichnis angeben');

%% Pfad und Dateinamen ermitteln
%sveDatadir = sprintf('%s',pathnameS,filenameS);

% Pfad zum Arbeitsverzeichnis angeben
pathname = pathnameS;

clear filenameS fltidx;
%-----------------------------------------------------------
%% Ordner för Hilfsdateien erstellen
% Prüfen ob Ordner bereits existiert, sonst Ornder erstellen

% Namen des Orders erstellen
dte = (strftime ("%Y-%m-%d", localtime (time ())));
% Ordnernamen angeben
dirNme = sprintf('DatenVrsPlng%s', dte);

if dirNme(end) ~= '\', dirNme = [dirNme, '\']; end;

% Arbeitsverzeichnis öffnen
cd(pathname);

% Verzeichnis erstellen falls nötig
if (exist(dirNme, 'dir') == 0); mkdir(dirNme); end;

% Pfad zum Hilfsverzeichnis aufbauen
auxdirpath = sprintf('%s%s%s', pathname, '\', dirNme);
% Hilfsverzeichnis öffnen
cd(auxdirpath);

%- - - - - - - - - - - - - - - - - - - - - - - - - - -
%% Diary aktivieren
% Datei mit Meldungen des CommandWindows schreiben
diary on; diary auxLogFile.txt;
%- - - - - - - - - - - - - - - - - - - - - - - - - - -

% Zurück in aktuelles Verzeichnis wechseln
cd(currntdir);
%.............................................................

% Zeitstempel für das diary erzeugen
tstmpDiary = (strftime ("%Y-%m-%d_%H:%M:%S", localtime (time ())));
txtProg = 'uipanelDoE';
txtToDiary = fprintf('\n---------\nLogfile: %s | %s\n---------\n', tstmpDiary, txtProg);
clear txtToDiary;
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=


% Erstellen eines figure windows und dieses auf handle referenzieren
fg02 = figure(2);
% Eigenschaften zum handle antragen, durch den Befehl set(...)
set(fg02, 'Name', 'DoE UI PANEL - Testversion', 'NumberTitle', 'off');
% relative Angabe [left bottom width height]
set(fg02,'Units','normalized','Position',[0.25 0.275 0.275 0.425]);
% Hintergrundfarbe vorgeben
set(uipanel, "backgroundcolor", [(221/255), (223/255), (212/255)]);
% Art der Begrenzung
set(uipanel, "BorderType", "line", "BorderWidth", 0.5);


%% Erstellung der Elemente

%===============================================
%%  Schaltflächen im Menüband erstellen
%===============================================
%   create a entry in the uimenu
% Entry in uimenu closes the current figure
uim01 = uimenu (fg02, "label", "Close", "accelerator", "q", ...
                "callback", "diary off, close (gcf)");

% Entry in uimenu shows information about the program
uim04 = uimenu (fg02, "label", "Uber", ...
                "callback", "makeInfo(auxdirpath, currntdir)");

%===============================================
%%  Hintergrundbild einfügen
%===============================================
%   create a entry for an image (sloppy background image)
% %h = imshow (im, [low, high]);
%himg = imshow ('Vplan3E3S02.jpg');

%===============================================
%%  Text hinzufügen
%===============================================

%   create a plain text
% relative Angabe [left bottom width height]
text1 =  uicontrol (fg02, ...
                    "style", "text", ...
                    "string", "Basis DoE", ...
                    "FontSize", 16, "FontWeight", "bold", ...
                    "tooltipstring", "Programm mit OCTAVE erstellt", ...
                    "Units","normalized","position", [0 0.9 1 0.1], ...
                    "ForegroundColor",[(254/255), (255/255), (255/255)], ...
                    "BackgroundColor", [(23/255), (62/255), (67/255)]);


%===============================================
%%  Schaltflächen erstellen
%===============================================
% relative Angabe [left bottom width height]

%   create a button (default style)
% Display some text and run a file
btn01 = uicontrol (fg02, "string", "Versuchsplan erstellen", ...
                 "FontWeight", "bold", "FontSize", 10, ...
                 "tooltipstring", "Erstellt einen vollfaktoriellen Versuchsplan", ...
                 "Units","normalized","position", [0.05 0.7 0.45 0.1], ...
                 %"position",[10 300 150 40], ...
                 "BackgroundColor",[(250/255), (229/255), (150/255)], ...
                 "ForegroundColor",[(29/255), (33/255), (32/255)], ...
                 "callback", ...
                 "disp('Versuchsplan erstellen wurde gedrückt!'), \
                 DOE2StpVpV03(auxdirpath)");


%   create a button (default style)
% Display some text and run a file
btn04 = uicontrol (fg02, "string", "Messdaten auswerten", ...
                 "FontWeight", "bold", "FontSize", 10, ...
                 "tooltipstring", "Auswertung von Messdaten nach statistischen Merkmalen", ...
                 "Units","normalized","position", [0.05 0.55 0.45 0.1], ...
                 %"position",[10 225 150 40], ...
                 "BackgroundColor",[(250/255), (229/255), (150/255)], ...
                 "ForegroundColor",[(29/255), (33/255), (32/255)], ...
                 "callback", ...
                 "disp('Messdaten auswerten wurde gedrückt!'), \
                 StatisticMWerteV01(auxdirpath)");


%   create a button (default style)
% Display some text and run a file
btn06 = uicontrol (fg02, "string", "Analyse der Daten", ...
                 "FontWeight", "bold", "FontSize", 10, ...
                 "tooltipstring", "Erstellen einer Regressionsfunktion", ...
                 "Units","normalized","position", [0.05 0.4 0.45 0.1], ...
                 %"position",[10 150 150 40], ...
                 "BackgroundColor",[(250/255), (229/255), (150/255)], ...
                 "ForegroundColor",[(29/255), (33/255), (32/255)], ...
                 "callback", ...
                 "disp('Analyse der Daten wurde gedrückt!'), \
                 msgDemo");



%   create a button (default style)
% Select a file
btn20 = uicontrol (fg02, "string", "Beenden mit Logfile", ...
                 "FontWeight", "bold", "FontSize", 10, ...
                 "Units","normalized","position", [0.525 0.1 0.4 0.1], ...
                 %"position",[200 100 150 40], ...
                 "BackgroundColor",[(52/255), (73/255), (94/255)], ...
                 "ForegroundColor",[(236/255), (240/255), (241/255)], ...
                 "tooltipstring", "Schliesst das Programm und zeigt den Log-File", ...
                 "callback", "showLogfile(pathname, currntdir, dirNme)");




%===============================================
%%  Fehlende Pakete installieren
%===============================================
% Liste der installierten Pakete erstellen
[loPKG] = pkg('list');
% Liste nötiger Pakete
zuPKG = ['general'; 'io'; 'statistics'];
% Durchsuchen der Liste nach relevanten Paketen
for nP = 1:size(zuPKG,1)
  for lstP = 1:size(loPKG,2)
    % Vorhandene und nötige Pakete vergleichen
    if strcmp( (loPKG{1,lstP}.name), deblank(zuPKG(nP, :)) );
      % Nötiges Paket ist vorhanden
      mrk = 1;
      break;
    else strcmp( (loPKG{1,lstP}.name), deblank(zuPKG(nP, :)) );
      % Nötiges Paket ist nicht vorhanden
      mrk = 0;
    endif
    %
  endfor
  % Prüfen ob Paket heruntergeladen und installiert werden muss
  if mrk == 1;
    % Kein Paket heruntergeladen und installieren
    txtPKG = fprintf('\nDas Paket: %s ist vorhanden\n', deblank(zuPKG(nP, :)) );
    fprintf('\n');
  else
    % Paket heruntergeladen und installieren
    txtPKG = fprintf('\nDas Paket: %s ist nicht vorhanden\n(pkg install -forge <package>)\n', ...
                     deblank(zuPKG(nP, :)) );
    fprintf('\n');
    %   Information an Nutzer
    % Informationstext
    txtInstall = sprintf('pkg install -forge %s', deblank(zuPKG(nP, :)) );
    sprnt1 = sprintf('Bitte folgendes im Befehlsfenster eingeben:\n%s\n\nMeldungen beachten!', txtInstall );
    mb1 = msgbox(sprnt1, 'Paket installieren', "help");
  endif
  %
  clear txtPKG txtInstall sprnt1 mb1;
  %
endfor
%
clear lstP nP zuPKG loPKG;
%

%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Funktion: Erstellung und Anzeigen der Information
%= = = = = = = = = = = = = = = = = = = = = = = = = = = =

function makeInfo(auxdirpath, currntdir)
%% Informationsdatei schreiben
% Inhalt
contntInfo = sprintf(['Generelle Informationen\r\n\r\n' ...
    'Copyright (c) Lichterfeld Robert-Vincent, 2017\r\n\r\n' ...
    'Dieses Werk ist lizenziert unter einer\r\n' ...
    'Creative Commons Namensnennung -\r\n' ...
    'Weitergabe unter gleichen Bedingungen\r\n' ...
    '4.0 International Lizenz.\r\n\r\n' ...
    'https://creativecommons.org/licenses/by-sa/4.0/\r\n\r\n\r\n' ...
    'Beschreibung\r\n\r\n' ...
    'Dieses Script dient zum Erstellen und Speichern von ' ...
    'Versuchsplänen.\r\n' ...
    'Der generierte Versuchsplan wird im .csv-Format ' ...
    'gespeichert.\r\n' ...
    'Zudem werden Daten zu Messwerten mit statistischen Methoden\r\n' ...
    'betrachtet und ein Regressionspolynom aus\r\n' ...
    'Eingaben sowie Ergebnissen des Versuchsplans gebildet.\r\n']);

% Pfad und Dateinamen für Informationsdatei
% txtinfo = sprintf('%s%s', pathname, dirpath, 'auxInfoAbout.txt');

% Arbeitsverzeichnis öffnen
cd(auxdirpath);

% Informationsdatei schreiben
% dlmwrite(txtinfo, contntInfo,'delimiter', '', 'newline', 'pc');
dlmwrite('auxInfoAbout.txt', contntInfo, 'delimiter', '', 'newline', 'pc');

% Prüfen ob LogFile bereits existiert
if (exist('auxInfoAbout.txt','file') > 0);
  % Logdatei durch Systemprogramm öffnen lassen
  %winopen('auxLogFile.txt'); <- Nur in MATLAB möglich
  %= = = = = = = = = =
  % Open an external file with an external program
  open('auxInfoAbout.txt');
  %= = = = = = = = = =
else
  % do nothing
endif

% Zurück in aktuelles Verzeichnis wechseln
cd(currntdir);
%------------------
endfunction


%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Funktion: Erstellung und Ausgabe des Logfiles
%= = = = = = = = = = = = = = = = = = = = = = = = = = = =

function showLogfile(pathname, currntdir, dirNme)
% Funktion zum anzeigen des LogFiles

% Aktuelles Verzeichnis speichern

% Ordnernamen angeben
%dirpath = 'auxData2LaTeXtabular';
if dirNme(end) ~= '/', dirNme = [dirNme '/'];
else
end;

% Arbeitsverzeichnis öffnen
cd(pathname);

% Prüfen ob der Hilfsordner bereits existiert
if (exist(dirNme, 'dir') > 0);
    % Pfad zum Hilfsverzeichnis aufbauen
    auxdirpath = sprintf('%s%s', pathname, dirNme);%
    % Hilfsverzeichnis der Logdatei öffnen
    cd(auxdirpath);
    % Prüfen ob LogFile bereits existiert
    if (exist('auxLogFile.txt','file') > 0);
        % Logdatei durch Systemprogramm öffnen lassen
        %winopen('auxLogFile.txt'); <- Nur in MATLAB möglich
        %= = = = = = = = = =
        % Open an external file with an external program
        open('auxLogFile.txt');
        %= = = = = = = = = =
    end%file
end%dirpath

% Zurück in aktuelles Verzeichnis wechseln
cd(currntdir);

% Mitschreiben des diary beenden
diary off;

% Aktuelles Fenster schliessen
figure(2); close (gcf);

endfunction
%..............................................................


%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Funktion: Meldung zur Demoversion/Testversion
%= = = = = = = = = = = = = = = = = = = = = = = = = = = =
function msgDemo

%   Information an Nutzer
% Informationstext
sprnt1 = ('Nicht im Umfang der Testversion enthalten!');
mb1 = msgbox(sprnt1, 'Demoversion', "warn");
%
clear sprnt1 mb1;

endfunction
%..............................................................


