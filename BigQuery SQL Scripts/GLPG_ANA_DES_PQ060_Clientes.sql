MERGE 
  `production-glpg.GJBI.Clientes` P
USING
  (

    SELECT 

    CLI.*,
    NomeLojaComparaJogos

    FROM (

            SELECT 

                Nome,
                Marcador,
                NivelWPN,
                CNPJ,
                Endereco,
                EmailCadastro AS EmailCadastro,
                CidadeMunicipioVilaLocalidade AS Cidade,
                DistritoSublocalidade AS Distrito,
                EstadoMunicipio,
                Regiao,
                CAST(NegociosGanhos AS INT64) AS NegociosGanhos,
                TipoLoja,
                Status,
                CAST(AtividadesConcluidas AS INT64) AS AtividadesConcluidas,
                CAST(AtividadesParaFazer AS INT64) AS AtividadesParaFazer,
                SAFE_CAST(DataAtualizada AS DATE) AS DataAtualizada,
                SAFE_CAST(DataProximaAtividade AS DATE) AS DatadaProximaAtividade,
                SAFE_CAST(DataUltimaAtividade AS DATE) AS DataUltimaAtividade,
                Facebook,
                ApartamentoSuiteNum AS Apartamento,
                NumeroCasa,
                NomeRuaVia AS Rua,
                Pais,
                EnderecoCompletoCombinado AS EnderecoCompleto,
                CEPCodigoPostal AS CEP,
                Fiscal,
                Fonte,
                HorarioFuncionamento,
                InscricaoEstadual,
                Instagram,
                Liberado,
                CAST(NegociosEmAberto AS INT64) AS NegociosEmAberto,
                CAST(NegociosFechados AS INT64) AS NegociosFechados,
                CAST(NegociosPerdidos AS INT64) AS NegociosPerdidos,
                NivelL5R,
                Observacoes,
                OCC,
                SAFE_CAST(OrganizacaoCriada AS DATE) AS DataCriacao,
                PerfilCompra,
                PerfilVisualizacao,
                CAST(Pessoas AS INT64) AS Pessoas,
                OwnerName AS Proprietario,
                Qualificacao,
                QuarentenaSDR,
                RazaoSocial,
                Segmento,
                Site,
                CAST(TotalAtividades AS INT64) AS TotalAtividades,
                _a68bbff944a743344215d348c3edf04204d95c96  AS ContatoPrincipal,
                NivelAember AS NivelEmber,
                PerfilCompraLEGADO AS PerfildeCompraLEGADO,
                CAST(ID AS STRING) AS ID,
                Redes,
                CustomerGroup

                FROM (
                      SELECT 
                      B.*
                      FROM (
                            SELECT
                            A.*,
                            ROW_NUMBER() OVER (Partition BY A.CNPJ) AS rownum

                            FROM (
                                  SELECT 
                                  * EXCEPT(CNPJ),
                                  REPLACE(REPLACE(REPLACE(REPLACE(CNPJ, '-', ''), '/', ''), '.', ''), "'\'", '' ) AS CNPJ
                                  FROM `Loading.Pipedrive_Organizations`
                                  WHERE Status NOT IN  ('Inativo', 'Fechado') OR Status IS NULL
                                  ORDER BY CONCAT(CNPJ, DataAtualizada)  DESC
                                 ) A
                           ) B

              WHERE rownum = 1
              AND CNPJ IS NOT NULL) -- Remove linhas com CNPJ duplicados e vazios. Mantém apenas o CNPJ mais recente.
                                    -- CNPJs Duplicados = Problema de duplicação de linhas do Pipedrive devido a chave forte ser e-mail para OCC
                                    -- CNPJs Vazios = Cliente em processo de cadastro
            ) CLI

    LEFT JOIN `production-glpg.Loading.ComparaJogos_DePara` DP
    ON DP.CNPJCliente = CLI.CNPJ) L

