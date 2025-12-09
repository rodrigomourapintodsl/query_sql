SELECT NOTASFISCAIS.DATAEMISSAO,
    CASE 
        WHEN CONFIGURA3.REGIMETRIBUTARIO=0
        THEN 5
        ELSE 0
    END AS REGIMEESPECIALTRIBUTACAO,  ----0-nenhum, 1-MicroempresaMunicipal, 2-Estimativa, 3-SociedadeProfissionais, 4-Cooperativa, 5-MicroempresarioIndividual, 6-MicroempresarioEmpresaPP, 7-LucroReal, 8-LucroPresumido, 9-SimplesNacional,10-Imune,11-EmpresaIndividualRELI,12-EmpresaPP,13-MicroEmpresario,14-Outros,15-MovimentoMensal,16-ISSQNAutonomos,17-ISSQNSociedade,18-NotarioRegistrador,19-TribFaturamentoVariavel,20-Fixo,21-Isencao,22-ExigibSuspensaJudicial,23-ExigibSuspensaAdm
    CASE WHEN NFERETORNO.FLTIPONOTA=1 AND ( NFERETORNO.FLSTATUS IN (2,6))
        THEN NOTASFISCAIS.descmotivocancel 
    END AS DSMOTIVOCANC,    
    1 AS infAdicAT, ----0-Sim,1-Nao
    1 AS Transacao, ----0-Sim,1-Nao
    0 AS tpEmit, ----0-Prestador,1-Tomador,2-Intermediario
    CASE 
        WHEN CONFIGURA3.REGIMETRIBUTARIO=0 
        THEN 1 --1-OptanteMEI
        ELSE 0 --0-NaoOptante,2-OptanteMEEPP
    END AS OptanteSN,
    CASE 
        WHEN CONFIGURA3.REGIMETRIBUTARIO=0 AND CONFIGURA3.regtribexsublimite<>'S'
        THEN 0 --0-FederaisMunicipalpeloSN
        ELSE 2 --2-FederaisMunicipalforaSN
    END AS RegimeApuracaoSN, --,1-FederaisSN,
    0 AS tpXML, ----0-RPS,1-NFSe,2-Espelho
    0 AS ZERO,
    1 AS UM
  FROM NOTASFISCAIS
  JOIN CONFIGURA ON CONFIGURA.CODHOTEL = NOTASFISCAIS.CODHOTEL
  JOIN CONFIGURA3 ON CONFIGURA3.CODHOTEL = NOTASFISCAIS.CODHOTEL
  JOIN NFERETORNO ON NFERETORNO.CDEMPRESA = NOTASFISCAIS.CODHOTEL AND NFERETORNO.CDNOTA = NOTASFISCAIS.CODNOTA
    WHERE NOTASFISCAIS.CODHOTEL = :CDEMPRESA
  AND NOTASFISCAIS.CODNOTA = :CDNOTA