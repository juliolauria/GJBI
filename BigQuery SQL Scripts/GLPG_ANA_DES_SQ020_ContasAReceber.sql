MERGE
  `production-glpg.GJBI.ContasAReceber` P
USING
    ( SELECT 

        BilltoCustomerAccountNumber AS CNPJ
      , BilltoCustomerName AS Cliente
      , PARSE_DATE('%Y-%m-%d', AccountingDate) AS DataEmissao
      , PARSE_DATE('%Y-%m-%d', DueDate) AS DataVencimento
      , CAST(PaymentTermsInstallmentNumber AS INT64) AS Parcela
      , PaymentTermsName AS TipoPagamento
      , CAST(BaseAmount AS INT64) AS  TotalPonderacao
      , CAST(RelativeAmount AS INT64) AS PesoRelativoPonderacao
      , TransactionNumber AS NumeroTransacao
      , CAST(NumberofPaymentScheduleInstallments AS INT64) AS NumeroParcelas
      , ROUND(CAST(AccountedAmountDueRemaining AS FLOAT64), 2) AS SaldoAberto
      , ROUND(CAST(AdjustedEnteredAmount AS FLOAT64), 2) AS AjusteAplicado
      , ROUND(CAST(AdjustedEnteredAmountPending AS FLOAT64), 2) AS AjustePendente
      , ROUND(CAST(AppliedEnteredAmount AS FLOAT64), 2) AS ValorConsiderado
      , ROUND(CAST(ChargesEnteredAmount AS FLOAT64), 2) AS TaxasAplicadas
      , ROUND(CAST(ChargesEnteredAmountRemaining AS FLOAT64), 2) AS TaxasRestante
      , ROUND(CAST(CreditedEnteredAmount AS FLOAT64), 2) AS ValorCreditado
      , ROUND(CAST(EnteredAmountDueOriginal AS FLOAT64), 2) AS ValorOriginal
      , ROUND(CAST(EnteredAmountDueRemaining  AS FLOAT64), 2) AS ValorOriginalRestante 
      , ROUND(CAST(LineEnteredAmountOriginal  AS FLOAT64), 2) AS ValorSemFrete 
      , ROUND(CAST(LineEnteredAmountRemaining  AS FLOAT64), 2) AS ValorSemFreteRestante
      , CONCAT(AccountingDate, '_', DueDate, '_', TransactionNumber, '_', PaymentTermsInstallmentNumber) AS Chave
      , PARSE_DATE('%Y-%m-%d', InstallmentClosedAccountingDate) AS DataPagamento
      , CustomerTransactionReference AS Ordem
      , ExternalNumber AS ExternalNumber

      FROM Loading.Oracle_AR) L
    
    ON P.Chave = L.Chave

WHEN MATCHED THEN
  UPDATE SET
    P.CNPJ = L.CNPJ,
    P.Cliente = L.Cliente,
    P.DataEmissao = L.DataEmissao,
    P.DataVencimento = L.DataVencimento,
    P.Parcela = L.Parcela,
    P.TipoPagamento = L.TipoPagamento,
    P.TotalPonderacao = L.TotalPonderacao,
    P.PesoRelativoPonderacao = L.PesoRelativoPonderacao,
    P.NumeroTransacao = L.NumeroTransacao,
    P.NumeroParcelas = L.NumeroParcelas,
    P.SaldoAberto = L.SaldoAberto,
    P.AjusteAplicado = L.AjusteAplicado,
    P.AjustePendente = L.AjustePendente,
    P.ValorConsiderado = L.ValorConsiderado,
    P.TaxasAplicadas = L.TaxasAplicadas,
    P.TaxasRestante = L.TaxasRestante,
    P.ValorCreditado = L.ValorCreditado,
    P.ValorOriginal = L.ValorOriginal,
    P.ValorOriginalRestante = L.ValorOriginalRestante,
    P.ValorSemFrete = L.ValorSemFrete,
    P.ValorSemFreteRestante = L.ValorSemFreteRestante,
    P.Chave = L.Chave,
    P.DataPagamento = L.DataPagamento,
    P.Ordem = L.Ordem,
    P.ExternalNumber = L.ExternalNumber    
    
 WHEN NOT MATCHED THEN
  INSERT VALUES (
    L.CNPJ,
    L.Cliente,
    L.DataEmissao,
    L.DataVencimento,
    L.Parcela,
    L.TipoPagamento,
    L.TotalPonderacao,
    L.PesoRelativoPonderacao,
    L.NumeroTransacao,
    L.NumeroParcelas,
    L.SaldoAberto,
    L.AjusteAplicado,
    L.AjustePendente,
    L.ValorConsiderado,
    L.TaxasAplicadas,
    L.TaxasRestante,
    L.ValorCreditado,
    L.ValorOriginal,
    L.ValorOriginalRestante,
    L.ValorSemFrete,
    L.ValorSemFreteRestante,
    L.Chave,
    L.DataPagamento,
    L.Ordem,
    L.ExternalNumber
  )