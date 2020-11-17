unit SQLBuilder;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.StrUtils,
  System.Rtti,
  System.TypInfo,
  Vcl.Dialogs;

type

  TSQLStatementType = (stNone, stSelect, stInsert, stUpdate, stDelete);
  TSQLConnector = (ctAnd, ctOr, ctComma);
  TSQLJoinType = (jtNone, jtInner, jtLeft, jtRight, jtFull);
  TSQLUnionType = (utUnion, utUnionAll);
  TSQLSort = (srNone, srAsc, srDesc);
  TSQLLikeOperator = (loEqual, loStarting, loEnding, loContaining);
  TSQLOperator = (opEqual, opDifferent, opGreater, opLess, opGreaterOrEqual, opLessOrEqual, opLike, opNotLike, opIsNull, opNotNull);
  TSQLValueCase = (vcNone, vcUpper, vcLower);
  TSQLAggFunction = (aggAvg, aggCount, aggMax, aggMin, aggSum);

  ESQLBuilderException = class(Exception);

  ISQLSelect = interface;
  ISQLWhere = interface;
  ISQLGroupBy = interface;
  ISQLHaving = interface;
  ISQLCoalesce = interface;
  ISQLAggregate = interface;

  ISQL = interface
    ['{85047AF8-8194-4010-A342-6D476D0EFF33}']
    function ToString(): string;
    function ToFile(const AFileName: string): ISQL;
  end;

  ISQLStatement = interface(ISQL)
    ['{399C45DA-6741-4C4F-BFBF-D1AC039AF811}']
    function GetStatementType(): TSQLStatementType;
    property StatementType: TSQLStatementType read GetStatementType;
  end;

  ISQLCriteria = interface(ISQL)
    ['{5524CB77-17EA-4F1C-B919-1F62C07E9E1C}']
    function GetCriteria(): string;
    function GetConnector(): TSQLConnector;
    function ConnectorDescription(): string;

    property Criteria: string read GetCriteria;
    property Connector: TSQLConnector read GetConnector;
  end;

  ISQLClause = interface(ISQL)
    ['{98DF3D3C-DB71-48F1-A257-CAE95C31D273}']
    function GetCriterias(): TList<ISQLCriteria>;
    property Criterias: TList<ISQLCriteria> read GetCriterias;
  end;

  ISQLTable = interface(ISQL)
    ['{693CC0DB-07B5-4459-BDCE-1FB40E03185B}']
    function GetName(): string;
    property Name: string read GetName;
  end;

  ISQLFrom = interface(ISQL)
    ['{3152DE95-8C23-49C9-BAA1-51DA505E9F82}']
    function GetTable(): ISQLTable;
    property Table: ISQLTable read GetTable;
  end;

  ISQLValue = interface(ISQL)
    ['{5DE14FF9-A1D6-4FAF-9ADD-9FECEFDAF5BE}']
    function Insensetive(): ISQLValue;
    function IsInsensetive(): Boolean;

    function Column(): ISQLValue;
    function IsColumn(): Boolean;

    function Expression(): ISQLValue;
    function IsExpression(): Boolean;

    function Upper(): ISQLValue;
    function IsUpper(): Boolean;

    function Lower(): ISQLValue;
    function IsLower(): Boolean;

    function Like(const AOperator: TSQLLikeOperator): ISQLValue;
    function IsLike(): Boolean;

    function Date(): ISQLValue;
    function IsDate(): Boolean;

    function DateTime(): ISQLValue;
    function IsDateTime(): Boolean;

    function Time(): ISQLValue;
    function IsTime(): Boolean;

    function GetValue(): TValue;

    property Value: TValue read GetValue;
  end;

  ISQLJoinTerm = interface(ISQL)
    ['{D74BEA2E-25CF-4305-BBC2-30F0AAF7427C}']
    function Left(const ATerm: TValue): ISQLJoinTerm; overload;
    function Left(ATerm: ISQLValue): ISQLJoinTerm; overload;

    function Op(const AOperator: TSQLOperator): ISQLJoinTerm;

    function Right(const ATerm: TValue): ISQLJoinTerm; overload;
    function Right(Aterm: ISQLValue): ISQLJoinTerm; overload;
  end;

  ISQLJoin = interface(ISQL)
    ['{230EBE24-5294-4A9D-87FC-0B4AC15FB00D}']
    function Table(ATable: ISQLTable): ISQLJoin;
    function Condition(ATerm: ISQLJoinTerm): ISQLJoin;
    function &And(ATerm: ISQLJoinTerm): ISQLJoin;
    function &Or(ATerm: ISQLJoinTerm): ISQLJoin;
  end;

  ISQLUnion = interface(ISQL)
    ['{8A43F457-1852-482F-B392-15C38ADD55F2}']
    function GetUnionType(): TSQLUnionType;
    function GetUnionSQL(): string;

    property UnionType: TSQLUnionType read GetUnionType;
    property UnionSQL: string read GetUnionSQL;
  end;

  ISQLCase = interface(ISQL)
    ['{A2F21196-CFFC-4D93-ADF6-D7C936039DD7}']
    function Expression(const ATerm: string): ISQLCase; overload;
    function Expression(ATerm: ISQLValue): ISQLCase; overload;

    function When(const ACondition: TValue): ISQLCase; overload;
    function When(ACondition: ISQLValue): ISQLCase; overload;

    function &Then(const AValue: TValue): ISQLCase; overload;
    function &Then(AValue: ISQLValue): ISQLCase; overload;
    function &Then(AValue: ISQLAggregate): ISQLCase; overload;
    function &Then(AValue: ISQLCoalesce): ISQLCase; overload;

    function &Else(const ADefValue: TValue): ISQLCase; overload;
    function &Else(ADefValue: ISQLValue): ISQLCase; overload;
    function &Else(ADefValue: ISQLAggregate): ISQLCase; overload;
    function &Else(ADefValue: ISQLCoalesce): ISQLCase; overload;

    function &End(): ISQLCase;

    function &As(const AAlias: string): ISQLCase;
    function Alias(const AAlias: string): ISQLCase;
  end;

  ISQLOrderBy = interface(ISQLClause)
    ['{FD091328-5391-4107-BE7D-076254325B9D}']
    procedure CopyOf(ASource: ISQLOrderBy);

    function Column(const AColumn: string; const ASortType: TSQLSort = srNone): ISQLOrderBy;
    function Columns(const AColumns: array of string; const ASortType: TSQLSort = srNone): ISQLOrderBy;
    function Sort(const ASortType: TSQLSort): ISQLOrderBy;

    function Union(ASelect: ISQLSelect; const AType: TSQLUnionType = utUnion): ISQLOrderBy; overload;
    function Union(AWhere: ISQLWhere; const AType: TSQLUnionType = utUnion): ISQLOrderBy; overload;
    function Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType = utUnion): ISQLOrderBy; overload;
    function Union(AHaving: ISQLHaving; const AType: TSQLUnionType = utUnion): ISQLOrderBy; overload;
    function Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType = utUnion): ISQLOrderBy; overload;
  end;

  ISQLHaving = interface(ISQLClause)
    ['{761AE5F5-0D92-4E65-892C-380CE3D393DB}']
    procedure CopyOf(ASource: ISQLHaving);

    function Expression(AAggregateTerm: ISQLAggregate): ISQLHaving; overload;
    function Expression(const ATerm: string): ISQLHaving; overload;

    function Expressions(AAggregateTerms: array of ISQLAggregate): ISQLHaving; overload;
    function Expressions(const ATerms: array of string): ISQLHaving; overload;

    function OrderBy(): ISQLOrderBy; overload;
    function OrderBy(AOrderBy: ISQLOrderBy): ISQLOrderBy; overload;

    function Union(ASelect: ISQLSelect; const AType: TSQLUnionType = utUnion): ISQLHaving; overload;
    function Union(AWhere: ISQLWhere; const AType: TSQLUnionType = utUnion): ISQLHaving; overload;
    function Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType = utUnion): ISQLHaving; overload;
    function Union(AHaving: ISQLHaving; const AType: TSQLUnionType = utUnion): ISQLHaving; overload;
    function Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType = utUnion): ISQLHaving; overload;
  end;

  ISQLGroupBy = interface(ISQLClause)
    ['{CBFC998D-C2EB-4CFE-99DD-191E8E6184AD}']
    procedure CopyOf(ASource: ISQLGroupBy);

    function Column(const AColumn: string): ISQLGroupBy;
    function Columns(const AColumns: array of string): ISQLGroupBy;

    function Having(): ISQLHaving; overload;
    function Having(AHaving: ISQLHaving): ISQLHaving; overload;

    function OrderBy(): ISQLOrderBy; overload;
    function OrderBy(AOrderBy: ISQLOrderBy): ISQLOrderBy; overload;

    function Union(ASelect: ISQLSelect; const AType: TSQLUnionType = utUnion): ISQLGroupBy; overload;
    function Union(AWhere: ISQLWhere; const AType: TSQLUnionType = utUnion): ISQLGroupBy; overload;
    function Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType = utUnion): ISQLGroupBy; overload;
    function Union(AHaving: ISQLHaving; const AType: TSQLUnionType = utUnion): ISQLGroupBy; overload;
    function Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType = utUnion): ISQLGroupBy; overload;
  end;

  ISQLWhere = interface(ISQLClause)
    ['{2F0A526F-541D-4176-9D9E-DD57745F9DDE}']
    procedure CopyOf(ASource: ISQLWhere);

    function Column(const AColumn: string): ISQLWhere;

    function &And(const AColumn: string): ISQLWhere; overload;
    function &And(AWhere: ISQLWhere): ISQLWhere; overload;

    function &Or(const AColumn: string): ISQLWhere; overload;
    function &Or(AWhere: ISQLWhere): ISQLWhere; overload;

    function Equal(const AValue: TValue): ISQLWhere; overload;
    function Equal(AValue: ISQLValue): ISQLWhere; overload;

    function Different(const AValue: TValue): ISQLWhere; overload;
    function Different(AValue: ISQLValue): ISQLWhere; overload;

    function Greater(const AValue: TValue): ISQLWhere; overload;
    function Greater(AValue: ISQLValue): ISQLWhere; overload;

    function GreaterOrEqual(const AValue: TValue): ISQLWhere; overload;
    function GreaterOrEqual(AValue: ISQLValue): ISQLWhere; overload;

    function Less(const AValue: TValue): ISQLWhere; overload;
    function Less(AValue: ISQLValue): ISQLWhere; overload;

    function LessOrEqual(const AValue: TValue): ISQLWhere; overload;
    function LessOrEqual(AValue: ISQLValue): ISQLWhere; overload;

    function Like(const AValue: string; const AOp: TSQLLikeOperator = loEqual): ISQLWhere; overload;
    function Like(AValue: ISQLValue): ISQLWhere; overload;
    function Like(const AValues: array of string; const AOp: TSQLLikeOperator = loEqual): ISQLWhere; overload;
    function Like(AValues: array of ISQLValue): ISQLWhere; overload;

    function NotLike(const AValue: string; const AOp: TSQLLikeOperator = loEqual): ISQLWhere; overload;
    function NotLike(AValue: ISQLValue): ISQLWhere; overload;
    function NotLike(const AValues: array of string; const AOp: TSQLLikeOperator = loEqual): ISQLWhere; overload;
    function NotLike(AValues: array of ISQLValue): ISQLWhere; overload;

    function IsNull(): IsQLWhere;
    function IsNotNull(): ISQLWhere;

    function InList(const AValues: array of TValue): ISQLWhere; overload;
    function InList(AValues: array of ISQLValue): ISQLWhere; overload;

    function NotInList(const AValues: array of TValue): ISQLWhere; overload;
    function NotInList(AValues: array of ISQLValue): ISQLWhere; overload;

    function Between(const AStart, AEnd: TValue): ISQLWhere; overload;
    function Between(AStart, AEnd: ISQLValue): ISQLWhere; overload;

    function Expression(const AOp: TSQLOperator; const AValue: TValue): ISQLWhere; overload;
    function Expression(const AOp: TSQLOperator; AValue: ISQLValue): ISQLWhere; overload;
    function Expression(const AOp: TSQLOperator): ISQLWhere; overload;

    function GroupBy(): ISQLGroupBy; overload;
    function GroupBy(AGroupBy: ISQLGroupBy): ISQLGroupBy; overload;

    function Having(): ISQLHaving; overload;
    function Having(AHaving: ISQLHaving): ISQLHaving; overload;

    function OrderBy(): ISQLOrderBy; overload;
    function OrderBy(AOrderBy: ISQLOrderBy): ISQLOrderBy; overload;

    function Union(ASelect: ISQLSelect; const AType: TSQLUnionType = utUnion): ISQLWhere; overload;
    function Union(AWhere: ISQLWhere; const AType: TSQLUnionType = utUnion): ISQLWhere; overload;
    function Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType = utUnion): ISQLWhere; overload;
    function Union(AHaving: ISQLHaving; const AType: TSQLUnionType = utUnion): ISQLWhere; overload;
    function Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType = utUnion): ISQLWhere; overload;
  end;

  ISQLAggregate = interface(ISQL)
    ['{D7F798E4-F83C-469B-8303-5F1EDB557B43}']
    function Avg(): ISQLAggregate; overload;
    function Avg(const AExpression: string): ISQLAggregate; overload;
    function Avg(ACoalesceExpression: ISQLCoalesce): ISQLAggregate; overload;
    function Avg(ACaseTerm: ISQLCase): ISQLAggregate; overload;

    function Count(): ISQLAggregate; overload;
    function Count(const AExpression: string): ISQLAggregate; overload;
    function Count(ACoalesceExpression: ISQLCoalesce): ISQLAggregate; overload;
    function Count(ACaseTerm: ISQLCase): ISQLAggregate; overload;

    function Max(): ISQLAggregate; overload;
    function Max(const AExpression: string): ISQLAggregate; overload;
    function Max(ACoalesceExpression: ISQLCoalesce): ISQLAggregate; overload;
    function Max(ACaseTerm: ISQLCase): ISQLAggregate; overload;

    function Min(): ISQLAggregate; overload;
    function Min(const AExpression: string): ISQLAggregate; overload;
    function Min(ACoalesceExpression: ISQLCoalesce): ISQLAggregate; overload;
    function Min(ACaseTerm: ISQLCase): ISQLAggregate; overload;

    function Sum(): ISQLAggregate; overload;
    function Sum(const AExpression: string): ISQLAggregate; overload;
    function Sum(ACoalesceExpression: ISQLCoalesce): ISQLAggregate; overload;
    function Sum(ACaseTerm: ISQLCase): ISQLAggregate; overload;

    function Expression(const ATerm: string): ISQLAggregate; overload;
    function Expression(ACoalesceTerm: ISQLCoalesce): ISQLAggregate; overload;
    function Expression(ACaseTerm: ISQLCase): ISQLAggregate; overload;

    function Condition(const AOp: TSQLOperator; const AValue: TValue): ISQLAggregate; overload;
    function Condition(const AOp: TSQLOperator; AValue: ISQLValue): ISQLAggregate; overload;
    function Condition(const AOp: TSQLOperator): ISQLAggregate; overload;

    function &As(const AAlias: string): ISQLAggregate;
    function Alias(const AAlias: string): ISQLAggregate;
  end;

  ISQLCoalesce = interface(ISQL)
    ['{604973B2-B104-477D-9EDB-F9F89E1D9A93}']
    function Expression(const ATerm: string): ISQLCoalesce; overload;
    function Expression(const AAggregateTerm: ISQLAggregate): ISQLCoalesce; overload;
    function Expression(const ACaseTerm: ISQLCase): ISQLCoalesce; overload;

    function Value(const AValue: TValue): ISQLCoalesce; overload;
    function Value(AValue: ISQLValue): ISQLCoalesce; overload;

    function &As(const AAlias: string): ISQLCoalesce;
    function Alias(const AAlias: string): ISQLCoalesce;
  end;

  ISQLSelect = interface(ISQLStatement)
    ['{A6B7CF96-703A-47F1-86E1-DFC9EC455610}']
    function Distinct(): ISQLSelect;

    function AllColumns(): ISQLSelect;
    function Column(const AColumn: string): ISQLSelect; overload;
    function Column(const AColumn: ISQLCoalesce): ISQLSelect; overload;
    function Column(const AColumn: ISQLAggregate): ISQLSelect; overload;
    function Column(const AColumn: ISQLCase): ISQLSelect; overload;
    function &As(const AAlias: string): ISQLSelect;
    function Alias(const AAlias: string): ISQLSelect;

    function SubSelect(ASelect: ISQLSelect; const AAlias: string): ISQLSelect; overload;
    function SubSelect(AWhere: ISQLWhere; const AAlias: string): ISQLSelect; overload;
    function SubSelect(AGroupBy: ISQLGroupBy; const AAlias: string): ISQLSelect; overload;
    function SubSelect(AHaving: ISQLHaving; const AAlias: string): ISQLSelect; overload;
    function SubSelect(AOrderBy: ISQLOrderBy; const AAlias: string): ISQLSelect; overload;

    function From(const ATable: string): ISQLSelect; overload;
    function From(const ATables: array of string): ISQLSelect; overload;
    function From(ATerm: ISQLFrom): ISQLSelect; overload;
    function From(ATerms: array of ISQLFrom): ISQLSelect; overload;

    function Join(AJoin: ISQLJoin): ISQLSelect; overload;
    function Join(const ATable, ACondition: string): ISQLSelect; overload;

    function LeftJoin(ALeftJoin: ISQLJoin): ISQLSelect; overload;
    function LeftJoin(const ATable, ACondition: string): ISQLSelect; overload;

    function RightJoin(ARightJoin: ISQLJoin): ISQLSelect; overload;
    function RightJoin(const ATable, ACondition: string): ISQLSelect; overload;

    function FullJoin(AFullJoin: ISQLJoin): ISQLSelect; overload;
    function FullJoin(const ATable, ACondition: string): ISQLSelect; overload;

    function Union(ASelect: ISQLSelect; const AType: TSQLUnionType = utUnion): ISQLSelect; overload;
    function Union(AWhere: ISQLWhere; const AType: TSQLUnionType = utUnion): ISQLSelect; overload;
    function Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType = utUnion): ISQLSelect; overload;
    function Union(AHaving: ISQLHaving; const AType: TSQLUnionType = utUnion): ISQLSelect; overload;
    function Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType = utUnion): ISQLSelect; overload;

    function Where(): ISQLWhere; overload;
    function Where(const AColumn: string): ISQLWhere; overload;
    function Where(AWhere: ISQLWhere): ISQLWhere; overload;

    function GroupBy(): ISQLGroupBy; overload;
    function GroupBy(AGroupBy: ISQLGroupBy): ISQLGroupBy; overload;

    function Having(): ISQLHaving; overload;
    function Having(AHaving: ISQLHaving): ISQLHaving; overload;

    function OrderBy(): ISQLOrderBy; overload;
    function OrderBy(AOrderBy: ISQLOrderBy): ISQLOrderBy; overload;
  end;

  ISQLDelete = interface(ISQLStatement)
    ['{11395DFA-C2D5-4769-BF7D-CF4430977D62}']
    function From(const ATable: string): ISQLDelete; overload;
    function From(ATable: ISQLTable): ISQLDelete; overload;

    function Where(): ISQLWhere; overload;
    function Where(const AColumn: string): ISQLWhere; overload;
    function Where(AWhere: ISQLWhere): ISQLWhere; overload;
  end;

  ISQLUpdate = interface(ISQLStatement)
    ['{FD6C73B7-D9E6-434B-A22A-64FE5223995E}']
    function Table(const AName: string): ISQLUpdate; overload;
    function Table(ATable: ISQLTable): ISQLUpdate; overload;

    function ColumnSetValue(const AColumn: string; const AValue: TValue): ISQLUpdate; overload;
    function ColumnSetValue(const AColumn: string; AValue: ISQLValue): ISQLUpdate; overload;

    function Columns(const AColumns: array of string): ISQLUpdate;
    function SetValues(const AValues: array of TValue): ISQLUpdate; overload;
    function SetValues(AValues: array of ISQLValue): ISQLUpdate; overload;

    function Where(): ISQLWhere; overload;
    function Where(const AColumn: string): ISQLWhere; overload;
    function Where(AWhere: ISQLWhere): ISQLWhere; overload;
  end;

  ISQLInsert = interface(ISQLStatement)
    ['{3419D1E2-F577-484C-8BCB-53666CEE90F3}']
    function Into(const ATable: string): ISQLInsert; overload;
    function Into(ATable: ISQLTable): ISQLInsert; overload;

    function ColumnValue(const AColumn: string; const AValue: TValue): ISQLInsert; overload;
    function ColumnValue(const AColumn: string; AValue: ISQLValue): ISQLInsert; overload;

    function Columns(const AColumns: array of string): ISQLInsert;
    function Values(const AValues: array of TValue): ISQLInsert; overload;
    function Values(AValues: array of ISQLValue): ISQLInsert; overload;
  end;

  SQL = class sealed
    strict private
      const CanNotBeInstantiatedException = 'This class can not be instantiated!';

    strict private
      {$HINTS OFF}
        constructor Create;
      {$HINTS ON}

    public
      class function Select(): ISQLSelect; static;
      class function Insert(): ISQLInsert; static;
      class function Update(): ISQLUpdate; static;
      class function Delete(): ISQLDelete; static;

      class function Where(): ISQLWhere; overload; static;
      class function Where(const AColumn: string): ISQLWhere; overload; static;

      class function GroupBy(): ISQLGroupBy; overload; static;
      class function GroupBy(const AColumn: string): ISQLGroupBy; overload; static;
      class function GroupBy(const AColumns: array of string): ISQLGroupBy; overload; static;

      class function Having(): ISQLHaving; overload; static;
      class function Having(const AExpression: string): ISQLHaving; overload; static;
      class function Having(const AExpressions: array of string): ISQLHaving; overload; static;
      class function Having(AExpression: ISQLAggregate): ISQLHaving; overload; static;
      class function Having(AExpressions: array of ISQLAggregate): ISQLHaving; overload; static;

      class function OrderBy(): ISQLOrderBy; overload; static;
      class function OrderBy(const AColumn: string; const ASortType: TSQLSort = srNone): ISQLOrderBy; overload; static;
      class function OrderBy(const AColumns: array of string; const ASortType: TSQLSort = srNone): ISQLOrderBy; overload; static;

      class function Coalesce(): ISQLCoalesce; overload;
      class function Coalesce(const AExpression: string; const AValue: TValue): ISQLCoalesce; overload; static;
      class function Coalesce(const AExpression: string; AValue: ISQLValue): ISQLCoalesce; overload; static;
      class function Coalesce(AExpression: ISQLAggregate; const AValue: TValue): ISQLCoalesce; overload; static;
      class function Coalesce(AExpression: ISQLAggregate; AValue: ISQLValue): ISQLCoalesce; overload; static;
      class function Coalesce(AExpression: ISQLCase; const AValue: TValue): ISQLCoalesce; overload; static;
      class function Coalesce(AExpression: ISQLCase; AValue: ISQLValue): ISQLCoalesce; overload; static;

      class function Aggregate(): ISQLAggregate; overload;
      class function Aggregate(const AFunction: TSQLAggFunction; const AExpression: string): ISQLAggregate; overload; static;
      class function Aggregate(const AFunction: TSQLAggFunction; AExpression: ISQLCoalesce): ISQLAggregate; overload; static;

      class function &Case(): ISQLCase; overload; static;
      class function &Case(const AExpression: string): ISQLCase; overload; static;
      class function &Case(AExpression: ISQLValue): ISQLCase; overload; static;

      class function Join(): ISQLJoin; overload; static;
      class function Join(const ATable: string): ISQLJoin; overload; static;
      class function Join(ATable: ISQLTable): ISQLJoin; overload; static;

      class function LeftJoin(): ISQLJoin; overload; static;
      class function LeftJoin(const ATable: string): ISQLJoin; overload; static;
      class function LeftJoin(ATable: ISQLTable): ISQLJoin; overload; static;

      class function RightJoin(): ISQLJoin; overload; static;
      class function RightJoin(const ATable: string): ISQLJoin; overload; static;
      class function RightJoin(ATable: ISQLTable): ISQLJoin; overload; static;

      class function FullJoin(): ISQLJoin; overload; static;
      class function FullJoin(const ATable: string): ISQLJoin; overload; static;
      class function FullJoin(ATable: ISQLTable): ISQLJoin; overload; static;

      class function JoinTerm(): ISQLJoinTerm; static;

      class function Value(const AValue: TValue): ISQLValue; static;
      class function Table(const AName: string): ISQLTable; static;
      class function From(ATable: ISQLTable): ISQLFrom; static;
  end;

