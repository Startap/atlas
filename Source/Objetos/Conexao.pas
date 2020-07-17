unit Conexao;

interface

type
  TMecanismoConexao = ( mcSQLServer, mcPostgreSQL, mcMySQL, mcSQLite );

type
  RInformacoesConexao = record
    Usuario: string;
    Senha: string;
    NomeBancoDados: string;
    MecanismoBanco: TMecanismoConexao;
  end;

type
  ConexaoBanco = class( TObject )
    /// <summary>
    /// Cria o objeto com as informações de conexão estabelecidas
    /// </summary>
    /// <param name="AInformacoesConexao">
    /// Um record do tipo <c>RInformacoesConexao</c> alimentado
    /// com todas as variáveis necessárias
    /// </param>
    /// <remarks>
    /// Se o parâmetro for nulo a função retorna uma <c>EArgumentNilException</c>
    /// Se algum field do AInformacoesConexao for inválido deve retornar
    /// uma <c>EArgumentException</c> com mensagem do parâmetro vazio
    /// </remarks>
    constructor Create( AInformacoesConexao: RInformacoesConexao );
  private
    /// <summary>
    /// Retorna o driver utilizado para conectar no banco
    /// </summary>
    /// <param name="AMecanismo">
    /// Um mecanismo do tipo TMecanismoConexao para identificar o SGDB
    /// </param>
    /// <remarks>
    /// Se o parâmetro <c>AMecanismo</c> for inválido a função
    /// vai retornar um <c>EArgumentException</c>
    /// </remarks>
    /// <returns>
    /// Uma string com o nome da biblioteca de conexão ao banco
    /// </returns>
    function fnGetDriverConexao( AMecanismo: TMecanismoConexao ): string;
  end;

implementation

uses System.SysUtils;

{ ConexaoBanco }

constructor ConexaoBanco.Create( AInformacoesConexao: RInformacoesConexao );
begin
  // Atribuir as informações de conexão

end;

function ConexaoBanco.fnGetDriverConexao( AMecanismo
  : TMecanismoConexao ): string;
var
  sNomeDriver: string;
begin
  case AMecanismo of
    mcSQLServer:
      sNomeDriver := '';
    mcPostgreSQL:
      sNomeDriver := '';
    mcMySQL:
      sNomeDriver := '';
    mcSQLite:
      sNomeDriver := '';
  end;

  Result := sNomeDriver;
end;

initialization

end.
