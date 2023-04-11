MERGE
  `production-glpg.GJBI.ContasAPagar` P
USING
    (SELECT DISTINCT

     Supplier,
     SupplierNumber,
     InvoiceLineDescription,
     PARSE_DATE('%Y-%m-%d', InvoiceLineAccountingDate) AS InvoiceLineAccountingDate,
     CAST(REPLACE(REPLACE(InvoiceLineAmount, '.', ''), ',', '.') AS FLOAT64) AS InvoiceLineAmount,
     CAST(REPLACE(REPLACE(InvoiceAmount, '.', ''), ',', '.') AS FLOAT64) AS InvoiceAmount,
     InvoiceNumber,
     InvoiceID,
     AccountType,
     SummaryAccount,
     AlternateAccount,
     AccountDescription,

     SPLIT(AccountDescription, '-')[OFFSET(0)] Arvore_01_Empresa,
     TRIM(SPLIT(AccountDescription, '-')[OFFSET(1)], "\\ ") Arvore_02_Servico,
     TRIM(SPLIT(AccountDescription, '-')[OFFSET(2)], "\\ ") Arvore_03_CentroDeCusto,
     TRIM(SPLIT(AccountDescription, '-')[OFFSET(3)], "\\ ") Arvore_04_Cliente,
     TRIM(SPLIT(AccountDescription, '-')[OFFSET(4)], "\\ ") Arvore_05_CodigoSKU,
     TRIM(SPLIT(AccountDescription, '-')[OFFSET(5)], "\\ ") Arvore_06_NomeSKU,
     TRIM(SPLIT(AccountDescription, '-')[OFFSET(6)], "\\ ") Arvore_07_TipoSKU,

     CAST(REPLACE(REPLACE(InvoiceDistributionAmount, '.', ''), ',', '.') AS FLOAT64) AS InvoiceDistributionAmount,
     InvoiceLineNumber

     FROM `production-glpg.Loading.Oracle_AP`
     
     WHERE TRIM(SPLIT(AccountDescription, '-')[OFFSET(2)], "\\ ") IN ('Comercial', 
                                                                      'Logistica', 
                                                                      'OP', 
                                                                      'Marketing', 
                                                                      'Financeiro',
                                                                      'Geral',
                                                                      'PCP',
                                                                      'Juridico')) L
    
    ON P.InvoiceID = L.InvoiceID
    AND P.InvoiceLineNumber = L.InvoiceLineNumber

WHEN MATCHED THEN
  UPDATE SET
    P.Supplier = L.Supplier,
    P.SupplierNumber = L.SupplierNumber,
    P.InvoiceLineDescription = L.InvoiceLineDescription,
    P.InvoiceLineAccountingDate = L.InvoiceLineAccountingDate,
    P.InvoiceLineAmount = L.InvoiceLineAmount,
    P.InvoiceAmount = L.InvoiceAmount,
    P.InvoiceNumber = L.InvoiceNumber,
    P.InvoiceID = L.InvoiceID,
    P.AccountType = L.AccountType,
    P.SummaryAccount = L.SummaryAccount,
    P.AlternateAccount = L.AlternateAccount,
    P.AccountDescription = L.AccountDescription,
    P.Arvore_01_Empresa = L.Arvore_01_Empresa,
    P.Arvore_02_Servico = L.Arvore_02_Servico,
    P.Arvore_03_CentroDeCusto = L.Arvore_03_CentroDeCusto,
    P.Arvore_04_Cliente = L.Arvore_04_Cliente,
    P.Arvore_05_CodigoSKU = L.Arvore_05_CodigoSKU,
    P.Arvore_06_NomeSKU = L.Arvore_06_NomeSKU,
    P.Arvore_07_TipoSKU = L.Arvore_07_TipoSKU,
    P.InvoiceDistributionAmount = L.InvoiceDistributionAmount,
    P.InvoiceLineNumber = L.InvoiceLineNumber
    
 WHEN NOT MATCHED THEN
  INSERT VALUES (
    L.Supplier,
    L.SupplierNumber,
    L.InvoiceLineDescription,
    L.InvoiceLineAccountingDate,
    L.InvoiceLineAmount,
    L.InvoiceAmount,
    L.InvoiceNumber,
    L.InvoiceID,
    L.AccountType,
    L.SummaryAccount,
    L.AlternateAccount,
    L.AccountDescription,
    L.Arvore_01_Empresa,
    L.Arvore_02_Servico,
    L.Arvore_03_CentroDeCusto,
    L.Arvore_04_Cliente,
    L.Arvore_05_CodigoSKU,
    L.Arvore_06_NomeSKU,
    L.Arvore_07_TipoSKU,
    L.InvoiceDistributionAmount,
    L.InvoiceLineNumber
  )