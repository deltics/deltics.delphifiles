
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles.Interfaces;


interface

  uses
    Deltics.StringTypes;


  type
    IBuildConfig  = interface;
    IProject      = interface;


    TBuildConfigArray = array of IBuildConfig;


    IBuildConfig = interface
    ['{C48D9488-0308-4EB2-8CAA-85AA014E7DD7}']
      function get_Key: String;
      function get_Name: String;
      function get_ParentKey: String;
      property Key: String read get_Key;
      property Name: String read get_Name;
      property ParentKey: String read get_ParentKey;
    end;


    IProject = interface
    ['{C47473EF-38CF-47D8-87CA-E5C14FA9506D}']
      function get_BuildConfigs: TBuildConfigArray;
      function get_Filename: String;
      function get_Platforms: StringArray;
      function get_SearchPath(const aBuild: String; const aPlatform: String): String;
      procedure set_SearchPath(const aBuild: String; const aPlatform: String; const aValue: String);
      property BuildConfigs: TBuildConfigArray read get_BuildConfigs;
      property Filename: String read get_Filename;
      property Platforms: StringArray read get_Platforms;
      property SearchPath[const aBuild: String; const aPlatform: String]: String read get_SearchPath write set_SearchPath;
    end;



implementation

end.
