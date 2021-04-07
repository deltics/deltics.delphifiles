
  unit Deltics.Delphi.ProjectFiles.DPROJ;

interface

  uses
    Deltics.Strings,
    Deltics.XML;


  type
    TDprojFile = class
    private
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

  constructor TDprojFile.Create;
  begin
    inherited Create;

    fBuildConfigurations  := TStringList.Create;
    fPlatforms            := TStringList.Create;
  end;




  destructor TDprojFile.Destroy;
  begin
    fPlatforms.Free;
    fBuildConfigurations.Free;
    fXML.Free;

    inherited;
  end;



  procedure TDprojFile.LoadFromFile(const aFilename: String);
  var
    i: Integer;
    platforms: TXMLElement;
    buildconfigs: IXMLNodeSelection;
  begin
    fXML := TXMLDocument.CreateFromFile(aFilename);

    platforms := fXML.SelectElement('Project/ProjectExtensions/BorlandProject/Platforms');
    for i := 0 to Pred(platforms.Nodes.Count) do
      fPlatforms.Add(STR.FromUTF8(platforms.Nodes[i].AsElement.Attributes[0].Value));

    buildconfigs := fXML.SelectNodes('Project/ItemGroup/BuildConfiguration');
    for i := 0 to Pred(buildconfigs.Count) do
      fBuildConfigurations.Add(STR.FromUTF8(buildconfigs[i].AsElement.Attributes[0].Value));
  end;




end.
