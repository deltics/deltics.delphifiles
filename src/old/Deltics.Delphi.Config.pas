
  unit Deltics.Delphi.Config;

interface

  uses
    Contnrs,
    Classes,
    Graphics;


  type
    TDelphiIDEType = (
                      diAppBuilder,
                      diGalileo
                     );

    TDelphiVersion = (
                      dvUnknown,
                      dvDelphi1,
                      dvDelphi2,
                      dvDelphi3,
                      dvDelphi4,
                      dvDelphi5,
                      dvDelphi6,
                      dvDelphi7,
                      dvDelphi8,
                      dvDelphi2005,
                      dvDelphi2006,
                      dvDelphi2007,
                      dvDelphi2009
                     );

    TDelphiEdition = (
                      deUnknown,
                      dePersonal,
                      deExplorer,
                      deProfessional,
                      deEnterprise,
                      deArchitect
                     );

    TDelphiInstallation = class;
    TDelphiInstallations = class;
    TEditorColor = class;
    TEditorOptions = class;


    TDelphiInstallation = class
    private
      fEdition: TDelphiEdition;
      fEditorColors: TObjectList;
      fEditorOptions: TEditorOptions;
      fEditorFileTypes: TStringList;
      fVersion: TDelphiVersion;
      function get_IDEType: TDelphiIDEType;
      function get_IDEVer: Double;
      function get_CompilerVer: Double;
      function get_DisplayName: String;
      function get_EditorColor(const aIndex: Integer): TEditorColor;
      function get_EditorColorCount: Integer;
    public
      constructor Create(const aVersion: TDelphiVersion);
      destructor Destroy; override;
      function RegistryRoot: String;
      procedure SaveAs(const aVersion: TDelphiVersion = dvUnknown);
      property CompilerVer: Double read get_CompilerVer;
      property DisplayName: String read get_DisplayName;
      property Edition: TDelphiEdition read fEdition;
      property EditorColor[const aIndex: Integer]: TEditorColor read get_EditorColor;
      property EditorColorCount: Integer read get_EditorColorCount;
      property EditorFileTypes: TStringList read fEditorFileTypes;
      property IDEType: TDelphiIDEType read get_IDEType;
      property IDEVer: Double read get_IDEVer;
      property Version: TDelphiVersion read fVersion;
    end;


    TDelphiInstallations = class
    private
      fList: TObjectList;
      function get_Count: Integer;
      function get_Items(const aIndex: Integer): TDelphiInstallation;
    public
      constructor Create;
      destructor Destroy; override;
      property Count: Integer read get_Count;
      property Items[const aIndex: Integer]: TDelphiInstallation read get_Items; default;
    end;



    TEditorColor = class
    private
      fName: String;
      fBackground: TColor;
      fBackgroundDefault: Boolean;
      fForeground: TColor;
      fForegroundDefault: Boolean;
      fStyle: TFontStyles;
    public
      constructor Create(const aVersion: TDelphiVersion;
                         const aHighlight: String);
      procedure SaveAs(const aVersion: TDelphiVersion;
                       const aHighlight: String = '');
      property Background: TColor read fBackground write fBackground;
      property BackgroundDefault: Boolean read fBackgroundDefault write fBackgroundDefault;
      property Foreground: TColor read fForeground write fForeground;
      property ForegroundDefault: Boolean read fForegroundDefault write fForegroundDefault;
      property Name: String read fName;
      property Style: TFontStyles read fStyle write fStyle;
    end;



    TEditorOptions = class
    private
      fFileType: String;
      fValues: TStringList;
      procedure ReadValues(const aKey: String;
                           const aDWORDs, aBOOLs, aSTRs: array of String);
    protected
      constructor Create; overload;
      constructor Create(const aVersion: TDelphiVersion); overload;
      constructor Create(const aVersion: TDelphiVersion;
                         const aFileType: String); overload;
    public
      destructor Destroy; override;
      procedure SaveAs(const aVersion: TDelphiVersion); overload;
      procedure SaveAs(const aVersion: TDelphiVersion;
                       const aFileType: String); overload;
    end;


    
  const
    COMPILER_VERSIONS : array[TDelphiVersion] of Double
                          = (0.0, 8.0, 9.0, 10.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 18.5, 20.0);

    IDE_VERSIONS      : array[TDelphiVersion] of Double
                          = (0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 3.0, 4.0, 5.0, 6.0);

    PRODUCT_NAME      : array[TDelphiVersion] of String
                          = (
                             'Unknown Delphi',
                             'Delphi 1',
                             'Delphi 2',
                             'Delphi 3',
                             'Delphi 4',
                             'Delphi 5',
                             'Delphi 6',
                             'Delphi 7',
                             'Delphi 8',
                             'Delphi 2005',
                             'Delphi 2006',
                             'Delphi 2007',
                             'Delphi 2009'
                            );