implementation

const
  SQL_OPERATOR: array [TSQLOperator] of string = ('=', '<>', '>', '<', '>=', '<=', 'like', 'not like', 'is null', 'is not null');

type

  TSQL = class(TInterfacedObject, ISQL)
    strict protected
      function DoToString(): string; virtual; abstract;
    public
      function ToString(): string; override;
      function ToFile(const AFileName: string): ISQL;
  end;

  TSQLStatement = class(TSQL, ISQLStatement)
    strict private
      FStatementType: TSQLStatementType;

      function GetStatementType(): TSQLStatementType;
    strict protected
      procedure SetStatementType(const AValue: TSQLStatementType);
      function DoToString(): string; override;
    public
      constructor Create();

      property StatementType: TSQLStatementType read GetStatementType;
  end;

  TSQLCriteria = class(TSQL, ISQLCriteria)
    strict private
      FCriteria: string;
      FConnectorType: TSQLConnector;
      function GetCriteria(): string;
      function GetConnector(): TSQLConnector;
    strict protected
      function DoToString(): string; override;
      function ConnectorDescription(): string;
    public
      constructor Create(const ACriteria: string; const AConnector: TSQLConnector);

      property Criteria: string read GetCriteria;
      property Connector: TSQLConnector read GetConnector;
  end;

  TSQLClause = class(TSQL, ISQLClause)
    strict private
      FCriterias: TList<ISQLCriteria>;
      function GetCriterias(): TList<ISQLCriteria>;
    strict protected
      OwnerString: TFunc<string>;
      function DoToString(): string; override;
    public
      constructor Create(const AOwnerString: TFunc<string>);
      destructor Destroy; override;

      property Criterias: TList<ISQLCriteria> read GetCriterias;
  end;

  TSQLTable = class(TSQL, ISQLTable)
    strict private
      FName: string;
      function GetName(): string;
    strict protected
      function DoToString(): string; override;
    public
      constructor Create(const AName: string);

      property Name: string read GetName;
  end;

  TSQLFrom = class(TSQL, ISQLFrom)
    strict private
      FTable: ISQLTable;
      function GetTable(): ISQLTable;
    strict protected
      function DoToString(): string; override;
    public
      constructor Create(ATable: ISQLTable);

      property Table: ISQLTable read GetTable;
  end;

  TSQLValue = class(TSQL, ISQLValue)
    strict private
      FValue: TValue;
      FIsColumn: Boolean;
      FIsExpression: Boolean;
      FCase: TSQLValueCase;
      FIsInsensetive: Boolean;
      FIsLike: Boolean;
      FIsDate: Boolean;
      FIsDateTime: Boolean;
      FIsTime: Boolean;
      FLikeOp: TSQLLikeOperator;
      function GetValue(): TValue;
      function IsReserverdWord(const AValue: string): Boolean;
      function GetLikeOperator(): TSQLLikeOperator;
      function ConvertDate(const ADate: TDate): string;
      function ConvertDateTime(const ADateTime: TDateTime): string;
      function ConvertTime(const ATime: TTime): string;
    strict protected
      function DoToString(): string; override;
    public
      constructor Create(const AValue: TValue);

      function Insensetive(): ISQLValue;
      function IsInsensetive(): Boolean;

      function Column(): ISQLValue;
      function IsColumn(): Boolean;

      function Expression(): ISQLValue;
      function IsExpression(): Boolean;

      function Upper(): ISQLValue;
      function IsUpper(): Boolean;

      function Lower(): ISQLValue;
      function IsLower(): Boolean;

      function Like(const AOp: TSQLLikeOperator): ISQLValue;
      function IsLike(): Boolean;

      function Date(): ISQLValue;
      function IsDate(): Boolean;

      function DateTime(): ISQLValue;
      function IsDateTime(): Boolean;

      function Time(): ISQLValue;
      function IsTime(): Boolean;

      property Value: TValue read GetValue;
  end;

  TSQLJoinTerm = class(TSQL, ISQLJoinTerm)
    strict private
      FLeft: ISQLValue;
      FOp: TSQLOperator;
      FRight: ISQLValue;
    strict protected
      function DoToString(): string; override;
    public
      constructor Create();

      function Left(const ATerm: TValue): ISQLJoinTerm; overload;
      function Left(ATerm: ISQLValue): ISQLJoinTerm; overload;

      function Op(const AOp: TSQLOperator): ISQLJoinTerm;

      function Right(const ATerm: TValue): ISQLJoinTerm; overload;
      function Right(ATerm: ISQLValue): ISQLJoinTerm; overload;
  end;

  TSQLJoin = class(TSQL, ISQLJoin)
    strict private
      FTable: ISQLTable;
      FType: TSQLJoinType;
      FConditions: TStringList;
    strict protected
      function DoToString(): string; override;
    public
      constructor Create(ATable: ISQLTable; const AType: TSQLJoinType; const ADefaultCondition: string);
      destructor Destroy; override;

      function Table(ATable: ISQLTable): ISQLJoin;
      function Condition(ATerm: ISQLJoinTerm): ISQLJoin;
      function &And(ATerm: ISQLJoinTerm): ISQLJoin;
      function &Or(ATerm: ISQLJoinTerm): ISQLJoin;
  end;

  TSQLUnion = class(TSQL, ISQLUnion)
    strict private
      FUnionType: TSQLUnionType;
      FUnionSQL: string;
      function GetUnionType(): TSQLUnionType;
      function GetUnionSQL(): string;
    strict protected
      function DoToString(): string; override;
    public
      constructor Create(const AType: TSQLUnionType; const ASQL: string);

      property UnionType: TSQLUnionType read GetUnionType;
      property UnionSQL: string read GetUnionSQL;
  end;

  TSQLOrderBy = class(TSQLClause, ISQLOrderBy)
    strict private
      FSortType: TSQLSort;
      FUnions: TList<ISQLUnion>;
      procedure AddUnion(const ASQL: string; const AType: TSQLUnionType);
    strict protected
      function DoToString(): string; override;
    public
      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;

      procedure CopyOf(ASource: ISQLOrderBy);

      function Column(const AColumn: string; const ASortType: TSQLSort = srNone): ISQLOrderBy;
      function Columns(const AColumns: array of string; const ASortType: TSQLSort = srNone): ISQLOrderBy;
      function Sort(const ASortType: TSQLSort): ISQLOrderBy;

      function Union(ASelect: ISQLSelect; const AType: TSQLUnionType = utUnion): ISQLOrderBy; overload;
      function Union(AWhere: ISQLWhere; const AType: TSQLUnionType = utUnion): ISQLOrderBy; overload;
      function Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType = utUnion): ISQLOrderBy; overload;
      function Union(AHaving: ISQLHaving; const AType: TSQLUnionType = utUnion): ISQLOrderBy; overload;
      function Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType = utUnion): ISQLOrderBy; overload;
  end;

  TSQLHaving = class(TSQLClause, ISQLHaving)
    strict private
      FOrderBy: ISQLOrderBy;
      FUnions: TList<ISQLUnion>;
      procedure AddUnion(const ASQL: string; const AType: TSQLUnionType);
    strict protected
      function DoToString(): string; override;
    public
      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;

      procedure CopyOf(ASource: ISQLHaving);

      function Expression(AAggregateTerm: ISQLAggregate): ISQLHaving; overload;
      function Expression(const ATerm: string): ISQLHaving; overload;

      function Expressions(AAggregateTerms: array of ISQLAggregate): ISQLHaving; overload;
      function Expressions(const ATerms: array of string): ISQLHaving; overload;

      function OrderBy(): ISQLOrderBy; overload;
      function OrderBy(AOrderBy: ISQLOrderBy): ISQLOrderBy; overload;

      function Union(ASelect: ISQLSelect; const AType: TSQLUnionType = utUnion): ISQLHaving; overload;
      function Union(AWhere: ISQLWhere; const AType: TSQLUnionType = utUnion): ISQLHaving; overload;
      function Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType = utUnion): ISQLHaving; overload;
      function Union(AHaving: ISQLHaving; const AType: TSQLUnionType = utUnion): ISQLHaving; overload;
      function Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType = utUnion): ISQLHaving; overload;
  end;

  TSQLGroupBy = class(TSQLClause, ISQLGroupBy)
    strict private
      FOrderBy: ISQLOrderBy;
      FHaving: ISQLHaving;
      FUnions: TList<ISQLUnion>;
      procedure AddUnion(const ASQL: string; const AType: TSQLUnionType);
    strict protected
      function DoToString(): string; override;
    public
      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;

      procedure CopyOf(ASource: ISQLGroupBy);

      function Column(const AColumn: string): ISQLGroupBy;
      function Columns(const AColumns: array of string): ISQLGroupBy;

      function Having(): ISQLHaving; overload;
      function Having(AHaving: ISQLHaving): ISQLHaving; overload;

      function OrderBy(): ISQLOrderBy; overload;
      function OrderBy(AOrderBy: ISQLOrderBy): ISQLOrderBy; overload;

      function Union(ASelect: ISQLSelect; const AType: TSQLUnionType = utUnion): ISQLGroupBy; overload;
      function Union(AWhere: ISQLWhere; const AType: TSQLUnionType = utUnion): ISQLGroupBy; overload;
      function Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType = utUnion): ISQLGroupBy; overload;
      function Union(AHaving: ISQLHaving; const AType: TSQLUnionType = utUnion): ISQLGroupBy; overload;
      function Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType = utUnion): ISQLGroupBy; overload;
  end;

  TSQLWhere = class(TSQLClause, ISQLWhere)
    strict private
      FColumn: string;
      FConnector: TSQLConnector;
      FGroupBy: ISQLGroupBy;
      FHaving: ISQLHaving;
      FOrderBy: ISQLOrderBy;
      FUnions: TList<ISQLUnion>;
      procedure AddUnion(const ASQL: string; const AType: TSQLUnionType);
      procedure AddExpression(const ASQLOp: TSQLOperator; ASQLValue: ISQLValue);
      procedure AddInList(AValues: array of ISQLValue; const ANotIn: Boolean);
    strict protected
      function DoToString(): string; override;
    public
      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;

      procedure CopyOf(ASource: ISQLWhere);

      function Column(const AColumn: string): ISQLWhere;

      function &And(const AColumn: string): ISQLWhere; overload;
      function &And(AWhere: ISQLWhere): ISQLWhere; overload;

      function &Or(const AColumn: string): ISQLWhere; overload;
      function &Or(AWhere: ISQLWhere): ISQLWhere; overload;

      function Equal(const AValue: TValue): ISQLWhere; overload;
      function Equal(AValue: ISQLValue): ISQLWhere; overload;

      function Different(const AValue: TValue): ISQLWhere; overload;
      function Different(AValue: ISQLValue): ISQLWhere; overload;

      function Greater(const AValue: TValue): ISQLWhere; overload;
      function Greater(AValue: ISQLValue): ISQLWhere; overload;

      function GreaterOrEqual(const AValue: TValue): ISQLWhere; overload;
      function GreaterOrEqual(AValue: ISQLValue): ISQLWhere; overload;

      function Less(const AValue: TValue): ISQLWhere; overload;
      function Less(AValue: ISQLValue): ISQLWhere; overload;

      function LessOrEqual(const AValue: TValue): ISQLWhere; overload;
      function LessOrEqual(AValue: ISQLValue): ISQLWhere; overload;

      function Like(const AValue: string; const AOp: TSQLLikeOperator = loEqual): ISQLWhere; overload;
      function Like(AValue: ISQLValue): ISQLWhere; overload;
      function Like(const AValues: array of string; const AOp: TSQLLikeOperator = loEqual): ISQLWhere; overload;
      function Like(AValues: array of ISQLValue): ISQLWhere; overload;

      function NotLike(const AValue: string; const AOp: TSQLLikeOperator = loEqual): ISQLWhere; overload;
      function NotLike(AValue: ISQLValue): ISQLWhere; overload;
      function NotLike(const AValues: array of string; const AOp: TSQLLikeOperator = loEqual): ISQLWhere; overload;
      function NotLike(AValues: array of ISQLValue): ISQLWhere; overload;

      function IsNull(): ISQLWhere;
      function IsNotNull(): ISQLWhere;

      function InList(const AValues: array of TValue): ISQLWhere; overload;
      function InList(AValues: array of ISQLValue): ISQLWhere; overload;

      function NotInList(const AValues: array of TValue): ISQLWhere; overload;
      function NotInList(AValues: array of ISQLValue): ISQLWhere; overload;

      function Between(const AStart, AEnd: TValue): ISQLWhere; overload;
      function Between(AStart, AEnd: ISQLValue): ISQLWhere; overload;

      function Expression(const AOp: TSQLOperator; const AValue: TValue): ISQLWhere; overload;
      function Expression(const AOp: TSQLOperator; AValue: ISQLValue): ISQLWhere; overload;
      function Expression(const AOp: TSQLOperator): ISQLWhere; overload;

      function GroupBy(): ISQLGroupBy; overload;
      function GroupBy(AGroupBy: ISQLGroupBy): ISQLGroupBy; overload;

      function Having(): ISQLHaving; overload;
      function Having(AHaving: ISQLHaving): ISQLHaving; overload;

      function OrderBy(): ISQLOrderBy; overload;
      function OrderBy(AOrderBy: ISQLOrderBy): ISQLOrderBy; overload;

      function Union(ASelect: ISQLSelect; const AType: TSQLUnionType = utUnion): ISQLWhere; overload;
      function Union(AWhere: ISQLWhere; const AType: TSQLUnionType = utUnion): ISQLWhere; overload;
      function Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType = utUnion): ISQLWhere; overload;
      function Union(AHaving: ISQLHaving; const AType: TSQLUnionType = utUnion): ISQLWhere; overload;
      function Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType = utUnion): ISQLWhere; overload;
  end;

  TSQLSelect = class(TSQLStatement, ISQLSelect)
    strict private
      FDistinct: Boolean;
      FColumns: TStringList;
      FJoinedTables: TList<ISQLJoin>;
      FFrom: ISQLFrom;
      FGroupBy: ISQLGroupBy;
      FHaving: ISQLHaving;
      FOrderBy: ISQLOrderBy;
      FWhere: ISQLWhere;
      FUnions: TList<ISQLUnion>;
    strict protected
      function DoToString(): string; override;
    public
      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;

      function Distinct(): ISQLSelect;

      function AllColumns(): ISQLSelect;
      function Column(const AColumn: string): ISQLSelect; overload;
      function Column(const AColumn: ISQLCoalesce): ISQLSelect; overload;
      function Column(const AColumn: ISQLAggregate): ISQLSelect; overload;
      function Column(const AColumn: ISQLCase): ISQLSelect; overload;
      function &As(const AAlias: string): ISQLSelect;
      function Alias(const AAlias: string): ISQLSelect;

      function SubSelect(ASelect: ISQLSelect; const AAlias: string): ISQLSelect; overload;
      function SubSelect(AWhere: ISQLWhere; const AAlias: string): ISQLSelect; overload;
      function SubSelect(AGroupBy: ISQLGroupBy; const AAlias: string): ISQLSelect; overload;
      function SubSelect(AHaving: ISQLHaving; const AAlias: string): ISQLSelect; overload;
      function SubSelect(AOrderBy: ISQLOrderBy; const AAlias: string): ISQLSelect; overload;

      function From(const ATable: string): ISQLSelect; overload;
      function From(const ATables: array of string): ISQLSelect; overload;
      function From(ATerm: ISQLFrom): ISQLSelect; overload;
      function From(ATerms: array of ISQLFrom): ISQLSelect; overload;

      function Join(AJoin: ISQLJoin): ISQLSelect; overload;
      function Join(const ATable, ACondition: string): ISQLSelect; overload;

      function LeftJoin(ALeftJoin: ISQLJoin): ISQLSelect; overload;
      function LeftJoin(const ATable, ACondition: string): ISQLSelect; overload;

      function RightJoin(ARightJoin: ISQLJoin): ISQLSelect; overload;
      function RightJoin(const ATable, ACondition: string): ISQLSelect; overload;

      function FullJoin(AFullJoin: ISQLJoin): ISQLSelect; overload;
      function FullJoin(const ATable, ACondition: string): ISQLSelect; overload;

      function Union(ASelect: ISQLSelect; const AType: TSQLUnionType = utUnion): ISQLSelect; overload;
      function Union(AWhere: ISQLWhere; const AType: TSQLUnionType = utUnion): ISQLSelect; overload;
      function Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType = utUnion): ISQLSelect; overload;
      function Union(AHaving: ISQLHaving; const AType: TSQLUnionType = utUnion): ISQLSelect; overload;
      function Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType = utUnion): ISQLSelect; overload;

      function Where(): ISQLWhere; overload;
      function Where(const AColumn: string): ISQLWhere; overload;
      function Where(AWhere: ISQLWhere): ISQLWhere; overload;

      function GroupBy(): ISQLGroupBy; overload;
      function GroupBy(AGroupBy: ISQLGroupBy): ISQLGroupBy; overload;

      function Having(): ISQLHaving; overload;
      function Having(AHaving: ISQLHaving): ISQLHaving; overload;

      function OrderBy(): ISQLOrderBy; overload;
      function OrderBy(AOrderBy: ISQLOrderBy): ISQLOrderBy; overload;
  end;

  TSQLDelete = class(TSQLStatement, ISQLDelete)
    strict private
      FTable: ISQLTable;
      FWhere: ISQLWhere;
    strict protected
      function DoToString(): string; override;
    public
      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;

      function From(const ATable: string): ISQLDelete; overload;
      function From(ATable: ISQLTable): ISQLDelete; overload;

      function Where(): ISQLWhere; overload;
      function Where(const AColumn: string): ISQLWhere; overload;
      function Where(AWhere: ISQLWhere): ISQLWhere; overload;
  end;

  TSQLUpdate = class(TSQLStatement, ISQLUpdate)
    strict private
      FColumns: TStringList;
      FValues: TList<ISQLValue>;
      FTable: ISQLTable;
      FWhere: ISQLWhere;
    strict protected
      function DoToString(): string; override;
    public
      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;

      function Table(const AName: string): ISQLUpdate; overload;
      function Table(ATable: ISQLTable): ISQLUpdate; overload;

      function ColumnSetValue(const AColumn: string; const AValue: TValue): ISQLUpdate; overload;
      function ColumnSetValue(const AColumn: string; AValue: ISQLValue): ISQLUpdate; overload;

      function Columns(const AColumns: array of string): ISQLUpdate;
      function SetValues(const AValues: array of TValue): ISQLUpdate; overload;
      function SetValues(AValues: array of ISQLValue): ISQLUpdate; overload;

      function Where(): ISQLWhere; overload;
      function Where(const AColumn: string): ISQLWhere; overload;
      function Where(AWhere: ISQLWhere): ISQLWhere; overload;
  end;

  TSQLInsert = class(TSQLStatement, ISQLInsert)
    strict private
      FColumns: TStringList;
      FValues: TList<ISQLValue>;
      FTable: ISQLTable;
    strict protected
      function DoToString(): string; override;
    public
      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;

      function Into(const ATable: string): ISQLInsert; overload;
      function Into(ATable: ISQLTable): ISQLInsert; overload;

      function ColumnValue(const AColumn: string; const AValue: TValue): ISQLInsert; overload;
      function ColumnValue(const AColumn: string; AValue: ISQLValue): ISQLInsert; overload;

      function Columns(const AColumns: array of string): ISQLInsert;
      function Values(const AValues: array of TValue): ISQLInsert; overload;
      function Values(AValues: array of ISQLValue): ISQLInsert; overload;
  end;

  TSQLCoalesce = class(TSQL, ISQLCoalesce)
    strict private
      FTerm: string;
      FValue: ISQLValue;
      FAlias: string;
    strict protected
      function DoToString(): string; override;
    public
      constructor Create();

      function Expression(const ATerm: string): ISQLCoalesce; overload;
      function Expression(const AAggregateTerm: ISQLAggregate): ISQLCoalesce; overload;
      function Expression(const ACaseTerm: ISQLCase): ISQLCoalesce; overload;

      function Value(const AValue: TValue): ISQLCoalesce; overload;
      function Value(AValue: ISQLValue): ISQLCoalesce; overload;

      function &As(const AAlias: string): ISQLCoalesce;
      function Alias(const AAlias: string): ISQLCoalesce;
  end;

  TSQLAggregate = class(TSQL, ISQLAggregate)
    strict private
      FFunction: TSQLAggFunction;
      FTerm: string;
      FAlias: string;
      FOp: TSQLOperator;
      FValue: ISQLValue;
      FIsCondition: Boolean;
    strict protected
      function DoToString(): string; override;
    public
      constructor Create();

      function Avg(): ISQLAggregate; overload;
      function Avg(const AExpression: string): ISQLAggregate; overload;
      function Avg(ACoalesceExpression: ISQLCoalesce): ISQLAggregate; overload;
      function Avg(ACaseTerm: ISQLCase): ISQLAggregate; overload;

      function Count(): ISQLAggregate; overload;
      function Count(const AExpression: string): ISQLAggregate; overload;
      function Count(ACoalesceExpression: ISQLCoalesce): ISQLAggregate; overload;
      function Count(ACaseTerm: ISQLCase): ISQLAggregate; overload;

      function Max(): ISQLAggregate; overload;
      function Max(const AExpression: string): ISQLAggregate; overload;
      function Max(ACoalesceExpression: ISQLCoalesce): ISQLAggregate; overload;
      function Max(ACaseTerm: ISQLCase): ISQLAggregate; overload;

      function Min(): ISQLAggregate; overload;
      function Min(const AExpression: string): ISQLAggregate; overload;
      function Min(ACoalesceExpression: ISQLCoalesce): ISQLAggregate; overload;
      function Min(ACaseTerm: ISQLCase): ISQLAggregate; overload;

      function Sum(): ISQLAggregate; overload;
      function Sum(const AExpression: string): ISQLAggregate; overload;
      function Sum(ACoalesceExpression: ISQLCoalesce): ISQLAggregate; overload;
      function Sum(ACaseTerm: ISQLCase): ISQLAggregate; overload;

      function Expression(const ATerm: string): ISQLAggregate; overload;
      function Expression(ACoalesceTerm: ISQLCoalesce): ISQLAggregate; overload;
      function Expression(ACaseTerm: ISQLCase): ISQLAggregate; overload;

      function Condition(const AOp: TSQLOperator; const AValue: TValue): ISQLAggregate; overload;
      function Condition(const AOp: TSQLOperator; AValue: ISQLValue): ISQLAggregate; overload;
      function Condition(const AOp: TSQLOperator): ISQLAggregate; overload;

      function &As(const AAlias: string): ISQLAggregate;
      function Alias(const AAlias: string): ISQLAggregate;
  end;

  TSQLCase = class(TSQL, ISQLCase)
    strict private
      type
        TPossibility = class
          private
            FCondition: ISQLValue;
            FValue: ISQLValue;
          public
            constructor Create(ACondition, AValue: ISQLValue);

            property Condition: ISQLValue read FCondition;
            property Value: ISQLValue read FValue;
        end;

    strict private
      FExpression: ISQLValue;
      FDefValue: ISQLValue;
      FCondition: ISQLValue;
      FPossibilities: TObjectList<TPossibility>;
      FAlias: string;
    strict protected
      function DoToString(): string; override;
    public
      constructor Create();
      destructor Destroy; override;

      function Expression(const ATerm: string): ISQLCase; overload;
      function Expression(ATerm: ISQLValue): ISQLCase; overload;

      function When(const ACondition: TValue): ISQLCase; overload;
      function When(ACondition: ISQLValue): ISQLCase; overload;

      function &Then(const AValue: TValue): ISQLCase; overload;
      function &Then(AValue: ISQLValue): ISQLCase; overload;
      function &Then(AValue: ISQLAggregate): ISQLCase; overload;
      function &Then(AValue: ISQLCoalesce): ISQLCase; overload;

      function &Else(const ADefValue: TValue): ISQLCase; overload;
      function &Else(ADefValue: ISQLValue): ISQLCase; overload;
      function &Else(ADefValue: ISQLAggregate): ISQLCase; overload;
      function &Else(ADefValue: ISQLCoalesce): ISQLCase; overload;

      function &End(): ISQLCase;

      function &As(const AAlias: string): ISQLCase;
      function Alias(const AAlias: string): ISQLCase;
  end;

