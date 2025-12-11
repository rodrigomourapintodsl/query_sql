SELECT 
    DOCFISCAL.DTEMISSAO AS DATAEMISSAO, ----COMPETENCIA_CAB,
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
    CASE 
        WHEN REGIMEEMPRESA.nrvalorint=0 
        THEN 1 --1-OptanteMEI
        ELSE 0 --0-NaoOptante,2-OptanteMEEPP
    END AS OptanteSN,
    CASE 
        WHEN REGIMEEMPRESA.nrvalorint=0 
        THEN 0 --0-FederaisMunicipalpeloSN
        ELSE 2 --2-FederaisMunicipalforaSN
    END AS RegimeApuracaoSN, --,1-FederaisSN,
    0 AS tpXML, ----0-RPS,1-NFSe,2-Espelho
    0 AS ZERO,
    1 AS UM
  FROM DOCFISCAL
  JOIN EMPRESA ON DOCFISCAL.CDEMPRESA = EMPRESA.CDEMPRESA
  JOIN PESSOA EMITENTE ON EMITENTE.CDPESSOA = EMPRESA.CDESTABELECIMENTO
  LEFT JOIN CONFIGURACAO AS REGIMEEMPRESA ON  REGIMEEMPRESA.CDEMPRESA=DOCFISCAL.CDEMPRESA AND REGIMEEMPRESA.dsparametro ='CFGREGIMEEMPRESA' AND REGIMEEMPRESA.CDPARAMETRO=66
  LEFT JOIN CONFIGURACAO AS REGIMETRIBISSQN ON REGIMETRIBISSQN.CDEMPRESA=DOCFISCAL.CDEMPRESA AND REGIMETRIBISSQN.dsparametro = 'CFGREGTRIBISSQN' AND REGIMETRIBISSQN.CDPARAMETRO=416
  JOIN NFERETORNO ON DOCFISCAL.CDDOCFISCAL=NFERETORNO.CDNOTA AND DOCFISCAL.CDEMPRESA=NFERETORNO.CDEMPRESA
  WHERE DOCFISCAL.CDEMPRESA = :CDEMPRESA
  AND DOCFISCAL.CDDOCFISCAL = :CDNOTA
  and NFERETORNO.fltiponota = 1