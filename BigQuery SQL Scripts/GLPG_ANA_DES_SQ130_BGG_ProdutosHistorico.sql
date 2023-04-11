MERGE
  `production-glpg.External.BGG_ProdutosHistorico` P
USING
  (
      SELECT 

      CURRENT_DATE() as Timestamp,
      ID, 
      CAST(NumVotos AS INT64) AS NumVotos, 
      CAST(Media AS FLOAT64) AS Media, 
      CAST(MediaBGG AS FLOAT64) AS MediaBGG, 
      CAST(Tem AS INT64) AS Tem, 
      CAST(TemParaTrocar AS INT64) AS TemParaTrocar, 
      CAST(QueremTrocar AS INT64) AS QueremTrocar, 
      CAST(Wishlist AS INT64) AS Wishlist, 
      CAST(NumComentarios AS INT64) AS NumComentarios, 
      CAST(NumVotosComplexidade AS INT64) AS NumVotosComplexidade, 
      CAST(Complexidade AS FLOAT64) AS Complexidade, 
      CAST(RankingGeral AS INT64) AS RankingGeral, 
      RankingEspecificos,
      ROUND(SAFE_CAST(REPLACE(BG.ListPrice, '$', '')AS FLOAT64), 2) AS MSRP,
      ROUND(SAFE_CAST(REPLACE(REPLACE(BG.NewAmazonPrice, '$', ''),'Too low to display', '')AS FLOAT64), 2) AS PrecoAmazon

      FROM Loading.BGG_Profile
      
      INNER JOIN `production-glpg.Staging.BGG_Boardgames_SemDuplicadas` BG
      ON split(BG.Link, '/')[OFFSET(2)] = ID
   ) L
  ON P.Timestamp = L.Timestamp
  AND P.ID = L.ID
WHEN MATCHED THEN
  UPDATE SET
      P.Timestamp = L.Timestamp
    , P.ID = L.ID
    , P.NumVotos = L.NumVotos
    , P.Media = L.Media
    , P.MediaBGG = L.MediaBGG
    , P.Tem = L.Tem
    , P.TemParaTrocar = L.TemParaTrocar
    , P.QueremTrocar = L.QueremTrocar
    , P.Wishlist = L.Wishlist
    , P.NumComentarios = L.NumComentarios
    , P.NumVotosComplexidade = L.NumVotosComplexidade
    , P.Complexidade = L.Complexidade
    , P.RankingGeral = L.RankingGeral
    , P.RankingEspecificos = L.RankingEspecificos
    , P.MSRP = L.MSRP
    , P.PrecoAmazon = L.PrecoAmazon

WHEN NOT MATCHED THEN
  INSERT VALUES (
      L.Timestamp
    , L.ID
    , L.NumVotos
    , L.Media
    , L.MediaBGG
    , L.Tem
    , L.TemParaTrocar
    , L.QueremTrocar
    , L.Wishlist
    , L.NumComentarios
    , L.NumVotosComplexidade
    , L.Complexidade
    , L.RankingGeral
    , L.RankingEspecificos
    , L.MSRP
    , L.PrecoAmazon
  )