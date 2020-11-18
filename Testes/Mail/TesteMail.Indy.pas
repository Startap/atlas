unit TesteMail.Indy;

interface

uses
  DUnitX.TestFramework,
  DUnitX.Assert.Ex;

type

  [ TestFixture ]
  TTestSQLBuilderSelect = class( TObject )
    public

      [ Test ]
      procedure sendEmail;

  end;

implementation

uses
  MailBase,
  Mail.Indy;

{ TTestSQLBuilderSelect }

procedure TTestSQLBuilderSelect.sendEmail;
begin
  TMailIndy.New
    .Host('')
    .Port(0)
    .Username('')
    .Password('')
    .From('name', 'email')
    .ToRecipient('')
    .CcRecipient('')
    .BccRecipient('')
    .Attachment('')
    .Subject('')
    .Message('')
    .Send;
end;

end.
