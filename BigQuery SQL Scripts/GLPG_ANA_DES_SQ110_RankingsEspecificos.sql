MERGE
  `production-glpg.External.Ludopedia_RankingsEspecificos` P
USING
  (
      SELECT 

      CURRENT_DATE() AS Timestamp
    , RE.Link
    , RE.Categoria
    , CAST(REPLACE(RE.RankingEspecifico, 'º', '') AS INT64) AS RankingEspecifico

    FROM `production-glpg.Loading.Ludopedia_RankingsEspecificos` RE
   ) L 
  ON
  P.Timestamp = L.Timestamp
  AND P.Link = L.Link
  AND P.Categoria = L.Categoria
WHEN MATCHED THEN
  UPDATE SET
      P.Timestamp = L.Timestamp
    , P.Link = L.Link
    , P.Categoria = L.Categoria
    , P.RankingEspecifico = L.RankingEspecifico

WHEN NOT MATCHED THEN
  INSERT VALUES (
      L.Timestamp
    , L.Link
    , L.Categoria
    , L.RankingEspecifico
  )