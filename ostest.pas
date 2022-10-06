unit OStest;

{$mode objfpc}{$H+}

interface
function OSVersion: Str255;
uses
                  Classes, SysUtils;

implementation

function OSVersion: Str255;
 var
  osErr: integer;
  response: longint;
begin
  {$IFDEF LCLcarbon}
  OSVersion := 'Mac OSX';
  {$ELSE}
  {$IFDEF Linux}
  OSVersion := 'Linux';
  {$ELSE}
  {$IFDEF UNIX}
  OSVersion := 'Unix';
  {$ELSE}
  {$IFDEF WINDOWS}
  OSVersion:= 'Windows';
  {$ENDIF}
  {$ENDIF}
  {$ENDIF}
  {$ENDIF}
end;



end.