ON P.CNPJ = L.CNPJ
WHEN MATCHED THEN
  UPDATE SET
      P.Nome = L.Nome,
      P.Marcador = L.Marcador,
      P.NivelWPN = L.NivelWPN,
      P.CNPJ = L.CNPJ,
      P.Endereco = L.Endereco,
      P.EmailCadastro = L.EmailCadastro,
      P.Cidade = L.Cidade,
      P.Distrito = L.Distrito,
      P.EstadoMunicipio = L.EstadoMunicipio,
      P.Regiao = L.Regiao,
      P.NegociosGanhos = L.NegociosGanhos,
      P.TipoLoja = L.TipoLoja,
      P.Status = L.Status,
      P.AtividadesConcluidas = L.AtividadesConcluidas,
      P.AtividadesParaFazer = L.AtividadesParaFazer,
      P.DataAtualizada = L.DataAtualizada,
      P.DatadaProximaAtividade = L.DatadaProximaAtividade,
      P.DataUltimaAtividade = L.DataUltimaAtividade,
      P.Facebook = L.Facebook,
      P.Apartamento = L.Apartamento,
      P.NumeroCasa = L.NumeroCasa,
      P.Rua = L.Rua,
      P.Pais = L.Pais,
      P.EnderecoCompleto = L.EnderecoCompleto,
      P.CEP = L.CEP,
      P.Fiscal = L.Fiscal,
      P.Fonte = L.Fonte,
      P.HorarioFuncionamento = L.HorarioFuncionamento,
      P.InscricaoEstadual = L.InscricaoEstadual,
      P.Instagram = L.Instagram,
      P.Liberado = L.Liberado,
      P.NegociosEmAberto = L.NegociosEmAberto,
      P.NegociosFechados = L.NegociosFechados,
      P.NegociosPerdidos = L.NegociosPerdidos,
      P.NivelL5R = L.NivelL5R,
      P.Observacoes = L.Observacoes,
      P.OCC = L.OCC,
      P.DataCriacao = L.DataCriacao,
      P.PerfilCompra = L.PerfilCompra,
      P.PerfilVisualizacao = L.PerfilVisualizacao,
      P.Pessoas = L.Pessoas,
      P.Proprietario = L.Proprietario,
      P.Qualificacao = L.Qualificacao,
      P.QuarentenaSDR = L.QuarentenaSDR,
      P.RazaoSocial = L.RazaoSocial,
      P.Segmento = L.Segmento,
      P.Site = L.Site,
      P.TotalAtividades = L.TotalAtividades,
      P.ContatoPrincipal = L.ContatoPrincipal,
      P.NivelEmber = L.NivelEmber,
      P.PerfildeCompraLEGADO = L.PerfildeCompraLEGADO,
      P.ID = L.ID,
      P.Redes = L.Redes,
      P.CustomerGroup = L.CustomerGroup,
      P.NomeLojaComparaJogos = L.NomeLojaComparaJogos
    	
WHEN NOT MATCHED THEN
  INSERT VALUES 
    (
      L.Nome,
      L.Marcador,
      L.NivelWPN,
      L.CNPJ,
      L.Endereco,
      L.EmailCadastro,
      L.Cidade,
      L.Distrito,
      L.EstadoMunicipio,
      L.Regiao,
      L.NegociosGanhos,
      L.TipoLoja,
      L.Status,
      L.AtividadesConcluidas,
      L.AtividadesParaFazer,
      L.DataAtualizada,
      L.DatadaProximaAtividade,
      L.DataUltimaAtividade,
      L.Facebook,
      L.Apartamento,
      L.NumeroCasa,
      L.Rua,
      L.Pais,
      L.EnderecoCompleto,
      L.CEP,
      L.Fiscal,
      L.Fonte,
      L.HorarioFuncionamento,
      L.InscricaoEstadual,
      L.Instagram,
      L.Liberado,
      L.NegociosEmAberto,
      L.NegociosFechados,
      L.NegociosPerdidos,
      L.NivelL5R,
      L.Observacoes,
      L.OCC,
      L.DataCriacao,
      L.PerfilCompra,
      L.PerfilVisualizacao,
      L.Pessoas,
      L.Proprietario,
      L.Qualificacao,
      L.QuarentenaSDR,
      L.RazaoSocial,
      L.Segmento,
      L.Site,
      L.TotalAtividades,
      L.ContatoPrincipal,
      L.NivelEmber,
      L.PerfildeCompraLEGADO,
      L.ID,
      L.Redes,
      L.CustomerGroup,
      L.NomeLojaComparaJogos
    )
 