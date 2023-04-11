MERGE
  `production-glpg.External.Ludopedia_Ranking` P
USING
  (
      SELECT 

      CURRENT_DATE() AS Timestamp
    , R.Link
    , CAST(REPLACE(R.Ranking, 'º', '') AS INT64) AS Ranking
    , ROUND(CAST(R.Score AS FLOAT64), 2) AS Nota
    , ROUND(CAST(R.ScoreMedio AS FLOAT64), 2) AS NotaMedia
    , CAST(R.NumVotos AS INT64) AS NumVotos

    FROM `production-glpg.Loading.Ludopedia_Ranking` R
   ) L 
  ON
  P.Timestamp = L.Timestamp
  AND P.Link = L.Link
WHEN MATCHED THEN
  UPDATE SET
      P.Timestamp = L.Timestamp
    , P.Link = L.Link
    , P.Ranking = L.Ranking
    , P.Nota = L.Nota
    , P.NotaMedia = L.NotaMedia
    , P.NumVotos = L.NumVotos
    
WHEN NOT MATCHED THEN
  INSERT VALUES (
      L.Timestamp
    , L.Link
    , L.Ranking
    , L.Nota
    , L.NotaMedia
    , L.NumVotos
  )