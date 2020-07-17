unit TesteObjetoConexao;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Conexao;

type

  [ TestFixture ]
  TTesteObjetoConexao = class( TObject )
  public
    [ SetUp ]
    procedure SetUp;

    [ TearDown ]
    procedure TearDown;

    [ Test ]
    procedure TestaObjetoCriado;

    [ Test ]
    procedure TestaEArgumentNilExceptionAoCriarObjeto;

    [ Test ]
    procedure TestaEArgumentNilExceptionUsuarioVazio;

    [ Test ]
    procedure TestaEArgumentNilExceptionNomeBancoVazio;

    [ Test ]
    procedure TestaEArgumentNilExceptionSenhaUsuarioVazia;

    [ Test ]
    procedure TestaEArgumentNilExceptionMecanismoIncorreto;

    [ Test ]
    [ TestCase( 'SQL Server', 'TMecanismoConexao.mcSQLServer, dbx.dll' ) ]
    [ TestCase( 'SQL Server', 'TMecanismoConexao.mcPostgreSQL, dbx.dll' ) ]
    [ TestCase( 'SQL Server', 'TMecanismoConexao.mcMySQL, dbx.dll' ) ]
    [ TestCase( 'SQL Server', 'TMecanismoConexao.mcSQLite, dbx.dll' ) ]
    procedure TestaMapeamentoDeDriversDoBancoDeDados
      ( AMecanismo: TMecanismoConexao; AEsperado: string );
  end;

implementation

{ TTesteObjetoConexao }

var
  rInformacoesBanco: RInformacoesConexao;

procedure TTesteObjetoConexao.SetUp;
begin
  rInformacoesBanco.Usuario := '';
  rInformacoesBanco.Senha := '';
  rInformacoesBanco.NomeBancoDados := '';
end;

procedure TTesteObjetoConexao.TearDown;
begin
  FreeAndNil( rInformacoesBanco );
end;

procedure TTesteObjetoConexao.TestaEArgumentNilExceptionAoCriarObjeto;
begin
  Assert.NotImplemented;
end;

procedure TTesteObjetoConexao.TestaEArgumentNilExceptionMecanismoIncorreto;
begin
  Assert.NotImplemented;
end;

procedure TTesteObjetoConexao.TestaEArgumentNilExceptionNomeBancoVazio;
begin
  Assert.NotImplemented;
end;

procedure TTesteObjetoConexao.TestaEArgumentNilExceptionSenhaUsuarioVazia;
begin
  Assert.NotImplemented;
end;

procedure TTesteObjetoConexao.TestaEArgumentNilExceptionUsuarioVazio;
begin
  Assert.NotImplemented;
end;

procedure TTesteObjetoConexao.TestaMapeamentoDeDriversDoBancoDeDados(AMecanismo: TMecanismoConexao;
  AEsperado: string);
begin
  Assert.NotImplemented;
end;

procedure TTesteObjetoConexao.TestaObjetoCriado;
begin
  Assert.NotImplemented;
end;

initialization

TDUnitX.RegisterTestFixture( TTesteObjetoConexao );

end.
