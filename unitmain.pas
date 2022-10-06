unit unitmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Grids, StrUtils, LazFileUtils, unitdebug, Process, Types;

type

  { TFormMain }

  TFormMain = class(TForm)
  ButtonConsole: TButton;
    ButtonAddShow: TButton;
    ButtonRemoveShow: TButton;
    ButtonSaveShowList: TButton;
    ButtonLoadFiles: TButton;
    ButtonProcess: TButton;
    Image1: TImage;
    OpenDialog1: TOpenDialog;
    PageControl: TPageControl;
    SaveDialog1: TSaveDialog;
    StringGridFiles: TStringGrid;
    StringGridShows: TStringGrid;
    TabFiles: TTabSheet;
    TabShows: TTabSheet;
    TopPanel: TPanel;
    StatusBar: TStatusBar;
    procedure ButtonAddShowClick(Sender: TObject);
    procedure ButtonConsoleClick(Sender: TObject);
    procedure ButtonLoadFilesClick(Sender: TObject);
    procedure ButtonProcessClick(Sender: TObject);
    procedure ButtonSaveShowListClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure StringGridFilesResize(Sender: TObject);
    procedure StringGridShowsResize(Sender: TObject);
    procedure MakeTag(FileName : string; out st, TitleTag, AuthorTag :string);
    procedure GenerateTags;
    procedure Log(msg : string);
    procedure LoadFromCdmline;
    procedure TabFilesContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
  private

  public
    UserFolder : string;
    ShowListFilePath : string;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.Log(msg : string);
begin
   Form1.Memo.Append(msg);

end;

procedure TFormMain.TabFilesContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

procedure TFormMain.GenerateTags;
var i : integer;
    matchStr, FileNameOnly, Title, Author : string;

begin
   for i := 1 to StringGridFiles.RowCount -1 do
       begin
         FilenameOnly := StringGridFiles.Cells[2,i];
         MakeTag(FilenameOnly, MatchStr, Title, Author);

         Log('MatchStr' + MatchStr);
         Log('Title = ' + Title);
         Log('Author = ' + Author);

         if MatchStr = '1' then
           begin
		  StringGridFiles.Cells[1,i] := MatchStr;
		  StringGridFiles.Cells[3,i] := Title;
		  StringGridFiles.Cells[4,i] := Author;
	   end
           else
           begin
		  StringGridFiles.Cells[1,i] := MatchStr;
		  StringGridFiles.Cells[3,i] := 'Nie znaleziono na liście audycji';
		  StringGridFiles.Cells[5,i] := 'Bład';
	   end;
       end;
end;

procedure TFormMain.MakeTag(FileName : string; out st, TitleTag, AuthorTag :string);
var i : integer;
    ShortName : string;
    Date : String;
    Part : string;
    Match : integer;
    Multipart : boolean;

begin
     st := '0';
     Match := -1;
     TitleTag := '';
     AuthorTag := '';
     Multipart := IsWild(Filename,'*_?',True);
     if Multipart = true then
        begin
             // Multipart
             Date := RightStr(Copy2Symb(Filename,'_'),8);
             ShortName := LeftStr(Filename,Length(Filename) - 10);
             Part := RightStr(filename,1);
        end
     else
         begin
              // SinglePart;
              Date := RightStr(Filename,8);
              ShortName := LeftStr(Filename,Length(Filename) - 8);
         end;

     Log('nazwa pliku = ' + Filename);
     Log('shortname = ' + shortname);
     Log('Multipart = ' + BoolToStr(Multipart));
     Log('Data = ' + date);
     Log('Part = ' + part);


     for i := 1 to StringGridShows.RowCount - 1 do
         begin
           if ShortName = StringGridShows.Cells[1,i] then match := i;
         end;

     Log('Match = ' + inttostr(Match));

     if match > 0 then
        begin
             // on match
             TitleTag := StringGridShows.Cells[0,match] + ' [' + Date + ']';
             if Multipart then TitleTag := TitleTag + ' ' + Part;
             AuthorTag := StringGridShows.Cells[2,match];
             St := '1';
        end
     else
        begin
             // on no match
             st := '0';
        end;

     Log('status = ' + st);

end;


procedure TFormMain.StringGridFilesResize(Sender: TObject);
begin

     //StringGridFiles.ColWidths[0]:= (StringGridFiles.Width -150) div 4;
     //StringGridFiles.ColWidths[1]:= 50;
     StringGridFiles.ColWidths[2]:= (StringGridFiles.Width -100) div 3;
     StringGridFiles.ColWidths[3]:= (StringGridFiles.Width -100) div 3;
     StringGridFiles.ColWidths[4]:= (StringGridFiles.Width -100) div 3;
     StringGridFiles.ColWidths[5]:= 99;

end;

procedure TFormMain.ButtonSaveShowListClick(Sender: TObject);
begin
     StringGridShows.SaveToCSVFile(UserFolder + 'showlist.csv',';',false);
end;

procedure TFormMain.FormActivate(Sender: TObject);


begin

end;



procedure TFormMain.FormCreate(Sender: TObject);
begin
     ButtonConsole.Visible := fileexists('debug');
{$IFDEF Linux}
     UserFolder := GetUserDir + '.autotag/';
{$ENDIF}

