MERGE
  `production-glpg.External.Ludopedia_Anuncios` P
USING
  (
      SELECT 

      CURRENT_DATE() AS Timestamp
    , A.IDAnuncio
    , A.TipoAnuncio
    , A.Link
    , A.Cidade
    , ROUND(CAST(REPLACE(REPLACE(REPLACE(A.Preco, 'R$ ', ''),'.', ''), ',', '.') AS FLOAT64), 2) AS Preco
    , EstadoProduto

    FROM `production-glpg.Loading.Ludopedia_Anuncios` A
   ) L 
  ON
  P.Timestamp = L.Timestamp
  AND P.IDAnuncio = L.IDAnuncio
WHEN MATCHED THEN
  UPDATE SET
    P.Timestamp = L.Timestamp
    , P.IDAnuncio = L.IDAnuncio
    , P.TipoAnuncio = L.TipoAnuncio
    , P.Link = L.Link
    , P.Cidade = L.Cidade
    , P.Preco = L.Preco
    , P.EstadoProduto = L.EstadoProduto

WHEN NOT MATCHED THEN
  INSERT VALUES (
      L.Timestamp
    , L.IDAnuncio
    , L.TipoAnuncio
    , L.Link
    , L.Cidade
    , L.Preco
    , L.EstadoProduto
  )