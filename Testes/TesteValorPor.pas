unit TesteValorPor;

interface

uses
  DUnitX.TestFramework, ValorPor;

type

  [TestFixture]
  TTestValorPor = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    // Sample Methods
    // Simple single Test
    [Test]
    procedure TestValorExtensoZerado;
    // Test with TestCase Attribute to supply parameters.
    [Test]
    [TestCase('TestaValorNegativo', '20,VINTE REAIS')]
    [TestCase('TesteValorPositivo', '4.50,QUATRO REAIS, CINQUENTA CENTAVOS')]
    [TestCase('TesteValorPositivo', '24.13,VINTE E QUATRO REAIS, TREZE CENTAVOS')]
    procedure TestValoresPorExtenso(const AValue1: Double;
      const AValue2: string);

    [Test]
    procedure TestExceptionValorNegativo;
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
  Assert.NotImplemented;
end;

procedure TTestValorPor.TestValoresPorExtenso(
  const AValue1: Double;
  const AValue2: String);
begin
  objValor.Valor := AValue1;
  Assert.Contains(objValor.Texto, AValue2);
end;

initialization

TDUnitX.RegisterTestFixture(TTestValorPor);

end.
