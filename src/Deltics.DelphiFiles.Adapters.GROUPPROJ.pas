
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles.Adapters.GROUPPROJ;


interface

  uses
    Deltics.StringLists,
    Deltics.DelphiFiles.Adapters.ProjectGroupAdapter;


  type
    GROUPPROJ = class(TXmlProjectGroupAdapter)
    protected
      procedure DoGetProjectFilenames(const aList: IStringList); override;
      procedure DoGetProjectSourceFilenames(const aList: IStringList); override;
    end;


implementation

  uses
    Deltics.Strings,
    Deltics.Xml;



{ GROUPPROJ -------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure GROUPPROJ.DoGetProjectFilenames(const aList: IStringList);
  var
    i: Integer;
    itemGroupXml: IXmlElement;
    element: IXmlElement;
    value: Utf8String;
  begin
    itemGroupXml := Settings.SelectNode('/Project/ItemGroup') as IXmlElement;

    for i := 0 to Pred(itemGroupXml.Nodes.Count) do
    begin
      element := itemGroupXml.Nodes[i].AsElement;
      if element.HasAttribute('Include', value) then
        aList.Add(Str.FromUTF8(value));
    end;
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure GROUPPROJ.DoGetProjectSourceFilenames(const aList: IStringList);
  var
    i: Integer;
    itemGroupXml: IXmlElement;
    element: IXmlElement;
    value: Utf8String;
  begin
    itemGroupXml := Settings.SelectNode('/Project/ItemGroup') as IXmlElement;

    for i := 0 to Pred(itemGroupXml.Nodes.Count) do
    begin
      element := itemGroupXml.Nodes[i].AsElement;
      if element.HasAttribute('Include', value) then
        aList.Add(STR.FromUTF8(value));
    end;
  end;




end.
