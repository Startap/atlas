unit MailInterface;

interface

uses
  System.Classes,
  System.SysUtils;

type
  EMailException = class(Exception);

  IMail = interface
    ['{07C2551B-B2A6-47C6-9454-A2AE5BE884DB}']

    function Host(const AValue: string): IMail;
    function Port(const AValue: Integer): IMail;
    function Username(const AValue: string): IMail;
    function Password(const AValue: string): IMail;
    function UsingSSL(const AValue: Boolean = True): IMail;
    function UsingTLS(const AValue: Boolean = True): IMail;
    function AuthenticationRequired(const AValue: Boolean = True): IMail;

    function From(const AName: string; const AAddress: string): IMail;
    function ReplyTo(const AName: string; const AAddress: string): IMail;
    function ToRecipient(const AAddress: string): IMail;
    function CcRecipient(const AAddress: string): IMail;
    function BccRecipient(const AAddress: string): IMail;
    function AskForConfirmation(const AValue: Boolean = True): IMail;

    function Attachment(const AFileName: string): IMail;

    function Subject(const AValue: string): IMail;
    function &Message(const AValue: string): IMail; overload;
    function &Message(const AValue: TStringList): IMail; overload;
    function UsingHTML(const AValue: Boolean = True): IMail;

    procedure Send;
  end;

implementation

end.
