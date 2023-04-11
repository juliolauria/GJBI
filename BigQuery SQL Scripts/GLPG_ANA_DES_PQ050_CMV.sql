MERGE
  `production-glpg.GJBI.CMV` P
USING
      (
        SELECT
        SKU AS CodigoSKU,
        Edicao,
        Nacionalizacao,
        ROUND(SUM(SAFE_CAST(REPLACE(REPLACE(REPLACE(REPLACE(ValorCMVContabil,'R', ''), '$', ''), '.', ''), ',', '.') AS FLOAT64)), 2) AS CMV,
        ROUND(SUM(SAFE_CAST(REPLACE(REPLACE(REPLACE(REPLACE(ValorRoyaltiesContabilaApropriar,'R', ''), '$', ''),'.', ''), ',', '.') AS FLOAT64)), 2) AS RoyaltiesContabilApropriar,
        ROUND(SUM(SAFE_CAST(REPLACE(REPLACE(REPLACE(REPLACE(ValorRoyaltiesPorVenda,'R', ''), '$', ''),'.', ''), ',', '.') AS FLOAT64)), 2) AS RoyaltiesVendaBRL,
        ROUND(SUM(SAFE_CAST(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PorcRoyaltiesPorVendaAprox,'%', ''),'R', ''), '$', ''),'.', ''), ',', '.') AS FLOAT64)) / 100, 2) AS RoyaltiesVendaPerc,    
        MIN(PARSE_DATE('%d/%m/%Y', DataEmissaoNF)) as DataEmissaoNF

      FROM
        `production-glpg.Loading.CMV`
        WHERE SKU IS NOT NULL
      GROUP BY
        SKU,
        Edicao,
        Nacionalizacao
      ) L
ON
  L.CodigoSKU = P.CodigoSKU
  AND L.Edicao = P.Edicao
  AND L.Nacionalizacao = P.Nacionalizacao
  
  WHEN MATCHED THEN UPDATE SET  P.CodigoSKU = L.CodigoSKU,
  P.Edicao = L.Edicao,
  P.Nacionalizacao = L.Nacionalizacao,
  P.CMV = L.CMV,
  P.RoyaltiesContabilApropriar = L.RoyaltiesContabilApropriar,
  P.RoyaltiesVendaBRL = L.RoyaltiesVendaBRL,
  P.RoyaltiesVendaPerc = L.RoyaltiesVendaPerc,
  P.DataEmissaoNF = L.DataEmissaoNF
  
  WHEN NOT MATCHED
  THEN
INSERT
VALUES(
L.CodigoSKU,
L.Edicao,
L.Nacionalizacao,
L.CMV,
L.RoyaltiesContabilApropriar,
L.RoyaltiesVendaBRL,
L.RoyaltiesVendaPerc,
L.DataEmissaoNF
)