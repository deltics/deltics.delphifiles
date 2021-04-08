
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles.Adapters.DPROJ;


interface

  uses
    SysUtils,
    Deltics.InterfacedObjects,
    Deltics.Strings,
    Deltics.Xml,
    Deltics.DelphiFiles.Adapters,
    Deltics.DelphiFiles.Adapters.ProjectAdapter,
    Deltics.DelphiFiles.Interfaces,
    Deltics.DelphiFiles.Project;


  type
    DPROJ = class(TProjectAdapter)
    protected
      function DoGetSearchPath(const aPlatform: String; const aBuild: String): String; override;
      procedure DoSetSearchPath(const aPlatform: String; const aBuild: String; const aValue: String); override;
    private
      fXml: IXmlDocument;
      function CreateBuildConfig(const aPlatform, aBuild: String): IXmlElement;
      function FindBuildConfig(const aPlatform, aBuild: String; var aElement: IXmlElement): Boolean;
      function BuildKey(const aBuild: String): String;
      function ConfigKey(const aPlatform: String; const aBuild: String): String;
    protected
      procedure DoClose; override;
      procedure DoInit(const aProject: TProject); override;
      procedure DoOpen; override;
      procedure DoSave; override;
    end;


implementation


  function DPROJ.DoGetSearchPath(const aPlatform: String;
                                 const aBuild: String): String;
  var
    config: IXmlElement;
    path: IXmlElement;
  begin
    result := '';

    OpenFile;
    try
      if FindBuildConfig(aPlatform, aBuild, config)
      and config.ContainsElement('DCC_UnitSearchPath', path) then
        result := Str.FromUtf8(path.Text);

    finally
      CloseFile;
    end;
  end;



  procedure DPROJ.DoSetSearchPath(const aPlatform: String;
                                  const aBuild: String;
                                  const aValue: String);
  var
    i: Integer;
    config: IXmlElement;
    path: IXmlElement;
    oldPath: String;
    newPath: String;
    emptyPath: Boolean;
    emptyConfig: Boolean;
  begin
    OpenFile;
    try
      oldPath := DoGetSearchPath(aPlatform, aBuild);
      newPath := aValue;

      if newPath = oldPath then
        EXIT;

      if NOT FindBuildConfig(aPlatform, aBuild, config) then
      begin
        config  := CreateBuildConfig(aPlatform, aBuild);
        newPath := Str.Concat([aValue, '$(DCC_UnitSearchPath)'], ';');
      end;

      emptyPath := (newPath = '') or Str.SameText(newPath, '$(DCC_UnitSearchPath)');

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

      HasChanges := TRUE;

    finally
      CloseFile;
    end;
  end;



  function DPROJ.BuildKey(const aBuild: String): String;
  var
    i: Integer;
    project: IProject;
  begin
    result := aBuild;

    if result <> '' then
    begin
      project := self.get_Project;
      for i := 0 to High(project.BuildConfigs) do
      begin
        if Str.SameText(project.BuildConfigs[i].Name, aBuild) then
        begin
          result := project.BuildConfigs[i].Key;
          BREAK;
        end;
      end;
    end
    else
      result := 'Base';
  end;


  function DPROJ.ConfigKey(const aPlatform, aBuild: String): String;
  var
    build: String;
  begin
    build := BuildKey(aBuild);

    if aPlatform <> '' then
      result := '''$(' + build + '_' + aPlatform + ')''!='''''
    else
      result := '''$(' + build + ')''!=''''';
  end;



  function DPROJ.CreateBuildConfig(const aPlatform, aBuild: String): IXmlElement;
  var
    condition: IXmlAttribute;
    project: IXmlElement;
    lastConfig: IXmlNode;
  begin
    condition := Xml.Attribute('Condition', Utf8.FromString(ConfigKey(aPlatform, aBuild)));

    result := Xml.Element('PropertyGroup');
    result.Add(condition);

    project     := fXml.SelectElement('Project');
    lastConfig  := fXml.SelectNodes('Project/PropertyGroup').Last;

    project.Insert(result).After(lastConfig);
  end;


  procedure DPROJ.DoClose;
  begin
    fXml := NIL;
  end;


  procedure DPROJ.DoInit(const aProject: TProject);
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
  begin
    Xml.Load(doc).FromFile(Filename);

    platforms := doc.SelectNode('Project/ProjectExtensions/BorlandProject/Platforms') as IXmlElement;
    for i := 0 to Pred(platforms.Nodes.Count) do
    begin
      if platforms.Nodes[i].Text = 'True' then
        aProject.AddPlatform(STR.FromUtf8(platforms.Nodes[i].AsElement.Attributes[0].Value));
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

      aProject.AddBuildConfig(key, name, parentKey);
    end;
  end;


  procedure DPROJ.DoOpen;
  begin
    Xml.Load(fXml).FromFile(Filename);
  end;


  procedure DPROJ.DoSave;
  begin
    fXml.SaveToFile(Filename);
  end;



  function DPROJ.FindBuildConfig(const aPlatform, aBuild: String; var aElement: IXmlElement): Boolean;
  var
    i: Integer;
    configs: IXmlElementSelection;
    condition: Utf8String;
    conditionKey: String;
  begin
    result    := FALSE;
    aElement  := NIL;

    conditionKey  := ConfigKey(aPlatform, aBuild);
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
