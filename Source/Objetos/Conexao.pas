unit Conexao;

interface

uses FireDAC.Comp.Client;

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

    {**
    TODO -oAPG: Escrever rotina para retornar o objeto FireDAC conectado ao banco
    **}

    {**
    TODO -oAPG: Escrever rotina para criar o objeto FireDAC com as informações do Create
    **}

    {**
    TODO -oAPG: Escrever rotina para finalizar a conexao com o objeto durante o Destroy
    **}

    {**
    TODO -oAPG: Escrever rotina para gerar SQL dos dados (CRUD completo)
    **}
  private
    procedure prVerificaParametrosVazios(AInformacoesConexao: RInformacoesConexao);

  end;

implementation

uses System.SysUtils;

{ ConexaoBanco }

constructor ConexaoBanco.Create( AInformacoesConexao: RInformacoesConexao );
begin
  prVerificaParametrosVazios(AInformacoesConexao);
end;

procedure ConexaoBanco.prVerificaParametrosVazios(AInformacoesConexao: RInformacoesConexao);
begin
  if AInformacoesConexao.Usuario.IsEmpty then
  begin
    raise EArgumentNilException.Create('Nenhum usuário para conexão foi informado');
  end;
  if AInformacoesConexao.Senha.IsEmpty then
  begin
    raise EArgumentNilException.Create('Nenhuma senha para conexão foi informado');
  end;
  if AInformacoesConexao.NomeBancoDados.IsEmpty then
  begin
    raise EArgumentNilException.Create('Nenhum banco de dados para conexão foi informado');
  end;
end;

initialization

end.
