
  unit Deltics.DelphiFiles.Adapters.DOF;

interface

  uses
    IniFiles,
    SysUtils,
    Deltics.InterfacedObjects,
    Deltics.StringLists,
    Deltics.Xml,
    Deltics.DelphiFiles.Adapters,
    Deltics.DelphiFiles.Interfaces;


  type
    DOF = class(TComInterfacedObject, IProjectFileAdapter)
    private
      fFilename: String;
      function get_Project: IProject;
      function GetSearchPath(const aBuild: String = ''; const aPlatform: String = ''): String;
      procedure SetSearchPath(const aPath: String; const aBuild: String = ''; const aPlatform: String = '');
    private
      fOpenCount: Integer;
      fContent: TStringList;
      function ReadSetting(const aSection, aSetting: String): String;
      procedure WriteSetting(const aSection, aSetting, aValue: String);
      procedure CloseProject(const aSaveChanges: Boolean = FALSE);
      procedure OpenProject;
//      procedure SaveProject;
    public
      constructor Create(const aFilename: String);
      property Filename: String read fFilename;
    end;


implementation

  uses
    Deltics.Strings,
    Deltics.DelphiFiles.Project;


  constructor DOF.Create(const aFilename: String);
  begin
    inherited Create;

    fFilename := aFilename;
  end;


  function DOF.get_Project: IProject;
  var
    project: TProject;
  begin
    project := TProject.Create;
    project.Adapter   := self;
    project.Filename  := Filename;

    result  := project;
  end;


  procedure DOF.OpenProject;
  begin
    Inc(fOpenCount);

    fContent  := TStringList.Create;
    fContent.LoadFromFile(Filename);
  end;


  function DOF.ReadSetting(const aSection, aSetting: String): String;
  var
    i: Integer;
    entry: String;
    inSection: Boolean;
    key: String;
    value: String;
  begin
    result := '';
    inSection := FALSE;

    for i := 0 to Pred(fContent.Count) do
    begin
      entry := fContent[i];

      if entry.BeginsWith('[') then
      begin
        if inSection then
          EXIT;

        inSection := entry.EqualsText('[' + aSection + ']');
        CONTINUE;
      end;

      if NOT inSection then
        CONTINUE;

      if entry.BeginsWithText(aSetting + '=') then
      begin
        entry.Split('=', key, value);
        result := value;
        EXIT;
      end;
    end;
  end;


  function DOF.GetSearchPath(const aBuild: String;
                             const aPlatform: String): String;
  begin
    result := '';
    if NOT aPlatform.EqualsText('win32') then
      EXIT;

    OpenProject;
    try
      result := ReadSetting('Directories', 'SearchPath');

    finally
      CloseProject;
    end;
  end;



//  procedure DPROJ.SaveProject;
//  begin
//    // TODO: Make backup of existing project file
//
//    fXml.SaveToFile(Filename);
//  end;



  procedure DOF.SetSearchPath(const aPath: String;
                              const aBuild: String;
                              const aPlatform: String);
  begin
    if NOT aPlatform.IsEmpty then
      EXIT;

    OpenProject;
    try
      WriteSetting('Directories', 'SearchPath', aPath);

    finally
      CloseProject(TRUE);
    end;
  end;



  procedure DOF.WriteSetting(const aSection, aSetting, aValue: String);
  var
    i: Integer;
    entry: String;
    inSection: Boolean;
    key: String;
    value: String;
  begin
    inSection := FALSE;

    for i := 0 to Pred(fContent.Count) do
    begin
      entry := fContent[i];

      if entry.BeginsWith('[') then
      begin
        if inSection then
          EXIT;

        inSection := entry.EqualsText('[' + aSection + ']');
        CONTINUE;
      end;

      if NOT inSection then
        CONTINUE;

      if entry.BeginsWithText(aSetting + '=') then
      begin
        entry.Split('=', key, value);
        fContent[i] := key + '=' + aValue;
        EXIT;
      end;
    end;
  end;


  procedure DOF.CloseProject(const aSaveChanges: Boolean);
  begin
    Dec(fOpenCount);

    if aSaveChanges then
      fContent.SaveToFile(Filename);

    if fOpenCount = 0 then
      FreeAndNIL(fContent);
  end;





end.
