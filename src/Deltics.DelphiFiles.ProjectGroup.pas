
  unit Deltics.DelphiFiles.ProjectGroup;

interface

  uses
    Deltics.StringLists,
    Deltics.StringTypes;


  type
    TProjectGroupFileFormat =
    (
      ffBorlandProjectGroup,  // *.bpg        : Delphi 7 and earlier
      ffBDSProjectGroup,      // *.bdsgroup   : Delphi 2006 / 2007
      ffDelphiProjectGroup    // *.groupproj  : Delphi 2009 onward
    );



    TProjectGroup = class
    public
      class procedure GetProjectFilenames(const aFilename: String; var aList: StringArray);
      class function GetProjectSourceFilenames(const aFilename: String): IStringList;
    end;



implementation

  uses
    SysUtils,
    Deltics.IO.Path,
    Deltics.Strings,
    Deltics.Xml;


  type
    BPG = class
    public
      class procedure GetProjects(const aFilename: String; var aList: StringArray);
      class function GetProjectSources(const aFilename: String): IStringList;
    end;


    BDSGROUP = class
    public
      class procedure GetProjects(const aXml: IXmlDocument; var aList: StringArray);
      class function GetProjectSources(const aXml: IXmlDocument): IStringList;
    end;


    GROUPPROJ = class
    public
      class procedure GetProjects(const aXml: IXmlDocument; var aList: StringArray);
      class function GetProjectSources(const aXml: IXmlDocument): IStringList;
    end;



