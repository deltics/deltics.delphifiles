
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles.Adapters.ProjectAdapter;


interface

  uses
    Deltics.InterfacedObjects,
    Deltics.DelphiFiles.Adapters,
    Deltics.DelphiFiles.Adapters.FileAdapter,
    Deltics.DelphiFiles.Interfaces,
    Deltics.DelphiFiles.Project;


  type
    TProjectAdapter = class(TFileAdapter, IProjectAdapter)
    protected // IProjectAdapter
      function get_Project: IProject;
      function get_SearchPath(const aPlatform: String; const aBuild: String): String;
      procedure set_SearchPath(const aPlatform: String; const aBuild: String; const aValue: String);

    protected
      function DoGetSearchPath(const aPlatform: String; const aBuild: String): String; virtual; abstract;
      procedure DoSetSearchPath(const aPlatform: String; const aBuild: String; const aValue: String); virtual; abstract;
      procedure DoInit(const aProject: TProject); virtual;
    end;


implementation



{ TProjectAdapter }

  function TProjectAdapter.get_SearchPath(const aPlatform, aBuild: String): String;
  begin
    result := DoGetSearchPath(aPlatform, aBuild);
  end;


  procedure TProjectAdapter.set_SearchPath(const aPlatform, aBuild, aValue: String);
  begin
    DoSetSearchPath(aPlatform, aBuild, aValue);
  end;


  procedure TProjectAdapter.DoInit(const aProject: TProject);
  begin
    // NO-OP
  end;


  function TProjectAdapter.get_Project: IProject;
  var
    project: TProject;
  begin
    project := TProject.Create(self);

    DoInit(project);

    result := project;
  end;


end.

