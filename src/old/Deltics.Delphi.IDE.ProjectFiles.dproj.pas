
  unit Deltics.Delphi.IDE.ProjectFiles.dproj;

interface

  uses
    Deltics.Strings,
    Deltics.XML;


  type
    TDelphiDprojFile = class
    private
      fFilename: String;
      fBuildConfigurations: TStringList;
      fPlatforms: TStringList;
      fXML: TXMLDocument;
    public
      constructor Create;
      destructor Destroy; override;
      procedure LoadFromFile(const aFilename: String);
      property BuildConfigurations: TStringList read fBuildConfigurations;
      property Platforms: TStringList read fPlatforms;
      property XML: TXMLDocument read fXML;
    end;


implementation

  uses
    SysUtils;


{ TDelphiDprojFile }

  constructor TDelphiDprojFile.Create;
  begin
    inherited Create;

    fBuildConfigurations  := TStringList.Create;
    fPlatforms            := TStringList.Create;
  end;




  destructor TDelphiDprojFile.Destroy;
  begin
    fPlatforms.Free;
    fBuildConfigurations.Free;
    fXML.Free;

    inherited;
  end;



  procedure TDelphiDprojFile.LoadFromFile(const aFilename: String);
  var
    i: Integer;
    platforms: TXMLElement;
    buildconfigs: IXMLNodeSelection;
  begin
    fXML := TXMLDocument.CreateFromFile(aFilename);

    platforms := fXML.SelectElement('Project/ProjectExtensions/BorlandProject/Platforms');
    for i := 0 to Pred(platforms.Nodes.Count) do
      fPlatforms.Add(platforms.Nodes[i].AsElement.Attributes[0].Value);

    buildconfigs := fXML.SelectNodes('Project/ItemGroup/BuildConfiguration');
    for i := 0 to Pred(buildconfigs.Count) do
      fBuildConfigurations.Add(buildconfigs[i].AsElement.Attributes[0].Value);
  end;




end.
