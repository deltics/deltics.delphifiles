
  unit Deltics.Delphi.ProjectFiles.DOF;

interface

  uses
    IniFiles,
    Deltics.Strings,
    Deltics.Delphi.Versions,
    Deltics.Delphi.ProjectSettings;


  type
    TDOFFiler = class
    public
      class function LoadFromFile(const aFilename: String): TProjectSettings;
      class procedure SaveToFile(const aProject: TProjectSettings; const aFilename: String);
    end;




implementation

  uses
    SysUtils;


{ TDOFFiler }

  class function TDOFFiler.LoadFromFile(const aFilename: String): TProjectSettings;
  var
    ini: TINIFile;

    procedure ReadValue(const aIdent: String; const aDefault: String = '');
    var
      sectionName: String;
      valueName: String;
      settings: TProjectSettingList;
    begin
      STR.Split(aIdent, '.', sectionName, valueName);

      if STR.SameText(sectionName, 'compiler') then
        settings := result.CompilerSettings
      else
        raise Exception.CreateFmt('Unknown project settings section name ''%s''', [sectionName]);

      settings.ItemByName[valueName].Value := ini.ReadString(sectionName, valueName, aDefault);
    end;

  begin
    ini := TINIFile.Create(aFilename);
    try
      if ini.ReadString('FileVersion', 'Version', '') <> '7.0' then
        raise ENotSupportedException.Create('Only DOF files for Delphi 7 are supported');


    finally
      ini.Free;
    end;
  end;



//  class function TDOFFiler.ReadCompilerSettings(const aIni: TIniFile): IDelphi7CompilerSettings;
//  begin
//    result := TCompilerSettings.
//  end;






  class procedure TDOFFiler.SaveToFile(const aProject: TProjectSettings; const aFilename: String);
  begin

  end;

end.
