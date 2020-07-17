unit TesteObjetoConexao;

interface

uses
  DUnitX.TestFramework;

type

  [ TestFixture ]
  TTesteObjetoConexao = class( TObject )
  public
    [ Test ]
    procedure TestaObjetoCriado;

    [ Test ]
    procedure TestaEArgumentNilExceptionAoCriarObjeto;

    [ Test ]
    [ TestCase( 'TestaUsuarioConexaoVazio', 'FUsuarioConexao' ) ]
    [ TestCase( 'TestaNomeBancoDadosVazio', 'FNomeBancoDados' ) ]
    [ TestCase( 'TestaSenhaUsuarioVazio', 'FSenhaConexao' ) ]
    [ TestCase( 'TestaMecanismoBancoDadosInvalidoOuVazio', 'FMecanismoBanco' ) ]
    procedure TestaEArgumentExceptionAoCriarObjeto;
  end;

implementation

uses Conexao;

procedure TTesteObjetoConexao.TestaEArgumentExceptionAoCriarObjeto;
begin

end;

procedure TTesteObjetoConexao.TestaEArgumentNilExceptionAoCriarObjeto;
begin

end;

procedure TTesteObjetoConexao.TestaObjetoCriado;
begin

end;

initialization

TDUnitX.RegisterTestFixture( TTesteObjetoConexao );

end.