{ TSQL }

function TSQL.ToFile(const AFileName: string): ISQL;
var
  slList: TStringList;
begin
  if FileExists(AFileName) then
  begin
    DeleteFile(AFileName);
  end;

  slList := TStringList.Create;
  try
    slList.Add(ToString);
    slList.SaveToFile(AFileName);
    if not FileExists(AFileName) then
    begin
      raise ESQLBuilderException.Create('Could not save the file!');
    end;
  finally
    FreeAndNil(slList);
  end;
end;

function TSQL.ToString: string;
begin
  Result := DoToString;
end;

{ TSQLStatement }

constructor TSQLStatement.Create;
begin
  FStatementType := stNone;
end;

function TSQLStatement.DoToString: string;
begin
  Result := EmptyStr;
end;

function TSQLStatement.GetStatementType: TSQLStatementType;
begin
  Result := FStatementType;
end;

procedure TSQLStatement.SetStatementType(const AValue: TSQLStatementType);
begin
  FStatementType := AValue;
end;

{ TSQLCriteria }

function TSQLCriteria.ConnectorDescription: string;
begin
  Result := EmptyStr;
  case FConnectorType of
    ctAnd: Result := 'and';
    ctOr: Result := 'or';
    ctComma: Result := ',';
  end;
end;

constructor TSQLCriteria.Create(const ACriteria: string; const AConnector: TSQLConnector);
begin
  FCriteria := ACriteria;
  FConnectorType := AConnector;
