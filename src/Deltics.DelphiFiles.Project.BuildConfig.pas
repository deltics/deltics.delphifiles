
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles.Project.BuildConfig;


interface

  uses
    Deltics.InterfacedObjects,
    Deltics.DelphiFiles.Interfaces;


  type
    TBuildConfig = class(TComInterfacedObject, IBuildConfig)
    private
      fKey: String;
      fName: String;
      fParentKey: String;
      function get_Key: String;
      function get_Name: String;
      function get_ParentKey: String;
//      property Key: String read fKey;
//      property Name: String read fName;
//      property ParentKey: String read fParentKey;
    public
      constructor Create(const aKey, aName, aParentKey: String);
    end;


implementation

{ TBuildConfig }

  constructor TBuildConfig.Create(const aKey, aName, aParentKey: String);
  begin
    inherited Create;

    fKey        := aKey;
    fName       := aName;
    fParentKey  := aParentKey;
  end;


  function TBuildConfig.get_Key: String;
  begin
    result := fKey;
  end;

  function TBuildConfig.get_Name: String;
  begin
    result := fName;
  end;

  function TBuildConfig.get_ParentKey: String;
  begin
    result := fParentKey;
  end;



end.
