unit TesteSQLBuilder.Select;

interface

uses
  DUnitX.TestFramework,
  DUnitX.Assert.Ex;

type

  [ TestFixture ]
  TTestSQLBuilderSelect = class( TObject )
    public
      [ Test ]
      procedure TestSelectAllFields;

      [ Test ]
      procedure TestSelectAllFieldsWithTables;

      [ Test ]
      procedure TestSelectFields;

      [ Test ]
      procedure TestSelectFieldsWithJoins;

      [ Test ]
      procedure TestSelectFieldsWithJoinsAndOperatorsAND_OR;

      [ Test ]
      procedure TestSelectFieldsWithJoinsAndValues;

      [ Test ]
      procedure TestSelectComplete;
  end;

implementation

uses
  SQLBuilder;

{ TTestSQLBuilder }

procedure TTestSQLBuilderSelect.TestSelectAllFields;
const
  SELECT_ALL_FIELDS =
    'select' + sLineBreak +
    ' *' + sLineBreak +
    'from Customers';
var
  sSQL: string;
begin
  sSQL := SQL
            .Select
            .AllColumns
            .From('Customers')
            .ToString;
  Assert.AreEqual(SELECT_ALL_FIELDS, sSQL);

  sSQL := SQL
            .Select
            .AllColumns
            .From(SQL.From(SQL.Table('Customers')))
            .ToString;
  Assert.AreEqual(SELECT_ALL_FIELDS, sSQL);
end;

procedure TTestSQLBuilderSelect.TestSelectAllFieldsWithTables;
const
  SELECT_ALL_FIELDS_WITH_TABLES =
    'select' + sLineBreak +
    ' *' + sLineBreak +
    'from Customers, Places';

var
  sSQL: string;
begin
  sSQL := SQL
            .Select
            .AllColumns
            .From(['Customers', 'Places'])
            .ToString;
  Assert.AreEqual(SELECT_ALL_FIELDS_WITH_TABLES, sSQL);

  sSQL := SQL
            .Select
            .AllColumns
            .From([SQL.From(SQL.Table('Customers')),
                   SQL.From(SQL.Table('Places'))])
            .ToString;
  Assert.AreEqual(SELECT_ALL_FIELDS_WITH_TABLES, sSQL);
end;

procedure TTestSQLBuilderSelect.TestSelectComplete;
const
  SELECT_COMPLETE =
    'select' + sLineBreak +
    ' id_customer,' + sLineBreak +
    ' name_customer,' + sLineBreak +
    ' doc_customer' + sLineBreak +
    'from Customers' + sLineBreak +
    'join CustomersPhones on (Customers.id_customer = CustomersPhones.id_cusomer)' + sLineBreak +
    'left join CustomersPhones on (Customers.id_customer <> CustomersPhones.id_cusomer)' + sLineBreak +
    'right join CustomersPhones on (Customers.id_customer > CustomersPhones.id_cusomer)' + sLineBreak +
    'group by' + sLineBreak +
    ' id_customer,' + sLineBreak +
    ' name_customer,' + sLineBreak +
    ' doc_customer' + sLineBreak +
    'having ((doc_customer > 0))' + sLineBreak +
    'order by' + sLineBreak +
    ' doc_customer,' + sLineBreak +
    ' name_customer';

var
  sSQL: string;
begin
  sSQL := SQL
            .Select
              .Column('id_customer')
              .Column('name_customer')
              .Column('doc_customer')
            .From('Customers')
            .Join('CustomersPhones', '(Customers.id_customer = CustomersPhones.id_cusomer)')
            .LeftJoin('CustomersPhones', '(Customers.id_customer <> CustomersPhones.id_cusomer)')
            .RightJoin('CustomersPhones', '(Customers.id_customer > CustomersPhones.id_cusomer)')
            .GroupBy
              .Column('id_customer')
              .Column('name_customer')
              .Column('doc_customer')
            .Having.Expression('(doc_customer > 0)')
            .OrderBy
              .Column('doc_customer')
              .Column('name_customer')
            .ToString;
  Assert.AreEqual(SELECT_COMPLETE, sSQL);

  sSQL := SQL
            .Select
              .Column('id_customer')
              .Column('name_customer')
              .Column('doc_customer')
            .From('Customers')
            .Join(SQL
                    .Join('CustomersPhones')
                    .Condition(SQL
                                 .JoinTerm
                                 .Left('Customers.id_customer')
                                 .Op(opEqual)
                                 .Right('CustomersPhones.id_cusomer')))
            .LeftJoin(SQL
                        .LeftJoin('CustomersPhones')
                        .Condition(SQL
                                     .JoinTerm
                                     .Left('Customers.id_customer')
                                     .Op(opDifferent)
                                     .Right('CustomersPhones.id_cusomer')))
            .RightJoin(SQL
                         .RightJoin('CustomersPhones')
                         .Condition(SQL
                                      .JoinTerm
                                      .Left('Customers.id_customer')
                                      .Op(opGreater)
                                      .Right('CustomersPhones.id_cusomer')))
            .GroupBy(SQL
                       .GroupBy
                       .Column('id_customer')
                       .Column('name_customer')
                       .Column('doc_customer'))
            .Having(SQL
                      .Having
                      .Expression('(doc_customer > 0)'))
            .OrderBy(SQL
                       .OrderBy
                       .Column('doc_customer')
                       .Column('name_customer'))
            .ToString;
  Assert.AreEqual(SELECT_COMPLETE, sSQL);