end;

function TSQLCriteria.DoToString: string;
begin
  Result := EmptyStr;
end;

function TSQLCriteria.GetConnector: TSQLConnector;
begin
  Result := FConnectorType;
end;

function TSQLCriteria.GetCriteria: string;
begin
  Result := FCriteria;
end;

{ TSQLClause }

constructor TSQLClause.Create(const AOwnerString: TFunc<string>);
begin
  FCriterias := TList<ISQLCriteria>.Create;
  OwnerString := AOwnerString;
end;

destructor TSQLClause.Destroy;
begin
  FreeAndNil(FCriterias);
  inherited;
end;

function TSQLClause.DoToString: string;
begin
  Result := EmptyStr;
end;

function TSQLClause.GetCriterias: TList<ISQLCriteria>;
begin
  Result := FCriterias;
end;

{ TSQLValue }

function TSQLValue.Column: ISQLValue;
begin
  FIsColumn := True;
  Result := Self;
end;

function TSQLValue.ConvertDate(const ADate: TDate): string;
var
  vFmt: TFormatSettings;
begin
  vFmt := TFormatSettings.Create;
  vFmt.DateSeparator := '.';
  vFmt.ShortDateFormat := 'dd.mm.yyyy';
  vFmt.LongDateFormat := 'dd.mm.yyyy';
  Result := QuotedStr(DateToStr(ADate, vFmt));
end;

function TSQLValue.ConvertDateTime(const ADateTime: TDateTime): string;
var
  vFmt: TFormatSettings;
begin
  vFmt := TFormatSettings.Create;
  vFmt.DateSeparator := '.';
  vFmt.ShortDateFormat := 'dd.mm.yyyy hh:mm:ss';
  vFmt.LongDateFormat := 'dd.mm.yyyy hh:mm:ss';
  vFmt.TimeSeparator := ':';
  vFmt.TimeAMString := 'AM';
  vFmt.TimePMString := 'PM';
  vFmt.ShortTimeFormat := 'hh:mm:ss';
  vFmt.LongTimeFormat := 'hh:mm:ss';
  Result := QuotedStr(DateToStr(ADateTime, vFmt));
end;

function TSQLValue.ConvertTime(const ATime: TTime): string;
var
  vFmt: TFormatSettings;
begin
  vFmt := TFormatSettings.Create;
  vFmt.ShortDateFormat := 'hh:mm:ss';
  vFmt.LongDateFormat := 'hh:mm:ss';
  vFmt.TimeSeparator := ':';
  vFmt.TimeAMString := 'AM';
  vFmt.TimePMString := 'PM';
  vFmt.ShortTimeFormat := 'hh:mm:ss';
  vFmt.LongTimeFormat := 'hh:mm:ss';
  Result := QuotedStr(DateToStr(ATime, vFmt));
end;

constructor TSQLValue.Create(const AValue: TValue);
begin
  FValue := AValue;
  FIsColumn := False;
  FIsExpression := False;
  FCase := vcNone;
  FIsInsensetive := False;
  FIsLike := False;
  FIsDate := False;
  FIsDateTime := False;
  FIsTime := False;
  FLikeOp := loEqual;
end;

function TSQLValue.Date: ISQLValue;
begin
  FIsDate := True;
  Result := Self;
end;

function TSQLValue.DateTime: ISQLValue;
begin
  FIsDateTime := True;
  Result := Self;
end;

function TSQLValue.DoToString: string;
begin
  if IsDate then
  begin
    Exit(ConvertDate(FloatToDateTime(GetValue.AsExtended)));
  end;
  if IsDateTime then
  begin
    Exit(ConvertDateTime(FloatToDateTime(GetValue.AsExtended)));
  end;
  if IsTime then
  begin
    Exit(ConvertTime(FloatToDateTime(GetValue.AsExtended)));
  end;
  Result := FValue.ToString;
  if (Result = EmptyStr) and (not IsExpression) then
  begin
    Exit('null');
  end;
  if IsReserverdWord(Result) then
  begin
    raise ESQLBuilderException.Create('Value informed for the SQL Builer is invalid!');
  end;
  case FValue.Kind of
    tkString, tkWChar, tkLString, tkWString, tkUString, tkChar:
    begin
      if (IsColumn or IsExpression) then
      begin
        if (IsInsensetive or IsLower) then
        begin
          Result := Format('lower(%s)', [Result]);
        end
        else if IsUpper then
        begin
          Result := Format('upper(%s)', [Result]);
        end
        else
        begin
          Result := Result;
        end;
      end
      else
      begin
        if IsLike then
        begin
          case GetLikeOperator of
            loStarting: Result := Result + '%';
            loEnding: Result := '%' + Result;
            loContaining: Result := '%' + Result + '%';
          end;
        end;
        if (IsInsensetive or IsLower) then
        begin
          Result := Format('lower(%s)', [QuotedStr(Result)]);
        end
        else if IsUpper then
        begin
          Result := Format('upper(%s)', [QuotedStr(Result)]);
        end
        else
        begin
          Result := QuotedStr(Result);
        end;
      end;
    end;

    tkUnknown: Result := 'null';

    tkFloat: Result := ReplaceText(Result, ',', '.');
  end;
end;

function TSQLValue.Expression: ISQLValue;
begin
  FIsExpression := True;
  Result := Self;
end;

function TSQLValue.GetLikeOperator: TSQLLikeOperator;
begin
  Result := FLikeOp;
end;

function TSQLValue.GetValue: TValue;
begin
  Result := FValue;
end;

function TSQLValue.Insensetive: ISQLValue;
begin
  FIsInsensetive := True;
  Result := Self;
end;

function TSQLValue.IsColumn: Boolean;
begin
  Result := FIsColumn;
end;

function TSQLValue.IsDate: Boolean;
begin
  Result := FIsDate;
end;

function TSQLValue.IsDateTime: Boolean;
begin
  Result := FIsDateTime;
end;

function TSQLValue.IsExpression: Boolean;
begin
  Result := FIsExpression;
end;

function TSQLValue.IsInsensetive: Boolean;
begin
  Result := FIsInsensetive;
end;

function TSQLValue.IsLike: Boolean;
begin
  Result := FIsLike;
end;

function TSQLValue.IsLower: Boolean;
begin
  Result := (FCase = vcLower);
end;

function TSQLValue.IsReserverdWord(const AValue: string): Boolean;
var
  vWords: TArray<string>;
  i: Integer;
begin
  Result := False;
  vWords := TArray<string>.Create('or', 'and', 'between', 'is', 'not', 'null', 'in', 'like',
                                  'select', 'union', 'inner', 'join', 'right', 'left', 'full',
                                  'first', 'insert', 'update', 'delete', 'upper', 'lower');
  for i := Low(vWords) to High(vWords) do
  begin
    if (CompareText(LowerCase(AValue), vWords[i]) = 0) then
    begin
      Exit(True);
    end;
  end;
end;

function TSQLValue.IsTime: Boolean;
begin
  Result := FIsTime;
end;

function TSQLValue.IsUpper: Boolean;
begin
  Result := (FCase = vcUpper);
end;

function TSQLValue.Like(const AOp: TSQLLikeOperator): ISQLValue;
begin
  FLikeOp := AOp;
  FIsLike := True;
  Result := Self;
end;

function TSQLValue.Lower: ISQLValue;
begin
  FCase := vcLower;
  Result := Self;
end;

function TSQLValue.Time: ISQLValue;
begin
  FIsTime := True;
  Result := Self;
end;

function TSQLValue.Upper: ISQLValue;
begin
  FCase := vcUpper;
  Result := Self;
end;

{ TSQLTable }

constructor TSQLTable.Create(const AName: string);
begin
  FName := AName;
end;

function TSQLTable.DoToString: string;
begin
  Result := EmptyStr;
end;

function TSQLTable.GetName: string;
begin
  Result := FName;
end;

{ TSQLFrom }

constructor TSQLFrom.Create(ATable: ISQLTable);
begin
  FTable := ATable;
end;

function TSQLFrom.DoToString: string;
begin
  Result := EmptyStr;
end;

function TSQLFrom.GetTable: ISQLTable;
begin
  Result := FTable;
end;

{ TSQLJoinTerm }

constructor TSQLJoinTerm.Create;
begin
  FLeft := nil;
  FOp := opEqual;
  FRight := nil;
end;

function TSQLJoinTerm.DoToString: string;
begin
  Result := EmptyStr;
  if (FLeft <> nil) and (FRight <> nil) then
  begin
    Result := Format('(%s %s %s)', [FLeft.ToString, SQL_OPERATOR[FOp], FRight.ToString]);
  end;
end;

function TSQLJoinTerm.Left(const ATerm: TValue): ISQLJoinTerm;
begin
  Result := Left(TSQLValue.Create(ATerm).Column);
end;

function TSQLJoinTerm.Left(ATerm: ISQLValue): ISQLJoinTerm;
begin
  FLeft := ATerm;
  Result := Self;
end;

function TSQLJoinTerm.Op(const AOp: TSQLOperator): ISQLJoinTerm;
begin
  FOp := AOp;
  Result := Self;
end;

function TSQLJoinTerm.Right(const ATerm: TValue): ISQLJoinTerm;
begin
  Result := Right(TSQLValue.Create(ATerm).Column);
end;

function TSQLJoinTerm.Right(ATerm: ISQLValue): ISQLJoinTerm;
begin
  FRight := ATerm;
  Result := Self;
end;

{ TSQLJoin }

function TSQLJoin.&And(ATerm: ISQLJoinTerm): ISQLJoin;
begin
  FConditions.Add(Format(' and %s', [ATerm.ToString]));
  Result := Self;
end;

function TSQLJoin.Condition(ATerm: ISQLJoinTerm): ISQLJoin;
begin
  if FConditions.Count > 0 then
  begin
    Result := &And(ATerm);
  end
  else
  begin
    FConditions.Add(ATerm.ToString);
    Result := Self;
  end;
end;

constructor TSQLJoin.Create(ATable: ISQLTable; const AType: TSQLJoinType; const ADefaultCondition: string);
begin
  FConditions := TStringList.Create;
  if not (ADefaultCondition = EmptyStr) then
  begin
    FConditions.Add(ADefaultCondition);
  end;
  FType := AType;
  FTable := ATable;
end;

destructor TSQLJoin.Destroy;
begin
  FreeAndNil(FConditions);
  inherited;
end;

function TSQLJoin.DoToString: string;
var
  vStringBuilder: TStringBuilder;
  i: Integer;
begin
  Result := EmptyStr;
  if (FTable = nil) or (FTable.Name.Trim.IsEmpty) or (FConditions.Count = 0) then
  begin
    Exit();
  end;
  case FType of
    jtInner: Result := Format('join %s on ', [FTable.Name]);
    jtLeft: Result := Format('left join %s on ', [FTable.Name]);
    jtRight: Result := Format('right join %s on ', [FTable.Name]);
    jtFull: Result := Format('full join %s on ', [FTable.Name]);
  end;
  vStringBuilder := TStringBuilder.Create;
  try
    for i := 0 to Pred(FConditions.Count) do
    begin
      vStringBuilder.Append(FConditions[i]);
      if i < Pred(FConditions.Count) then
      begin
        vStringBuilder.AppendLine;
      end;
    end;
    Result := Result + vStringBuilder.ToString;
  finally
    FreeAndNil(vStringBuilder);
  end;
end;

function TSQLJoin.&Or(ATerm: ISQLJoinTerm): ISQLJoin;
begin
  FConditions.Add(Format(' or %s', [ATerm.ToString]));
  Result := Self;
end;

function TSQLJoin.Table(ATable: ISQLTable): ISQLJoin;
begin
  FTable := ATable;
end;

{ TSQLUnion }

constructor TSQLUnion.Create(const AType: TSQLUnionType; const ASQL: string);
begin
  FUnionType := AType;
  FUnionSQL := ASQL;
end;

function TSQLUnion.DoToString: string;
begin
  case FUnionType of
    utUnion: Result := 'union';
    utUnionAll: Result := 'union all';
  end;
  Result := Result + sLineBreak + FUnionSQL;
end;

function TSQLUnion.GetUnionSQL: string;
begin
  Result := FUnionSQL;
end;

function TSQLUnion.GetUnionType: TSQLUnionType;
begin
  Result := FUnionType;
end;

{ TSQLOrderBy }

procedure TSQLOrderBy.AddUnion(const ASQL: string; const AType: TSQLUnionType);
begin
  FUnions.Add(TSQLUnion.Create(AType, ASQL));
end;

