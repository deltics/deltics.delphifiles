
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles.Adapters;

interface

  uses
    Deltics.StringLists,
    Deltics.DelphiFiles.Interfaces;


  type
    IFileAdapter = interface
    ['{2B22F644-5CF7-4660-9E97-EF2768E9EF24}']
      function get_Filename: String;

      property Filename: String read get_Filename;
    end;


    IProjectAdapter = interface(IFileAdapter)
    ['{B4D7EFDF-3BFF-45AC-889E-79C2140DBF26}']
      function get_Project: IProject;
      function get_SearchPath(const aPlatform: String; const aBuild: String): String;
      procedure set_SearchPath(const aPlatform: String; const aBuild: String; const aValue: String);

      property Project: IProject read get_Project;
      property SearchPath[const aPlatform: String; const aBuild: String]: String read get_SearchPath write set_SearchPath;
    end;


    IProjectGroupAdapter = interface
    ['{D3E06A0B-C46C-4E5A-84AC-4F742F15D977}']
      function get_ProjectGroup: IProjectGroup;

      function GetProjectFilenames(var aFilenames: IStringList): Boolean;
      function GetProjectSourceFilenames(var aFilenames: IStringList): Boolean;

      property ProjectGroup: IProjectGroup read get_ProjectGroup;
    end;



  function FileAdapter(const aFilename: String; var aAdapter: IProjectAdapter): Boolean; overload;
  function FileAdapter(const aFilename: String; var aAdapter: IProjectGroupAdapter): Boolean; overload;



implementation

  uses
    SysUtils,
    Deltics.Strings,
    Deltics.DelphiFiles.Adapters.BDSGROUP,
    Deltics.DelphiFiles.Adapters.BPG,
    Deltics.DelphiFiles.Adapters.DOF,
    Deltics.DelphiFiles.Adapters.DPROJ,
    Deltics.DelphiFiles.Adapters.GROUPPROJ;


  function FileAdapter(const aFilename: String;
                       var   aAdapter: IProjectAdapter): Boolean;
  var
    ext: String;
    filename: String;
  begin
    aAdapter  := NIL;
    filename  := aFilename;

    ext := Str.Lowercase(ExtractFileExt(filename));
    if (ext = '.dpr') then
    begin
      if FileExists(ChangeFileExt(filename, '.dproj')) then
        filename := ChangeFileExt(filename, '.dproj')
      else if FileExists(ChangeFileExt(filename, '.bdsproj')) then
        filename := ChangeFileExt(filename, '.bdsproj')
      else if FileExists(ChangeFileExt(filename, '.dof')) then
        filename := ChangeFileExt(filename, '.dof');

      ext := Str.Lowercase(ExtractFileExt(filename));
    end;

    if ext = '.dproj' then
      aAdapter := DPROJ.Create(filename)
    else if ext = '.dof' then
      aAdapter := DOF.Create(filename);

    result := Assigned(aAdapter);
  end;



  function FileAdapter(const aFilename: String;
                       var   aAdapter: IProjectGroupAdapter): Boolean;
  var
    ext: String;
    filename: String;
  begin
    aAdapter  := NIL;
    filename  := aFilename;

    ext := Str.Lowercase(ExtractFileExt(filename));
    if (ext = '.bpg') then
      aAdapter := BPG.Create(aFilename)
    else if (ext = '.bdsgroup') then
      aAdapter := BDSGROUP.Create(aFilename)
    else if (ext = '.groupproj') then
      aAdapter := GROUPPROJ.Create(aFilename);

    result := Assigned(aAdapter);
  end;








end.
