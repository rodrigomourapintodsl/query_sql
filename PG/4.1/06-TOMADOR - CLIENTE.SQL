SELECT
    CASE WHEN TIPO.TIPOENDERECO IN ('N','E') THEN 'S' ELSE 'N' END AS ENDERECO_IDENTIFICAO,
    TIPO.TIPOPESSOA,
    TIPO.TIPOENDERECO,

/*Identificação*/
--# DPS.infDPS.toma.xNome
    CASE 
        WHEN DOCUMENTOS.NOME_UPPER NOT IN ('HOSPEDE','PASSANTE','CONSUMIDOR','ACOMPANHANTE','ACOMPANHANTE1','ACOMPANHANTE2','ACOMPANHANTE3','ACOMPANHANTE4','ACOMPANHANTE5','ACOMPANHANTE6')
        THEN CAST(NOTASFISCAIS.nome AS VARCHAR(150)) 
    END AS nome, 

--# DPS.infDPS.toma.CNPJ
--# DPS.infDPS.toma.CPF
    CASE 
        WHEN TIPO.TIPOPESSOA IN ('F','J')  --Brasil
        THEN DOCUMENTOS.CGCCPF
    END AS CGCCPF,

--# DPS.infDPS.toma.IM
    CASE 
        WHEN TIPO.TIPOPESSOA IN ('F','J') AND NOTASFISCAIS.inscmunicipal > '0'
        THEN CAST(DOCUMENTOS.INSCMUNIC AS VARCHAR(15)) 
    END AS INSCMUNIC,

--# DPS.infDPS.toma.CAEPF
    CASE 
        WHEN TIPO.TIPOPESSOA = 'F' AND NOTASFISCAIS.inscest > '0'
        THEN CAST(DOCUMENTOS.INSCEST AS VARCHAR(15)) 
    END AS CAEPF, --Pessoas Físicas
    
    CASE 
        WHEN TIPO.TIPOPESSOA = 'J' AND NOTASFISCAIS.inscest > '0'
        THEN CAST(DOCUMENTOS.INSCEST AS VARCHAR(15)) 
    END AS inscest, --Pessoas Jurídica

/*Identificação Estrangeiro*/
--# DPS.infDPS.toma.NIF
    CASE 
        WHEN TIPO.TIPOPESSOA = 'E' AND NOTASFISCAIS.CGCCPF > '0'
        THEN CAST(NOTASFISCAIS.CGCCPF AS VARCHAR(40))
    END AS Nif,

--# DPS.infDPS.toma.cNaoNIF
    CASE 
        WHEN TIPO.TIPOPESSOA IN ('E','C') AND NOTASFISCAIS.CGCCPF > '0'
        THEN 2 ----0-NaoInformado,1-Dispensado,2-NaoExigencia
    END AS cNaoNIF,

/*Endereço*/
--# DPS.infDPS.toma.end.xLgr
    CASE 
        WHEN TIPO.TIPOENDERECO <> 'C'
        THEN CAST(NOTASFISCAIS.ENDERECO AS VARCHAR(255))
    END AS endereco,

--# DPS.infDPS.toma.end.nro
    CASE 
        WHEN TIPO.TIPOENDERECO <> 'C'
        THEN COALESCE(NULLIF(NULLIF(DOCUMENTOS.NROENDERECO, ''), '0'), 'S/N') 
    END AS nroendereco,

--# DPS.infDPS.toma.end.xCpl
    CASE 
        WHEN TIPO.TIPOENDERECO <> 'C' AND NOTASFISCAIS.complemento LIKE '...%'
        THEN NOTASFISCAIS.complemento
    END AS complemento,

--# DPS.infDPS.toma.end.xBairro
    CASE 
        WHEN TIPO.TIPOENDERECO <> 'C'
        THEN COALESCE(NULLIF(NOTASFISCAIS.bairro, ''), 'CENTRO') 
    END AS bairro,

--# DPS.infDPS.toma.end.endNac.cMun
    CASE TIPO.TIPOENDERECO
        WHEN 'N' THEN NOTASFISCAIS.CodMunicipio
        WHEN 'E' THEN '9999999'
    END AS CodMunicipio,

    CASE TIPO.TIPOENDERECO
        WHEN 'N' THEN NOTASFISCAIS.CodMunicipioSiaf
        WHEN 'E' THEN '99999'
    END AS CodMunicipioSiaf,

