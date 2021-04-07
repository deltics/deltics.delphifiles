
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




implementation

  uses
    Deltics.DelphiFiles.Adapters,
    Deltics.DelphiFiles.Project;



{ Project }

  class function Project.LoadFromFile(const aFilename: String): IProject;
  var
    adapter: IProjectFileAdapter;
  begin
    result  := NIL;
    adapter := ProjectAdapter(aFilename);

    if Assigned(adapter) then
      result := adapter.Project;
  end;



end.