procedure TSQLOrderBy.AfterConstruction;
begin
  inherited AfterConstruction;
  FSortType := srNone;
  FUnions := TList<ISQLUnion>.Create;
end;

procedure TSQLOrderBy.BeforeDestruction;
begin
  FreeAndNil(FUnions);
  inherited BeforeDestruction;
end;

function TSQLOrderBy.Column(const AColumn: string; const ASortType: TSQLSort): ISQLOrderBy;
var
  vSrt: string;
begin
  case ASortType of
    srNone: vSrt := AColumn;
    srAsc: vSrt := Format('%s asc', [AColumn]);
    srDesc: vSrt := Format('%s desc', [AColumn]);
  end;
  Criterias.Add(TSQLCriteria.Create(vSrt, ctComma));
  Result := Self;
end;

function TSQLOrderBy.Columns(const AColumns: array of string; const ASortType: TSQLSort): ISQLOrderBy;
var
  i: Integer;
begin
  Criterias.Clear;
  for i := Low(AColumns) to High(AColumns) do
  begin
    Column(AColumns[i]);
  end;
  if ASortType <> srNone then
  begin
    Sort(ASortType);
  end;
  Result := Self;
end;

procedure TSQLOrderBy.CopyOf(ASource: ISQLOrderBy);
var
  i: Integer;
begin
  Criterias.Clear;
  for i := 0 to Pred(ASource.Criterias.Count) do
  begin
    Criterias.Add(ASource.Criterias[i]);
  end;
end;

function TSQLOrderBy.DoToString: string;
var
  vStringBuilder: TStringBuilder;
  i: Integer;
begin
  Result := EmptyStr;
  vStringBuilder := TStringBuilder.Create;
  try
    if Assigned(OwnerString) then
    begin
      vStringBuilder
        .Append(OwnerString)
        .AppendLine;
    end;
    for i := 0 to Pred(Criterias.Count) do
    begin
      if i = 0 then
      begin
        vStringBuilder.Append('order by');
      end
      else
      begin
        vStringBuilder.Append(Criterias[i].ConnectorDescription);
      end;
      vStringBuilder
      .AppendLine
      .Append(Format(' %s', [Criterias[i].Criteria]));
      case FSortType of
        srAsc:
          begin
            if not ContainsStr(Criterias[i].Criteria, 'asc') then
            begin
              vStringBuilder.Append(' asc ');
            end;
          end;

        srDesc:
          begin
            if not ContainsStr(Criterias[i].Criteria, 'desc') then
            begin
              vStringBuilder.Append(' desc ');
            end;
          end;
      end;
    end;
    for i := 0 to Pred(FUnions.Count) do
    begin
      vStringBuilder
        .AppendLine
        .Append(FUnions[i].ToString);
    end;
    Result := vStringBuilder.ToString;
  finally
    FreeAndNil(vStringBuilder);
  end;
end;

function TSQLOrderBy.Sort(const ASortType: TSQLSort): ISQLOrderBy;
begin
  FSortType := ASortType;
  Result := Self;
end;

function TSQLOrderBy.Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType): ISQLOrderBy;
begin
  AddUnion(AOrderBy.ToString, AType);
  Result := Self;
end;

function TSQLOrderBy.Union(AHaving: ISQLHaving; const AType: TSQLUnionType): ISQLOrderBy;
begin
  AddUnion(AHaving.ToString, AType);
  Result := Self;
end;

function TSQLOrderBy.Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType): ISQLOrderBy;
begin
  AddUnion(AGroupBy.ToString, AType);
  Result := Self;
end;

function TSQLOrderBy.Union(AWhere: ISQLWhere; const AType: TSQLUnionType): ISQLOrderBy;
begin
  AddUnion(AWhere.ToString, AType);
  Result := Self;
end;

function TSQLOrderBy.Union(ASelect: ISQLSelect; const AType: TSQLUnionType): ISQLOrderBy;
begin
  AddUnion(ASelect.ToString, AType);
  Result := Self;
end;

{ TSQLHaving }

procedure TSQLHaving.AddUnion(const ASQL: string; const AType: TSQLUnionType);
begin
  FUnions.Add(TSQLUnion.Create(AType, ASQL));
end;

procedure TSQLHaving.AfterConstruction;
begin
  inherited AfterConstruction;
  FOrderBy := TSQLOrderBy.Create(Self.ToString);
  FUnions := TList<ISQLUnion>.Create;
end;

procedure TSQLHaving.BeforeDestruction;
begin
  FreeAndNil(FUnions);
  inherited BeforeDestruction;
end;

procedure TSQLHaving.CopyOf(ASource: ISQLHaving);
var
  i: Integer;
begin
  Criterias.Clear;
  for i := 0 to Pred(ASource.Criterias.Count) do
  begin
    Criterias.Add(ASource.Criterias[i]);
  end;
end;

function TSQLHaving.DoToString: string;
var
  vStringBuilder: TStringBuilder;
  i: Integer;
begin
  Result := EmptyStr;
  vStringBuilder := TStringBuilder.Create;
  try
    if Assigned(OwnerString) then
    begin
      vStringBuilder
        .Append(OwnerString)
        .AppendLine;
    end;
    for i := 0 to Pred(Criterias.Count) do
    begin
      if i = 0 then
      begin
        vStringBuilder.Append('having');
      end
      else
      begin
        vStringBuilder.Append(Format(' %s', [Criterias[i].ConnectorDescription]));
      end;
      vStringBuilder.AppendFormat(' (%0:S)', [Criterias[i].Criteria]);
    end;
    for i := 0 to Pred(FUnions.Count) do
    begin
      vStringBuilder
        .AppendLine
        .Append(FUnions[i].ToString);
    end;
    Result := vStringBuilder.ToString;
  finally
    FreeAndNil(vStringBuilder);
  end;
end;

function TSQLHaving.Expression(const ATerm: string): ISQLHaving;
begin
  Criterias.Add(TSQLCriteria.Create(ATerm, ctAnd));
  Result := Self;
end;

function TSQLHaving.Expression(AAggregateTerm: ISQLAggregate): ISQLHaving;
begin
  Result := Expression(AAggregateTerm.ToString);
end;

function TSQLHaving.Expressions(AAggregateTerms: array of ISQLAggregate): ISQLHaving;
var
  i: Integer;
begin
  Criterias.Clear;
  for i := Low(AAggregateTerms) to High(AAggregateTerms) do
  begin
    Expression(AAggregateTerms[i]);
  end;
  Result := Self;
end;

function TSQLHaving.Expressions(const ATerms: array of string): ISQLHaving;
var
  i: Integer;
begin
  Criterias.Clear;
  for i := Low(ATerms) to High(ATerms) do
  begin
    Expression(ATerms[i]);
  end;
  Result := Self;
end;

function TSQLHaving.OrderBy: ISQLOrderBy;
begin
  Result := FOrderBy;
end;

function TSQLHaving.OrderBy(AOrderBy: ISQLOrderBy): ISQLOrderBy;
begin
  FOrderBy.CopyOf(AOrderBy);
  Result := FOrderBy;
end;

function TSQLHaving.Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType): ISQLHaving;
begin
  AddUnion(AOrderBy.ToString, AType);
  Result := Self;
end;

function TSQLHaving.Union(AHaving: ISQLHaving; const AType: TSQLUnionType): ISQLHaving;
begin
  AddUnion(AHaving.ToString, AType);
  Result := Self;
end;

function TSQLHaving.Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType): ISQLHaving;
begin
  AddUnion(AGroupBy.ToString, AType);
  Result := Self;
end;

function TSQLHaving.Union(AWhere: ISQLWhere; const AType: TSQLUnionType): ISQLHaving;
begin
  AddUnion(AWhere.ToString, AType);
  Result := Self;
end;

function TSQLHaving.Union(ASelect: ISQLSelect; const AType: TSQLUnionType): ISQLHaving;
begin
  AddUnion(ASelect.ToString, AType);
  Result := Self;
end;

{ TSQLGroupBy }

procedure TSQLGroupBy.AddUnion(const ASQL: string; const AType: TSQLUnionType);
begin
  FUnions.Add(TSQLUnion.Create(AType, ASQL));
end;

procedure TSQLGroupBy.AfterConstruction;
begin
  inherited AfterConstruction;
  FOrderBy := TSQLOrderBy.Create(Self.ToString);
  FHaving := TSQLHaving.Create(Self.ToString);
  FUnions := TList<ISQLUnion>.Create;
end;

procedure TSQLGroupBy.BeforeDestruction;
begin
  FreeAndNil(FUnions);
  inherited BeforeDestruction;
end;

function TSQLGroupBy.Column(const AColumn: string): ISQLGroupBy;
begin
  Criterias.Add(TSQLCriteria.Create(AColumn, ctComma));
  Result := Self;
end;

function TSQLGroupBy.Columns(const AColumns: array of string): ISQLGroupBy;
var
  i: Integer;
begin
  Criterias.Clear;
  for i := Low(AColumns) to High(AColumns) do
  begin
    Column(AColumns[i]);
  end;
  Result := Self;
end;

procedure TSQLGroupBy.CopyOf(ASource: ISQLGroupBy);
var
  i: Integer;
begin
  Criterias.Clear;
  for i := 0 to Pred(ASource.Criterias.Count) do
  begin
    Criterias.Add(ASource.Criterias[i]);
  end;
end;

function TSQLGroupBy.DoToString: string;
var
  vStringBuilder: TStringBuilder;
  i: Integer;
begin
  Result := EmptyStr;
  vStringBuilder := TStringBuilder.Create;
  try
    if Assigned(OwnerString) then
    begin
      vStringBuilder
        .Append(OwnerString)
        .AppendLine;
    end;
    for i := 0 to Pred(Criterias.Count) do
    begin
      if i = 0 then
      begin
        vStringBuilder.Append('group by');
      end
      else
      begin
        vStringBuilder.Append(Criterias[i].ConnectorDescription);
      end;
      vStringBuilder
      .AppendLine
      .Append(Format(' %s', [Criterias[i].Criteria]));
    end;
    for i := 0 to Pred(FUnions.Count) do
    begin
      vStringBuilder
        .AppendLine
        .Append(FUnions[i].ToString);
    end;
    Result := vStringBuilder.ToString;
  finally
    FreeAndNil(vStringBuilder);
  end;
end;

function TSQLGroupBy.Having(AHaving: ISQLHaving): ISQLHaving;
begin
  FHaving.CopyOf(AHaving);
  Result := FHaving;
end;

function TSQLGroupBy.Having: ISQLHaving;
begin
  Result := FHaving;
end;

function TSQLGroupBy.OrderBy(AOrderBy: ISQLOrderBy): ISQLOrderBy;
begin
  FOrderBy.CopyOf(AOrderBy);
  Result := FOrderBy;
end;

function TSQLGroupBy.OrderBy: ISQLOrderBy;
begin
  Result := FOrderBy;
end;

function TSQLGroupBy.Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType): ISQLGroupBy;
begin
  AddUnion(AOrderBy.ToString, AType);
  Result := Self;
end;

function TSQLGroupBy.Union(AHaving: ISQLHaving; const AType: TSQLUnionType): ISQLGroupBy;
begin
  AddUnion(AHaving.ToString, AType);
  Result := Self;
end;

function TSQLGroupBy.Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType): ISQLGroupBy;
begin
  AddUnion(AGroupBy.ToString, AType);
  Result := Self;
end;

function TSQLGroupBy.Union(AWhere: ISQLWhere; const AType: TSQLUnionType): ISQLGroupBy;
begin
  AddUnion(AWhere.ToString, AType);
  Result := Self;
end;

function TSQLGroupBy.Union(ASelect: ISQLSelect; const AType: TSQLUnionType): ISQLGroupBy;
begin
  AddUnion(ASelect.ToString, AType);
  Result := Self;
end;

{ TSQLWhere }

procedure TSQLWhere.AddExpression(const ASQLOp: TSQLOperator; ASQLValue: ISQLValue);
begin
  if FColumn = EmptyStr then
  begin
    raise ESQLBuilderException.Create('Column can not be empty!');
  end;
  if ASQLValue.IsInsensetive then
  begin
    Criterias.Add(TSQLCriteria.Create(Format('(lower(%s) %s %s)', [FColumn, SQL_OPERATOR[ASQLOp], ASQLValue.ToString]), FConnector));
  end
  else
  begin
    Criterias.Add(TSQLCriteria.Create(Format('(%s %s %s)', [FColumn, SQL_OPERATOR[ASQLOp], ASQLValue.ToString]), FConnector));
  end;
  FConnector := ctAnd;
  FColumn := EmptyStr;
end;

procedure TSQLWhere.AddInList(AValues: array of ISQLValue; const ANotIn: Boolean);
var
  vStringBuilder: TStringBuilder;
  i: Integer;
  vInsensetive: Boolean;
  vStrIn: string;
begin
  if FColumn = EmptyStr then
  begin
    raise ESQLBuilderException.Create('Column can not be empty!');
  end;

  vInsensetive := False;
  vStringBuilder := TStringBuilder.Create;
  try
    vStringBuilder.Append('(');
    for i := Low(AValues) to High(AValues) do
    begin
      if i > 0 then
      begin
        vStringBuilder.Append(', ');
      end;
      vStringBuilder.Append(AValues[i].ToString);
      if AValues[i].IsInsensetive then
      begin
        vInsensetive := True;
      end;
    end;
    vStringBuilder.Append(')');
    vStrIn := 'in';
    if ANotIn then
    begin
      vStrIn := 'not in';
    end;
    if vInsensetive then
    begin
      Criterias.Add(TSQLCriteria.Create(Format('(lower(%s) %s %s)', [FColumn, vStrIn, vStringBuilder.ToString]), FConnector));
    end
    else
    begin
      Criterias.Add(TSQLCriteria.Create(Format('(%s %s %s)', [FColumn, vStrIn, vStringBuilder.ToString]), FConnector));
    end;
  finally
    FreeAndNil(vStringBuilder);
  end;
  FConnector := ctAnd;
  FColumn := EmptyStr;
end;

procedure TSQLWhere.AddUnion(const ASQL: string; const AType: TSQLUnionType);
begin
  FUnions.Add(TSQLUnion.Create(AType, ASQL));
end;

procedure TSQLWhere.AfterConstruction;
begin
  inherited AfterConstruction;
  FColumn := EmptyStr;
  FConnector := ctAnd;
  FGroupBy := TSQLGroupBy.Create(Self.ToString);
  FHaving := TSQLHaving.Create(Self.ToString);
  FOrderBy := TSQLOrderBy.Create(Self.ToString);
  FUnions := TList<ISQLUnion>.Create;
end;

function TSQLWhere.&And(const AColumn: string): ISQLWhere;
begin
  FConnector := ctAnd;
  FColumn := AColumn;
  Result := Self;
end;

function TSQLWhere.&And(AWhere: ISQLWhere): ISQLWhere;
begin
  Criterias.Add(TSQLCriteria.Create(Format('(%s)', [ReplaceText(AWhere.ToString, ' where ', '')]), ctAnd));
  FConnector := ctAnd;
  FColumn := EmptyStr;
  Result := Self;
end;

procedure TSQLWhere.BeforeDestruction;
begin
  FreeAndNil(FUnions);
  inherited BeforeDestruction;
end;

function TSQLWhere.Between(const AStart, AEnd: TValue): ISQLWhere;
begin
  Result := Between(TSQLValue.Create(AStart), TSQLValue.Create(AEnd));
end;

function TSQLWhere.Between(AStart, AEnd: ISQLValue): ISQLWhere;
begin
  if FColumn.Trim.IsEmpty then
  begin
    raise ESQLBuilderException.Create('Column can not be empty!');
  end;
  Criterias.Add(TSQLCriteria.Create(Format('(%s between %s and %s)', [FColumn, AStart.ToString, AEnd.ToString]), FConnector));
  FConnector := ctAnd;
  FColumn := EmptyStr;
  Result := Self;
