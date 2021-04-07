
  unit Deltics.Delphi.IDE;

interface

  uses
  {$if CompilerVersion > 19}
    Generics.Collections,
  {$ifend}
    Contnrs,
    Classes,
    Graphics;


  const
    VER80   = 8.0;    // Delphi 1
    VER90   = 9.0;    // Delphi 2
    VER100  = 10.0;   // Delphi 3
    VER120  = 12.0;   // Delphi 4
    VER130  = 13.0;   // Delphi 5
    VER140  = 14.0;   // Delphi 6
    VER150  = 15.0;   // Delphi 7
    VER160  = 16.0;   // Delphi 8
    VER170  = 17.0;   // Delphi 2005
    VER180  = 18.0;   // Delphi 2006
    VER185  = 18.5;   // Delphi 2007
    VER190  = 19.0;   // Delphi 2007.NET
    VER200  = 20.0;   // Delphi 2009


  type
    TDelphiInstallation = class;
    TDelphiInstallations = class;
    TEditorColor = class;



    TDelphiInstallation = class
    private
      fEdition: TDelphiEdition;
    {$if CompilerVersion > 19}
      fEditorColors: TObjectList<TEditorColor>;
    {$else}
      fEditorColors: TObjectList;
    {$ifend}
      fVersion: TDelphiVersion;
      function get_IDEVersion: Double;
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
      property IDEVersion: Double read get_IDEVersion;
      property Version: TDelphiVersion read fVersion;
    end;


    TDelphiInstallations = class
    private
    {$if CompilerVersion > 19}
      fList: TObjectList<TDelphiInstallation>;
    {$else}
      fList: TObjectList;
    {$ifend}
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


    
  const
    COMPILER_VERSIONS : array[TDelphiVersion] of Double
                          = (0.0, 8.0, 9.0, 10.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 18.5, 19.0);

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






{ TDelphiInstallation }

  constructor TDelphiInstallation.Create(const aVersion: TDelphiVersion);
  var
    i: Integer;
    reg: TRegistry;
    keys: TStringList;
  begin
    inherited Create;

    fVersion      := aVersion;
  {$if CompilerVersion > 19}
    fEditorColors := TObjectList<TEditorColor>.Create;
  {$else}
    fEditorColors := TObjectList.Create;
  {$ifend}

    reg := TRegistry.Create;
    AutoFree(@reg);

    keys := TStringList.Create;
    AutoFree(@keys);

    reg.Access  := KEY_READ;
    reg.RootKey := HKEY_LOCAL_MACHINE;

    reg.OpenKey(_RegistryRoot(Version), FALSE);
    fEdition := _EditionFromStr(reg.ReadString(_EditionKey(Version)));
    reg.CloseKey;

    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey(_EditorHighlightKey(Version), FALSE);
    reg.GetKeyNames(keys);
    for i := 0 to Pred(keys.Count) do
      fEditorColors.Add(TEditorColor.Create(Version, keys[i]));
    reg.CloseKey;
  end;


  destructor TDelphiInstallation.Destroy;
  begin
    FreeAndNIL(fEditorColors);
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
  {$if CompilerVersion > 19}
    result := fEditorColors[aIndex];
  {$else}
    result := TEditorColor(fEditorColors[aIndex]);
  {$ifend}
  end;


  function TDelphiInstallation.get_EditorColorCount: Integer;
  begin
    result := fEditorColors.Count;
  end;


  function TDelphiInstallation.get_IDEVersion: Double;
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
    {$if CompilerVersion > 19}
      fEditorColors[i].SaveAs(ver);
    {$else}
      TEditorColor(fEditorColors[i]).SaveAs(ver);
    {$ifend}
  end;






{ TDelphiInstallations }

  constructor TDelphiInstallations.Create;
  var
    reg: TRegistry;
    ver: TDelphiVersion;
  begin
    inherited Create;

  {$if CompilerVersion > 19}
    fList := TObjectList<TDelphiInstallation>.Create(TRUE);
  {$else}
    fList := TObjectList.Create(TRUE);
  {$ifend}

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
  {$if CompilerVersion > 19}
    result := fList[aIndex];
  {$else}
    result := TDelphiInstallation(fList[aIndex]);
  {$ifend}
  end;




{ TEditorColor }

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


  


end.
