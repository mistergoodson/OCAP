library ocap;

{
  Copyright (C) 2016 Jörg Eitemuller (aka destotelhorus) (destotelhorus@googlemail.com)

  Heavily based on Jamie Goodson''s C# implementation located at
  https://github.com/mistergoodson/OCAP/blob/master/extension/OCAPExporter/OCAPExporter/Class1.cs

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
}

{$mode objfpc}{$H+}

uses
  Classes,
  SysUtils,
  strutils, fphttpclient;

const
  C_LOGFILENAME = 'ocap.log';

procedure AppendToFile(filename : String; outputText : String);
var
  outputFile : TextFile;
begin
  AssignFile(outputFile, filename);
  try
    if not FileExists(filename) then
      Rewrite(outputFile)
    else
      Append(outputFile);
    write(outputFile, outputText);
  finally
    try
      CloseFile(outputFile);
    finally
    end;
  end;
end;

function GetFileContents(filename : String) : String;
var
  fileLines : TStringList;
begin
  fileLines := TStringList.Create;
  try
    fileLines.LoadFromFile(filename);
    result := fileLines.Text;
  finally
    fileLines.Free;
  end;
end;

procedure Log(logline : String);
begin
  AppendToFile( C_LOGFILENAME, FormatDateTime('YYYY-MM-YY hh:nn:ss', Now) + logline + Chr(13));
end;

{Return value is not used.}
procedure RVExtension(output: PAnsiChar; outputSize: Integer; input: PAnsiChar); stdcall; export;
var
  inputString: String;
  bracketStart, bracketEnd : Integer;
  remainingInput : String;
  arguments : TStrings;
  option : String;
  captureFilename, captureFilepath : String;
  tempDir : String;
  worldName, missionName, missionDuration, ocapURL : String;
  targetFilepath : String;
  PostVars: TStrings;
begin
  tempDir := IncludeTrailingPathDelimiter(GetTempDir(True));
  inputString := input;
  bracketStart := Pos('{',inputString);
  bracketEnd := Pos('}',inputString);
  remainingInput := inputString[(bracketEnd+1)..Length(inputString)];
  inputString := inputString[(bracketStart+1)..(bracketEnd-1)];

  arguments := TStringList.Create;
  try
    ExtractStrings([';'], [], PChar(inputString), arguments);

    option := arguments[0];
    captureFilename := arguments[1];
    captureFilepath := tempDir + arguments[1];

    if option = 'write' then
       AppendToFile(captureFilepath, remainingInput)
    else
    begin
      worldName := arguments[2];
      missionName := arguments[3];
      missionDuration := arguments[4];
      ocapURL := arguments[5];
      if not AnsiStartsText('http://', ocapURL) then ocapURL := 'http://' + ocapURL;
      if not AnsiEndsStr('/', ocapURL) then ocapURL := ocapURL + '/';

      if option = 'transferLocal' then
      begin
        targetFilepath := IncludeTrailingPathDelimiter(arguments[6]) + 'data/' + captureFilename;
        try
          RenameFile(captureFilepath, targetFilepath);
        finally
        end;
      end else if option = 'transferRemote' then
      begin
        With TFPHTTPClient.Create(Nil) do
        begin
          PostVars:=TstringList.Create;
          try
            PostVars.Add('option=addFile');
            PostVars.Add('fileName=' + captureFilename);
            PostVars.Add('fileContents=' + GetFileContents(captureFilepath));
            PostVars.Add('dummy=nothing');

            FormPost(ocapURL, PostVars);
          finally
            PostVars.Free;
          end;
        end;
      end;

      With TFPHTTPClient.Create(Nil) do
        begin
          PostVars:=TstringList.Create;
          try
            PostVars.Add('option=dbInsert');
            PostVars.Add('worldName='+worldName);
            PostVars.Add('missionName='+missionName);
            PostVars.Add('missionDuration='+missionDuration);
            PostVars.Add('fileName=' + captureFilename);

            FormPost(ocapURL, PostVars);
          finally
            PostVars.Free;
          end;
        end;
    end;
    output := 'Success';
  finally
    arguments.Free;
  end;
end;

exports
  RVExtension name '_RVExtension@12';

begin
end.