end;

procedure TTestSQLBuilderSelect.TestSelectFields;
const
  SELECT_FIELDS =
    'select' + sLineBreak +
    ' id_customer,' + sLineBreak +
    ' name_customer,' + sLineBreak +
    ' doc_customer' + sLineBreak +
    'from Customers';

var
  sSQL: string;
begin
  sSQL := SQL
            .Select
              .Column('id_customer')
              .Column('name_customer')
              .Column('doc_customer')
            .From('Customers')
            .ToString;
  Assert.AreEqual(SELECT_FIELDS, sSQL);
end;

procedure TTestSQLBuilderSelect.TestSelectFieldsWithJoins;
const
  SELECT_FIELDS_WITH_JOINS =
    'select' + sLineBreak +
    ' id_customer,' + sLineBreak +
    ' name_customer,' + sLineBreak +
    ' doc_customer' + sLineBreak +
    'from Customers' + sLineBreak +
    'join CustomersPhones on (Customers.id_customer = CustomersPhones.id_customer)' + sLineBreak +
    'left join CustomersPhones on (Customers.id_customer <> CustomersPhones.id_customer)' + sLineBreak +
    'right join CustomersPhones on (Customers.id_customer > CustomersPhones.id_customer)' + sLineBreak +
    'full join CustomersPhones on (Customers.id_customer < CustomersPhones.id_customer)';

var
  sSQL: string;
begin
  sSQL := SQL
            .Select
              .Column('id_customer')
              .Column('name_customer')
              .Column('doc_customer')
            .From('Customers')
            .Join('CustomersPhones', '(Customers.id_customer = CustomersPhones.id_customer)')
            .LeftJoin('CustomersPhones', '(Customers.id_customer <> CustomersPhones.id_customer)')
            .RightJoin('CustomersPhones', '(Customers.id_customer > CustomersPhones.id_customer)')
            .FullJoin('CustomersPhones', '(Customers.id_customer < CustomersPhones.id_customer)')
            .ToString;
  Assert.AreEqual(SELECT_FIELDS_WITH_JOINS, sSQL);

  sSQL := SQL
            .Select
              .Column('id_customer')
              .Column('name_customer')
              .Column('doc_customer')
            .From('Customers')
            .Join(SQL
                    .Join('CustomersPhones')
                    .Condition(SQL
                                 .JoinTerm
                                 .Left('Customers.id_customer')
                                 .Op(opEqual)
                                 .Right('CustomersPhones.id_customer')))
            .LeftJoin(SQL
                        .LeftJoin('CustomersPhones')
                        .Condition(SQL
                                     .JoinTerm
                                     .Left('Customers.id_customer')
                                     .Op(opDifferent)
                                     .Right('CustomersPhones.id_customer')))
            .RightJoin(SQL
                         .RightJoin('CustomersPhones')
                         .Condition(SQL
                                      .JoinTerm
                                      .Left('Customers.id_customer')
                                      .Op(opGreater)
                                      .Right('CustomersPhones.id_customer')))
            .FullJoin(SQL
                        .FullJoin('CustomersPhones')
                        .Condition(SQL
                                     .JoinTerm
                                     .Left('Customers.id_customer')
                                     .Op(opLess)
                                     .Right('CustomersPhones.id_customer')))
            .ToString;
  Assert.AreEqual(SELECT_FIELDS_WITH_JOINS, sSQL);
end;

procedure TTestSQLBuilderSelect.TestSelectFieldsWithJoinsAndOperatorsAND_OR;
const
  SELECT_FIELDS_WITH_JOINS_AND_OPERATORS_AND_OR =
    'select' + sLineBreak +
    ' id_customer,' + sLineBreak +
    ' name_customer,' + sLineBreak +
    ' doc_customer' + sLineBreak +
    'from Customers' + sLineBreak +
    'join CustomersPhones on (Customers.id_customer = CustomersPhones.id_customer)' + sLineBreak +
    ' and (Customers.name_customer = CustomersPhones.name_customer)' + sLineBreak +
    ' or (Customers.name_customer = CustomersPhones.name_customer)' + sLineBreak +
    'left join CustomersPhones on (Customers.id_customer = CustomersPhones.id_customer)' + sLineBreak +
    ' and (Customers.name_customer = CustomersPhones.name_customer)' + sLineBreak +
    ' or (Customers.name_customer = CustomersPhones.name_customer)' + sLineBreak +
    'right join CustomersPhones on (Customers.id_customer = CustomersPhones.id_customer)' + sLineBreak +
    ' and (Customers.name_customer = CustomersPhones.name_customer)' + sLineBreak +
    ' or (Customers.name_customer = CustomersPhones.name_customer)' + sLineBreak +
    'full join CustomersPhones on (Customers.id_customer = CustomersPhones.id_customer)' + sLineBreak +
    ' and (Customers.name_customer = CustomersPhones.name_customer)' + sLineBreak +
    ' or (Customers.name_customer = CustomersPhones.name_customer)';

