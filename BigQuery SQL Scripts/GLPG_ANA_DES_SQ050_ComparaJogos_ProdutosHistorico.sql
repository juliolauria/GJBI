MERGE
  `production-glpg.External.ComparaJogos_ProdutosHistorico` P
USING
  (
      SELECT DISTINCT

      CURRENT_DATE() as Timestamp
    , H.LinkComparaJogos
    , CAST(H.Quero AS INT64) AS Quero
    , CAST(H.Tenho AS INT64) AS Tenho
    , H.RankingBGG
    , ROUND(CAST(REPLACE(H.Nota, ',', '.') AS FLOAT64), 1) AS Nota
    , ROUND(CAST(REPLACE(H.Complexidade, ',', '.') AS FLOAT64), 1) AS Complexidade

    FROM `production-glpg.Loading.ComparaJogos_Home` H
   ) L
  ON P.Timestamp = L.Timestamp
  AND P.LinkComparaJogos = L.LinkComparaJogos
WHEN MATCHED THEN
  UPDATE SET
      P.Timestamp = L.Timestamp
    , P.LinkComparaJogos = L.LinkComparaJogos
    , P.Quero = L.Quero
    , P.Tenho = L.Tenho
    , P.RankingBGG = L.RankingBGG
    , P.Nota = L.Nota
    , P.Complexidade = L.Complexidade

WHEN NOT MATCHED THEN
  INSERT VALUES (
      L.Timestamp
    , L.LinkComparaJogos
    , L.Quero
    , L.Tenho
    , L.RankingBGG
    , L.Nota
    , L.Complexidade
  )