end;

function TSQLWhere.Column(const AColumn: string): ISQLWhere;
begin
  FConnector := ctAnd;
  FColumn := AColumn;
  Result := Self;
end;

procedure TSQLWhere.CopyOf(ASource: ISQLWhere);
begin
  Criterias.Clear;
  &And(ASource);
end;

function TSQLWhere.Different(AValue: ISQLValue): ISQLWhere;
begin
  AddExpression(opDifferent, AValue);
  Result := Self;
end;

function TSQLWhere.Different(const AValue: TValue): ISQLWhere;
begin
  Result := Different(TSQLValue.Create(AValue));
end;

function TSQLWhere.DoToString: string;
var
  vStringBuilder: TStringBuilder;
  i: Integer;
begin
  Result := EmptyStr;
  vStringBuilder := TStringBuilder.Create;
  try
    if Assigned(OwnerString) then
    begin
      vStringBuilder
        .Append(OwnerString)
        .AppendLine;
    end;
    for i := 0 to Pred(Criterias.Count) do
    begin
      if i = 0 then
      begin
        vStringBuilder.Append(' where ');
      end
      else
      begin
        vStringBuilder.Append(Format(' %s ', [Criterias[i].ConnectorDescription]));
      end;
      vStringBuilder.Append(Criterias[i].Criteria);
    end;
    for i := 0 to Pred(FUnions.Count) do
    begin
      vStringBuilder
        .AppendLine
        .Append(FUnions[i].ToString);
    end;
    Result := vStringBuilder.ToString;
  finally
    FreeAndNil(vStringBuilder);
  end;
end;

function TSQLWhere.Equal(AValue: ISQLValue): ISQLWhere;
begin
  AddExpression(opEqual, AValue);
  Result := Self;
end;

function TSQLWhere.Equal(const AValue: TValue): ISQLWhere;
begin
  Result := Equal(TSQLValue.Create(AValue));
end;

function TSQLWhere.Expression(const AOp: TSQLOperator): ISQLWhere;
begin

end;

function TSQLWhere.Expression(const AOp: TSQLOperator; const AValue: TValue): ISQLWhere;
begin
  Result := Expression(AOp, TSQLValue.Create(AValue));
end;

function TSQLWhere.Expression(const AOp: TSQLOperator; AValue: ISQLValue): ISQLWhere;
begin
  AddExpression(AOp, AValue);
  Result := Self;
end;

function TSQLWhere.Greater(AValue: ISQLValue): ISQLWhere;
begin
  AddExpression(opGreater, AValue);
  Result := Self;
end;

function TSQLWhere.Greater(const AValue: TValue): ISQLWhere;
begin
  Result := Greater(TSQLValue.Create(AValue));
end;

function TSQLWhere.GreaterOrEqual(const AValue: TValue): ISQLWhere;
begin
  Result := GreaterOrEqual(TSQLValue.Create(AValue));
end;

function TSQLWhere.GreaterOrEqual(AValue: ISQLValue): ISQLWhere;
begin
  AddExpression(opGreaterOrEqual, AValue);
  Result := Self;
end;

function TSQLWhere.GroupBy(AGroupBy: ISQLGroupBy): ISQLGroupBy;
begin
  FGroupBy.CopyOf(AGroupBy);
  Result := FGroupBy;
end;

function TSQLWhere.GroupBy: ISQLGroupBy;
begin
  Result := FGroupBy;
end;

function TSQLWhere.Having: ISQLHaving;
begin
  Result := FHaving;
end;

function TSQLWhere.Having(AHaving: ISQLHaving): ISQLHaving;
begin
  FHaving.CopyOf(AHaving);
  Result := FHaving;
end;

function TSQLWhere.InList(const AValues: array of TValue): ISQLWhere;
var
  vValues: array of ISQLValue;
  i: Integer;
begin
  SetLength(vValues, Length(AValues));
  for i := Low(AValues) to High(AValues) do
  begin
    vValues[i] := TSQLValue.Create(AValues[i]);
  end;
  Result := InList(vValues);
end;

function TSQLWhere.InList(AValues: array of ISQLValue): ISQLWhere;
begin
  AddInList(AValues, False);
  Result := Self;
end;

function TSQLWhere.IsNotNull: ISQLWhere;
begin
  AddExpression(opNotNull, TSQLValue.Create('').Expression);
  Result := Self;
end;

function TSQLWhere.IsNull: ISQLWhere;
begin
  AddExpression(opIsNull, TSQLValue.Create('').Expression);
  Result := Self;
end;

function TSQLWhere.Less(const AValue: TValue): ISQLWhere;
begin
  Result := Less(TSQLValue.Create(AValue));
end;

function TSQLWhere.Less(AValue: ISQLValue): ISQLWhere;
begin
  AddExpression(opLess, AValue);
  Result := Self;
end;

function TSQLWhere.LessOrEqual(AValue: ISQLValue): ISQLWhere;
begin
  AddExpression(opLessOrEqual, AValue);
  Result := Self;
end;

function TSQLWhere.LessOrEqual(const AValue: TValue): ISQLWhere;
begin
  Result := LessOrEqual(TSQLValue.Create(AValue));
end;

function TSQLWhere.Like(AValues: array of ISQLValue): ISQLWhere;
var
  vWhere: ISQLWhere;
  i: Integer;
begin
  vWhere := TSQLWhere.Create(nil);
  vWhere.Column(FColumn).Like(AValues[0]);
  for i := 1 to High(AValues) do
  begin
    vWhere.&Or(FColumn).Like(AValues[i]);
  end;
  Self.&And(vWhere);
  FConnector := ctAnd;
  FColumn := EmptyStr;
  Result := Self;
end;

function TSQLWhere.Like(const AValues: array of string; const AOp: TSQLLikeOperator): ISQLWhere;
var
  vValues: array of ISQLValue;
  i: Integer;
begin
  SetLength(vValues, Length(AValues));
  for i := Low(AValues) to High(AValues) do
  begin
    vValues[i] := TSQLValue.Create(AValues[i]).Like(AOp);
  end;
  Result := Like(vValues);
end;

function TSQLWhere.Like(const AValue: string; const AOp: TSQLLikeOperator): ISQLWhere;
begin
  Result := Like(TSQLValue.Create(AValue).Like(AOp));
end;

function TSQLWhere.Like(AValue: ISQLValue): ISQLWhere;
begin
  AddExpression(opLike, AValue);
  Result := Self;
end;

function TSQLWhere.NotInList(const AValues: array of TValue): ISQLWhere;
var
  vValues: array of ISQLValue;
  i: Integer;
begin
  SetLength(vValues, Length(AValues));
  for i := Low(AValues) to High(AValues) do
  begin
    vValues[i] := TSQLValue.Create(AValues[i]);
  end;
  Result := NotInList(vValues);
end;

function TSQLWhere.NotInList(AValues: array of ISQLValue): ISQLWhere;
begin
  AddInList(AValues, True);
  Result := Self;
end;

function TSQLWhere.NotLike(AValue: ISQLValue): ISQLWhere;
begin
  AddExpression(opNotLike, AValue);
  Result := Self;
end;

function TSQLWhere.NotLike(const AValue: string; const AOp: TSQLLikeOperator): ISQLWhere;
begin
  Result := NotLike(TSQLValue.Create(AValue).Like(AOp));
end;

function TSQLWhere.NotLike(AValues: array of ISQLValue): ISQLWhere;
var
  vWhere: ISQLWhere;
  i: Integer;
begin
  vWhere := TSQLWhere.Create(nil);
  vWhere.Column(FColumn).NotLike(AValues[0]);
  for i := 1 to High(AValues) do
  begin
    vWhere.&Or(FColumn).NotLike(AValues[i]);
  end;
  Self.&And(vWhere);
  FConnector := ctAnd;
  FColumn := EmptyStr;
  Result := Self;
end;

function TSQLWhere.NotLike(const AValues: array of string; const AOp: TSQLLikeOperator): ISQLWhere;
var
  vValues: array of ISQLValue;
  i: Integer;
begin
  SetLength(vValues, Length(AValues));
  for i := Low(AValues) to High(AValues) do
  begin
    vValues[i] := TSQLValue.Create(AValues[i]).Like(AOp);
  end;
  Result := NotLike(vValues);
end;

function TSQLWhere.&Or(AWhere: ISQLWhere): ISQLWhere;
begin
  Criterias.Add(TSQLCriteria.Create(Format('(%s)', [ReplaceText(AWhere.ToString, ' where ', '')]), ctOr));
  FConnector := ctOr;
  FColumn := EmptyStr;
  Result := Self;
end;

function TSQLWhere.&Or(const AColumn: string): ISQLWhere;
begin
  FConnector := ctOr;
  FColumn := AColumn;
  Result := Self;
end;

function TSQLWhere.OrderBy(AOrderBy: ISQLOrderBy): ISQLOrderBy;
begin
  FOrderBy.CopyOf(AOrderBy);
  Result := FOrderBy;
end;

function TSQLWhere.OrderBy: ISQLOrderBy;
begin
  Result := FOrderBy;
end;

function TSQLWhere.Union(ASelect: ISQLSelect; const AType: TSQLUnionType): ISQLWhere;
begin
  AddUnion(ASelect.ToString, AType);
  Result := Self;
end;

function TSQLWhere.Union(AWhere: ISQLWhere; const AType: TSQLUnionType): ISQLWhere;
begin
  AddUnion(AWhere.ToString, AType);
  Result := Self;
end;

function TSQLWhere.Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType): ISQLWhere;
begin
  AddUnion(AOrderBy.ToString, AType);
  Result := Self;
end;

function TSQLWhere.Union(AHaving: ISQLHaving; const AType: TSQLUnionType): ISQLWhere;
begin
  AddUnion(AHaving.ToString, AType);
  Result := Self;
end;

function TSQLWhere.Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType): ISQLWhere;
begin
  AddUnion(AGroupBy.ToString, AType);
  Result := Self;
end;

{ TSQLSelect }

procedure TSQLSelect.AfterConstruction;
begin
  inherited AfterConstruction;
  SetStatementType(stSelect);
  FDistinct := False;
  FColumns := TStringList.Create;
  FColumns.Delimiter := ',';
  FColumns.StrictDelimiter := True;
  FFrom := nil;
  FJoinedTables := TList<ISQLJoin>.Create;
  FGroupBy := TSQLGroupBy.Create(Self.ToString);
  FHaving := TSQLHaving.Create(Self.ToString);
  FOrderBy := TSQLOrderBy.Create(Self.ToString);
  FWhere := TSQLWhere.Create(Self.ToString);
  FUnions := TList<ISQLUnion>.Create;
end;

function TSQLSelect.Alias(const AAlias: string): ISQLSelect;
var
  vColumn: string;
begin
  if not AAlias.Trim.IsEmpty then
  begin
    vColumn := FColumns[FColumns.Count - 1];
    if not ContainsText(vColumn, ' as ') then
    begin
      FColumns[FColumns.Count - 1] := Format('%s as %s', [vColumn, AAlias]);
    end;
  end;
  Result := Self;
end;

function TSQLSelect.AllColumns: ISQLSelect;
begin
  FColumns.Clear;
  FColumns.Add('*');
  Result := Self;
end;

function TSQLSelect.&As(const AAlias: string): ISQLSelect;
begin
  Result := Alias(AAlias);
end;

procedure TSQLSelect.BeforeDestruction;
begin
  FreeAndNil(FColumns);
  FreeAndNil(FJoinedTables);
  FreeAndNil(FUnions);
  inherited BeforeDestruction;
end;

function TSQLSelect.Column(const AColumn: ISQLCase): ISQLSelect;
begin
  Result := Column(AColumn.ToString);
end;

function TSQLSelect.Column(const AColumn: ISQLAggregate): ISQLSelect;
begin
  Result := Column(AColumn.ToString);
end;

function TSQLSelect.Column(const AColumn: string): ISQLSelect;
begin
  FColumns.Add(AColumn);
  Result := Self;
end;

function TSQLSelect.Column(const AColumn: ISQLCoalesce): ISQLSelect;
begin
  Result := Column(AColumn.ToString);
end;

function TSQLSelect.Distinct: ISQLSelect;
begin
  FDistinct := True;
  Result := Self;
end;

function TSQLSelect.DoToString: string;
var
  vStringBuilder: TStringBuilder;
  i: Integer;
begin
  Result := EmptyStr;
  if (FColumns.Count = 0) or (FFrom = nil) or (FFrom.Table.Name.Trim.IsEmpty) then
  begin
    Exit;
  end;

  vStringBuilder := TStringBuilder.Create;
  try
    vStringBuilder.Append('select');
    if FDistinct then
    begin
      vStringBuilder
        .AppendLine
        .Append('distinct');
    end;
    for i := 0 to Pred(FColumns.Count) do
    begin
      if i > 0 then
      begin
        vStringBuilder.Append(',');
      end;
      vStringBuilder
        .AppendLine
        .Append(Format(' %s', [FColumns[i]]));
    end;
    vStringBuilder
      .AppendLine
      .Append(Format('from %s', [FFrom.Table.Name]));

    for i := 0 to Pred(FJoinedTables.Count) do
    begin
      vStringBuilder
        .AppendLine
        .Append(FJoinedTables[i].ToString);
    end;
    for i := 0 to Pred(FUnions.Count) do
    begin
      vStringBuilder
        .AppendLine
        .Append(FUnions[i].ToString);
    end;
    Result := vStringBuilder.ToString;
  finally
    FreeAndNil(vStringBuilder);
  end;
end;

function TSQLSelect.From(ATerms: array of ISQLFrom): ISQLSelect;
var
  vStringBuilder: TStringBuilder;
  i: Integer;
begin
  vStringBuilder := TStringBuilder.Create;
  try
    for i := Low(ATerms) to High(ATerms) do
    begin
      if i > 0 then
      begin
        vStringBuilder.Append(', ');
      end;
      vStringBuilder.Append(ATerms[i].Table.Name);
    end;
    Result := From(vStringBuilder.ToString);
  finally
    FreeAndNil(vStringBuilder);
  end;
end;

function TSQLSelect.From(ATerm: ISQLFrom): ISQLSelect;
begin
  FFrom := TSQLFrom.Create(TSQLTable.Create(ATerm.Table.Name));
  Result := Self;
end;

function TSQLSelect.From(const ATables: array of string): ISQLSelect;
var
  vFroms: array of ISQLFrom;
  i: Integer;
begin
  SetLength(vFroms, Length(ATables));
  for i := Low(ATables) to High(ATables) do
  begin
    vFroms[i] := TSQLFrom.Create(TSQLTable.Create(ATables[i]));
  end;
  Result := From(vFroms);
end;

function TSQLSelect.From(const ATable: string): ISQLSelect;
begin
  Result := From(TSQLFrom.Create(TSQLTable.Create(ATable)));
end;

function TSQLSelect.FullJoin(AFullJoin: ISQLJoin): ISQLSelect;
begin
  FJoinedTables.Add(AFullJoin);
  Result := Self;
end;

function TSQLSelect.FullJoin(const ATable, ACondition: string): ISQLSelect;
begin
  Result := FullJoin(TSQLJoin.Create(TSQLTable.Create(ATable), jtFull, ACondition));
end;

function TSQLSelect.GroupBy(AGroupBy: ISQLGroupBy): ISQLGroupBy;
begin
  FGroupBy.CopyOf(AGroupBy);
  Result := FGroupBy;
end;

function TSQLSelect.GroupBy: ISQLGroupBy;
begin
  Result := FGroupBy;
end;

function TSQLSelect.Having(AHaving: ISQLHaving): ISQLHaving;
begin
  FHaving.CopyOf(AHaving);
  Result := FHaving;
end;

function TSQLSelect.Having: ISQLHaving;
begin
  Result := FHaving;
