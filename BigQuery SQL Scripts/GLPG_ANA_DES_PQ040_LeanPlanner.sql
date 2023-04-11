MERGE
  `production-glpg.GJBI.LeanPlanner` P
USING
  (
  SELECT
    SKU AS CodigoSKU,
    Edicao,
    CAST(REPLACE(REPLACE(Quantidade, '.', ''), ',', '.') AS INT64) AS Quantidade,
    CAST(REPLACE(REPLACE(REPLACE(REPLACE(PrecoTotal, 'R', ''), '$', ''), '.', ''), ',', '.') AS FLOAT64) AS PrecoUnitario,
    Moeda,
    CAST(REPLACE(REPLACE(REPLACE(REPLACE(ValorProjeto, 'R', ''), '$', ''), '.', ''), ',', '.') AS FLOAT64) AS ValorProjetoME,
    PARSE_DATE('%d/%m/%Y', PlanejadoFimProducao) AS PlanejadoFimProducao,
    CASE WHEN EXTRACT(YEAR FROM (PARSE_DATE('%d/%m/%Y', PlanejadoDisponivelEstoque))) < 1999 THEN NULL ELSE PARSE_DATE('%d/%m/%Y', PlanejadoDisponivelEstoque) END AS PlanejadoDisponivelEstoque
  FROM
    `production-glpg.Loading.GJPlanner_LeanPlanner`
  WHERE
    SKU IS NOT NULL
    AND Edicao IS NOT NULL) L
ON
  L.CodigoSKU = P.CodigoSKU
  AND L.Edicao = P.Edicao
  WHEN MATCHED THEN UPDATE SET P.CodigoSKU = L.CodigoSKU, P.Edicao = L.Edicao, P.Quantidade = L.Quantidade, P.PrecoUnitario = L.PrecoUnitario, P.Moeda = L.Moeda, P.ValorProjetoME = L.ValorProjetoME, P.PlanejadoFimProducao = L.PlanejadoFimProducao, P.PlanejadoDisponivelEstoque = L.PlanejadoDisponivelEstoque
  WHEN NOT MATCHED
  THEN
INSERT
VALUES
  ( L.CodigoSKU, L.Edicao, L.Quantidade, L.PrecoUnitario, L.Moeda, L.ValorProjetoME, L.PlanejadoFimProducao, L.PlanejadoDisponivelEstoque)