--# DPS.infDPS.toma.end.endExt.xEstProvReg
    CASE TIPO.TIPOENDERECO
        WHEN 'N' THEN NOTASFISCAIS.estado
        WHEN 'E' THEN 'EX'
    END AS UF,

--# DPS.infDPS.toma.end.endNac.CEP
--# DPS.infDPS.toma.end.endExt.cEndPost
    CASE 
        WHEN TIPO.TIPOENDERECO = 'N'
        THEN CAST(DOCUMENTOS.CEP AS VARCHAR(8))
        WHEN TIPO.TIPOENDERECO = 'E' AND COALESCE(REPLACE(NOTASFISCAIS.cep, LEFT(NOTASFISCAIS.cep, 1), ''), '') = '' 
        THEN '99999999'
        WHEN TIPO.TIPOENDERECO = 'E'
        THEN NOTASFISCAIS.cep
    END AS cep,

--# DPS.infDPS.toma.end.endExt.xCidade
    COALESCE(NULLIF(NOTASFISCAIS.cidade, ''), NOTASFISCAIS.pais) AS xMunicipio,

    CASE TIPO.TIPOENDERECO
        WHEN 'N' THEN '1058'
        WHEN 'E' THEN RIGHT(TRIM(NOTASFISCAIS.codpais), 4)
        WHEN 'C' THEN '1058'
    END AS codpais,

    '' AS PontoReferencia

