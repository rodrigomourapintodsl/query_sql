SELECT 
    CONFIGURA.RazaoSocial,
    CONFIGURA.CGC,
     CASE WHEN CONFIGURA3.CODIBGEHOTEL IN ('31026052','2611606','21113002') THEN
      cast(cast(regexp_replace(CONFIGURA.INSCMUNICIP, '[^0-9]', '', 'g') as int) as varchar(15))
      WHEN CONFIGURA3.CODIBGEHOTEL IN ('1200401') THEN
      regexp_replace(CONFIGURA.CGC, '[^0-9]', '', 'g')
    END AS INSCMUNICIP,
    REGEXP_REPLACE(CONFIGURA3.NFSECNAE,'[^0-9]','','g') AS CNAE,
    '' AS CAEPF, --Pessoas Físicas
    0 AS cNaoNIF, ----0-NaoInformado,1-Dispensado,2-NaoExigencia
    CONFIGURA.ENDERECO AS endereco_emp,
    COALESCE(CONFIGURA.ENDNUMERO,0) AS nroendereco_emp,
    CONFIGURA.ENDCOMPLEM AS complemento_emp,
    CONFIGURA.BAIRRO AS bairro_emp,
    CONFIGURA3.CODIBGEHOTEL AS CodMunicipio_emp,
    CONFIGURA.ESTADO AS UF_emp,
    CONFIGURA.CEP AS cep_emp,
    CONFIGURA.CIDADE AS xMunicipio_emp,
    1058 AS CodPais_emp,
    'BR' AS CodPaisAlf2_emp,
    '0076' AS CODM49_emp,
    CONFIGURA.PAIS AS DSPAIS,
    CONFIGURA.NOMEEMPRESA AS PontoReferencia_emp,
    CASE 
        WHEN LENGTH(CONFIGURA.TELEFONE) BETWEEN 8 AND 14 
        THEN CASE 
                    WHEN CONFIGURA.TELEFONE LIKE '+55' 
                    THEN REGEXP_REPLACE(RIGHT(CONFIGURA.TELEFONE,-3),'[^0-9]','','g')
                    ELSE REGEXP_REPLACE(CONFIGURA.TELEFONE,'[^0-9]','','g')
                 END
    END AS fone_fax_emp,
    TRIM(SPLIT_PART(CONFIGURA.EMAIL,';',1)) AS email_emp
  FROM CONFIGURA 
  JOIN CONFIGURA3 ON CONFIGURA3.CODHOTEL = CONFIGURA.CODHOTEL
WHERE CONFIGURA.CODHOTEL = :CDEMPRESA