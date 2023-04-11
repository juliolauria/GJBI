MERGE 
  `production-glpg.GJBI.NFS_Saida` P

USING
  (SELECT
  PARSE_DATE('%d/%m/%Y', GFT.DataProcesso) AS DataProcesso,
  PARSE_DATE('%d/%m/%Y', GFT.DataEmissao) AS DataEmissao,
  GFT.NumNota,
  GFT.NaturezaOperacao,
  GFT.CNPJFornecCliente AS CNPJCliente,
  GFT.CodMaterial AS CodigoSKU,
  CAST(CAST(REPLACE(REPLACE(GFT.QtdItem, '.', ''), ',', '.') AS FLOAT64) AS INT64) AS QtdItem,
  ROUND(CAST(REPLACE(REPLACE(GFT.ValorItem, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorItem,
  ROUND(CAST(REPLACE(REPLACE(GFT.ValorTotal, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorTotal,
  ROUND(CAST(REPLACE(REPLACE(GFT.ValorSeguro, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorSeguro,
  ROUND(CAST(REPLACE(REPLACE(GFT.ValorDesconto, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorDesconto,
  ROUND(CAST(REPLACE(REPLACE(GFT.ValorOutrasDespesas, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorOutrasDespesas,
  ROUND(CAST(REPLACE(REPLACE(GFT.ValorICMS, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorICMS,
  ROUND(CAST(REPLACE(REPLACE(GFT.ValorIPI, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorIPI,
  ROUND(CAST(REPLACE(REPLACE(GFT.ValorPIS, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorPIS,
  ROUND(CAST(REPLACE(REPLACE(GFT.ValorCOFINS, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorCOFINS,
  ROUND(CAST(REPLACE(REPLACE(GFT.ValorNota, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorNota,
  ROUND(CAST(REPLACE(REPLACE(GFT.ValorFrete, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorFrete,
  MON.Ordem

FROM
  `production-glpg.Loading.GFT_RelatorioNF` GFT

LEFT JOIN 
  (SELECT DISTINCT
  
  NumNota,
  Ordem

  FROM `production-glpg.Loading.GFT_MonitorNFe`
  WHERE CodigoSituacao = '100-Autorizado o uso da NF-e'
  AND NumDocumento <> '39468'
  ) MON
ON MON.NumNota = GFT.NumNota

WHERE
  GFT.EntradaSaida = 'Saída'
  AND GFT.Situacao = 'Autorizada'
  AND GFT.NaturezaOperacao NOT IN (
                               'REMESSA PARA BONIFICAÇÃO',
                               'REMESSA PARA BONIFICA�ÃO', -- Caracter diferente. Verificar o Load. 
                               'Remessa de Mercadoria ou Bem p/ Exposição ou Feira',
                               'TRANSFERÊNCIA DE ESTOQUE',
                               'REMESSA DE MERCADORIA PARA CONSERTO'
                              )
) L

  ON
  P.CodigoSKU = L.CodigoSKU
  AND P.NumNota = L.NumNota

WHEN MATCHED THEN
  UPDATE SET 
  P.DataProcesso = L.DataProcesso,
  P.DataEmissao = L.DataEmissao,
  P.NumNota = L.NumNota,
  P.NaturezaOperacao = L.NaturezaOperacao,
  P.CNPJCliente = L.CNPJCliente,
  P.CodigoSKU = L.CodigoSKU,
  P.QtdItem = L.QtdItem,
  P.ValorItem = L.ValorItem,
  P.ValorTotal = L.ValorTotal,
  P.ValorSeguro = L.ValorSeguro,
  P.ValorDesconto = L.ValorDesconto,
  P.ValorOutrasDespesas = L.ValorOutrasDespesas,
  P.ValorICMS = L.ValorICMS,
  P.ValorIPI = L.ValorIPI,
  P.ValorPIS = L.ValorPIS,
  P.ValorCOFINS = L.ValorCOFINS,
  P.ValorNota = L.ValorNota,
  P.ValorFrete = L.ValorFrete,
  P.Ordem = L.Ordem,
  P.Abacus_cd_notafiscal = NULL

WHEN NOT MATCHED THEN
  INSERT VALUES (
  L.NumNota,
  L.CodigoSKU,
  L.ValorNota,
  L.ValorICMS,
  L.ValorIPI,
  L.ValorPIS,
  L.ValorCOFINS,  
  L.DataProcesso,
  L.DataEmissao,
  L.NaturezaOperacao,
  L.QtdItem,
  L.ValorItem,
  L.ValorTotal,
  L.ValorSeguro,
  L.ValorDesconto,
  L.ValorOutrasDespesas,
  L.ValorFrete,
  L.CNPJCliente,
  L.Ordem,
  NULL -- Abacus_cd_notafiscal
  )
 