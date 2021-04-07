
  unit Deltics.DelphiFiles.Adapters;

interface

  uses
    Deltics.DelphiFiles.Interfaces;


  type
    IProjectFileAdapter = interface
    ['{B4D7EFDF-3BFF-45AC-889E-79C2140DBF26}']
      function get_Project: IProject;
      function GetSearchPath(const aBuild: String = ''; const aPlatform: String = ''): String;
      procedure SetSearchPath(const aPath: String; const aBuild: String = ''; const aPlatform: String = '');
      property Project: IProject read get_Project;
    end;


  function ProjectAdapter(const aFilename: String): IProjectFileAdapter;



implementation

  uses
    SysUtils,
    Deltics.DelphiFiles.Adapters.DOF,
    Deltics.DelphiFiles.Adapters.DPROJ;


  function ProjectAdapter(const aFilename: String): IProjectFileAdapter;
  var
    ext: String;
    filename: String;
  begin
    result    := NIL;
    filename  := aFilename;

    ext := ExtractFileExt(filename).ToLower;
    if (ext = '.dpr') then
    begin
      if FileExists(ChangeFileExt(filename, '.dproj')) then
        filename := ChangeFileExt(filename, '.dproj')
      else if FileExists(ChangeFileExt(filename, '.bdsproj')) then
        filename := ChangeFileExt(filename, '.bdsproj')
      else if FileExists(ChangeFileExt(filename, '.dof')) then
        filename := ChangeFileExt(filename, '.dof');
    end;

    ext := ExtractFileExt(filename).ToLower;

    if ext = '.dproj' then
      result := DPROJ.Create(filename)
    else if ext = '.dof' then
      result := DOF.Create(filename);
  end;



  end.
