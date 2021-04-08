
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles.ProjectGroup;

interface

  uses
    Deltics.InterfacedObjects,
    Deltics.StringLists,
    Deltics.DelphiFiles.Adapters,
    Deltics.DelphiFiles.Interfaces;


  type
    // *.bpg        : Delphi 7 and earlier
    // *.bdsgroup   : Delphi 2006 / 2007
    // *.groupproj  : Delphi 2009 onward


    TProjectGroup = class(TComInterfacedObject, IProjectGroup)
    protected // IProjectGroup
      function GetProjectFilenames(var aFilenames: IStringList): Boolean;
      function GetProjectSourceFilenames(var aFilenames: IStringList): Boolean;

    private
      fAdapter: IProjectGroupAdapter;
    public
      constructor Create(const aAdapter: IProjectGroupAdapter);
    end;



implementation



{ ------------------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TProjectGroup.Create(const aAdapter: IProjectGroupAdapter);
  begin
    inherited Create;

    fAdapter := aAdapter;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TProjectGroup.GetProjectFilenames(var aFilenames: IStringList): Boolean;
  begin
    result := fAdapter.GetProjectFilenames(aFilenames);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TProjectGroup.GetProjectSourceFilenames(var aFilenames: IStringList): Boolean;
  begin
    result := fAdapter.GetProjectSourceFilenames(aFilenames);
  end;




end.
