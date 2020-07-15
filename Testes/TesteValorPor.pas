unit TesteValorPor;

interface

uses
  DUnitX.TestFramework,
  Vcl.StdCtrls,
  ValorPor;

type

  [TestFixture]
  TTestValorPor = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestValorExtensoZerado;
    [Test]
    procedure TestExceptionValorNegativo;
    [Test]
    procedure TestMudaLabelAssociado;
    [Test]
    procedure TestMudaMoedaNoSingular;
    [Test]
    procedure TestMudaMoedaNoPlural;
    [Test]
    [TestCase('TestaValorNegativo', '20,VINTE REAIS')]
    [TestCase('TesteValorPositivo', '4.50,QUATRO REAIS, CINQUENTA CENTAVOS')]
    [TestCase('TesteValorPositivo',
      '24.13,VINTE E QUATRO REAIS, TREZE CENTAVOS')]
    procedure TestValoresPorExtenso(const AValue1: Double;
      const AValue2: string);
  end;

implementation

uses DUnitX.Assert.Ex;

var
  objValor: TValorPorExtenso;

procedure TTestValorPor.Setup;
begin
  objValor := TValorPorExtenso.Create(nil);
end;

procedure TTestValorPor.TearDown;
begin
  objValor.Destroy;
end;

procedure TTestValorPor.TestValorExtensoZerado;
begin
  objValor.Valor := 0;
  Assert.Contains(objValor.Texto, 'ZERO REAIS');
end;

procedure TTestValorPor.TestExceptionValorNegativo;
begin
  Assert.WillRaiseAny(
    procedure
    begin
      objValor.Valor :=  -16;
    end, '');
end;

procedure TTestValorPor.TestMudaLabelAssociado;
var lLabelAssociado: TLabel;
begin
  lLabelAssociado := TLabel.Create(nil);
  lLabelAssociado.Caption := 'Valor Padrão';

  Assert.AreEqual('Valor Padrão', lLabelAssociado.Caption);

  objValor.LabelAssociado := lLabelAssociado;
  objValor.Valor := 10;

  Assert.AreEqual(objValor.Texto, lLabelAssociado.Caption);
end;

procedure TTestValorPor.TestMudaMoedaNoPlural;
begin
  Assert.NotImplemented;
end;

procedure TTestValorPor.TestMudaMoedaNoSingular;
begin
  Assert.NotImplemented;
end;

procedure TTestValorPor.TestValoresPorExtenso(const AValue1: Double;
const AValue2: String);
begin
  objValor.Valor := AValue1;
  Assert.Contains(objValor.Texto, AValue2);
end;

initialization

TDUnitX.RegisterTestFixture(TTestValorPor);

end.
