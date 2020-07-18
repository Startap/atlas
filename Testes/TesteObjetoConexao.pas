unit TesteObjetoConexao;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Conexao;

type

  [ TestFixture ]
  TTestObjetoConexao = class( TObject )
  public
    [ SetUp ]
    procedure SetUp;

    [ TearDown ]
    procedure TearDown;

    [ Test ]
    procedure TestaObjetoCriado;
    [ Test ]
    procedure TestaExcecaoUsuarioVazio;
    [ Test ]
    procedure TestaExcecaoNomeBancoVazio;
    [ Test ]
    procedure TestaExcecaoSenhaVazia;
    [ Test ]
    procedure TestaExcecaoIpVazio;

    // procedure TestaGetConexaoMySql;

    // procedure TestaGetConexaoMySql;
  end;

implementation

{ TTestObjetoConexao }

var
  rInformacoesBanco: RInformacoesConexao;
  objConexao: ConexaoBanco;

const
  USUARIO   = 'UsuárioBancoDados';
  SENHA     = 'SenhaBancoDados';
  BANCO     = 'Database';
  IP        = '127.0.0.1';
  MECANISMO = mcMySQL;

procedure TTestObjetoConexao.SetUp;
begin
  rInformacoesBanco.Usuario := USUARIO;
  rInformacoesBanco.NomeBancoDados := BANCO;
  rInformacoesBanco.Senha := SENHA;
  rInformacoesBanco.IPServidor := IP;
end;

procedure TTestObjetoConexao.TearDown;
begin
  objConexao := nil;
end;

procedure TTestObjetoConexao.TestaExcecaoIpVazio;
begin
  rInformacoesBanco.IPServidor := '';
  rInformacoesBanco.MecanismoBanco := MECANISMO;
  Assert.WillRaiseWithMessage(
    procedure
    begin
      objConexao := ConexaoBanco.Create( rInformacoesBanco );
    end
    ,
    EArgumentNilException,
    'Nenhum endereço de servidor para conexão foi informado',
    'Quando não houver endereço de servidor informado é esperada uma exceção EArgumentNilException' );
end;

procedure TTestObjetoConexao.TestaExcecaoNomeBancoVazio;
begin
  rInformacoesBanco.NomeBancoDados := '';
  rInformacoesBanco.MecanismoBanco := MECANISMO;
  Assert.WillRaiseWithMessage(
    procedure
    begin
      objConexao := ConexaoBanco.Create( rInformacoesBanco );
    end
    ,
    EArgumentNilException,
    'Nenhum banco de dados para conexão foi informado',
    'Quando não houver nome do banco informado é esperada uma exceção EArgumentNilException' );
end;

procedure TTestObjetoConexao.TestaExcecaoSenhaVazia;
begin
  rInformacoesBanco.Senha := '';
  rInformacoesBanco.MecanismoBanco := MECANISMO;
  Assert.WillRaiseWithMessage(
    procedure
    begin
      objConexao := ConexaoBanco.Create( rInformacoesBanco );
    end
    ,
    EArgumentNilException,
    'Nenhuma senha para conexão foi informado',
    'Quando não houver senha informada é esperada uma exceção EArgumentNilException' );
end;

procedure TTestObjetoConexao.TestaExcecaoUsuarioVazio;
begin
  rInformacoesBanco.Usuario := '';
  rInformacoesBanco.MecanismoBanco := MECANISMO;
  Assert.WillRaiseWithMessage(
    procedure
    begin
      objConexao := ConexaoBanco.Create( rInformacoesBanco );
    end
    ,
    EArgumentNilException,
    'Nenhum usuário para conexão foi informado',
    'Quando não houver usuário informado é esperada uma exceção EArgumentNilException' );
end;

procedure TTestObjetoConexao.TestaObjetoCriado;
begin
  rInformacoesBanco.MecanismoBanco := MECANISMO;

  Assert.WillNotRaise(
    procedure
    begin
      objConexao := ConexaoBanco.Create( rInformacoesBanco );
    end
    ,
    Exception,
    'É esperado que a criação de um objeto não retorne exceções' );

  Assert.InheritsFrom(
    objConexao.ClassType,
    ConexaoBanco );
end;

initialization

TDUnitX.RegisterTestFixture( TTestObjetoConexao );

end.
