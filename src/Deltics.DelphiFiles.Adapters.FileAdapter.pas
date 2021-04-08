
{$i deltics.delphifiles.inc}

  unit Deltics.DelphiFiles.Adapters.FileAdapter;


interface

  uses
    Deltics.InterfacedObjects;


  type
    TFileAdapter = class(TComInterfacedObject)
    protected // IXmlFileAdapter
      function get_Filename: String;
    private
      fFilename: String;
      fHasChanges: Boolean;
      fOpenCount: Integer;
      procedure set_HasChanges(const aValue: Boolean);
    protected
      procedure CloseFile(const aSaveChanges: Boolean = FALSE);
      procedure DoClose; virtual;
      procedure DoOpen; virtual;
      procedure DoSave; virtual;
      procedure OpenFile;
      procedure SaveChanges;
    public
      constructor Create(const aFilename: String);
      procedure BeforeDestruction; override;
      property Filename: String read fFilename;
      property HasChanges: Boolean read fHasChanges write set_HasChanges;
    end;


implementation



{ TFileAdapter }

  constructor TFileAdapter.Create(const aFilename: String);
  begin
    inherited Create;

    fFilename := aFilename;
  end;


  procedure TFileAdapter.BeforeDestruction;
  begin
    inherited;

    CloseFile(TRUE);
  end;


  procedure TFileAdapter.set_HasChanges(const aValue: Boolean);
  begin
    fHasChanges := fHasChanges or aValue;
  end;


  procedure TFileAdapter.CloseFile;
  begin
    Dec(fOpenCount);

    if fOpenCount > 0 then
      EXIT;

    if fHasChanges then
      SaveChanges;

    DoClose;
  end;


  procedure TFileAdapter.DoClose;
  begin
    // NO-OP
  end;


  procedure TFileAdapter.DoOpen;
  begin
    // NO-OP
  end;


  procedure TFileAdapter.DoSave;
  begin
    // NO-OP
  end;


  function TFileAdapter.get_Filename: String;
  begin
    result := fFilename;
  end;


  procedure TFileAdapter.OpenFile;
  begin
    Inc(fOpenCount);

    if fOpenCount = 1 then
      DoOpen;
  end;


  procedure TFileAdapter.SaveChanges;
  begin
    DoSave;
    fHasChanges := FALSE;
  end;




end.

