
  unit Deltics.Delphi.ProjectSettings;

interface

  uses
    Classes,
    Contnrs,
    SysUtils,
    Deltics.Classes,
    Deltics.Strings,
    Deltics.Delphi.Versions;


  type
    TValidator = class
    private
      fStrings: array of String;
    public
      constructor Create(const aValues: array of Integer); overload;
      constructor Create(const aValues: array of String); overload;
      function IsValid(const aValue: String): Boolean;
    end;



    TProjectSetting = class
    private
      fDisplayName: String;
      fDirective: String;
      fOption: String;
      fDefaultValue: String;
      fValue: String;
      fValidator: TValidator;
      procedure set_Value(const aValue: String);
    public
      constructor Create(const aDisplayName, aDirective, aOption: String; const aDefault: String; const aValidator: TValidator = NIL);
      destructor Destroy; override;
      property DisplayName: String read fDisplayName;
      property Directive: String read fDirective;
      property Option: String read fOption;
      property Value: String read fValue write set_Value;
      property DefaultValue: String read fDefaultValue;
    end;


    TProjectSettingList = class
    private
      fItems: TObjectList;
      function get_Count: Integer;
      function get_Item(const aIndex: Integer): TProjectSetting;
      function get_ItemByName(const aName: String): TProjectSetting;
    private
      procedure Add(const aDisplayName, aDirective, aOption: String; const aDefault: Integer); overload;
      procedure Add(const aDisplayName, aDirective, aOption: String; const aDefault: Integer; const aValidValues: array of Integer); overload;
      procedure Add(const aDisplayName, aDirective, aOption, aDefault: String); overload;
//      procedure Add(const aDisplayName, aDirective, aOption, aDefault: String; const aValidValues: array of Integer); overload;
//      procedure Add(const aDisplayName, aDirective, aOption, aDefault: String; const aValidValues: array of String); overload;
    public
      constructor Create;
      destructor Destroy; override;
      property Count: Integer read get_Count;
      property Items[const aIndex: Integer]: TProjectSetting read get_Item;
      property ItemByName[const aName: String]: TProjectSetting read get_ItemByName;
    end;


    TProjectSettings = class
    private
      fCompilerSettings: TProjectSettingList;
//      fDelphiVersion: TDelphiVersion;
//      function get_CompilerValue(const aName: String): String;
      function get_Value(const aName: String): String;
//      procedure set_CompilerValue(const aName, Value: String);
      procedure set_Value(const aName, Value: String);

      procedure InitDelphi7Settings;
    public
      constructor Create(const aVersion: TDelphiVersion);
      destructor Destroy; override;
      property CompilerSettings: TProjectSettingList read fCompilerSettings;
      property Setting[const aName: String]: String read get_Value write set_Value;
    end;



  const
    alignPacked     = 'A1';
    alignWord       = 'A2';
    alignDoubleWord = 'A4';
    alignQuadWord   = 'A8';
    alignOff        = alignPacked;
    alignOn         = alignQuadWord;





implementation



{ TProjectSettingList }

  procedure TProjectSettingList.Add(const aDisplayName: String;
                                    const aDirective: String;
                                    const aOption: String;
                                    const aDefault: Integer);
  begin
    fItems.Add(TProjectSetting.Create(aDisplayName, aDirective, aOption, IntToStr(aDefault)));
  end;



  procedure TProjectSettingList.Add(const aDisplayName: String;
                                    const aDirective: String;
                                    const aOption: String;
                                    const aDefault: Integer;
                                    const aValidValues: array of Integer);
  begin
    fItems.Add(TProjectSetting.Create(aDisplayName, aDirective, aOption, IntToStr(aDefault), TValidator.Create(aValidValues)));
  end;



  procedure TProjectSettingList.Add(const aDisplayName: String;
                                    const aDirective: String;
                                    const aOption: String;
                                    const aDefault: String);
  begin
    fItems.Add(TProjectSetting.Create(aDisplayName, aDirective, aOption, aDefault));
  end;



//  procedure TProjectSettingList.Add(const aDisplayName: String;
//                                    const aDirective: String;
//                                    const aOption: String;
//                                    const aDefault: String;
//                                    const aValidValues: array of Integer);
//  begin
//    fItems.Add(TProjectSetting.Create(aDisplayName, aDirective, aOption, aDefault, TValidator.Create(aValidValues)));
//  end;
//
//
//
//  procedure TProjectSettingList.Add(const aDisplayName: String;
//                                    const aDirective: String;
//                                    const aOption: String;
//                                    const aDefault: String;
//                                    const aValidValues: array of String);
//  begin
//    fItems.Add(TProjectSetting.Create(aDisplayName, aDirective, aOption, aDefault, TValidator.Create(aValidValues)));
//  end;




  constructor TProjectSettingList.Create;
  begin
    inherited Create;

    fItems := TObjectList.Create(TRUE);
  end;



  destructor TProjectSettingList.Destroy;
  begin
    fItems.Free;

    inherited;
  end;



  function TProjectSettingList.get_Count: Integer;
  begin
    result := fItems.Count;
  end;



  function TProjectSettingList.get_Item(const aIndex: Integer): TProjectSetting;
  begin
    result := TProjectSetting(fItems[aIndex]);
  end;


  function TProjectSettingList.get_ItemByName(const aName: String): TProjectSetting;
  var
    i: Integer;
  begin
    for i := 0 to Pred(fItems.Count) do
    begin
      result := Items[i];
      if STR.MatchesAny(aName, [result.DisplayName, result.Directive, result.Option]) then
        EXIT;
    end;

    raise Exception.CreateFmt('No setting found with name ''%s''.', [aName]);
  end;




