unit Types.Conexao;

interface

uses System.Classes;

type
  TMecanismoConexao = ( mcSQLServer, mcPostgreSQL, mcMySQL, mcSQLite );

  TTipoOperacaoSql = ( osSelect, osInsert, osUpdate, osDelete );

  RInformacoesConexao = record
    Usuario: string;
    Senha: string;
    IPServidor: string;
    PortaConexao: Integer;
    NomeBancoDados: string;
    MecanismoBanco: TMecanismoConexao;
  end;

  RCamposExecucaoSql = record
    TipoOperacao: TTipoOperacaoSql;
    UsarPrimaryKey: Boolean;
    PrimaryKey: string;
    TabelaPrincipal: string;
    CamposTabela: TStringList;
    ValoresTabela: TArray<Variant>;
    WhereCustomizado: TStringList;
    JoinCustomizado: TStringList;
    UnionCustomizado: TStringList;
    GroupBy: TStringList;
    OrderBy: TstringList;
  end;

implementation

end.
