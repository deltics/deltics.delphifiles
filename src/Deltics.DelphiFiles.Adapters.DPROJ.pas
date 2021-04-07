
  unit Deltics.DelphiFiles.Adapters.DPROJ;

interface

  uses
    SysUtils,
    Deltics.InterfacedObjects,
    Deltics.Strings,
    Deltics.Xml,
    Deltics.DelphiFiles.Adapters,
    Deltics.DelphiFiles.Interfaces,
    Deltics.DelphiFiles.Project;


  type
    DPROJ = class(TComInterfacedObject, IProjectFileAdapter)
    private
      fFilename: String;
      function get_Project: IProject;
      function GetSearchPath(const aBuild: String = ''; const aPlatform: String = ''): String;
      procedure SetSearchPath(const aPath: String; const aBuild: String = ''; const aPlatform: String = '');
    private
      fOpenCount: Integer;
      fXml: IXmlDocument;
      function CreateBuildConfig(const aBuild, aPlatform: String): IXmlElement;
      function FindBuildConfig(const aBuild, aPlatform: String; var aElement: IXmlElement): Boolean;
      function BuildKey(const aBuild: String): String;
      function ConfigKey(const aBuild, aPlatform: String): String;
      procedure CloseProject(const aSaveChanges: Boolean = FALSE);
      procedure OpenProject;
//      procedure SaveProject;
    public
      constructor Create(const aFilename: String);
      property Filename: String read fFilename;
    end;


implementation


  constructor DPROJ.Create(const aFilename: String);
  begin
    inherited Create;

    fFilename := aFilename;
  end;


  function DPROJ.get_Project: IProject;
  var
    i: Integer;
    doc: IXmlDocument;
    platforms: IXmlElement;
    buildconfigs: IXmlElementSelection;
    config: IXmlElement;
    key: String;
    name: String;
    parent: IXmlElement;
    parentKey: String;
    project: TProject;
  begin
    project := TProject.Create;
    project.Adapter   := self;
    project.Filename  := Filename;

    result  := project;

    Xml.Load(doc).FromFile(Filename);

    platforms := doc.SelectNode('Project/ProjectExtensions/BorlandProject/Platforms') as IXmlElement;
    for i := 0 to Pred(platforms.Nodes.Count) do
    begin
      if platforms.Nodes[i].Text = 'True' then
        project.AddPlatform(STR.FromUtf8(platforms.Nodes[i].AsElement.Attributes[0].Value));
    end;

    buildconfigs := doc.SelectElements('Project/ItemGroup/BuildConfiguration');
    for i := 0 to Pred(buildconfigs.Count) do
    begin
      config := buildConfigs[i];

      name      := STR.FromUtf8(config.Attributes.ItemByName('Include').AsAttribute.Value);
      key       := Str.FromUtf8(config.SelectNode('Key').Text);
      parentKey := '';

      if config.ContainsElement('CfgParent', parent) then
        parentKey := Str.FromUtf8(parent.Text);

      project.AddBuildConfig(key, name, parentKey);
    end;
  end;


  procedure DPROJ.OpenProject;
  begin
    Inc(fOpenCount);

    if fOpenCount = 1 then
      Xml.Load(fXml).FromFile(Filename);
  end;


  function DPROJ.GetSearchPath(const aBuild: String;
                               const aPlatform: String): String;
  var
    config: IXmlElement;
    path: IXmlElement;
  begin
    result := '';

    OpenProject;
    try
      if FindBuildConfig(aBuild, aPlatform, config)
      and config.ContainsElement('DCC_UnitSearchPath', path) then
        result := Str.FromUtf8(path.Text);

    finally
      CloseProject;
    end;
  end;



//  procedure DPROJ.SaveProject;
//  begin
//    // TODO: Make backup of existing project file
//
//    fXml.SaveToFile(Filename);
//  end;



  procedure DPROJ.SetSearchPath(const aPath: String;
                                const aBuild: String;
                                const aPlatform: String);
  var
    i: Integer;
    config: IXmlElement;
    path: IXmlElement;
    oldPath: String;
    newPath: String;
    emptyPath: Boolean;
    emptyConfig: Boolean;
  begin
    OpenProject;
    try
      oldPath := GetSearchPath(aBuild, aPlatform);
      newPath := aPath;

      if NOT FindBuildConfig(aBuild, aPlatform, config) then
      begin
        config  := CreateBuildConfig(aBuild, aPlatform);
        newPath := STR.Concat([aPath, '$(DCC_UnitSearchPath)'], ';');
      end;

      emptyPath := newPath.IsEmpty or newPath.EqualsText('$(DCC_UnitSearchPath)');

      if NOT emptyPath then
      begin
        if NOT config.ContainsElement('DCC_UnitSearchPath', path) then
        begin
          path := Xml.Element('DCC_UnitSearchPath');
          config.Add(path);
        end;

        path.Text := Utf8.FromWIDE(newPath);
      end
      else if config.ContainsElement('DCC_UnitSearchPath', path) then
        path.Delete;

      emptyConfig := TRUE;
      for i := 0 to Pred(config.Nodes.Count) do
        if config.Nodes[i].NodeType = xmlElement then
        begin
          emptyConfig := FALSE;
          BREAK;
        end;

      if emptyConfig then
        config.Delete;

    finally
      CloseProject(TRUE);
    end;
  end;



  function DPROJ.BuildKey(const aBuild: String): String;
  var
    i: Integer;
    project: IProject;
  begin
    result := aBuild;

    if result.IsNotEmpty then
    begin
      project := self.get_Project;
      for i := 0 to High(project.BuildConfigs) do
      begin
        if project.BuildConfigs[i].Name.EqualsText(aBuild) then
        begin
          result := project.BuildConfigs[i].Key;
          BREAK;
        end;
      end;
    end
    else
      result := 'Base';
  end;


  procedure DPROJ.CloseProject(const aSaveChanges: Boolean);
  begin
    Dec(fOpenCount);

    if aSaveChanges then
      fXml.SaveToFile(Filename);

    if fOpenCount = 0 then
      fXml := NIL;
  end;



  function DPROJ.ConfigKey(const aBuild, aPlatform: String): String;
  var
    build: String;
  begin
    build := BuildKey(aBuild);

    if aPlatform <> '' then
      result := '''$(' + build + '_' + aPlatform + ')''!='''''
    else
      result := '''$(' + build + ')''!=''''';
  end;



  function DPROJ.CreateBuildConfig(const aBuild, aPlatform: String): IXmlElement;
  var
    condition: IXmlAttribute;
    configs: IXmlNodeSelection;
  begin
    condition := Xml.Attribute('Condition', Utf8.FromString(ConfigKey(aBuild, aPlatform)));

    result := Xml.Element('PropertyGroup');
    result.Add(condition);

    configs := fXml.SelectNodes('Project/PropertyGroup');

    configs.Last.Parent.AsElement.Insert(result).After(configs.Last);
  end;


  function DPROJ.FindBuildConfig(const aBuild, aPlatform: String; var aElement: IXmlElement): Boolean;
  var
    i: Integer;
    configs: IXmlElementSelection;
    condition: Utf8String;
    conditionKey: String;
  begin
    result    := FALSE;
    aElement  := NIL;

    conditionKey  := ConfigKey(aBuild, aPlatform);
    configs       := fXml.SelectElements('Project/PropertyGroup');

    for i := 0 to Pred(configs.Count) do
    begin
      result := configs[i].HasAttribute('Condition', condition)
                 and (STR.FromUtf8(condition) = conditionKey);

      if result then
      begin
        aElement := configs[i].AsElement;
        BREAK;
      end;
    end;
  end;





end.