end;

function TSQLSelect.Join(const ATable, ACondition: string): ISQLSelect;
begin
  Result := Join(TSQLJoin.Create(TSQLTable.Create(ATable), jtInner, ACondition));
end;

function TSQLSelect.Join(AJoin: ISQLJoin): ISQLSelect;
begin
  FJoinedTables.Add(AJoin);
  Result := Self;
end;

function TSQLSelect.LeftJoin(ALeftJoin: ISQLJoin): ISQLSelect;
begin
  FJoinedTables.Add(ALeftJoin);
  Result := Self;
end;

function TSQLSelect.LeftJoin(const ATable, ACondition: string): ISQLSelect;
begin
  Result := LeftJoin(TSQLJoin.Create(TSQLTable.Create(ATable), jtLeft, ACondition));
end;

function TSQLSelect.OrderBy: ISQLOrderBy;
begin
  Result := FOrderBy;
end;

function TSQLSelect.OrderBy(AOrderBy: ISQLOrderBy): ISQLOrderBy;
begin
  FOrderBy.CopyOf(AOrderBy);
  Result := FOrderBy;
end;

function TSQLSelect.RightJoin(const ATable, ACondition: string): ISQLSelect;
begin
  Result := RightJoin(TSQLJoin.Create(TSQLTable.Create(ATable), jtRight, ACondition));
end;

function TSQLSelect.RightJoin(ARightJoin: ISQLJoin): ISQLSelect;
begin
  FJoinedTables.Add(ARightJoin);
  Result := Self;
end;

function TSQLSelect.SubSelect(AHaving: ISQLHaving; const AAlias: string): ISQLSelect;
begin
  FColumns.Add(Format('(%s) as %s', [AHaving.ToString, AAlias]));
  Result := Self;
end;

function TSQLSelect.SubSelect(AOrderBy: ISQLOrderBy; const AAlias: string): ISQLSelect;
begin
  FColumns.Add(Format('(%s) as %s', [AOrderBy.ToString, AAlias]));
  Result := Self;
end;

function TSQLSelect.SubSelect(AGroupBy: ISQLGroupBy; const AAlias: string): ISQLSelect;
begin
  FColumns.Add(Format('(%s) as %s', [AGroupBy.ToString, AAlias]));
  Result := Self;
end;

function TSQLSelect.SubSelect(AWhere: ISQLWhere; const AAlias: string): ISQLSelect;
begin
  FColumns.Add(Format('(%s) as %s', [AWhere.ToString, AAlias]));
  Result := Self;
end;

function TSQLSelect.SubSelect(ASelect: ISQLSelect; const AAlias: string): ISQLSelect;
begin
  FColumns.Add(Format('(%s) as %s', [ASelect.ToString, AAlias]));
  Result := Self;
end;

function TSQLSelect.Union(AWhere: ISQLWhere; const AType: TSQLUnionType): ISQLSelect;
begin
  FUnions.Add(TSQLUnion.Create(AType, AWhere.ToString));
  Result := Self;
end;

function TSQLSelect.Union(AGroupBy: ISQLGroupBy; const AType: TSQLUnionType): ISQLSelect;
begin
  FUnions.Add(TSQLUnion.Create(AType, AGroupBy.ToString));
  Result := Self;
end;

function TSQLSelect.Union(AHaving: ISQLHaving; const AType: TSQLUnionType): ISQLSelect;
begin
  FUnions.Add(TSQLUnion.Create(AType, AHaving.ToString));
  Result := Self;
end;

function TSQLSelect.Union(AOrderBy: ISQLOrderBy; const AType: TSQLUnionType): ISQLSelect;
begin
  FUnions.Add(TSQLUnion.Create(AType, AOrderBy.ToString));
  Result := Self;
end;

function TSQLSelect.Union(ASelect: ISQLSelect; const AType: TSQLUnionType): ISQLSelect;
begin
  FUnions.Add(TSQLUnion.Create(AType, ASelect.ToString));
  Result := Self;
end;

function TSQLSelect.Where(AWhere: ISQLWhere): ISQLWhere;
begin
  FWhere.CopyOf(AWhere);
  Result := FWhere;
end;

function TSQLSelect.Where(const AColumn: string): ISQLWhere;
begin
  FWhere.Column(AColumn);
  Result := FWhere;
end;

function TSQLSelect.Where: ISQLWhere;
begin
  Result := FWhere;
end;

{ TSQLDelete }

procedure TSQLDelete.AfterConstruction;
begin
  inherited AfterConstruction;
  SetStatementType(stDelete);
  FWhere := TSQLWhere.Create(Self.ToString);
  FTable := nil;
end;

procedure TSQLDelete.BeforeDestruction;
begin
  inherited BeforeDestruction;
end;

function TSQLDelete.DoToString: string;
var
  vStringBuilder: TStringBuilder;
begin
  Result := EmptyStr;
  if (FTable = nil) or (FTable.Name.Trim.IsEmpty) then
  begin
    Exit;
  end;
  vStringBuilder := TStringBuilder.Create;
  try
    vStringBuilder
      .Append('delete from ')
      .Append(FTable.Name);
    Result := vStringBuilder.ToString;
  finally
    FreeAndNil(vStringBuilder);
  end;
end;

function TSQLDelete.From(const ATable: string): ISQLDelete;
begin
  Result := From(TSQLTable.Create(ATable));
end;

function TSQLDelete.From(ATable: ISQLTable): ISQLDelete;
begin
  FTable := ATable;
  Result := Self;
end;

function TSQLDelete.Where: ISQLWhere;
begin
  Result := FWhere;
end;

function TSQLDelete.Where(const AColumn: string): ISQLWhere;
begin
  FWhere.Column(AColumn);
  Result := FWhere;
end;

function TSQLDelete.Where(AWhere: ISQLWhere): ISQLWhere;
begin
  FWhere.CopyOf(AWhere);
  Result := FWhere;
end;

{ TSQLUpdate }

procedure TSQLUpdate.AfterConstruction;
begin
  inherited AfterConstruction;
  SetStatementType(stUpdate);
  FColumns := TStringList.Create;
  FValues := TList<ISQLValue>.Create;
  FWhere := TSQLWhere.Create(Self.ToString);
  FTable := nil;
end;

procedure TSQLUpdate.BeforeDestruction;
begin
  FreeAndNil(FColumns);
  FreeAndNil(FValues);
  inherited BeforeDestruction;
end;

function TSQLUpdate.Columns(const AColumns: array of string): ISQLUpdate;
var
  i: Integer;
begin
  FColumns.Clear;
  for i := Low(AColumns) to High(AColumns) do
  begin
    if AColumns[i].Trim.IsEmpty then
    begin
      raise ESQLBuilderException.Create('The column can not be empty!');
    end;
    FColumns.Add(AColumns[i]);
  end;
  Result := Self;
end;

function TSQLUpdate.ColumnSetValue(const AColumn: string; AValue: ISQLValue): ISQLUpdate;
begin
  if AColumn.Trim.IsEmpty then
  begin
    raise ESQLBuilderException.Create('The column can not be empty!');
  end;
  FColumns.Add(AColumn);
  FValues.Add(AValue);
  Result := Self;
end;

function TSQLUpdate.ColumnSetValue(const AColumn: string; const AValue: TValue): ISQLUpdate;
begin
  Result := ColumnSetValue(AColumn, TSQLValue.Create(AValue));
end;

function TSQLUpdate.DoToString: string;
var
  vStringBuilder: TStringBuilder;
  i: Integer;
begin
  Result := EmptyStr;
  if (FColumns.Count <> FValues.Count) then
  begin
    raise ESQLBuilderException.Create('Columns count and Values count must be equal!');
  end;
  if (FTable = nil) or (FTable.Name.Trim.IsEmpty) then
  begin
    Exit;
  end;

  vStringBuilder := TStringBuilder.Create;
  try
    vStringBuilder.Append(Format('update %s set ', [FTable.Name]));
    for i := 0 to Pred(FColumns.Count) do
    begin
      if i = 0 then
      begin
        vStringBuilder.AppendLine;
      end
      else
      begin
        vStringBuilder.Append(', ').AppendLine;
      end;
      vStringBuilder.AppendFormat(' %0:S = %1:S', [FColumns[i], FValues[i].ToString]);
    end;
    Result := vStringBuilder.ToString;
  finally
    FreeAndNil(vStringBuilder);
  end;
end;

function TSQLUpdate.SetValues(const AValues: array of TValue): ISQLUpdate;
var
  vValues: array of ISQLValue;
  i: Integer;
begin
  SetLength(vValues, Length(AValues));
  for i := Low(AValues) to High(AValues) do
  begin
    vValues[i] := TSQLValue.Create(AValues[i]);
  end;
  Result := SetValues(vValues);
end;

function TSQLUpdate.SetValues(AValues: array of ISQLValue): ISQLUpdate;
var
  i: Integer;
begin
  FValues.Clear;
  for i := Low(AValues) to High(AValues) do
  begin
    FValues.Add(AValues[i]);
  end;
  Result := Self;
end;

function TSQLUpdate.Table(ATable: ISQLTable): ISQLUpdate;
begin
  FTable := ATable;
  Result := Self;
end;

function TSQLUpdate.Table(const AName: string): ISQLUpdate;
begin
  Result := Table(TSQLTable.Create(AName));
end;

function TSQLUpdate.Where(AWhere: ISQLWhere): ISQLWhere;
begin
  FWhere.CopyOf(AWhere);
  Result := FWhere;
end;

function TSQLUpdate.Where(const AColumn: string): ISQLWhere;
begin
  FWhere.Column(AColumn);
  Result := FWhere;
end;

function TSQLUpdate.Where: ISQLWhere;
begin
  Result := FWhere;
end;

{ TSQLInsert }

procedure TSQLInsert.AfterConstruction;
begin
  inherited AfterConstruction;
  SetStatementType(stInsert);
  FColumns := TStringList.Create;
  FValues := TList<ISQLValue>.Create;
  FTable := nil;
end;

procedure TSQLInsert.BeforeDestruction;
begin
  FreeAndNil(FColumns);
  FreeAndNil(FValues);
  inherited BeforeDestruction;
end;

function TSQLInsert.Columns(const AColumns: array of string): ISQLInsert;
var
  i: Integer;
begin
  FColumns.Clear;
  for i := Low(AColumns) to High(AColumns) do
  begin
    if AColumns[i].Trim.IsEmpty then
    begin
      raise ESQLBuilderException.Create('The column can not be empty!');
    end;
    FColumns.Add(AColumns[i]);
  end;
  Result := Self;
end;

function TSQLInsert.ColumnValue(const AColumn: string; const AValue: TValue): ISQLInsert;
begin
  Result := ColumnValue(AColumn, TSQLValue.Create(AValue));
end;

function TSQLInsert.ColumnValue(const AColumn: string; AValue: ISQLValue): ISQLInsert;
begin
  if AColumn.Trim.IsEmpty then
  begin
    raise ESQLBuilderException.Create('The column can not be empty!');
  end;
  FColumns.Add(AColumn);
  FValues.Add(AValue);
  Result := Self;
end;

function TSQLInsert.DoToString: string;
var
  vStringBuilder: TStringBuilder;
  i: Integer;
begin
  Result := EmptyStr;
  if FColumns.Count <> FValues.Count then
  begin
    raise ESQLBuilderException.Create('Columns count and Values count must be equal!');
  end;
  if (FTable = nil) or (FTable.Name.Trim.IsEmpty) then
  begin
    Exit;
  end;
  vStringBuilder := TStringBuilder.Create;
  try
    vStringBuilder
      .Append(Format('insert into %s ', [FTable.Name]))
      .AppendLine
      .Append('(');
    for i := 0 to Pred(FColumns.Count) do
    begin
      if i = 0 then
      begin
        vStringBuilder.Append(FColumns[i]);
      end
      else
      begin
        vStringBuilder
          .Append(', ')
          .AppendLine
          .Append(FColumns[i]);
      end;
    end;
    vStringBuilder
      .Append(')')
      .AppendLine
      .Append(' values ')
      .AppendLine
      .Append('(');
    for i := 0 to Pred(FValues.Count) do
    begin
      if i = 0 then
      begin
        vStringBuilder.Append(FValues[i].ToString);
      end
      else
      begin
        vStringBuilder
          .Append(', ')
          .AppendLine
          .Append(FValues[i].ToString);
      end;
    end;
    vStringBuilder.Append(')');
    Result := vStringBuilder.ToString;
  finally
    FreeAndNil(vStringBuilder);
  end;
end;

function TSQLInsert.Into(ATable: ISQLTable): ISQLInsert;
begin
  FTable := ATable;
  Result := Self;
end;

function TSQLInsert.Into(const ATable: string): ISQLInsert;
begin
  Result := Into(TSQLTable.Create(ATable));
end;

function TSQLInsert.Values(AValues: array of ISQLValue): ISQLInsert;
var
  i: Integer;
begin
  FValues.Clear;
  for i := Low(AValues) to High(AValues) do
  begin
    FValues.Add(AValues[i]);
  end;
  Result := Self;
end;

function TSQLInsert.Values(const AValues: array of TValue): ISQLInsert;
var
  vValues: array of ISQLValue;
  i: Integer;
begin
  SetLength(vValues, Length(AValues));
  for i := Low(AValues) to High(AValues) do
  begin
    vValues[i] := TSQLValue.Create(AValues[i]);
  end;
  Result := Values(vValues);
end;

{ TSQLCoalesce }

function TSQLCoalesce.Alias(const AAlias: string): ISQLCoalesce;
begin
  FAlias := AAlias;
  Result := Self;
end;

function TSQLCoalesce.&As(const AAlias: string): ISQLCoalesce;
begin
  Result := Alias(AAlias);
end;

constructor TSQLCoalesce.Create;
begin
  FTerm := EmptyStr;
  FValue := nil;
  FAlias := EmptyStr;
end;

function TSQLCoalesce.DoToString: string;
begin
  Result := Format('coalesce(%s, %s)', [FTerm, FValue.ToString]);
  if not FAlias.Trim.IsEmpty then
  begin
    Result := Format('%s as %s', [Result, FAlias]);
  end;
end;

function TSQLCoalesce.Expression(const ACaseTerm: ISQLCase): ISQLCoalesce;
begin
  Result := Expression(ACaseTerm.ToString);
end;

function TSQLCoalesce.Expression(const AAggregateTerm: ISQLAggregate): ISQLCoalesce;
begin
  Result := Expression(AAggregateTerm.ToString);
end;

function TSQLCoalesce.Expression(const ATerm: string): ISQLCoalesce;
begin
  FTerm := ATerm;
  Result := Self;
end;

function TSQLCoalesce.Value(const AValue: TValue): ISQLCoalesce;
begin
  Result := Value(TSQLValue.Create(AValue));
end;

function TSQLCoalesce.Value(AValue: ISQLValue): ISQLCoalesce;
begin
  FValue := AValue;
  Result := Self;
end;

{ TSQLAggregate }

function TSQLAggregate.Alias(const AAlias: string): ISQLAggregate;
begin
  FAlias := AAlias;
  Result := Self;
end;

function TSQLAggregate.&As(const AAlias: string): ISQLAggregate;
begin
  Result := Alias(AAlias);
end;

function TSQLAggregate.Avg: ISQLAggregate;
begin
  FFunction := aggAvg;
  Result := Self;
end;

function TSQLAggregate.Avg(ACaseTerm: ISQLCase): ISQLAggregate;
begin
  Result := Self.Avg.Expression(ACaseTerm);
end;

function TSQLAggregate.Avg(const AExpression: string): ISQLAggregate;
begin
  Result := Self.Avg.Expression(AExpression);
end;

function TSQLAggregate.Avg(ACoalesceExpression: ISQLCoalesce): ISQLAggregate;
begin
  Result := Self.Avg.Expression(ACoalesceExpression);
