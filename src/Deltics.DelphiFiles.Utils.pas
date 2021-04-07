
  unit Deltics.DelphiFiles.Utils;

interface

  uses
    SysUtils,
    Deltics.StringLists;


  type
    DelphiUtils = class
      class function FindProjectSourceFiles(const aPath: String): IStringList;
      class function FindSettingsForProjectFile(const aFilename: String): IStringList;
    end;


implementation

  uses
    Deltics.IO.FileSearch,
    Deltics.Strings,
    Deltics.DelphiFiles.ProjectGroup;


  class function DelphiUtils.FindProjectSourceFiles(const aPath: String): IStringList;
  var
    i: Integer;
    search: IFileSearch;
    files: IStringList;
    filename: String;
  begin
    result := TStringList.CreateManaged;
    result.Unique := TRUE;

    search := FileSearch.Folder(aPath).Yielding.Files(files, TRUE);

    search.Filename('*.dpr').Execute;

    for i := 0 to Pred(files.Count) do
    begin
      filename := files[i].ToLower;
      result.Add(filename)
    end;

    search.Filename('*.bpg;*.bdsgroup;*.groupproj', TRUE).Execute;

    for i := 0 to Pred(files.Count) do
      result.Add(TProjectGroup.GetProjectSourceFilenames(files[i]));
  end;



  class function DelphiUtils.FindSettingsForProjectFile(const aFilename: String): IStringList;

    procedure CheckExtension(const aExtension: String);
    var
      filename: String;
    begin
      filename := ChangeFileExt(aFilename, aExtension);
      if FileExists(filename) then
        result.Add(filename);
    end;

  begin
    result := TStringList.CreateManaged;

    if NOT ExtractFileExt(aFilename).EqualsText('.dpr') then
      raise EArgumentException.CreateFmt('''%s'' is not a valid project filename', [aFilename]);

    CheckExtension('.dproj');
    CheckExtension('.bdsproj');
    CheckExtension('.dof');
    CheckExtension('.cfg');
  end;



end.