var
  sSQL: string;
begin
  sSQL := SQL
            .Select
              .Column('id_customer')
              .Column('name_customer')
              .Column('doc_customer')
            .From('Customers')
            .Join(SQL
                    .Join('CustomersPhones')
                    .Condition(SQL
                                 .JoinTerm
                                 .Left('Customers.id_customer')
                                 .Op(opEqual)
                                 .Right('CustomersPhones.id_customer'))
                  .&And(SQL
                          .JoinTerm
                          .Left('Customers.name_customer')
                          .Op(opEqual)
                          .Right('CustomersPhones.name_customer'))
                  .&Or(SQL
                         .JoinTerm
                         .Left('Customers.name_customer')
                         .Op(opEqual)
                         .Right('CustomersPhones.name_customer')))
            .LeftJoin(SQL
                        .LeftJoin('CustomersPhones')
                        .Condition(SQL
                                     .JoinTerm
                                     .Left('Customers.id_customer')
                                     .Op(opEqual)
                                     .Right('CustomersPhones.id_customer'))
                      .&And(SQL
                              .JoinTerm
                              .Left('Customers.name_customer')
                              .Op(opEqual)
                              .Right('CustomersPhones.name_customer'))
                      .&Or(SQL
                             .JoinTerm
                             .Left('Customers.name_customer')
                             .Op(opEqual)
                             .Right('CustomersPhones.name_customer')))
            .RightJoin(SQL
                         .RightJoin('CustomersPhones')
                         .Condition(SQL
                                      .JoinTerm
                                      .Left('Customers.id_customer')
                                      .Op(opEqual)
                                      .Right('CustomersPhones.id_customer'))
                       .&And(SQL
                               .JoinTerm
                               .Left('Customers.name_customer')
                               .Op(opEqual)
                               .Right('CustomersPhones.name_customer'))
                       .&Or(SQL
                              .JoinTerm
                              .Left('Customers.name_customer')
                              .Op(opEqual)
                              .Right('CustomersPhones.name_customer')))
            .FullJoin(SQL
                        .FullJoin('CustomersPhones')
                        .Condition(SQL
                                     .JoinTerm
                                     .Left('Customers.id_customer')
                                     .Op(opEqual)
                                     .Right('CustomersPhones.id_customer'))
                      .&And(SQL
                              .JoinTerm
                              .Left('Customers.name_customer')
                              .Op(opEqual)
                              .Right('CustomersPhones.name_customer'))
                      .&Or(SQL
                             .JoinTerm
                             .Left('Customers.name_customer')
                             .Op(opEqual)
                             .Right('CustomersPhones.name_customer')))
            .ToString;
  Assert.AreEqual(SELECT_FIELDS_WITH_JOINS_AND_OPERATORS_AND_OR, sSQL);
end;

procedure TTestSQLBuilderSelect.TestSelectFieldsWithJoinsAndValues;
const
  SELECT_FIELDS_WITH_JOINS_AND_VALUES =
    'select' + sLineBreak +
    ' id_customer,' + sLineBreak +
    ' name_customer,' + sLineBreak +
    ' doc_customer' + sLineBreak +
    'from Customers' + sLineBreak +
    'join CustomersPhones on (1 = 1)' + sLineBreak +
    'left join CustomersPhones on (1 <> 1)' + sLineBreak +
    'right join CustomersPhones on (''SDK'' = ''SDK'')' + sLineBreak +
    'full join CustomersPhones on (''TEST'' = ''TEST'')';

var
  sSQL: string;
begin
  sSQL := SQL
            .Select
              .Column('id_customer')
              .Column('name_customer')
              .Column('doc_customer')
            .From('Customers')
            .Join(SQL
                    .Join('CustomersPhones')
                    .Condition(SQL.JoinTerm.Left(SQL.Value(1))
                    .Op(opEqual)
                    .Right(SQL.Value(1))))
            .LeftJoin(SQL
                        .LeftJoin('CustomersPhones')
                        .Condition(SQL.JoinTerm.Left(SQL.Value(1))
                        .Op(opDifferent)
                        .Right(SQL.Value(1))))
            .RightJoin(SQL
                         .RightJoin('CustomersPhones')
                         .Condition(SQL.JoinTerm.Left(SQL.Value('SDK'))
                         .Op(opEqual)
                         .Right(SQL.Value('SDK'))))
            .FullJoin(SQL
                        .FullJoin('CustomersPhones')
                        .Condition(SQL.JoinTerm.Left(SQL.Value('TEST'))
                        .Op(opEqual)
                        .Right(SQL.Value('TEST'))))
            .ToString;
  Assert.AreEqual(SELECT_FIELDS_WITH_JOINS_AND_VALUES, sSQL);
end;

initialization

TDUnitX.RegisterTestFixture( TTestSQLBuilderSelect );

end.
