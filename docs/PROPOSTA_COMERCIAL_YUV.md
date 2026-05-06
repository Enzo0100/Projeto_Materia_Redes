# Proposta Comercial: Kimura AI + Plataforma YUV

**Data:** 6 de Maio de 2026  
**Cliente:** Usuário da Plataforma YUV  
**Solução:** Módulo Kimura AI de Validação Automática de Eventos

## 1. Introdução
Esta proposta visa a implementação do módulo **Kimura AI** como uma camada de inteligência adicional à plataforma **YUV**. O objetivo principal é a redução drástica (estimada em +85%) de falsos positivos gerados por telemetria e câmeras embarcadas, permitindo que a equipe de monitoramento foque apenas em ocorrências reais e críticas.

## 2. Diferenciais da Solução via YUV
- **Nativo:** Integração direta com o RabbitMQ e Object Storage da YUV.
- **Transparência:** O cliente continua utilizando a interface YUV, com os alertas sendo validados "nos bastidores" pelo Kimura AI.
- **IA em Cascata:** Combinação de visão computacional com VLM (validação semântica contextual) para máxima precisão.

## 3. Escopo de Atendimento
O sistema processará automaticamente alarmes de:
- Uso de Celular ao dirigir.
- Fadiga e Sonolência (Bocejo/Olhos fechados).
- Ausência de EPI (Capacete/Colete).
- Fumo na cabine.
- Acompanhante não autorizado.

## 4. Investimento e Modelos de Valor

### Opção A: SaaS (Pay-per-Event)
*Ideal para clientes que buscam baixo investimento inicial.*

| Item | Valor | Detalhes |
| :--- | :--- | :--- |
| **Setup de Integração** | R$ 12.000,00 | Pago uma única vez para configuração inicial. |
| **Custo por Alerta Validado** | R$ 0,18 | Cobrado apenas para alertas confirmados ou descartados com sucesso. |
| **SLA de Processamento** | Incluso | Garantia de análise em até 5 segundos por evento. |

### Opção B: Licenciamento Dedicado (On-Premise/Cloud Privada)
*Ideal para frotas acima de 5.000 veículos.*

| Item | Valor | Detalhes |
| :--- | :--- | :--- |
| **Licença Anual** | R$ 60.000,00 | Permite processamento ilimitado em hardware dedicado. |
| **Suporte e Manutenção** | R$ 3.500,00 /mês | Atualizações de modelos e monitoramento de performance. |

---

## 5. Benefícios Financeiros Estimados
- **Redução de Headcount:** Economia média de 3 operadores de vídeo para cada 1.000 veículos monitorados.
- **Redução de Riscos:** Detecção preventiva de fadiga reduz sinistros em até 40%.
- **Eficiência de Rede:** Processamento inteligente consome menos banda ao solicitar apenas frames chave do vídeo.

## 6. Próximos Passos
1. Homologação técnica via API YUV (48h).
2. Período de Testes (PoC) de 7 dias com dados reais.
3. Ativação em ambiente de produção.

---
**Kimura AI - Inteligência que salva vidas.**
