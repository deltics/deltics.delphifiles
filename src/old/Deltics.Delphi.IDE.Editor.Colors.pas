
  unit Deltics.Delphi.IDE.Editor.Colors;

interface

  uses
  {$if CompilerVersion > 19}
    Generics.Collections,
  {$ifend}
    Contnrs,
    Classes,
    Graphics;


  type





implementation

  uses
    Registry,
    StrUtils,
    SysUtils,
    Windows,
    Deltics.SysUtils;









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
    AutoFree(reg);

    keys := TStringList.Create;
    AutoFree(keys);

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
    AutoFree(reg);

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







end.