FROM NOTASFISCAIS
 JOIN CONFIGURA ON CONFIGURA.CODHOTEL = NOTASFISCAIS.CODHOTEL
 JOIN NFERETORNO ON NOTASFISCAIS.CODNOTA = NFERETORNO.CDNOTA AND NOTASFISCAIS.CODHOTEL = NFERETORNO.CDEMPRESA
 
 -- Higienização de strings
 CROSS JOIN LATERAL (
    SELECT
        regexp_replace(NOTASFISCAIS.CGCCPF, '[^0-9A-Za-z]', '', 'g') AS CGCCPF,
        regexp_replace(NOTASFISCAIS.inscmunicipal, '[^0-9]', '', 'g') AS INSCMUNIC,
        regexp_replace(NOTASFISCAIS.inscest, '[^0-9]', '', 'g') AS INSCEST,
        regexp_replace(NOTASFISCAIS.nroendereco, '[^0-9]', '', 'g') AS NROENDERECO,
        regexp_replace(NOTASFISCAIS.cep, '[^0-9]', '', 'g') AS CEP,
        UPPER(NOTASFISCAIS.NOME) AS NOME_UPPER
 ) AS DOCUMENTOS

 -- Tipo de pessoa e tipo de endereço
 CROSS JOIN LATERAL (
    SELECT
        CASE 
            CASE
               WHEN CONFIGURA.CGC = NOTASFISCAIS.CGCCPF 
               THEN 'P'
               WHEN DOCUMENTOS.NOME_UPPER IN ('HOSPEDE','PASSANTE','CONSUMIDOR','ACOMPANHANTE','ACOMPANHANTE1','ACOMPANHANTE2','ACOMPANHANTE3','ACOMPANHANTE4','ACOMPANHANTE5','ACOMPANHANTE6')
               THEN 'FC' --CONSUMIDOR
               WHEN LENGTH(REPLACE(NOTASFISCAIS.CGCCPF, LEFT(NOTASFISCAIS.CGCCPF, 1), '')) <= 1
               THEN 'FC' --CONSUMIDOR
               WHEN CHAR_LENGTH(NOTASFISCAIS.CGCCPF) = 14 
                AND NOTASFISCAIS.CGCCPF ~ '^[0-9]{3}\.[0-9]{3}\.[0-9]{3}[^0-9A-Za-z][0-9Xx]{2}$'
                AND NOTASFISCAIS.CGCCPF NOT IN ('000.000.000-00','111.111.111-11','222.222.222-22','333.333.333-33','444.444.444-44','555.555.555-55','666.666.666-66','777.777.777-77','888.888.888-88','999.999.999-99')
               THEN 'F' --PESSOA FÍSICA IDENTIFICADA
               WHEN NOTASFISCAIS.PAIS IN ('BRASIL','BRAZIL') AND TRIM(NOTASFISCAIS.CODPAIS) IN ('01058','1058')
                AND CHAR_LENGTH(NOTASFISCAIS.CGCCPF) = 18 
                AND NOTASFISCAIS.CGCCPF ~ '^[0-9A-Za-z]{2}\.?[0-9A-Za-z]{3}\.?[0-9A-Za-z]{3}/?[0-9A-Za-z]{4}-?[0-9]{2}$'
                AND NOTASFISCAIS.CGCCPF NOT IN ('00.000.000/0000-00','11.111.111/1111-11','22.222.222/2222-22','33.333.333/3333-33','44.444.444/4444-44','55.555.555/5555-55','66.666.666/6666-66','77.777.777/7777-77','88.888.888/8888-88','99.999.999/9999-99')
               THEN 'J' --PESSOA JURÍDICA
               WHEN NOTASFISCAIS.PAIS IN ('BRASIL','BRAZIL') AND TRIM(NOTASFISCAIS.CODPAIS) IN ('01058','1058')
               THEN 'FC' --CONSUMIDOR
               WHEN NOTASFISCAIS.CODPAIS NOT IN ('01058','1058') AND (NOTASFISCAIS.CGCCPF = '' OR NOTASFISCAIS.CGCCPF IS NULL)
               THEN 'EC' --ESTRANGEIRO NÃO IDENTIFICADO
               ELSE 'E' --ESTRANGEIRO
            END
            WHEN 'F'  THEN 'F' --CPF de Pessoa Fisica
            WHEN 'J'  THEN 'J' --CNPJ de Empresa Jurídica
            WHEN 'FC' THEN 'C' --Consumidor não identificado
            WHEN 'E'  THEN 'E' --Estrangeiro
            WHEN 'EN' THEN 'E' --Estrangeiro com CPF
            WHEN 'EB' THEN 'C' --Estrangeiro Residente no Brasil comum no RJ
            WHEN 'EC' THEN 'E' --Estrangeiro não identificado
            WHEN 'P'  THEN 'A' --Emissão para o proprio CNPJ
            ELSE 'C' -- Outros
        END AS TIPOPESSOA,
        CASE
            WHEN CONFIGURA.CGC = NOTASFISCAIS.CGCCPF
            THEN 'A'
            WHEN NOTASFISCAIS.SITUACAO <> 'C'
             AND CHAR_LENGTH(REPLACE(NOTASFISCAIS.ENDERECO, LEFT(NOTASFISCAIS.ENDERECO, 1), '')) > 3
             AND TRIM(UPPER(NOTASFISCAIS.PAIS)) IN ('BRASIL','BRAZIL')
             AND TRIM(NOTASFISCAIS.CODPAIS) IN ('01058','1058')
             AND TRIM(UPPER(NOTASFISCAIS.estado)) IN ('AC', 'AL', 'AM', 'AP', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RN', 'RS', 'RJ', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO')
             AND CHAR_LENGTH(DOCUMENTOS.CEP) = 8
             AND NOTASFISCAIS.CodMunicipio > 1000000 AND NOTASFISCAIS.CodMunicipio < 9999999
             AND NOTASFISCAIS.codpais > '0'
            THEN 'N' --Nacional
            WHEN NOTASFISCAIS.SITUACAO <> 'C' 
             AND CHAR_LENGTH(REPLACE(NOTASFISCAIS.ENDERECO, LEFT(NOTASFISCAIS.ENDERECO, 1), '')) > 3
             AND TRIM(UPPER(NOTASFISCAIS.PAIS)) NOT IN ('BRASIL','BRAZIL')
             AND TRIM(NOTASFISCAIS.CODPAIS) NOT IN ('01058','1058')
             AND NOTASFISCAIS.codpais > '0'
            THEN 'E' --Estrangeiro
            ELSE 'C'
        END AS TIPOENDERECO
 ) AS TIPO

WHERE NFERETORNO.CDNOTA = :CDNOTA
  AND NFERETORNO.CDEMPRESA = :CDEMPRESA
  AND NFERETORNO.fltiponota = 1
  AND NOTASFISCAIS.CODNOTA = :CDNOTA
  AND NOTASFISCAIS.CODHOTEL = :CDEMPRESA
;