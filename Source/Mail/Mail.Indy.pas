unit Mail.Indy;

interface

uses
  System.SysUtils,
  IdSMTP,
  IdMessage,
  IdSSLOpenSSL,
  IdExplicitTLSClientServerBase,
  IdText,
  IdAttachmentFile,
  MailInterface,
  MailBase;

type
  EMailIndyException = class(EMailException);

  TMailIndy = class(TMailBase, IMail)
    private const
      CONNECT_TIMEOUT = 10000;
      READ_TIMEOUT = 10000;
    private
      procedure ConfigureSmtp(const ASmtp: TIdSMTP);
      procedure AddToRecipients(const AMsg: TIdMessage);
      procedure AddCcRecipients(const AMsg: TIdMessage);
      procedure AddBccRecipients(const AMsg: TIdMessage);
      procedure AddFrom(const AMsg: TIdMessage);
      procedure AddReplyTo(const AMsg: TIdMessage);
      procedure AddAttachments(const AMsg: TIdMessage);
      procedure AddBody(const AMsg: TIdMessage);
    protected
      procedure DoSend; override;
    public
      class function New: IMail; static;
  end;

implementation

{ TMailIndy }

procedure TMailIndy.AddAttachments(const AMsg: TIdMessage);
var
  i: Integer;
  attachment: TIdAttachmentFile;
begin
  for i := 0 to Pred(GetAttachments.Count) do
  begin
    attachment := TIdAttachmentFile.Create(AMsg.MessageParts, GetAttachments[i]);
    attachment.Headers.Add(Format('Content-ID: <%s>', [ExtractFileName(GetAttachments[i])]));
  end;
end;

procedure TMailIndy.AddBccRecipients(const AMsg: TIdMessage);
var
  i: Integer;
begin
  for i := 0 to Pred(GetBccRecipients.Count) do
  begin
    with AMsg.BccList.Add do
    begin
      Address := GetBccRecipients[i];
    end;
  end;
end;

procedure TMailIndy.AddBody(const AMsg: TIdMessage);
var
  body: TIdText;
begin
  body := TIdText.Create(AMsg.MessageParts);
  body.Body.Text := GetMessages.Text;
  body.ContentType := 'text/plain';
  if IsWithHTML then
  begin
    body.ContentType := 'text/html';
  end;
end;

procedure TMailIndy.AddCcRecipients(const AMsg: TIdMessage);
var
  i: Integer;
begin
  for i := 0 to Pred(GetCcRecipients.Count) do
  begin
    with AMsg.CCList.Add do
    begin
      Address := GetCcRecipients[i];
    end;
  end;
end;

procedure TMailIndy.AddFrom(const AMsg: TIdMessage);
begin
  AMsg.From.Address := GetFromAddress;
  AMsg.From.Name := GetFromName;
  if IsWithConfirmation then
  begin
    AMsg.ReceiptRecipient.Address := GetFromAddress;
    AMsg.ReceiptRecipient.Name := GetFromName;
  end;
end;

procedure TMailIndy.AddReplyTo(const AMsg: TIdMessage);
begin
  with AMsg.ReplyTo.Add do
  begin
    Address := GetReplyToAddress;
    Name := GetReplyToName;
  end;
end;

procedure TMailIndy.AddToRecipients(const AMsg: TIdMessage);
var
  i: Integer;
begin
  for i := 0 to Pred(GetToRecipients.Count) do
  begin
    with AMsg.Recipients.Add do
    begin
      Address := GetToRecipients[i];
    end;
  end;
end;

procedure TMailIndy.ConfigureSmtp(const ASmtp: TIdSMTP);
begin
  ASmtp.ConnectTimeout := CONNECT_TIMEOUT;
  ASmtp.ReadTimeout := READ_TIMEOUT;
  ASmtp.Host := GetHost;
  ASmtp.Username := GetUsername;
  ASmtp.Password := GetPassword;
  ASmtp.Port := GetPort;
  ASmtp.AuthType := satNone;
  if IsWithAuthentication then
  begin
    ASmtp.AuthType := satDefault;
  end;
  if IsWithSSL then
  begin
    ASmtp.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(ASmtp);
    TIdSSLIOHandlerSocketOpenSSL(ASmtp.IOHandler).SSLOptions.Method := sslvSSLv23;
    TIdSSLIOHandlerSocketOpenSSL(ASmtp.IOHandler).SSLOptions.Mode := sslmClient;
    ASmtp.UseTLS := utUseExplicitTLS;
  end;
  if IsWithTLS then
  begin
    ASmtp.UseTLS := utUseRequireTLS;
  end;
end;

procedure TMailIndy.DoSend;
var
  smtp: TIdSMTP;
  msg: TIdMessage;
begin
  inherited;
  smtp := TIdSMTP.Create(nil);
  try
    try
      ConfigureSmtp(smtp);
      msg := TIdMessage.Create(nil);
      try
        msg.Date := Now;
        msg.Subject := GetSubject;
        msg.ContentType := 'multipart/mixed';

        AddToRecipients(msg);
        AddCcRecipients(msg);
        AddBccRecipients(msg);
        AddFrom(msg);
        AddReplyTo(msg);
        AddAttachments(msg);
        AddBody(msg);

        smtp.Connect;
        try
          if IsWithAuthentication then
          begin
            smtp.Authenticate;
          end;
          smtp.Send(msg);
        finally
          smtp.Disconnect;
        end;
      finally
        FreeAndNil(msg);
      end;
    except
      on E: Exception do
      begin
        raise EMailIndyException.Create('E-mail could not be sent!' + ^M + E.Message);
      end;
    end;
  finally
    FreeAndNil(smtp);
  end;
end;

class function TMailIndy.New: IMail;
begin
  Result := TMailIndy.Create;
end;

end.
