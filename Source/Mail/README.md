# E-mail para Delphi

Framework de mailing voltada para simplificar o envio de e-mails com Delphi.
Inclui envio de e-mails com texto simples e/ou HTML, imagens incorporadas e anexos separados.
Utiliza: SMTP ou SMTPS/SSL ou SMTP + SSL.
O **Mail** fornece uma estrutura independente de driver, sendo possível extendê-lo para outros, como **Outlook**, **MAPI**, **Synapse** entre outros. 

A estrutura da mensagem de e-mail foi construída para funcionar com todos os clientes de e-mail e foi testada com muitos clientes da web, bem como alguns aplicativos de cliente convencionais, como MS Outlook ou Mozilla Thunderbird.

# Drivers implementados
- Indy

# Modo de usar
Adicione no library path do Delphi:

> Source\Mail

# Exemplo de uso

```
uses
  MailBase,
  Mail.Indy;

procedure EnviaEmail;
begin
  TMailIndy.New
    .Host('smtp.exemplo.com.br')
    .Port(123)
    .Username('usuario')
    .Password('senha_forte_do_usuario')
    .From('Princess Leia', 'princess.leia@jabba.the.hutt.com')
    .ToRecipient('darth.vader@darkforce.com')
    .CcRecipient('mestre.yoda@jedi.com')
    .BccRecipient('obi.wan.kenoby@jedi.com')
    .Attachment('C:\jabba.the.hutt.kill.luke.skywalker.jpg')
    .Subject('Veja só, Jabba The Hutt mata Luke Skywalker')
    .Message('Caro Darth Vader, veja como ele ficou nessa imagem... hahahaha')
    .Send;  
end
```