implementation

  uses
    Registry,
    StrUtils,
    SysUtils,
    Windows,
    Deltics.SysUtils;



  function _RegistryRoot(const aVersion: TDelphiVersion): String;
  begin
    if aVersion < dvDelphi2009 then
      result := 'SOFTWARE\Borland\'
    else
      result := 'SOFTWARE\CodeGear\';

    if aVersion < dvDelphi2005 then
      result := result + 'Delphi\'
    else
      result := result + 'BDS\';

    result := result + Format('%.1f', [IDE_VERSIONS[aVersion]]) + '\';
  end;


  function _EditionKey(const aVersion: TDelphiVersion): String;
  begin
    if aVersion < dvDelphi2009 then
      result := 'Version'
    else
      result := 'Edition';
  end;


  function _EditionFromStr(const aString: String): TDelphiEdition;
  begin
    if SameText(aString, 'pro') or SameText(aString, 'professional') then
      result := deProfessional
    else if SameText(aString, 'ent') or SameText(aString, 'enterprise') then
      result := deEnterprise
    else if SameText(aString, 'arc') or SameText(aString, 'architect') then
      result := deArchitect
    else
      result := deUnknown;
  end;


  function _EditorHighlightKey(const aVersion: TDelphiVersion;
                               const aHighlight: String = ''): String;
  begin
    result := _RegistryRoot(aVersion) + '\Editor\Highlight';
    if aHighlight <> '' then
      result := result + '\' + aHighlight;
  end;


  function _EditorOptionsKey(const aVersion: TDelphiVersion): String;
  begin
    result := _RegistryRoot(aVersion) + '\Editor\Options';
  end;


  function _EditorSourceOptionsKey(const aVersion: TDelphiVersion): String;
  begin
    ASSERT(aVersion >= dvDelphi7);
    result := _RegistryRoot(aVersion) + '\Editor\Source Options';
  end;


  function _EditorFileTypeOptionsKey(const aVersion: TDelphiVersion;
                                     const aFileType: String = ''): String;
  begin
    if (aVersion >= dvDelphi7) then
    begin
      result := _RegistryRoot(aVersion) + '\Editor\Source Options\Borland.EditOptions.';
      if (aFileType <> '') then
        result := result + aFileType
      else
        result := result + 'Pascal';
    end
    else
      result := _RegistryRoot(aVersion) + '\Editor\Options';
  end;





