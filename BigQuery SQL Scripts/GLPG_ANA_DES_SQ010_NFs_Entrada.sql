MERGE 
  `production-glpg.GJBI.NFS_Entrada` P

USING
  (SELECT
  PARSE_DATE('%d/%m/%Y', GFT.DataProcesso) AS DataProcesso,
  PARSE_DATE('%d/%m/%Y', GFT.DataEmissao) AS DataEmissao,
  GFT.NumNota,
  GFT.NaturezaOperacao,
  GFT.CNPJFornecCliente AS CNPJFornecedor,
  GFT.CodMaterial AS CodigoSKU,
  CAST(SAFE_CAST(REPLACE(REPLACE(GFT.QtdItem, '.', ''), ',', '.') AS FLOAT64) AS INT64) AS QtdItem,
  ROUND(SAFE_CAST(REPLACE(REPLACE(GFT.ValorItem, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorItem,
  ROUND(SAFE_CAST(REPLACE(REPLACE(GFT.ValorTotal, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorTotal,
  ROUND(SAFE_CAST(REPLACE(REPLACE(GFT.ValorSeguro, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorSeguro,
  ROUND(SAFE_CAST(REPLACE(REPLACE(GFT.ValorDesconto, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorDesconto,
  ROUND(SAFE_CAST(REPLACE(REPLACE(GFT.ValorOutrasDespesas, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorOutrasDespesas,
  ROUND(SAFE_CAST(REPLACE(REPLACE(GFT.ValorICMS, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorICMS,
  ROUND(SAFE_CAST(REPLACE(REPLACE(GFT.ValorIPI, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorIPI,
  ROUND(SAFE_CAST(REPLACE(REPLACE(GFT.ValorPIS, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorPIS,
  ROUND(SAFE_CAST(REPLACE(REPLACE(GFT.ValorCOFINS, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorCOFINS,
  ROUND(SAFE_CAST(REPLACE(REPLACE(GFT.ValorNota, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorNota,
  ROUND(SAFE_CAST(REPLACE(REPLACE(GFT.ValorFrete, '.', ''), ',', '.') AS FLOAT64), 2) AS ValorFrete,
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
  GFT.EntradaSaida = 'Entrada') L

  ON
  P.CodigoSKU = L.CodigoSKU
  AND P.NumNota = L.NumNota
  AND P.Ordem = L.Ordem

WHEN MATCHED THEN
  UPDATE SET 
  P.DataProcesso = L.DataProcesso,
  P.DataEmissao = L.DataEmissao,
  P.NumNota = L.NumNota,
  P.NaturezaOperacao = L.NaturezaOperacao,
  P.CNPJFornecedor = L.CNPJFornecedor,
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
  P.Ordem = L.Ordem

WHEN NOT MATCHED THEN
  INSERT VALUES (
  L.DataProcesso,
  L.DataEmissao,
  L.NumNota,
  L.NaturezaOperacao,
  L.CNPJFornecedor,
  L.CodigoSKU,
  L.QtdItem,
  L.ValorItem,
  L.ValorTotal,
  L.ValorSeguro,
  L.ValorDesconto,
  L.ValorOutrasDespesas,
  L.ValorICMS,
  L.ValorIPI,
  L.ValorPIS,
  L.ValorCOFINS,
  L.ValorNota,
  L.ValorFrete,
  L.Ordem
  )
 