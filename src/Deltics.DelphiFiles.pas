
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles;


interface

  uses
    Deltics.DelphiFiles.Interfaces;


  type
    IBuildConfig  = Deltics.DelphiFiles.Interfaces.IBuildConfig;
    IProject      = Deltics.DelphiFiles.Interfaces.IProject;



    Project = class
      class function LoadFromFile(const aFilename: String): IProject;
    end;


    ProjectGroup = class
      class function LoadFromFile(const aFilename: String): IProjectGroup;
    end;




implementation

  uses
    Deltics.DelphiFiles.Adapters,
    Deltics.DelphiFiles.Project;



{ Project }

  class function Project.LoadFromFile(const aFilename: String): IProject;
  var
    adapter: IProjectAdapter;
  begin
    if FileAdapter(aFilename, adapter) then
      result := adapter.Project;
  end;



{ ProjectGroup }

  class function ProjectGroup.LoadFromFile(const aFilename: String): IProjectGroup;
  var
    adapter: IProjectGroupAdapter;
  begin
    if FileAdapter(aFilename, adapter) then
      result := adapter.ProjectGroup;
  end;



end.