{ TDelphiInstallation }

  constructor TDelphiInstallation.Create(const aVersion: TDelphiVersion);
  var
    i: Integer;
    reg: TRegistry;
    keys: TStringList;
    s: String;
  begin
    AutoFree([@reg,
              @keys]);

    inherited Create;

    fVersion          := aVersion;
    fEditorColors     := TObjectList.Create;
    fEditorFileTypes  := TStringList.Create;

    reg  := TRegistry.Create;
    keys := TStringList.Create;

    reg.Access  := KEY_READ;
    reg.RootKey := HKEY_LOCAL_MACHINE;

    reg.OpenKey(_RegistryRoot(Version), FALSE);
    try
      fEdition := _EditionFromStr(reg.ReadString(_EditionKey(Version)));
    finally
      reg.CloseKey;
    end;

    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey(_EditorHighlightKey(Version), FALSE);
    try
      reg.GetKeyNames(keys);
      for i := 0 to Pred(keys.Count) do
        fEditorColors.Add(TEditorColor.Create(Version, keys[i]));
    finally
      reg.CloseKey;
    end;

    if (aVersion >= dvDelphi7) then
    begin
      reg.OpenKey(_EditorSourceOptionsKey(Version), FALSE);
      try
        reg.GetKeyNames(keys);
        for i := 0 to Pred(keys.Count) do
        begin
          s := keys[i];
          Delete(s, 1, Length('Borland.EditOptions.'));
          fEditorFileTypes.Add(s);
        end;
      finally
        reg.CloseKey;
      end;
    end
    else
      fEditorFileTypes.Add('Pascal');

    fEditorOptions := TEditorOptions.Create(aVersion);

    for i := 0 to Pred(fEditorFileTypes.Count) do
      fEditorFileTypes.Objects[i] := TEditorOptions.Create(aVersion, fEditorFileTypes[i]);
  end;


  destructor TDelphiInstallation.Destroy;
  var
    i: Integer;
  begin
    for i := 0 to Pred(fEditorFileTypes.Count) do
      fEditorFileTypes.Objects[i].Free;
      
    FreeAndNIL([@fEditorColors,
                @fEditorOptions,
                @fEditorFileTypes]);
    inherited;
  end;


  function TDelphiInstallation.get_CompilerVer: Double;
  begin
    result := COMPILER_VERSIONS[Version];
  end;


  function TDelphiInstallation.get_DisplayName: String;
  begin
    result := PRODUCT_NAME[Version];
    case Edition of
      dePersonal      : result := result + ' Personal';
      deProfessional  : result := result + ' Professional';
      deEnterprise    : result := result + ' Enterprise';
      deArchitect     : result := result + ' Architect';
    end;
  end;


  function TDelphiInstallation.get_EditorColor(const aIndex: Integer): TEditorColor;
  begin
    result := TEditorColor(fEditorColors[aIndex]);
  end;


  function TDelphiInstallation.get_EditorColorCount: Integer;
  begin
    result := fEditorColors.Count;
  end;


  function TDelphiInstallation.get_IDEType: TDelphiIDEType;
  begin
    if (Version <= dvDelphi7) then
      result := diAppBuilder
    else
      result := diGalileo;
  end;


  function TDelphiInstallation.get_IDEVer: Double;
  begin
    result := IDE_VERSIONS[Version];
  end;


  function TDelphiInstallation.RegistryRoot: String;
  begin
    result := _RegistryRoot(Version);
  end;


  procedure TDelphiInstallation.SaveAs(const aVersion: TDelphiVersion);
  var
    i: Integer;
    ver: TDelphiVersion;
  begin
    ver := aVersion;
    if (ver = dvUnknown) then
      ver := Version;

    for i := 0 to Pred(fEditorColors.Count) do
      TEditorColor(fEditorColors[i]).SaveAs(ver);
  end;






{ TDelphiInstallations }

  constructor TDelphiInstallations.Create;
  var
    reg: TRegistry;
    ver: TDelphiVersion;
  begin
    inherited Create;

    fList := TObjectList.Create(TRUE);

    reg := TRegistry.Create;
    AutoFree(@reg);

    reg.RootKey := HKEY_LOCAL_MACHINE;
    reg.Access  := KEY_READ;

    for ver := dvDelphi2 to dvDelphi2009 do
      if reg.KeyExists(_RegistryRoot(ver)) then
        fList.Add(TDelphiInstallation.Create(ver));
  end;


  destructor TDelphiInstallations.Destroy;
  begin
    FreeAndNIL(fList);
    inherited;
  end;


  function TDelphiInstallations.get_Count: Integer;
  begin
    result := fList.Count;
  end;


  function TDelphiInstallations.get_Items(const aIndex: Integer): TDelphiInstallation;
  begin
    result := TDelphiInstallation(fList[aIndex]);
  end;