{ TProjectSettings }

  constructor TProjectSettings.Create(const aVersion: TDelphiVersion);
  begin
    inherited Create;

    fCompilerSettings := TProjectSettingList.Create;

    case aVersion of
      dvDelphi7 : InitDelphi7Settings;
    end;
  end;



  destructor TProjectSettings.Destroy;
  begin
    fCompilerSettings.Free;

    inherited;
  end;



//  function TProjectSettings.get_CompilerValue(const aName: String): String;
//  begin
//    result := fCompilerSettings.ItemByName[aName].Value;
//  end;



  function TProjectSettings.get_Value(const aName: String): String;
  begin

  end;



  procedure TProjectSettings.InitDelphi7Settings;
  begin
    fCompilerSettings.Add('Align Fields',                       'ALIGN',            'A', 8, [1, 2, 4, 8]);
    fCompilerSettings.Add('Boolean Short-Circuit Evaluation',   'BOOLEVAL',         'B', 0, [0, 1]);
    fCompilerSettings.Add('Assertions',                         'ASSERTIONS',       'C', 1, [0, 1]);
    fCompilerSettings.Add('Debug Information',                  'DEBUGINFO',        'D', 1, [0, 1]);
//  fCompilerSettings.Add('Executable Extension',               'EXTENSION',        'E', 0, [0, 1]);
//  fCompilerSettings.Add('',                                   '',                 'F', 0, [0, 1]);
    fCompilerSettings.Add('Imported Data',                      'IMPORTEDDATA',     'G', 1, [0, 1]);
    fCompilerSettings.Add('Huge Strings',                       'LONGSTRINGS',      'H', 1, [0, 1]);
    fCompilerSettings.Add('I/O Checking',                       'IOCHECKS',         'I', 1, [0, 1]);
    fCompilerSettings.Add('Assignable Typed Constants',         'WRITABLECONST',    'J', 0, [0, 1]);
//  fCompilerSettings.Add('',                                   '',                 'K', 0, [0, 1]);
    fCompilerSettings.Add('Local Symbols',                      'LOCALSYMBOLS',     'L', 1, [0, 1]);
    fCompilerSettings.Add('Memory Allocation Sizes',            '',                 'M', '16384, 1048576');
//  fCompilerSettings.Add('',                                   '',                 'N', 0, [0, 1]);
    fCompilerSettings.Add('Optimization',                       'OPTIMIZATION',     'O', 1 ,[0, 1]);
    fCompilerSettings.Add('Open Parameters',                    'OPENSTRINGS',      'P', 1 ,[0, 1]);
    fCompilerSettings.Add('Overflow Checking',                  'OVERFLOWCHECKS',   'Q', 0, [0, 1]);
    fCompilerSettings.Add('Range Checking',                     'RANGECHECKS',      'R', 0, [0, 1]);
//  fCompilerSettings.Add('',                                   '',                 'S', 0, [0, 1]);
    fCompilerSettings.Add('Typed @ Operator',                   'TYPEDADDRESS',     'T', 0, [0, 1]);
    fCompilerSettings.Add('Pentium-safe FDIV',                  'SAFEDIVIDE',       'U', 0, [0, 1]);
    fCompilerSettings.Add('Strict var-Strings',                 'VARSTRINGCHECKS',  'V', 1, [0, 1]);
    fCompilerSettings.Add('Stack Frames',                       '' ,                'W', 0 ,[0, 1]);
    fCompilerSettings.Add('Extended Syntax',                    'EXTENDEDSYNTAX',   'X', 1, [0, 1]);
    fCompilerSettings.Add('Symbol Declaration and References',  'SYMBOLINFO',       'Y', 1, [0, 1, 2]);
    fCompilerSettings.Add('Minimum Enum Size',                  'MINENUMSIZE',      'Z', 1, [1, 2, 4]);

//    fCompilerSettings.Add('Minimum Stack Size',    'MINSTACKSIZE',   '',  '16384';
//    fCompilerSettings.Add('Maximum Stack Size',    'MAXSTACKSIZE',   ''   '1048576');
  end;


//  procedure TProjectSettings.set_CompilerValue(const aName, Value: String);
//  begin
//
//  end;



  procedure TProjectSettings.set_Value(const aName, Value: String);
  begin

  end;




{ TProjectSetting }

  constructor TProjectSetting.Create(const aDisplayName: String;
                                     const aDirective: String;
                                     const aOption: String;
                                     const aDefault: String;
                                     const aValidator: TValidator);
  begin
    inherited Create;

    fDisplayName  := aDisplayName;
    fDirective    := aDirective;
    fOption       := aOption;
    fDefaultValue := aDefault;
    fValidator    := fValidator;
  end;


  destructor TProjectSetting.Destroy;
  begin
    fValidator.Free;

    inherited;
  end;


  procedure TProjectSetting.set_Value(const aValue: String);
  begin
    if NOT Assigned(fValidator) or fValidator.IsValid(aValue) then
      fValue := aValue;

    raise Exception.CreateFmt('''%s'' is not valid', [aValue]);
  end;



{ TValidator }

  constructor TValidator.Create(const aValues: array of Integer);
  var
    i: Integer;
    strings: array of String;
  begin
    SetLength(strings, Length(aValues));

    for i := 0 to High(aValues) do
      strings[i] := IntToStr(aValues[i]);

    Create(strings);
  end;



  constructor TValidator.Create(const aValues: array of String);
  var
    i: Integer;
  begin
    inherited Create;

    SetLength(fStrings, Length(aValues));

    for i := 0 to High(aValues) do
      fStrings[i] := aValues[i];
  end;



  function TValidator.IsValid(const aValue: String): Boolean;
  begin
    result := STR.MatchesAny(aValue, fStrings, csIgnoreCase);
  end;




end.