{$IFDEF WINDOWS}
     //UserFolder := GetAppConfigDir(false);
     UserFolder := GetUserDir + 'autotag2\';
{$ENDIF}


     ShowListFilePath := FormMain.UserFolder + 'showlist.csv';
     If FileExists(ShowListFilePath) then StringGridShows.LoadFromCSVFile(ShowListFilePath,';',false);
     StatusBar.Panels.Items[1].Text:=UserFolder;
     StringGridFilesResize(nil);
     StringGridShowsResize(nil);


end;

procedure TFormMain.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
  var i : integer;
begin

     StringGridFiles.Clear;
     StringGridFiles.RowCount:=1;
     for i := Low(Filenames) to High(FileNames) do
     if isWild(FileNames[i],'*.mp3',true) then
        StringGridFiles.InsertRowWithValues(StringGridFiles.RowCount,[Filenames[i],'','','','',''] );
     for i := 0 to StringGridFiles.RowCount -1 do StringGridFiles.Cells[2,i] := ExtractFileNameOnly(StringGridFiles.Cells[0,i]);
     GenerateTags;
end;


procedure TFormMain.ButtonAddShowClick(Sender: TObject);
begin
     StringGridShows.RowCount:= StringGridShows.RowCount +1;
end;

procedure TFormMain.ButtonConsoleClick(Sender: TObject);
begin
        Form1.Visible:= True;
end;

procedure TFormMain.ButtonLoadFilesClick(Sender: TObject);
var
   i : integer;
begin
     if OpenDialog1.Execute then
        begin
             StringGridFiles.Clear;
             StringGridFiles.RowCount:=1;
             for i := 0 to OpenDialog1.Files.Count -1 do StringGridFiles.InsertRowWithValues(i+1,[OpenDialog1.Files.Strings[i],'','','','',''] );
             for i := 0 to StringGridFiles.RowCount -1 do StringGridFiles.Cells[2,i] := ExtractFileNameOnly(StringGridFiles.Cells[0,i]);
             StatusBar.Panels.Items[1].Text:= 'Załadowano plików: ' + inttostr(StringGridFiles.RowCount);
             for i := 0 to StringGridFiles.RowCount -1 do Log(inttostr(i) + ' = ' + StringGridFiles.Cells[2,i]);
             FormMain.GenerateTags;
     end;
end;

procedure TFormMain.ButtonProcessClick(Sender: TObject);
var
   i : integer;
   cmd, cmdout : string;
   TagArtist, TagTitle, TagAlbum, FilePath :string;

begin
     log('======================================');
     for i:= 1 to StringGridFiles.RowCount -1 do
         begin
           if StringGridFiles.cells[1,i] = '1' then
              begin
                   FilePath := StringGridFiles.Cells[0,i];
                   TagTitle := StringGridFiles.Cells[3,i];
                   TagArtist := StringGridFiles.Cells[4,i];
                   TagAlbum := 'Audycje';

           {$IFDEF Linux}
                   cmd := '-t "' + TagTitle + '" -a "' + TagArtist + '" -A "' + TagAlbum + '" ' + FilePath;
                   cmd := 'id3v2 ' + cmd;
                   if RunCommand(cmd,cmdout) then
                      begin
                           if cmdout = '' then StringGridFiles.Cells[5,i] := 'OK' else StringGridFiles.Cells[5,i] := 'Błąd';
                           Log(cmd);
                           If cmdout = '' then Log('cmdout string empty') else Log(cmdout);

                      end;
           {$ENDIF}


           {$IFDEF WINDOWS}
                   cmd := '-v -d -2 -t "' + TagTitle + '" -a "' + TagArtist + '" -l "' + TagAlbum + '" ' + FilePath;
                   cmd := 'id3 ' + cmd;
                   if RunCommand(cmd,cmdout) then
                      begin
                           if cmdout = '' then StringGridFiles.Cells[5,i] := 'OK' else StringGridFiles.Cells[5,i] := 'Błąd';
                           Log(cmd);
                           If cmdout = '' then Log('cmdout string empty') else Log(cmdout);

                      end;



           {$ENDIF}
	      end;
	 end;


end;

procedure TFormMain.StringGridShowsResize(Sender: TObject);
begin
  StringGridShows.ColWidths[1] := StringGridShows.Width div 4;
  StringGridShows.ColWidths[0] := (StringGridShows.Width - StringGridShows.ColWidths[1]) div 2 - 2;
  StringGridShows.ColWidths[2] := (StringGridShows.Width - StringGridShows.ColWidths[1]) div 2 - 2;

end;
procedure TFormMain.LoadFromCdmline;
var
    n, i : integer;

begin
     if ParamCount > 0 then
        begin
             StringGridFiles.RowCount:=1;
             for n := 1 to ParamCount do if isWild(paramstr(n),'*.mp3',true) then
                 StringGridFiles.InsertRowWithValues(StringGridFiles.RowCount,[ParamStr(n),'','','','',''] );
             for i := 1 to StringGridFiles.RowCount -1 do StringGridFiles.Cells[2,i] := ExtractFileNameOnly(StringGridFiles.Cells[0,i]);
             GenerateTags;
        end;


end;


end.

