MERGE
  `production-glpg.External.Ludopedia_Jogos` P
USING
  (
    SELECT 

      J.Link 
    , J.Nome
    , J.Idade
    , J.TempoJogo
    , J.NumJogadores
    , J.Designers
    , J.Editoras
    , J.EditoraNacional
    , J.Tema
    , J.Mecanica
    , J.Dominio
    , J.Categoria
    , J.URLImagem

    FROM `production-glpg.Loading.Ludopedia_Jogos` J
   ) L 
  ON
  P.Link = L.Link
WHEN MATCHED THEN
  UPDATE SET
      P.Link = L.Link 
    , P.Nome = L.Nome
    , P.Idade = L.Idade
    , P.TempoJogo = L.TempoJogo
    , P.NumJogadores = L.NumJogadores
    , P.Designers = L.Designers
    , P.Editoras = L.Editoras
    , P.EditoraNacional = L.EditoraNacional
    , P.Tema = L.Tema
    , P.Mecanica = L.Mecanica
    , P.Dominio = L.Dominio
    , P.Categoria = L.Categoria
    , P.URLImagem = L.URLImagem
    
WHEN NOT MATCHED THEN
  INSERT VALUES (
      L.Link 
    , L.Nome
    , L.Idade
    , L.TempoJogo
    , L.NumJogadores
    , L.Designers
    , L.Editoras
    , L.EditoraNacional
    , L.Tema
    , L.Mecanica
    , L.Dominio
    , L.Categoria
    , L.URLImagem
  )