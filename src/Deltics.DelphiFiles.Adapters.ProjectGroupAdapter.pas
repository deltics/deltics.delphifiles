
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles.Adapters.ProjectGroupAdapter;


interface

  uses
    Deltics.InterfacedObjects,
    Deltics.StringLists,
    Deltics.Xml,
    Deltics.DelphiFiles.Adapters,
    Deltics.DelphiFiles.Adapters.FileAdapter,
    Deltics.DelphiFiles.Interfaces,
    Deltics.DelphiFiles.ProjectGroup;


  type
    TProjectGroupAdapter = class(TFileAdapter, IProjectGroupAdapter)
    protected // IProjectGroupAdapter
      function get_ProjectGroup: IProjectGroup;

      function GetProjectFilenames(var aFilenames: IStringList): Boolean;
      function GetProjectSourceFilenames(var aFilenames: IStringList): Boolean;

    private
      function ConvertToAbsolute(const aFilenames: IStringList): Boolean;
    protected
      procedure DoGetProjectFilenames(const aList: IStringList); virtual; abstract;
      procedure DoGetProjectSourceFilenames(const aList: IStringList); virtual; abstract;
      procedure DoInit(const aProjectGroup: TProjectGroup); virtual;
    end;


    TStringListProjectGroupAdapter = class(TProjectGroupAdapter)
    private
      fSettings: IStringlist;
    protected
      procedure DoClose; override;
      procedure DoOpen; override;
      property Settings: IStringList read fSettings;
    end;


    TXmlProjectGroupAdapter = class(TProjectGroupAdapter)
    private
      fSettings: IXmlDocument;
    protected
      procedure DoClose; override;
      procedure DoOpen; override;
      property Settings: IXmlDocument read fSettings;
    end;



implementation

  uses
    Deltics.IO.Path;



{ TProjectGroupAdapter }

  function TProjectGroupAdapter.get_ProjectGroup: IProjectGroup;
  var
    group: TProjectGroup;
  begin
    group := TProjectGroup.Create(self);

    DoInit(group);

    result := group;
  end;


  function TProjectGroupAdapter.ConvertToAbsolute(const aFilenames: IStringList): Boolean;
  var
    i: Integer;
    basePath: String;
  begin
    result := Assigned(aFilenames ) and (aFilenames.Count > 0);
    if NOT result then
      EXIT;

    basePath := Path.Branch(Filename);
    for i := 0 to Pred(aFilenames.Count) do
      aFilenames[i] := Path.Absolute(aFilenames[i], basePath);
  end;


  procedure TProjectGroupAdapter.DoInit(const aProjectGroup: TProjectGroup);
  begin
    // NO-OP
  end;


  function TProjectGroupAdapter.GetProjectFilenames(var aFilenames: IStringList): Boolean;
  begin
    if NOT Assigned(aFilenames) then
      aFilenames := TStringList.CreateManaged;

    OpenFile;
    try
      DoGetProjectFilenames(aFilenames);

      result := ConvertToAbsolute(aFilenames);

    finally
      CloseFile;
    end;
  end;


  function TProjectGroupAdapter.GetProjectSourceFilenames(var aFilenames: IStringList): Boolean;
  begin
    if NOT Assigned(aFilenames) then
      aFilenames := TStringList.CreateManaged;

    OpenFile;
    try
      DoGetProjectSourceFilenames(aFilenames);

      result := ConvertToAbsolute(aFilenames);

    finally
      CloseFile;
    end;
  end;






{ TXmlProjectGroupAdapter }

  procedure TXmlProjectGroupAdapter.DoClose;
  begin
    fSettings := NIL;
  end;


  procedure TXmlProjectGroupAdapter.DoOpen;
  begin
    Xml.Load(fSettings).FromFile(Filename);
  end;



{ TStringListProjectGroupAdapter }

  procedure TStringListProjectGroupAdapter.DoClose;
  begin
    fSettings := NIL;
  end;


  procedure TStringListProjectGroupAdapter.DoOpen;
  begin
    fSettings := TStringList.CreateManaged;
    fSettings.LoadFromFile(Filename);
  end;




end.
