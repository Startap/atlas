unit MailBase;

interface

uses
  System.SysUtils,
  System.Classes,
  MailInterface;

type
  TMailBase = class abstract(TInterfacedObject, IMail)
    private
      FHost: string;
      FPort: Integer;
      FUsername: string;
      FPassword: string;
      FSSL: Boolean;
      FTLS: Boolean;
      FAuthentication: Boolean;
      FFromName: string;
      FFromAddress: string;
      FReplyToName: string;
      FReplyToAddress: string;
      FToRecipient: TStringList;
      FCcRecipient: TStringList;
      FBccRecipient: TStringList;
      FConfirmation: Boolean;
      FAttachment: TStringList;
      FSubject: string;
      FMessage: TStringList;
      FHTML: Boolean;
    protected
      function GetHost: string;
      function GetPort: Integer;
      function GetUsername: string;
      function GetPassword: string;
      function IsWithSSL: Boolean;
      function IsWithTLS: Boolean;
      function IsWithAuthentication: Boolean;
      function GetFromName: string;
      function GetFromAddress: string;
      function GetReplyToName: string;
      function GetReplyToAddress: string;
      function GetToRecipient: TStringList;
      function GetCcRecipient: TStringList;
      function GetBccRecipient: TStringList;
      function IsWithConfirmation: Boolean;
      function GetAttachments: TStringList;
      function GetSubject: string;
      function GetMessage: TStringList;
      function IsWithHTML: Boolean;

      procedure DoSend; virtual; abstract;

    public
      constructor Create;
      destructor Destroy; override;

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

{ TMailBase }

function TMailBase.AskForConfirmation(const AValue: Boolean): IMail;
begin
  FConfirmation := AValue;
  Result := Self;
end;

function TMailBase.Attachment(const AFileName: string): IMail;
begin
  FAttachment.Add(AFileName);
  Result := Self;
end;

function TMailBase.AuthenticationRequired(const AValue: Boolean): IMail;
begin
  FAuthentication := AValue;
  Result := Self;
end;

function TMailBase.BccRecipient(const AAddress: string): IMail;
begin
  FBccRecipient.Add(AAddress);
  Result := Self;
end;

function TMailBase.CcRecipient(const AAddress: string): IMail;
begin
  FCcRecipient.Add(AAddress);
  Result := Self;
end;

constructor TMailBase.Create;
begin
  inherited Create;
  FHost := EmptyStr;
  FPort := 0;
  FUsername := EmptyStr;
  FPassword := EmptyStr;
  FSSL := False;
  FTLS := False;
  FAuthentication := False;
  FFromName := EmptyStr;
  FFromAddress := EmptyStr;
  FToRecipient := TStringList.Create;
  FCcRecipient := TStringList.Create;
  FBccRecipient := TStringList.Create;
  FConfirmation := False;
  FAttachment := TStringList.Create;
  FSubject := EmptyStr;
  FMessage := TStringList.Create;
  FHTML := False;
end;

destructor TMailBase.Destroy;
begin
  FreeAndNil(FToRecipient);
  FreeAndNil(FCcRecipient);
  FreeAndNil(FBccRecipient);
  FreeAndNil(FAttachment);
  FreeAndNil(FMessage);
  inherited Destroy;
end;

function TMailBase.From(const AName, AAddress: string): IMail;
begin
  FFromName := AName;
  FFromAddress := AAddress;
  Result := Self;
end;

function TMailBase.GetAttachments: TStringList;
begin
  Result := FAttachment;
end;

function TMailBase.GetBccRecipient: TStringList;
begin
  Result := FBccRecipient;
end;

function TMailBase.GetCcRecipient: TStringList;
begin
  Result := FCcRecipient;
end;

function TMailBase.GetFromAddress: string;
begin
  Result := FFromAddress;
end;

function TMailBase.GetFromName: string;
begin
  Result := FFromName;
end;

function TMailBase.GetHost: string;
begin
  Result := FHost;
end;

function TMailBase.GetMessage: TStringList;
begin
  Result := FMessage;
end;

function TMailBase.GetPassword: string;
begin
  Result := FPassword;
end;

function TMailBase.GetPort: Integer;
begin
  Result := FPort;
end;

function TMailBase.GetReplyToAddress: string;
begin
  Result := FReplyToAddress;
  if Result.Trim.IsEmpty then
  begin
    Result := FFromAddress;
  end;
end;

function TMailBase.GetReplyToName: string;
begin
  Result := FReplyToName;
  if Result.Trim.IsEmpty then
  begin
    Result := FFromName;
  end;
end;

function TMailBase.GetSubject: string;
begin
  Result := FSubject;
end;

function TMailBase.GetToRecipient: TStringList;
begin
  Result := FToRecipient;
end;

function TMailBase.GetUsername: string;
begin
  Result := FUsername;
end;

function TMailBase.Host(const AValue: string): IMail;
begin
  FHost := AValue;
  Result := Self;
end;

function TMailBase.IsWithAuthentication: Boolean;
begin
  Result := FAuthentication;
end;

function TMailBase.IsWithConfirmation: Boolean;
begin
  Result := FConfirmation;
end;

function TMailBase.IsWithHTML: Boolean;
begin
  Result := FHTML;
end;

function TMailBase.IsWithSSL: Boolean;
begin
  Result := FSSL;
end;

function TMailBase.IsWithTLS: Boolean;
begin
  Result := FTLS;
end;

function TMailBase.Message(const AValue: string): IMail;
begin
  FMessage.Add(AValue);
  Result := Self;
end;

function TMailBase.Message(const AValue: TStringList): IMail;
begin
  FMessage.Text := AValue.Text;
  Result := Self;
end;

function TMailBase.Password(const AValue: string): IMail;
begin
  FPassword := AValue;
  Result := Self;
end;

function TMailBase.Port(const AValue: Integer): IMail;
begin
  FPort := AValue;
  Result := Self;
end;

function TMailBase.ReplyTo(const AName, AAddress: string): IMail;
begin
  FReplyToName := AName;
  FReplyToAddress := AAddress;
  Result := Self;
end;

procedure TMailBase.Send;
begin
  DoSend;
end;

function TMailBase.Subject(const AValue: string): IMail;
begin
  FSubject := AValue;
  Result := Self;
end;

function TMailBase.ToRecipient(const AAddress: string): IMail;
begin
  FToRecipient.Add(AAddress);
  Result := Self;
end;

function TMailBase.Username(const AValue: string): IMail;
begin
  FUsername := AValue;
  Result := Self;
end;

function TMailBase.UsingHTML(const AValue: Boolean): IMail;
begin
  FHTML := AValue;
  Result := Self;
end;

function TMailBase.UsingSSL(const AValue: Boolean): IMail;
begin
  FSSL := AValue;
  Result := Self;
end;

function TMailBase.UsingTLS(const AValue: Boolean): IMail;
begin
  FTLS := AValue;
  Result := Self;
end;

end.
