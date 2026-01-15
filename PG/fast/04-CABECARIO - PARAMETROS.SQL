SELECT 
    DOCFISCAL.DTEMISSAO AS DATAEMISSAO, ----COMPETENCIA_CAB,
    Current_timestamp AS DATACOMPETENCIA,
    CASE 
        --WHEN REGIMEEMPRESA.nrvalorint=0 AND EMITENTE.floptantesimples=1 ----0-Simples nacional, 1-Lucro real, 2-Lucro presumido, 3-Simples Nacional - Sublimite
        --THEN 9 --9-retSimplesNacional
        WHEN REGIMEEMPRESA.nrvalorint=0 AND (EMITENTE.floptantesimples=2 OR REGIMETRIBISSQN.nrvalorint = 5)
        THEN 5
        WHEN REGIMETRIBISSQN.nrvalorint BETWEEN 1 AND 5
        THEN REGIMETRIBISSQN.nrvalorint --1-Microempresa Municipal,2-Estimativa,3-Sociedade Profissionais,4-Cooperativa,5-MicroempresarioIndividual
        --WHEN REGIMEEMPRESA.nrvalorint=1
       --THEN 7--LucroReal
        --WHEN REGIMEEMPRESA.nrvalorint=2
        --THEN 8--LucroPresumido
        ELSE 0
         --6-retMicroempresarioEmpresaPP
    END AS REGIMEESPECIALTRIBUTACAO,  ----0-nenhum, 1-MicroempresaMunicipal, 2-Estimativa, 3-SociedadeProfissionais, 4-Cooperativa, 5-MicroempresarioIndividual, 6-MicroempresarioEmpresaPP, 7-LucroReal, 8-LucroPresumido, 9-SimplesNacional,10-Imune,11-EmpresaIndividualRELI,12-EmpresaPP,13-MicroEmpresario,14-Outros,15-MovimentoMensal,16-ISSQNAutonomos,17-ISSQNSociedade,18-NotarioRegistrador,19-TribFaturamentoVariavel,20-Fixo,21-Isencao,22-ExigibSuspensaJudicial,23-ExigibSuspensaAdm
    CASE WHEN NFERETORNO.FLTIPONOTA=1 AND ( NFERETORNO.FLSTATUS IN (2,6))
        THEN DOCFISCAL.DSMOTIVOCANC 
    END AS DSMOTIVOCANC,    
    1 AS infAdicAT, ----0-Sim,1-Nao
    1 AS Transacao, ----0-Sim,1-Nao
    0 AS tpEmit, ----0-Prestador,1-Tomador,2-Intermediario
    CASE REGIMEEMPRESA.nrvalorint
        WHEN 0 THEN 1 --1-OptanteMEI
        WHEN 3 THEN 1 --1-OptanteMEI
        ELSE 0 --0-NaoOptante,2-OptanteMEEPP
    END AS OptanteSN,
    CASE 
        WHEN REGIMEEMPRESA.nrvalorint=0 
        THEN 0 --0-FederaisMunicipalpeloSN
        ELSE 2 --2-FederaisMunicipalforaSN
    END AS RegimeApuracaoSN, --,1-FederaisSN,
    0 AS tpXML, ----0-RPS,1-NFSe,2-Espelho
    CASE WHEN REGIMEEMPRESA.nrvalorint IN (0) THEN 1 ELSE 0 END AS indTotTrib, --0 == Normal , 1 == Simples Nacional
    /*Reforma Tributária*/
    CASE WHEN REFORMATRIBUTARIA.nrvalorint = 1 AND CURRENT_DATE>='20260105' THEN 1 END AS REFORMATRIBUTARIA,
    0 AS finNFSe, --Indicador da finalidade da emissão de NFS-e 
    1 AS indFinal, --Indica operação de uso ou consumo pessoal.
    1 AS tpOper, -- código indicador de operação (1 == Fornecimento com pagamento posterior; 2 == Recebimento do pagamento com fornecimento já realizado; 3 == Fornecimento com pagamento já realizado; 4 == Recebimento do pagamento com fornecimento posterior; 5 == Fornecimento e recebimento do pagamento concomitantes.)
    4 AS tpEnteGov, -- Tipo de ente governamental  (1 == União;2 == Estado;3 == Distrito Federal;4 == Município;9 == Outro )
    CASE WHEN EMITENTE.IDDOCIDENT = DOCFISCAL.IDDOCIDENT THEN 0 ELSE 1 END AS indDest, --0 = idTomadorAdquirenteDestinatarioIguais, 1 = idTomadorAdquirenteIguais
    CASE REGEXP_REPLACE(EMITENTE.IDCNAE,'[^0-9]','','g') WHEN '9491000' THEN 1 ELSE 0 END AS tpSSQN, --0-Normal,1-Imune
    CASE REGEXP_REPLACE(EMITENTE.IDCNAE,'[^0-9]','','g') WHEN '9491000' THEN 3 ELSE 0 END AS tipodeimunidade, --1-OrgãoPublico,2-EntidadeDiplomatica,3-Outros
    0 AS ZERO,
    1 AS UM,
    2 AS DOIS,
    3 AS TRES,
    4 AS QUATRO,
    5 AS CINCO,
    CAST((regexp_match(NFECONFIG.blconfig,'(\[NF.)+'||
        'SERVICO'      ||'\][\r\n]{1,2}.*[\r\n]{1,2}'||
        'VERSAO'       ||'=([^\n\r]{0,6})[\r\n]{1,2}'
    ))[2] AS NUMERIC(5,2)) 
    AS VERSAO_NACIONAL,
    CASE (regexp_match(NFECONFIG.blconfig,'(\[NF.)+'||
        'SERVICO'      ||'\][\r\n]{1,2}.*[\r\n]{1,2}'||
        'AMBIENTE'     ||'=([^\n\r]{0,1})[\r\n]{1,2}'
    ))[2] 
    WHEN 0 THEN 2 --Homologação
    WHEN 1 THEN 1 --Produção
    END AS AMBIENTE_PRODUCAO
  FROM DOCFISCAL
  JOIN EMPRESA ON DOCFISCAL.CDEMPRESA = EMPRESA.CDEMPRESA
  JOIN PESSOA EMITENTE ON EMITENTE.CDPESSOA = EMPRESA.CDESTABELECIMENTO
  LEFT JOIN CONFIGURACAO AS REGIMEEMPRESA ON  REGIMEEMPRESA.CDEMPRESA=DOCFISCAL.CDEMPRESA AND REGIMEEMPRESA.dsparametro ='CFGREGIMEEMPRESA' 
  LEFT JOIN CONFIGURACAO AS REGIMETRIBISSQN ON REGIMETRIBISSQN.CDEMPRESA=DOCFISCAL.CDEMPRESA AND REGIMETRIBISSQN.dsparametro = 'CFGREGTRIBISSQN' 
  LEFT JOIN configuracao AS REFORMATRIBUTARIA on REFORMATRIBUTARIA.cdtipo = 3 AND REFORMATRIBUTARIA.dsparametro = 'CFGREFORMATRIBUTARIA'
  JOIN NFERETORNO ON DOCFISCAL.CDDOCFISCAL=NFERETORNO.CDNOTA AND DOCFISCAL.CDEMPRESA=NFERETORNO.CDEMPRESA
  LEFT JOIN NFECONFIG ON NFECONFIG.cdempresa = NFERETORNO.cdempresa AND NFECONFIG.fltiponotaes = 0
  WHERE DOCFISCAL.CDEMPRESA = :CDEMPRESA
  AND DOCFISCAL.CDDOCFISCAL = :CDNOTA
  and NFERETORNO.fltiponota = 1