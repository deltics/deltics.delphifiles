
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles.Adapters.BDSGROUP;


interface

  uses
    Deltics.StringLists,
    Deltics.DelphiFiles.Adapters.ProjectGroupAdapter;


  type
    BDSGROUP = class(TXmlProjectGroupAdapter)
    protected
      procedure DoGetProjectFilenames(const aList: IStringList); override;
      procedure DoGetProjectSourceFilenames(const aList: IStringList); override;
    end;


implementation

  uses
    Deltics.Strings,
    Deltics.Xml;



{ BDSGROUP --------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure BDSGROUP.DoGetProjectFilenames(const aList: IStringList);
  var
    i: Integer;
    projectsXml: IXmlElement;
    targetsArray: Utf8StringArray;
    targets: IUtf8StringList;
    value: Utf8String;
    element: IXmlElement;
  begin
    projectsXml := Settings.SelectNode('/BorlandProject/Default.Personality/Projects') as IXmlElement;

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
        aList.Add(Str.FromUtf8(projectsXml.Nodes[i].Text));
    end;
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure BDSGROUP.DoGetProjectSourceFilenames(const aList: IStringList);
  var
    i: Integer;
    projectsXml: IXmlElement;
    targetsArray: Utf8StringArray;
    targets: IUtf8StringList;
    value: Utf8String;
    element: IXmlElement;
  begin
    projectsXml := Settings.SelectNode('/BorlandProject/Default.Personality/Projects') as IXmlElement;

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
        aList.Add(STR.FromUTF8(projectsXml.Nodes[i].Text));
    end;
  end;


end.