{ TEditorColor ----------------------------------------------------------------------------------- }

  constructor TEditorColor.Create(const aVersion: TDelphiVersion;
                                  const aHighlight: String);
  var
    i: Integer;
    reg: TRegistry;
    vals: TStringList;
    pal: TPaletteEntry;

    function ReadColor: TColor;
    begin
      if SameText(RightStr(vals[i], 3), 'new') then
        result := StringToColor(reg.ReadString(vals[i]))
      else
      begin
        GetPaletteEntries(SystemPalette16, reg.ReadInteger(vals[i]), 1, pal);
        result := RGB(pal.peRed, pal.peGreen, pal.peBlue);
      end;
    end;

    function ReadBool: Boolean;
    var
      s: String;
    begin
      s := reg.ReadString(vals[i]);
      result := ((s = '-1') or SameText(s, 'true'));
    end;

  begin
    inherited Create;

    fName := aHighlight;

    reg := TRegistry.Create;
    AutoFree(@reg);

    vals := TStringList.Create;
    AutoFree(@vals);

    reg.Access  := KEY_READ;
    reg.RootKey := HKEY_CURRENT_USER;

    reg.OpenKey(_EditorHighlightKey(aVersion, aHighlight), FALSE);
    reg.GetValueNames(vals);
    for i := 0 to Pred(vals.Count) do
    begin
      if SameText(vals[i], 'background color')
       or SameText(vals[i], 'background color new') then
        fBackground := ReadColor
      else if SameText(vals[i], 'foreground color')
       or SameText(vals[i], 'foreground color new') then
        fForeground := ReadColor
      else if SameText(vals[i], 'default background') then
        fBackgroundDefault := ReadBool
      else if SameText(vals[i], 'default foreground') then
        fForegroundDefault := ReadBool
      else if SameText(vals[i], 'bold') and ReadBool then
        Include(fStyle, fsBold)
      else if SameText(vals[i], 'italic') and ReadBool then
        Include(fStyle, fsItalic)
      else if SameText(vals[i], 'underline') and ReadBool then
        Include(fStyle, fsUnderline);
    end;
    reg.CloseKey;
  end;


  procedure TEditorColor.SaveAs(const aVersion: TDelphiVersion;
                                const aHighlight: String);
  var
    reg: TRegistry;
    keys: TStringList;
    key: String;

    procedure SaveColor(aName: String; aValue: TColor);
    begin
      if aVersion > dvDelphi6 then
        reg.WriteString(aName + ' New', ColorToString(aValue))
      else
        reg.WriteInteger(aName, GetNearestPaletteIndex(SystemPalette16, ColorToRGB(aValue)));
    end;

    procedure SaveBool(aName: String; const aValue: Boolean);
    begin
      case aValue of
        FALSE : reg.WriteString(aName, 'False');
        TRUE  : reg.WriteString(aName, 'True');
      end;
    end;

  begin
    reg := TRegistry.Create;
    AutoFree(@reg);

    keys := TStringList.Create;
    AutoFree(@keys);

    reg.Access  := KEY_READ;
    reg.RootKey := HKEY_CURRENT_USER;

    reg.OpenKey(_EditorHighlightKey(aVersion), FALSE);
    reg.GetKeyNames(keys);
    reg.CloseKey;

    // We only save editor colors that the specified version is
    //  already aware of
    key := Deltics.SysUtils.IfThen(aHighlight = '', fName, aHighlight);
    if (keys.IndexOf(key) = -1) then
      EXIT;

    reg.Access  := KEY_ALL_ACCESS;
    reg.OpenKey(_EditorHighlightKey(aVersion, key), FALSE);

    SaveColor('Background Color', Background);
    SaveColor('Foreground Color', Foreground);
    SaveBool('Default Background', BackgroundDefault);
    SaveBool('Default Foreground', ForegroundDefault);
    SaveBool('Bold', fsBold in Style);
    SaveBool('Italic', fsItalic in Style);
    SaveBool('Underline', fsUnderline in Style);
  end;





