MERGE
  `production-glpg.External.BGG_Produtos` P
USING
  (
      SELECT 

      ID, 
      Ano, 
      CAST(MinJogadores AS INT64) AS MinJogadores, 
      CAST(MaxJogadores AS INT64) AS MaxJogadores,
      CAST(MinTempoJogo AS INT64) AS MinTempoJogo,
      CAST(MaxTempoJogo AS INT64) AS MaxTempoJogo,
      CAST(Idade AS INT64) AS Idade,
      Nome,
      Imagem,
      Premiacoes,
      Categoria,
      Mecanica,
      Familia,
      Designer,
      Artista,
      Expansao,
      Subdominio,
      CONCAT('https://boardgamegeek.com', Link) as LinkBGG

      FROM Loading.BGG_Profile
      
      INNER JOIN Staging.BGG_Boardgames_SemDuplicadas B
      ON split(B.Link, '/')[OFFSET(2)] = ID) L
  ON
  P.ID = L.ID
WHEN MATCHED THEN
  UPDATE SET
    P.ID = L.ID
    , P.Ano = L.Ano
    , P.MinJogadores = L.MinJogadores
    , P.MaxJogadores = L.MaxJogadores
    , P.MinTempoJogo = L.MinTempoJogo
    , P.MaxTempoJogo = L.MaxTempoJogo
    , P.Idade = L.Idade
    , P.Nome = L.Nome
    , P.Imagem = L.Imagem
    , P.Premiacoes = L.Premiacoes
    , P.Categoria = L.Categoria
    , P.Mecanica = L.Mecanica
    , P.Familia = L.Familia
    , P.Designer = L.Designer
    , P.Artista = L.Artista
    , P.Expansao = L.Expansao
    , P.Subdominio = L.Subdominio
    , P.LinkBGG = L.LinkBGG
    
WHEN NOT MATCHED THEN
  INSERT VALUES (
      L.ID
    , L.Ano
    , L.MinJogadores
    , L.MaxJogadores
    , L.MinTempoJogo
    , L.MaxTempoJogo
    , L.Idade
    , L.Nome
    , L.Imagem
    , L.Premiacoes
    , L.Categoria
    , L.Mecanica
    , L.Familia
    , L.Designer
    , L.Artista
    , L.Expansao
    , L.Subdominio
    , L.LinkBGG
  )