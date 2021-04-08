
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles.Adapters.DOF;


interface

  uses
    Deltics.StringLists,
    Deltics.DelphiFiles.Adapters,
    Deltics.DelphiFiles.Adapters.ProjectAdapter,
    Deltics.DelphiFiles.Interfaces,
    Deltics.DelphiFiles.Project;


  type
    DOF = class(TProjectAdapter)
    protected
      function DoGetSearchPath(const aPlatform: String; const aBuild: String): String; override;
      procedure DoSetSearchPath(const aPlatform: String; const aBuild: String; const aValue: String); override;
    private
      fContent: IStringList;
      function ReadSetting(const aSection, aSetting: String): String;
      procedure WriteSetting(const aSection, aSetting, aValue: String);
    protected
      procedure DoClose; override;
      procedure DoInit(const aProject: TProject); override;
      procedure DoOpen; override;
      procedure DoSave; override;
    end;


implementation

  uses
    Deltics.Strings;


  procedure DOF.DoInit(const aProject: TProject);
  begin
    inherited;

  end;


  procedure DOF.DoOpen;
  begin
    fContent := TStringList.CreateManaged;
    fContent.LoadFromFile(Filename);
  end;


  procedure DOF.DoSave;
  begin
    fContent.SaveToFile(Filename);
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

      if Str.BeginsWith(entry, '[') then
      begin
        if inSection then
          EXIT;

        inSection := Str.SameText(entry, '[' + aSection + ']');
        CONTINUE;
      end;

      if NOT inSection then
        CONTINUE;

      if Str.BeginsWithText(entry, aSetting + '=') then
      begin
        Str.Split(entry, '=', key, value);
        result := value;
        EXIT;
      end;
    end;
  end;


  function DOF.DoGetSearchPath(const aPlatform: String;
                               const aBuild: String): String;
  begin
    result := '';
    if NOT Str.SameText(aPlatform, 'win32') then
      EXIT;

    OpenFile;
    try
      result := ReadSetting('Directories', 'SearchPath');

    finally
      CloseFile;
    end;
  end;



  procedure DOF.DoSetSearchPath(const aPlatform: String;
                                const aBuild: String;
                                const aValue: String);
  begin
    if (aPlatform <> '') and NOT Str.SameText(aPlatform, 'win32') then
      EXIT;

    OpenFile;
    try
      WriteSetting('Directories', 'SearchPath', aValue);

    finally
      CloseFile;
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

      if Str.BeginsWith(entry, '[') then
      begin
        if inSection then
          EXIT;

        inSection := Str.SameText(entry, '[' + aSection + ']');
        CONTINUE;
      end;

      if NOT inSection then
        CONTINUE;

      if Str.BeginsWithText(entry, aSetting + '=') then
      begin
        Str.Split(entry, '=', key, value);
        fContent[i] := key + '=' + aValue;

        HasChanges := value <> aValue;

        EXIT;
      end;
    end;
  end;


  procedure DOF.DoClose;
  begin
    fContent := NIL;
  end;





end.
