MERGE
  `production-glpg.External.Ludopedia_JogosHistorico` P
USING
  (
    SELECT 

      CURRENT_DATE() AS Timestamp
    , J.Link 
    , CAST(J.Tenho AS INT64) AS Tenho
    , CAST(J.Quero AS INT64) AS Quero
    , CAST(J.Tive AS INT64) AS Tive
    , CAST(J.Favoritos AS INT64) AS Favoritos
    , CAST(J.Joguei AS INT64) AS Joguei

    FROM `production-glpg.Loading.Ludopedia_Jogos` J
   ) L 
  ON
  P.Timestamp = L.Timestamp
  AND P.Link = L.Link
WHEN MATCHED THEN
  UPDATE SET
      
      P.Timestamp = L.Timestamp
    , P.Link = L.Link 
    , P.Tenho = L.Tenho
    , P.Quero = L.Quero
    , P.Tive = L.Tive
    , P.Favoritos = L.Favoritos
    , P.Joguei = L.Joguei
    
WHEN NOT MATCHED THEN
  INSERT VALUES (
      
      L.Timestamp
    , L.Link 
    , L.Tenho
    , L.Quero
    , L.Tive
    , L.Favoritos
    , L.Joguei
  )