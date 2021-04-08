
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles.Adapters.BPG;


interface

  uses
    Deltics.StringLists,
    Deltics.DelphiFiles.Adapters.ProjectGroupAdapter;


  type
    BPG = class(TStringListProjectGroupAdapter)
    protected
      procedure DoGetProjectFilenames(const aList: IStringList); override;
      procedure DoGetProjectSourceFilenames(const aList: IStringList); override;
    end;



implementation

  uses
    Deltics.Strings;


{ ------------------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure BPG.DoGetProjectFilenames(const aList: IStringList);
  {
    Loads projects files from a BPG file (Delphi 7 and earlier).  BPG files
     contain a line of the form:

        PROJECTS = <Project1> <Project2> <ProjectN>

    Where each project is identified by it's TARGET name (e.g. Project1.exe).
     Later in the file, a line is present for each of the projects in the
     group.  Each such line is of the form:

        <Project1>: <ProjectSource>

    i.e. the TARGET project name corresponding to an entry in the PROJECTS
     line, followed by the path to and name of the DPR source file for that
     project.
  }
  var
    i, j: Integer;
    projectsEntry: String;
    projectNames: StringArray;
    name, filePath: String;
  begin
    projectsEntry := Str.Trim(Settings.Values['PROJECTS ']);

    STR.Split(projectsEntry, ' ', projectNames);

    for i := 0 to High(projectNames) do
    begin
      for j := 0 to Pred(Settings.Count) do
      begin
        if Str.BeginsWith(Settings[j], projectNames[i]) then
        begin
          Str.Split(Settings[j], ':', name, filePath);
          filePath := Str.Trim(filePath);

          aList.Add(filePath);
        end;
      end;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure BPG.DoGetProjectSourceFilenames(const aList: IStringList);
  {
    Loads projects files from a BPG file (Delphi 7 and earlier).  BPG files
     contain a line of the form:

        PROJECTS = <Project1> <Project2> <ProjectN>

    Where each project is identified by it's TARGET name (e.g. Project1.exe).
     Later in the file, a line is present for each of the projects in the
     group.  Each such line is of the form:

        <Project1>: <ProjectSource>

    i.e. the TARGET project name corresponding to an entry in the PROJECTS
     line, followed by the path to and name of the DPR source file for that
     project.
  }
  var
    i, j: Integer;
    projectsEntry: String;
    projectNames: StringArray;
    name, filePath: String;
  begin
    projectsEntry := STR.Trim(Settings.Values['PROJECTS ']);

    STR.Split(projectsEntry, ' ', projectNames);

    for i := 0 to High(projectNames) do
    begin
      for j := 0 to Pred(Settings.Count) do
      begin
        if Str.BeginsWith(Settings[j], projectNames[i]) then
        begin
          STR.Split(Settings[j], ':', name, filePath);
          filePath := STR.Trim(filePath);

          aList.Add(filePath);
        end;
      end;
    end;
  end;






end.
