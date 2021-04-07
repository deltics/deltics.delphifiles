
  unit Deltics.Delphi.CompilerSettings;

interface

  type
    ICompilerSettings = interface
    public
      // -D
      property ConditionalDefines: String read get_ConditionalDefines write set_ConditionalDefines;
      // -LN
      property DcpOutputPath: String read get_DcpOutputPath write set_DcpOutputPath;
      // -E
      property OutputPath: String read get_OutputPath write set_OutputPath;
      // -LE
      property PackageOutputPath: String read get_PackageOutputPath write set_PackageOutputPath;
      // -U
      property SearchPath: String read get_SearchPath write set_SearchPath;
      // -A
      property UnitAliases: String read get_UnitAliases write set_UnitAliases;
      // -NU
      property UnitOutputPath: String read get_UnitOutputPath write set_UnitOutputPath;

      // Version ?

      // -NS
      property UnitScopeNames: String read get_UnitScopeNames write set_UnitScopeNames;


      // --frameworkpath
      property FrameworkSearchPath: String read get_FrameworkSearchPath write set_FrameworkSearchPath;
      // --syslibroot
      property SystemLibraryRootPath: String read get_SystemLibraryRootPath write set_SystemLibraryRootPath;
    end;


implementation

end.
