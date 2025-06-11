# useful-queries
Aqui estão algumas queries úteis que eu utilizo no n8n 



SELECT string_agg(
  sub.nome || ' - ' || sub.mensagem || ' - ' || sub.data_formatada::TEXT, E'\n'
) AS conversa_formatada
FROM (
  SELECT 
    m."key"->>'remoteJid' AS grupo,
    SPLIT_PART(m."key"->>'participant', '@', 1) AS whatsapp,
    m."pushName" AS nome,
    m."message"->>'conversation' AS mensagem,
    TO_CHAR(TO_TIMESTAMP(m."messageTimestamp"), 'YYYY-MM-DD HH24:MI:SS') AS data_formatada
  
  FROM "Message" m 
  WHERE m."messageType" = 'conversation'
        AND m."key"->>'remoteJid' = '{{ $('Config').item.json.Grupo }}'
        AND m."messageTimestamp" > {{$now.minus($json.Horas, 'hours').toSeconds()}}
  ORDER BY m."messageTimestamp" ASC
) sub

-- Essa query busca todas as mensagens do grupo especificado e dentro do prazo especificado em horas. As mensagens são retornadas como um grande texto