{ ------------------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure BPG.GetProjects(const aFilename: String;
                                  var   aList: StringArray);
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
    lines: TStringList;
    projectsEntry: String;
    projectNames: StringArray;
    name, filePath: String;
  begin
    lines := TStringList.Create;
    try
      lines.LoadFromFile(aFilename);

      projectsEntry := Str.Trim(lines.Values['PROJECTS ']);

      STR.Split(projectsEntry, ' ', projectNames);

      for i := 0 to High(projectNames) do
      begin
        for j := 0 to Pred(lines.Count) do
        begin
          if Str.BeginsWith(lines[j], projectNames[i]) then
          begin
            Str.Split(lines[j], ':', name, filePath);
            filePath := Str.Trim(filePath);

            SetLength(aList, Length(aList) + 1);
            aList[High(aList)] := filePath;
          end;
        end;
      end;

    finally
      lines.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function BPG.GetProjectSources(const aFilename: String): IStringList;
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
    lines: TStringList;
    projectsEntry: String;
    projectNames: StringArray;
    name, filePath: String;
  begin
    result := TStringList.CreateManaged;

    lines := TStringList.Create;
    try
      lines.LoadFromFile(aFilename);

      projectsEntry := STR.Trim(lines.Values['PROJECTS ']);

      STR.Split(projectsEntry, ' ', projectNames);

      for i := 0 to High(projectNames) do
      begin
        for j := 0 to Pred(lines.Count) do
        begin
          if Str.BeginsWith(lines[j], projectNames[i]) then
          begin
            STR.Split(lines[j], ':', name, filePath);
            filePath := STR.Trim(filePath);

            result.Add(filePath);
          end;
        end;
      end;

    finally
      lines.Free;
    end;
  end;




{ BDSGROUP --------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure BDSGROUP.GetProjects(const aXml: IXmlDocument;
                                       var   aList: StringArray);
  var
    i: Integer;
    projectsXml: IXmlElement;
    targetsArray: Utf8StringArray;
    targets: IUtf8StringList;
    value: Utf8String;
    element: IXmlElement;
  begin
    projectsXml := aXml.SelectNode('/BorlandProject/Default.Personality/Projects') as IXmlElement;

    targets := TUtf8StringList.CreateManaged;

    for i := 0 to Pred(projectsXml.Nodes.Count) do
    begin
      element := projectsXml.Nodes[i].AsElement;
      if element.HasAttribute('Name', value) and (value = 'Targets') then
      begin
        Utf8.Split(element.Text, ' ', targetsArray);
        targets.Add(targetsArray);
        BREAK;
      end;
    end;

    if targets.Count = 0 then
      EXIT;

    for i := 0 to Pred(projectsXml.Nodes.Count) do
    begin
      element := projectsXml.Nodes[i].AsElement;

      if (element.Name = 'Projects')
       and element.HasAttribute('Name', value) and targets.Contains(value) then
      begin
        SetLength(aList, Length(aList) + 1);
        aList[High(aList)] := Str.FromUtf8(projectsXml.Nodes[i].Text);
      end;
    end;
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function BDSGROUP.GetProjectSources(const aXml: IXmlDocument): IStringList;
  var
    i: Integer;
    projectsXml: IXmlElement;
    targetsArray: Utf8StringArray;
    targets: IUtf8StringList;
    value: Utf8String;
    element: IXmlElement;
  begin
    result := TStringList.CreateManaged;

    projectsXml := aXml.SelectNode('/BorlandProject/Default.Personality/Projects') as IXmlElement;

    targets := TUtf8StringList.CreateManaged;

    for i := 0 to Pred(projectsXml.Nodes.Count) do
    begin
      element := projectsXml.Nodes[i].AsElement;
      if element.HasAttribute('Name', value) and (value = 'Targets') then
      begin
        Utf8.Split(element.Text, ' ', targetsArray);
        targets.Add(targetsArray);
        BREAK;
      end;
    end;

    if targets.Count = 0 then
      EXIT;

    for i := 0 to Pred(projectsXml.Nodes.Count) do
    begin
      element := projectsXml.Nodes[i].AsElement;

      if (element.Name = 'Projects')
       and element.HasAttribute('Name', value) and targets.Contains(value) then
        result.Add(STR.FromUTF8(projectsXml.Nodes[i].Text));
    end;
  end;









{ GROUPPROJ -------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure GROUPPROJ.GetProjects(const aXml: IXmlDocument;
                                        var   aList: StringArray);
  var
    i: Integer;
    itemGroupXml: IXmlElement;
    element: IXmlElement;
    value: Utf8String;
  begin
    itemGroupXml := aXml.SelectNode('/Project/ItemGroup') as IXmlElement;

    for i := 0 to Pred(itemGroupXml.Nodes.Count) do
    begin
      element := itemGroupXml.Nodes[i].AsElement;
      if element.HasAttribute('Include', value) then
      begin
        SetLength(aList, Length(aList) + 1);
        aList[High(aList)] := Str.FromUTF8(value);
      end;
    end;
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function GROUPPROJ.GetProjectSources(const aXml: IXmlDocument): IStringList;
  var
    i: Integer;
    itemGroupXml: IXmlElement;
    element: IXmlElement;
    value: Utf8String;
  begin
    result := TStringList.CreateManaged;

    itemGroupXml := aXml.SelectNode('/Project/ItemGroup') as IXmlElement;

    for i := 0 to Pred(itemGroupXml.Nodes.Count) do
    begin
      element := itemGroupXml.Nodes[i].AsElement;
      if element.HasAttribute('Include', value) then
        result.Add(STR.FromUTF8(value));
    end;
  end;



{ ------------------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure TProjectGroup.GetProjectFilenames(const aFilename: String;
                                                    var   aList: StringArray);
  var
    i: Integer;
    ext: String;
    doc: IXmlDocument;
    firstNewIdx: Integer;
    basePath: String;
    filePath: String;
  begin
    if NOT FileExists(aFilename) then
    begin
      SetLength(aList, 0);
      EXIT;
    end;

    firstNewIdx := Length(aList);

    ext := ExtractFileExt(aFilename);

    if NOT Str.MatchesAny(ext, ['.bpg', '.bdsgroup', '.groupproj']) then
      raise Exception.CreateFmt('''%s'' is not a supported project group filename (bpg, bdsgroup or groupproj).', [aFilename]);

    if ext = '.bpg' then
    begin
      BPG.GetProjects(aFilename, aList);
      EXIT;
    end;

    Xml.Load(doc).FromFile(aFilename);
    try
      if ext = '.bdsgroup' then
      begin
        BDSGROUP.GetProjects(doc, aList);
        EXIT;
      end;

      if ext = '.groupproj' then
      begin
        GROUPPROJ.GetProjects(doc, aList);
        EXIT;
      end;

    finally
      // Ensure that all newly added project paths are absolute (w.r.t the
      //  path to the project group file).

      basePath := ExtractFilePath(aFilename);
      for i := firstNewIdx to High(aList) do
      begin
        filePath := aList[i];
        if NOT Path.IsAbsolute(filePath) then
          aList[i] := Path.RelativeToAbsolute(filePath, basePath);
      end;
    end;
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TProjectGroup.GetProjectSourceFilenames(const aFilename: String): IStringList;
  var
    i: Integer;
    ext: String;
    doc: IXmlDocument;
    basePath: String;
    filePath: String;
  begin
    result := TStringList.CreateManaged;
    result.Unique := TRUE;

    if NOT FileExists(aFilename) then
      EXIT;

    ext := ExtractFileExt(aFilename);

    if NOT Str.MatchesAny(ext, ['.bpg', '.bdsgroup', '.groupproj']) then
      raise Exception.CreateFmt('''%s'' is not a supported project group filename (bpg, bdsgroup or groupproj).', [aFilename]);

    try
      if ext = '.bpg' then
      begin
        result.Add(BPG.GetProjectSources(aFilename));
        EXIT;
      end;

      Xml.Load(doc).FromFile(aFilename);

      if ext = '.bdsgroup' then
      begin
        result.Add(BDSGROUP.GetProjectSources(doc));
        EXIT;
      end;

      if ext = '.groupproj' then
      begin
        result.Add(GROUPPROJ.GetProjectSources(doc));
        EXIT;
      end;

    finally
      // Ensure that all newly added project paths are absolute (w.r.t the
      //  path to the project group file).

      basePath := ExtractFilePath(aFilename);
      for i := 0 to Pred(result.Count) do
      begin
        filePath := result[i];
        if NOT Path.IsAbsolute(filePath) then
          result[i] := Path.RelativeToAbsolute(filePath, basePath);
      end;
    end;
  end;



end.