end;

function TSQLAggregate.Condition(const AOp: TSQLOperator; const AValue: TValue): ISQLAggregate;
begin
  Result := Condition(AOp, TSQLValue.Create(AValue));
end;

function TSQLAggregate.Condition(const AOp: TSQLOperator; AValue: ISQLValue): ISQLAggregate;
begin
  FOp := AOp;
  FValue := AValue;
  FIsCondition := True;
  Result := Self;
end;

function TSQLAggregate.Condition(const AOp: TSQLOperator): ISQLAggregate;
begin
  Result := Condition(AOp, nil);
end;

function TSQLAggregate.Count(const AExpression: string): ISQLAggregate;
begin
  Result := Self.Count.Expression(AExpression);
end;

function TSQLAggregate.Count: ISQLAggregate;
begin
  FFunction := aggCount;
  Result := Self;
end;

function TSQLAggregate.Count(ACaseTerm: ISQLCase): ISQLAggregate;
begin
  Result := Self.Count.Expression(ACaseTerm);
end;

function TSQLAggregate.Count(ACoalesceExpression: ISQLCoalesce): ISQLAggregate;
begin
  Result := Self.Count.Expression(ACoalesceExpression);
end;

constructor TSQLAggregate.Create;
begin
  FFunction := aggAvg;
  FTerm := EmptyStr;
  FAlias := EmptyStr;
  FIsCondition := False;
  FOp := opEqual;
  FValue := nil;
end;

function TSQLAggregate.DoToString: string;
var
  vValue: string;
begin
  case FFunction of
    aggAvg: Result := 'avg';
    aggCount: Result := 'count';
    aggMax: Result := 'max';
    aggMin: Result := 'min';
    aggSum: Result := 'sum';
  end;
  Result := Format('%s (%s)', [Result, FTerm]);
  if FIsCondition then
  begin
    vValue := FValue.ToString;
    if not vValue.Trim.IsEmpty then
    begin
      vValue := Format(' %s', [vValue]);
    end;
    Result := Format('%s %s %s', [Result, SQL_OPERATOR[FOp], vValue]);
  end;
  if not FAlias.Trim.IsEmpty then
  begin
    Result := Format('%s as %s', [Result, FAlias]);
  end;
end;

function TSQLAggregate.Expression(ACoalesceTerm: ISQLCoalesce): ISQLAggregate;
begin
  Result := Expression(ACoalesceTerm.ToString);
end;

function TSQLAggregate.Expression(const ATerm: string): ISQLAggregate;
begin
  FTerm := ATerm;
  Result := Self;
end;

function TSQLAggregate.Expression(ACaseTerm: ISQLCase): ISQLAggregate;
begin

end;

function TSQLAggregate.Max(ACoalesceExpression: ISQLCoalesce): ISQLAggregate;
begin
  Result := Self.Max.Expression(ACoalesceExpression);
end;

function TSQLAggregate.Max(ACaseTerm: ISQLCase): ISQLAggregate;
begin
  Result := Self.Max.Expression(ACaseTerm);
end;

function TSQLAggregate.Max(const AExpression: string): ISQLAggregate;
begin
  Result := Self.Max.Expression(AExpression);
end;

function TSQLAggregate.Max: ISQLAggregate;
begin
  FFunction := aggMax;
  Result := Self;
end;

function TSQLAggregate.Min(ACaseTerm: ISQLCase): ISQLAggregate;
begin
  Result := Self.Min.Expression(ACaseTerm);
end;

function TSQLAggregate.Min(ACoalesceExpression: ISQLCoalesce): ISQLAggregate;
begin
  Result := Self.Min.Expression(ACoalesceExpression);
end;

function TSQLAggregate.Min: ISQLAggregate;
begin
  FFunction := aggMin;
  Result := Self;
end;

function TSQLAggregate.Min(const AExpression: string): ISQLAggregate;
begin
  Result := Self.Min.Expression(AExpression);
end;

function TSQLAggregate.Sum(const AExpression: string): ISQLAggregate;
begin
  Result := Self.Sum.Expression(AExpression);
end;

function TSQLAggregate.Sum: ISQLAggregate;
begin
  FFunction := aggSum;
  Result := Self;
end;

function TSQLAggregate.Sum(ACoalesceExpression: ISQLCoalesce): ISQLAggregate;
begin
  Result := Self.Sum.Expression(ACoalesceExpression);
end;

function TSQLAggregate.Sum(ACaseTerm: ISQLCase): ISQLAggregate;
begin
  Result := Self.Sum.Expression(ACaseTerm);
end;

{ TSQLCase }

function TSQLCase.Alias(const AAlias: string): ISQLCase;
begin
  FAlias := AAlias;
  Result := Self;
end;

function TSQLCase.&As(const AAlias: string): ISQLCase;
begin
  Result := Alias(AAlias);
end;

constructor TSQLCase.Create;
begin
  FExpression := nil;
  FDefValue := nil;
  FCondition := nil;
  FPossibilities := TObjectList<TPossibility>.Create(True);
  FAlias := EmptyStr;
end;

destructor TSQLCase.Destroy;
begin
  FreeAndNil(FPossibilities);
  inherited;
end;

function TSQLCase.DoToString: string;
var
  vStringBuilder: TStringBuilder;
  vPossibility: TPossibility;
  vExp: string;
begin
  Result := EmptyStr;
  vExp := EmptyStr;
  if (FExpression <> nil) and (not FExpression.ToString.Trim.IsEmpty) then
  begin
    vExp := FExpression.ToString;
  end;
  vStringBuilder := TStringBuilder.Create;
  try
    vStringBuilder
      .Append(Format('case %s', [vExp]))
      .AppendLine;
    for vPossibility in FPossibilities do
    begin
      vStringBuilder
        .Append(Format('  when %s then %s', [vPossibility.Condition.ToString, vPossibility.Value.ToString]))
        .AppendLine;
    end;
    if FDefValue <> nil then
    begin
      vStringBuilder
        .Append(Format('  else %s', [FDefValue.ToString]))
        .AppendLine;
    end;
    vStringBuilder.Append(' end');
    if not FAlias.Trim.IsEmpty then
    begin
      vStringBuilder.Append(Format(' as %s', [FAlias]));
    end;
    Result := vStringBuilder.ToString;
  finally
    FreeAndNil(vStringBuilder);
  end;
end;

function TSQLCase.&Else(ADefValue: ISQLCoalesce): ISQLCase;
begin
  Result := &Else(TSQLValue.Create(ADefValue.ToString).Expression);
end;

function TSQLCase.&Else(ADefValue: ISQLAggregate): ISQLCase;
begin
  Result := &Else(TSQLValue.Create(ADefValue.ToString).Expression);
end;

function TSQLCase.&Else(ADefValue: ISQLValue): ISQLCase;
begin
  FDefValue := ADefValue;
  Result := Self;
end;

function TSQLCase.&Else(const ADefValue: TValue): ISQLCase;
begin
  Result := &Else(TSQLValue.Create(ADefValue));
end;

function TSQLCase.&End: ISQLCase;
begin
  Result := Self;
end;

function TSQLCase.Expression(const ATerm: string): ISQLCase;
begin
  Result := Expression(TSQLValue.Create(ATerm).Expression);
end;

function TSQLCase.Expression(ATerm: ISQLValue): ISQLCase;
begin
  FExpression := ATerm;
  Result := Self;
end;

function TSQLCase.&Then(AValue: ISQLValue): ISQLCase;
begin
  if FCondition = nil then
  begin
    raise ESQLBuilderException.Create('You must call the When first!');
  end;
  FPossibilities.Add(TPossibility.Create(FCondition, AValue));
  FCondition := nil;
  Result := Self;
end;

function TSQLCase.&Then(AValue: ISQLAggregate): ISQLCase;
begin
  Result := &Then(TSQLValue.Create(AValue.ToString).Expression);
end;

function TSQLCase.&Then(const AValue: TValue): ISQLCase;
begin
  Result := &Then(TSQLValue.Create(AValue));
end;

function TSQLCase.&Then(AValue: ISQLCoalesce): ISQLCase;
begin
  Result := &Then(TSQLValue.Create(AValue.ToString).Expression);
end;

function TSQLCase.When(const ACondition: TValue): ISQLCase;
begin
  Result := When(TSQLValue.Create(ACondition));
end;

function TSQLCase.When(ACondition: ISQLValue): ISQLCase;
begin
  FCondition := ACondition;
  Result := Self;
end;

{ TSQLCase.TPossibility }

constructor TSQLCase.TPossibility.Create(ACondition, AValue: ISQLValue);
begin
  FCondition := ACondition;
  FValue := AValue;
end;

{ SQL }

class function SQL.Aggregate(const AFunction: TSQLAggFunction; const AExpression: string): ISQLAggregate;
begin
  Result := SQL.Aggregate;
  case AFunction of
    aggAvg: Result.Avg;
    aggCount: Result.Count;
    aggMax: Result.Max;
    aggMin: Result.Min;
    aggSum: Result.Sum;
  end;
  Result.Expression(AExpression);
end;

class function SQL.Aggregate(const AFunction: TSQLAggFunction; AExpression: ISQLCoalesce): ISQLAggregate;
begin
  Result := SQL.Aggregate(AFunction, AExpression.ToString);
end;

class function SQL.Aggregate: ISQLAggregate;
begin
  Result := TSQLAggregate.Create;
end;

class function SQL.&Case: ISQLCase;
begin
  Result := TSQLCase.Create;
end;

class function SQL.&Case(const AExpression: string): ISQLCase;
begin
  Result := SQL.&Case(TSQLValue.Create(AExpression).Expression);
end;

class function SQL.&Case(AExpression: ISQLValue): ISQLCase;
begin
  Result := SQL.&Case();
  Result.Expression(AExpression);
end;

class function SQL.Coalesce(AExpression: ISQLCase; const AValue: TValue): ISQLCoalesce;
begin
  Result := SQL.Coalesce(AExpression.ToString, SQL.Value(AValue));
end;

class function SQL.Coalesce(AExpression: ISQLCase; AValue: ISQLValue): ISQLCoalesce;
begin
  Result := SQL.Coalesce;
  Result.Expression(AExpression);
  Result.Value(AValue);
end;

class function SQL.Coalesce: ISQLCoalesce;
begin
  Result := TSQLCoalesce.Create;
end;

class function SQL.Coalesce(const AExpression: string; const AValue: TValue): ISQLCoalesce;
begin
  Result := SQL.Coalesce(AExpression, SQL.Value(AValue));
end;

class function SQL.Coalesce(const AExpression: string; AValue: ISQLValue): ISQLCoalesce;
begin
  Result := SQL.Coalesce;
  Result.Expression(AExpression);
  Result.Value(AValue);
end;

class function SQL.Coalesce(AExpression: ISQLAggregate; const AValue: TValue): ISQLCoalesce;
begin
  Result := SQL.Coalesce(AExpression.ToString, SQL.Value(AValue));
end;

class function SQL.Coalesce(AExpression: ISQLAggregate; AValue: ISQLValue): ISQLCoalesce;
begin
  Result := SQL.Coalesce(AExpression.ToString, AValue);
end;

constructor SQL.Create;
begin
  raise ESQLBuilderException.Create(CanNotBeInstantiatedException);
end;

class function SQL.Delete: ISQLDelete;
begin
  Result := TSQLDelete.Create;
end;

class function SQL.From(ATable: ISQLTable): ISQLFrom;
begin
  Result := TSQLFrom.Create(ATable);
end;

class function SQL.FullJoin: ISQLJoin;
begin
  Result := SQL.FullJoin(nil);
end;

class function SQL.FullJoin(ATable: ISQLTable): ISQLJoin;
begin
  Result := TSQLJoin.Create(ATable, jtFull, EmptyStr);
end;

class function SQL.FullJoin(const ATable: string): ISQLJoin;
begin
  Result := SQL.FullJoin(SQL.Table(ATable));
end;

class function SQL.GroupBy(const AColumns: array of string): ISQLGroupBy;
begin
  Result := SQL.GroupBy;
  Result.Columns(AColumns);
end;

class function SQL.GroupBy(const AColumn: string): ISQLGroupBy;
begin
  Result := SQL.GroupBy;
  Result.Column(AColumn);
end;

class function SQL.GroupBy: ISQLGroupBy;
begin
  Result := TSQLGroupBy.Create(nil);
end;

class function SQL.Having(AExpression: ISQLAggregate): ISQLHaving;
begin
  Result := SQL.Having;
  Result.Expression(AExpression);
end;

class function SQL.Having(AExpressions: array of ISQLAggregate): ISQLHaving;
begin
  Result := SQL.Having;
  Result.Expressions(AExpressions);
end;

class function SQL.Having(const AExpressions: array of string): ISQLHaving;
begin
  Result := SQL.Having;
  Result.Expressions(AExpressions);
end;

class function SQL.Having(const AExpression: string): ISQLHaving;
begin
  Result := SQL.Having;
  Result.Expression(AExpression);
end;

class function SQL.Having: ISQLHaving;
begin
  Result := TSQLHaving.Create(nil);
end;

class function SQL.Insert: ISQLInsert;
begin
  Result := TSQLInsert.Create;
end;

class function SQL.Join(ATable: ISQLTable): ISQLJoin;
begin
  Result := TSQLJoin.Create(ATable, jtInner, EmptyStr);
end;

class function SQL.Join(const ATable: string): ISQLJoin;
begin
  Result := SQL.Join(SQL.Table(ATable));
end;

class function SQL.Join: ISQLJoin;
begin
  Result := SQL.Join(nil);
end;

class function SQL.JoinTerm: ISQLJoinTerm;
begin
  Result := TSQLJoinTerm.Create;
end;

class function SQL.LeftJoin: ISQLJoin;
begin
  Result := SQL.LeftJoin(nil);
end;

class function SQL.LeftJoin(ATable: ISQLTable): ISQLJoin;
begin
  Result := TSQLJoin.Create(ATable, jtLeft, EmptyStr);
end;

class function SQL.LeftJoin(const ATable: string): ISQLJoin;
begin
  Result := SQL.LeftJoin(SQL.Table(ATable));
end;

class function SQL.OrderBy: ISQLOrderBy;
begin
  Result := TSQLOrderBy.Create(nil);
end;

class function SQL.OrderBy(const AColumn: string; const ASortType: TSQLSort): ISQLOrderBy;
begin
  Result := SQL.OrderBy;
  Result.Column(AColumn, ASortType);
end;

class function SQL.OrderBy(const AColumns: array of string; const ASortType: TSQLSort): ISQLOrderBy;
begin
  Result := SQL.OrderBy;
  Result.Columns(AColumns, ASortType);
end;

class function SQL.RightJoin: ISQLJoin;
begin
  Result := SQL.RightJoin(nil);
end;

class function SQL.RightJoin(const ATable: string): ISQLJoin;
begin
  Result := SQL.RightJoin(SQL.Table(ATable));
end;

class function SQL.RightJoin(ATable: ISQLTable): ISQLJoin;
begin
  Result := TSQLJoin.Create(ATable, jtRight, EmptyStr);
end;

class function SQL.Select: ISQLSelect;
begin
  Result := TSQLSelect.Create;
end;

class function SQL.Table(const AName: string): ISQLTable;
begin
  Result := TSQLTable.Create(AName);
end;

class function SQL.Update: ISQLUpdate;
begin
  Result := TSQLUpdate.Create;
end;

class function SQL.Value(const AValue: TValue): ISQLValue;
begin
  Result := TSQLValue.Create(AValue);
end;

class function SQL.Where(const AColumn: string): ISQLWhere;
begin
  Result := SQL.Where();
  Result.Column(AColumn);
end;

class function SQL.Where: ISQLWhere;
begin
  Result := TSQLWhere.Create(nil);
end;

end.
