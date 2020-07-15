unit TesteValorPor;

interface

uses
  DUnitX.TestFramework,
  Vcl.StdCtrls,
  ValorPor;

type

  [ TestFixture ]
  TTestValorPor = class( TObject )
  public
    [ Setup ]
    procedure Setup;
    [ TearDown ]
    procedure TearDown;
    [ Test ]
    procedure TestValorExtensoZerado;
    [ Test ]
    procedure TestExceptionValorNegativo;
    [ Test ]
    procedure TestMudaLabelAssociado;
    [ Test ]
    procedure TestMudaMoedaNoSingular;
    [ Test ]
    procedure TestMudaMoedaNoPlural;
    [ Test ]
    [ TestCase( 'TestaValorAbaixo10',
      '4.50,QUATRO REAIS, CINQUENTA CENTAVOS' ) ]
    [ TestCase( 'TestaValorEntre10e100',
      '34.80,TRINTA E QUATRO REAIS, OITENTA CENTAVOS' ) ]
    [ TestCase( 'TestaValorMilhar',
      '1569.80,UM MIL E QUINHENTOS E SESSENTA E NOVE REAIS, OITENTA CENTAVOS' )
      ]
    [ TestCase( 'TestaValorMilhar',
      '11569.80,ONZE MIL E QUINHENTOS E SESSENTA E NOVE REAIS, OITENTA CENTAVOS' )
      ]
    [ TestCase( 'TestaValorMilhao',
      '1020840.80,UM MILHÃO, VINTE MIL, OITOCENTOS E QUARENTA REAIS' ) ]
    [ TestCase( 'TestaValorBilhao',
      '2145543908.98,DOIS BILHÕES, CENTO E QUARENTA E CINCO MILHÕES, QUINHENTOS E QUARENTA E TRÊS MIL, NOVECENTOS E OITO REAIS, NOVENTA E OITO CENTAVOS' )
      ]
    procedure TestValoresPorExtenso( const AValue1: Double;
      const AValue2: string );
  end;

implementation

uses DUnitX.Assert.Ex;

var
  objValor: TValorPorExtenso;

procedure TTestValorPor.Setup;
begin
  objValor := TValorPorExtenso.Create( nil );
end;

procedure TTestValorPor.TearDown;
begin
  objValor.Destroy;
end;

procedure TTestValorPor.TestValorExtensoZerado;
begin
  objValor.Valor := 0;
  Assert.Contains(
    objValor.Texto,
    'ZERO REAIS' );
end;

procedure TTestValorPor.TestExceptionValorNegativo;
begin
  Assert.WillRaiseAny(
    procedure
    begin
      objValor.Valor := -16;
    end
    ,
    'Esperado TExceptionClass quando atribuído valor negativo.' );
end;

procedure TTestValorPor.TestMudaLabelAssociado;
var
  lLabelAssociado: TLabel;
begin
  lLabelAssociado := TLabel.Create( nil );
  lLabelAssociado.Caption := 'Valor Padrão';

  Assert.AreEqual(
    'Valor Padrão',
    lLabelAssociado.Caption );

  objValor.LabelAssociado := lLabelAssociado;
  objValor.Valor := 10;

  Assert.AreEqual(
    objValor.Texto,
    lLabelAssociado.Caption );

  objValor.Valor := 15.87;

  Assert.AreEqual(
    objValor.Texto,
    lLabelAssociado.Caption
  );
end;

procedure TTestValorPor.TestMudaMoedaNoPlural;
begin
  Assert.AreEqual('REAIS', objValor.MoedaNoPlural);
end;

procedure TTestValorPor.TestMudaMoedaNoSingular;
begin
  Assert.AreEqual('REAL', objValor.MoedaNoSingular);
end;

procedure TTestValorPor.TestValoresPorExtenso( const AValue1: Double;
const AValue2: string );
begin
  objValor.Valor := AValue1;
  Assert.Contains(
    objValor.Texto,
    AValue2 );
end;

initialization

TDUnitX.RegisterTestFixture( TTestValorPor );

end.