{ TEditorOptions --------------------------------------------------------------------------------- }

  constructor TEditorOptions.Create;
  begin
    inherited;

    fValues := TStringList.Create;
  end;


  constructor TEditorOptions.Create(const aVersion: TDelphiVersion);
  {
    Constructor that reads editor option values that apply to all file
     types edited by the IDE.
  }
  begin
    Create;
    ReadValues(_EditorOptionsKey(aVersion),

               ['File Backup Level',
                'Font Size',
                'Gutter Width',
                'Right Margin',
                'Undo Limit'],

               ['Ask To Reload Modified Files',
                'Auto Collapse Region Blocks',
                'BRIEF Cursor Shapes',
                'BRIEF RegEx',
                'Code Insight Use Editor Font',
                'Create Backup File',
                'Cursor Beyond EOF',
                'Cursor Through Tabs',
                'Double Click Line',
                'Enable Elisions',
                'Extended Pair Matching',
                'Find AutoCompletes',
                'Find Text At Cursor',
                'Force Cut Copy Enabled',
                'Group Undo',
                'Insert',
                'Number All Lines',
                'Overwrite Blocks',
                'Persistent Blocks',
                'Preserve Line Ends',
                'Show Image On Tabs',
                'Show Line Numbers',
                'ShowFullPath',
                'Sort Pages Menu',
                'Undo After Save',
                'Use CtrlAlt Keys',
                'Visible Gutter',
                'Visible Right Margin',
                'Zoom To Full Screen'],

               ['Color SpeedSetting',
                'Editor Emulation',
                'Editor Font',
                'Editor Keymapping',
                'Editor SpeedSetting']);
  end;


  constructor TEditorOptions.Create(const aVersion: TDelphiVersion;
                                    const aFileType: String);
  begin
    Create;

    fFileType := aFileType;

    ReadValues(_EditorFileTypeOptionsKey(aVersion, aFileType),

               ['Block Indent'],

               ['Auto Indent',
                'Backspace Unindents',
                'Cursor Through Tabs',
                'Highlight Current Line',
                'Keep Trailing Blanks',
                'Optimal Fill',
                'Show line breaks',
                'Show space character',
                'Show tab character',
                'Smart Tab',
                'Tab Character',
                'Use Syntax Highlight'],

               ['File Extensions',
                'Source Opt Internal ID',
                'Source Option Name',
                'Syntax Highlighter ID',
                'Tab Stops']);
  end;


  destructor TEditorOptions.Destroy;
  begin
    FreeAndNIL(fValues);
    inherited;
  end;


  procedure TEditorOptions.ReadValues(const aKey: String;
                                      const aDWORDs, aBOOLs, aSTRs: array of String);
  var
    i: Integer;
    reg: TRegistry;
    vals: TStringList;

    procedure ReadBOOL(const aName: String);
    var
      s: String;
    begin
      if NOT reg.ValueExists(aName) then
        EXIT;

      s := reg.ReadString(aName);
      case (s = '-1') or SameText(s, 'true') of
        TRUE  : s := 'True';
        FALSE : s := 'False';
      end;
      fValues.Add(Format('BL;%s;%s', [aName, s]));
    end;

    procedure ReadDWORD(const aName: String);
    begin
      if NOT reg.ValueExists(aName) then
        EXIT;

      fValues.Add(Format('DW;%s;%d', [aName, reg.ReadInteger(aName)]));
    end;

    procedure ReadSTR(const aName: String);
    begin
      if NOT reg.ValueExists(aName) then
        EXIT;

      fValues.Add(Format('ST;%s;%s', [aName, reg.ReadString(aName)]));
    end;

  begin
    AutoFree([@reg,
              @vals]);

    reg  := TRegistry.Create;
    vals := TStringList.Create;

    reg.Access  := KEY_READ;
    reg.RootKey := HKEY_LOCAL_MACHINE;

    reg.OpenKey(aKey, FALSE);
    reg.GetValueNames(vals);

    for i := 0 to Pred(Length(aDWORDs)) do
      ReadDWORD(aDWORDs[i]);

    for i := 0 to Pred(Length(aBOOLs)) do
      ReadBOOL(aBOOLs[i]);

    for i := 0 to Pred(Length(aSTRs)) do
      ReadSTR(aSTRs[i]);
  end;



  procedure TEditorOptions.SaveAs(const aVersion: TDelphiVersion);
  var
    i: Integer;
    reg: TRegistry;
  begin
    AutoFree(@reg);
    
    reg := TRegistry.Create;
    reg.Access  := KEY_ALL_ACCESS;
    reg.RootKey := HKEY_CURRENT_USER;
    for i := 0 to Pred(fValues.Count) do
      Save(reg, fValues[i]);
  end;


  procedure TEditorOptions.SaveAs(const aVersion: TDelphiVersion;
                                  const aFileType: String);
  begin

  end;

end.
