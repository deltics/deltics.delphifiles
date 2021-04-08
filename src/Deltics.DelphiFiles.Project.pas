
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles.Project;

interface

  uses
    Deltics.InterfacedObjects,
    Deltics.StringTypes,
    Deltics.DelphiFiles.Adapters,
    Deltics.DelphiFiles.Interfaces;


  type
    TProject = class(TComInterfacedObject, IProject)
    protected // IProject
      function get_BuildConfigs: TBuildConfigArray;
      function get_Filename: String;
      function get_Platforms: StringArray;
      function get_SearchPath(const aBuild: String; const aPlatform: String): String;
      procedure set_SearchPath(const aBuild: String; const aPlatform: String; const aValue: String);
//      procedure AddSearchPath(const aPath: String; const aBuild, aPlatform: String);

    private
      fAdapter: IProjectAdapter;
      fBuildConfigs: TBuildConfigArray;
      fPlatforms: StringArray;
    public
      constructor Create(const aAdapter: IProjectAdapter);
      procedure AddBuildConfig(const aKey, aName, aParentKey: String);
      procedure AddPlatform(const aValue: String);
      property Adapter: IProjectAdapter read fAdapter write fAdapter;
      property BuildConfigs: TBuildConfigArray read fBuildConfigs;
      property Filename: String read get_Filename;
      property Platforms: StringArray read fPlatforms;
    end;




implementation

  uses
    Deltics.DelphiFiles.Project.BuildConfig;



  procedure TProject.AddBuildConfig(const aKey, aName, aParentKey: String);
  var
    config: IBuildConfig;
  begin
    config := TBuildConfig.Create(aKey, aName, aParentKey);

    SetLength(fBuildConfigs, Length(fBuildConfigs) + 1);
    fBuildConfigs[High(fBuildConfigs)] := config;
  end;


  procedure TProject.AddPlatform(const aValue: String);
  begin
    SetLength(fPlatforms, Length(fPlatforms) + 1);
    fPlatforms[High(fPlatforms)] := aValue;
  end;


  constructor TProject.Create(const aAdapter: IProjectAdapter);
  begin
    inherited Create;

    fAdapter := aAdapter;
  end;



//  procedure TProject.AddSearchPath(const aPath: String;
//                                   const aBuild: String;
//                                   const aPlatform: String);
//  var
//    i: Integer;
//    buildKey: String;
//    config: IBuildConfig;
//  begin
//    buildKey := '';
//    for i := 0 to High(fBuildConfigs) do
//      if STR.SameText(fBuildConfigs[i].Name, aBuild) then
//        buildKey := fBuildConfigs[i].Key;
//
//    if (aBuild <> '') and (Length(fBuildConfigs) > 0) and (buildKey = '') then
//      raise Exception.CreateFmt('''%s'' is not a valid build configuration', [aBuild]);
//
//    Adapter.SetSearchPath(aPath, buildKey, aPlatform);
//  end;


  function TProject.get_BuildConfigs: TBuildConfigArray;
  begin
    result := fBuildConfigs;
  end;


  function TProject.get_Filename: String;
  begin
    result := fAdapter.Filename;
  end;


  function TProject.get_Platforms: StringArray;
  begin
    result := fPlatforms;
  end;


  function TProject.get_SearchPath(const aBuild, aPlatform: String): String;
  begin
    result := Adapter.SearchPath[aPlatform, aBuild];
  end;


  procedure TProject.set_SearchPath(const aBuild, aPlatform, aValue: String);
  begin
    Adapter.SearchPath[aPlatform, aBuild] := aValue;
  end;








end.
