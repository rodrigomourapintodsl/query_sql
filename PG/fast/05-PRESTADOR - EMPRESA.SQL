SELECT 
    EMITENTE.dsnomepessoa AS RazaoSocial,
    EMITENTE.iddocident AS CGC,
    EMITENTE.IDIM AS INSCMUNICIP,
    '' AS CAEPF, --Pessoas Físicas
    0 AS cNaoNIF, ----0-NaoInformado,1-Dispensado,2-NaoExigencia
    PESSOAENDERECO.dslogradouro AS endereco_emp,
    COALESCE(NULLIF(regexp_replace( PESSOAENDERECO.dsnumero , '[^0-9]', '', 'g'),''),'0') AS nroendereco_emp,
    PESSOAENDERECO.dscomplemento AS complemento_emp,
    PESSOAENDERECO.dsbairro AS bairro_emp,
    CIDADE.idibge AS CodMunicipio_emp,
    ESTADO.dssigla AS UF_emp,
    PESSOAENDERECO.idcep AS cep_emp,
    CIDADE.dscidade AS xMunicipio_emp,
    RIGHT(CAST(PAIS.idibge AS VARCHAR(5)),4) AS CodPais_emp,
    PAIS.dssigla as CodPaisAlf2_emp,
    PAIS.DSPAIS,
    EMPRESA.dsapelido AS PontoReferencia_emp,
    CASE 
        WHEN LENGTH(PESSOACONTATO.idtelefone) BETWEEN 8 AND 14 
        THEN CASE 
                    WHEN PESSOACONTATO.idtelefone LIKE '+55' 
                    THEN REGEXP_REPLACE(RIGHT(PESSOACONTATO.idtelefone,-3),'[^0-9]','','g')
                    ELSE  REGEXP_REPLACE(PESSOACONTATO.idtelefone,'[^0-9]','','g')
                 END
    END AS fone_fax_emp,
    trim(split_part(PESSOACONTATO.dsemailpessoa,';',1)) AS email_emp
FROM EMPRESA 
  JOIN PESSOA EMITENTE ON EMITENTE.CDPESSOA = EMPRESA.CDESTABELECIMENTO
  JOIN PESSOAENDERECO ON PESSOAENDERECO.CDPESSOA = EMITENTE.CDPESSOA AND PESSOAENDERECO.NRTIPOENDERECO = 0
  JOIN CIDADE ON CIDADE.CDCIDADE = PESSOAENDERECO.CDCIDADE
  JOIN ESTADO ESTADO ON ESTADO.CDESTADO = CIDADE.CDESTADO
  JOIN PAIS ON PAIS.CDPAIS = ESTADO.CDPAIS
  LEFT JOIN PESSOACONTATO ON PESSOAENDERECO.CDPESSOAENDERECO = PESSOACONTATO.CDPESSOAENDERECO AND PESSOACONTATO.FLENDERECO = 1
WHERE EMPRESA.CDEMPRESA = :CDEMPRESA