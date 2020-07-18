unit Conexao;

interface

uses FireDAC.Comp.Client, FireDAC.Stan.Def;

type
  TMecanismoConexao = ( mcSQLServer, mcPostgreSQL, mcMySQL, mcSQLite );

type
  RInformacoesConexao = record
    Usuario: string;
    Senha: string;
    IPServidor: string;
    PortaConexao: Integer;
    NomeBancoDados: string;
    MecanismoBanco: TMecanismoConexao;
  end;

type
  ConexaoBanco = class( TFDConnection )
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
    constructor Create( AInformacoesConexao: RInformacoesConexao ); reintroduce;

  private
    { **
      TODO -oAPG: Escrever rotina para retornar o objeto FireDAC conectado ao banco
      ** }
    function fnRetornaComponenteConexao: TFDConnection;
    { **
      TODO -oAPG: Escrever rotina para criar o objeto FireDAC com as informações do Create
      ** }
    procedure prConfiguraConexaoComBanco;

    { **
      TODO -oAPG: Escrever rotina para gerar SQL dos dados (CRUD completo)
      ** }

    { **
      TODO -oAPG: Escrever rotina para finalizar a conexao com o objeto durante o Destroy
      ** }
    destructor LimpaMemoria;

    { TODO -oAPG: Incluir documentação dos métodos já desenvolvidos }
    procedure prRetornarExcecao( AMessage: string );
    procedure prVerificaParametrosVazios( AInformacoesConexao
      : RInformacoesConexao );

  end;

implementation

uses System.SysUtils;

{ ConexaoBanco }

var
  cConexaoFiredac: TFDConnection;

constructor ConexaoBanco.Create( AInformacoesConexao: RInformacoesConexao );
begin
  prVerificaParametrosVazios( AInformacoesConexao );

  cConexaoFiredac := TFDConnection.Create( Self );
end;

function ConexaoBanco.fnRetornaComponenteConexao: TFDConnection;
begin
  Result := nil;
end;

destructor ConexaoBanco.LimpaMemoria;
begin
  // Limpar todo uso de memória necessário durante o funcionamento do componente
end;

procedure ConexaoBanco.prConfiguraConexaoComBanco;
begin

end;

procedure ConexaoBanco.prRetornarExcecao( AMessage: string );
begin
  raise EArgumentNilException.Create( AMessage );
end;

procedure ConexaoBanco.prVerificaParametrosVazios( AInformacoesConexao
  : RInformacoesConexao );
begin
  if AInformacoesConexao.Usuario.IsEmpty then
  begin
    prRetornarExcecao( 'Nenhum usuário para conexão foi informado' );
  end;
  if AInformacoesConexao.Senha.IsEmpty then
  begin
    prRetornarExcecao( 'Nenhuma senha para conexão foi informado' );
  end;
  if AInformacoesConexao.NomeBancoDados.IsEmpty then
  begin
    prRetornarExcecao( 'Nenhum banco de dados para conexão foi informado' );
  end;
  if AInformacoesConexao.IPServidor.IsEmpty then
  begin
    prRetornarExcecao
      ( 'Nenhum endereço de servidor para conexão foi informado' );
  end;
end;

initialization

end.
