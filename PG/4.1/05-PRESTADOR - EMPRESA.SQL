SELECT 
    CONFIGURA.RazaoSocial,
    CONFIGURA.CGC,
    CONFIGURA.INSCMUNICIP,
    '' AS CAEPF, --Pessoas Físicas
    0 AS cNaoNIF, ----0-NaoInformado,1-Dispensado,2-NaoExigencia
    CONFIGURA.ENDERECO AS endereco_emp,
    COALESCE(CONFIGURA.ENDNUMERO,0) AS nroendereco_emp,
    CONFIGURA.endcomplem AS complemento_emp,
    CONFIGURA.bairro AS bairro_emp,
    CONFIGURA3.CODIBGEHOTEL AS CodMunicipio_emp,
    CONFIGURA.ESTADO AS UF_emp,
    CONFIGURA.cep AS cep_emp,
    CONFIGURA.CIDADE AS xMunicipio_emp,
    1058 AS CodPais_emp,
    'BR' as CodPaisAlf2_emp,
    CONFIGURA.PAIS AS DSPAIS,
    CONFIGURA.nomeempresa AS PontoReferencia_emp,
    CASE 
        WHEN LENGTH(CONFIGURA.telefone) BETWEEN 8 AND 14 
        THEN CASE 
                    WHEN CONFIGURA.telefone LIKE '+55' 
                    THEN REGEXP_REPLACE(RIGHT(CONFIGURA.telefone,-3),'[^0-9]','','g')
                    ELSE REGEXP_REPLACE(CONFIGURA.telefone,'[^0-9]','','g')
                 END
    END AS fone_fax_emp,
    trim(split_part(configura.email,';',1)) AS email_emp
  FROM CONFIGURA 
  JOIN CONFIGURA3 ON CONFIGURA3.CODHOTEL = CONFIGURA.CODHOTEL
WHERE CONFIGURA.CODHOTEL = :CDEMPRESA