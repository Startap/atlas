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
      FToRecipients: TStringList;
      FCcRecipients: TStringList;
      FBccRecipients: TStringList;
      FConfirmation: Boolean;
      FAttachments: TStringList;
      FSubject: string;
      FMessages: TStringList;
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
      function GetToRecipients: TStringList;
      function GetCcRecipients: TStringList;
      function GetBccRecipients: TStringList;
      function IsWithConfirmation: Boolean;
      function GetAttachments: TStringList;
      function GetSubject: string;
      function GetMessages: TStringList;
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
      function &Message(const AValues: TStringList): IMail; overload;
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
  FAttachments.Add(AFileName);
  Result := Self;
end;

function TMailBase.AuthenticationRequired(const AValue: Boolean): IMail;
begin
  FAuthentication := AValue;
  Result := Self;
end;

function TMailBase.BccRecipient(const AAddress: string): IMail;
begin
  FBccRecipients.Add(AAddress);
  Result := Self;
end;

function TMailBase.CcRecipient(const AAddress: string): IMail;
begin
  FCcRecipients.Add(AAddress);
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
  FToRecipients := TStringList.Create;
  FCcRecipients := TStringList.Create;
  FBccRecipients := TStringList.Create;
  FConfirmation := False;
  FAttachments := TStringList.Create;
  FSubject := EmptyStr;
  FMessages := TStringList.Create;
  FHTML := False;
end;

destructor TMailBase.Destroy;
begin
  FreeAndNil(FToRecipients);
  FreeAndNil(FCcRecipients);
  FreeAndNil(FBccRecipients);
  FreeAndNil(FAttachments);
  FreeAndNil(FMessages);
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
  Result := FAttachments;
end;

function TMailBase.GetBccRecipients: TStringList;
begin
  Result := FBccRecipients;
end;

function TMailBase.GetCcRecipients: TStringList;
begin
  Result := FCcRecipients;
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

function TMailBase.GetMessages: TStringList;
begin
  Result := FMessages;
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

function TMailBase.GetToRecipients: TStringList;
begin
  Result := FToRecipients;
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
  FMessages.Add(AValue);
  Result := Self;
end;

function TMailBase.Message(const AValues: TStringList): IMail;
begin
  FMessages.Text := AValues.Text;
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
  FToRecipients.Add(AAddress);
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
