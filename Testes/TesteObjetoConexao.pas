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
    procedure TestaEArgumentNilExceptionUsuarioVazio;

    [ Test ]
    procedure TestaEArgumentNilExceptionNomeBancoVazio;

    [ Test ]
    procedure TestaEArgumentNilExceptionSenhaUsuarioVazia;
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
  MECANISMO = mcMySQL;

procedure TTestObjetoConexao.SetUp;
begin
  rInformacoesBanco.Usuario := USUARIO;
  rInformacoesBanco.NomeBancoDados := BANCO;
  rInformacoesBanco.Senha := SENHA;
end;

procedure TTestObjetoConexao.TearDown;
begin
  objConexao := nil;
end;

procedure TTestObjetoConexao.TestaEArgumentNilExceptionNomeBancoVazio;
begin
  rInformacoesBanco.NomeBancoDados := '';
  rInformacoesBanco.MecanismoBanco := MECANISMO;
  Assert.WillRaise(
    procedure
    begin
      objConexao := ConexaoBanco.Create( rInformacoesBanco );
    end
    ,
    EArgumentNilException,
    'Quando não houver nome do banco informado é esperada uma exceção EArgumentNilException' );
end;

procedure TTestObjetoConexao.TestaEArgumentNilExceptionSenhaUsuarioVazia;
begin
  rInformacoesBanco.Senha := '';
  rInformacoesBanco.MecanismoBanco := MECANISMO;
  Assert.WillRaise(
    procedure
    begin
      objConexao := ConexaoBanco.Create( rInformacoesBanco );
    end
    ,
    EArgumentNilException,
    'Quando não houver senha informada é esperada uma exceção EArgumentNilException' );
end;

procedure TTestObjetoConexao.TestaEArgumentNilExceptionUsuarioVazio;
begin
  rInformacoesBanco.Usuario := '';
  rInformacoesBanco.MecanismoBanco := MECANISMO;
  Assert.WillRaise(
    procedure
    begin
      objConexao := ConexaoBanco.Create( rInformacoesBanco );
    end
    ,
    EArgumentNilException,
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
