MERGE
  `production-glpg.GJBI.Fretes` P
USING
  (
  SELECT
    F.Pedido,
    F.NotaFiscal AS NumNota,
    CASE WHEN ROUND(CAST(REPLACE(REPLACE(C.ValorFreteConsiderado, '.', ''), ',', '.') AS FLOAT64), 2) IS NOT NULL 
         THEN ROUND(CAST(REPLACE(REPLACE(C.ValorFreteConsiderado, '.', ''), ',', '.') AS FLOAT64), 2) 
         ELSE ROUND(CAST(F.CustoFrete AS FLOAT64), 2) 
         END AS CustoFrete
    
  FROM
    `production-glpg.Loading.Intelipost_Frete_CSV` F
  
  LEFT JOIN `production-glpg.Loading.Intelipost_Frete_Correcoes` C
  ON F.Pedido = C.Pedido) L
ON
  P.Pedido = L.Pedido
  AND P.NumNota = L.NumNota
  WHEN MATCHED THEN UPDATE SET P.Pedido = L.Pedido, P.NumNota = L.NumNota, P.CustoFrete = L.CustoFrete
  WHEN NOT MATCHED
  THEN
INSERT
VALUES
  ( L.Pedido, L.NumNota, L.CustoFrete )