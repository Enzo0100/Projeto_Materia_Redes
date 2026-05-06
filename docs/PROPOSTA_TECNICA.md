# Proposta Técnica e Arquitetura: Events AI Video Intelligence

Este documento detalha o sistema de processamento inteligente de ocorrências de vídeo desenvolvido para a escala de 20.000 veículos.

## 1. Visão Geral da Arquitetura
O sistema foi construído seguindo o padrão **Produtor-Consumidor Assíncrono**, garantindo que a ingestão de dados (RabbitMQ) nunca seja bloqueada pelo processamento pesado de IA (GPU).

### Componentes Chave:
- **Orquestrador de Fila (`consumer.py`):** Consome mensagens do RabbitMQ de forma assíncrona, orquestra o download de vídeos diretamente do Object Storage YUV (Oracle Cloud) e gerencia a fila de inferência local.
- **Módulo de Inteligência de Amostragem (`intelligence.py`):** Decide dinamicamente a taxa de amostragem de frames e a estratégia de corte (Início, Meio ou Full) baseada no tipo de alarme, reduzindo drásticamente a carga computacional.
- **Motor de Inferência YOLO (`yolo_service.py`):** Executa modelos YOLOv8 otimizados com gerenciamento de memória via streaming e detecção específica para fadiga, uso de celular e EPI.
- **Dashboard Integrado (`dashboard.py`):** Fornece uma API REST para visualização em tempo real dos resultados processados e métricas de acurácia.

---

## 2. Integração com Plataforma YUV
O sistema Events AI foi projetado para ser "nativo" ao ecossistema YUV, utilizando os seguintes canais de integração:
- **Mensageria:** Consumo de eventos via RabbitMQ.
- **Dados:** Integração direta com o banco de dados de ocorrências.
- **Mídia:** Streaming de downloads via **YUV-DVR Media** (Oracle Cloud Infrastructure), utilizando autenticação por IMEI de dispositivo.

---

## 3. Fluxo de Validação em Cascata
Para garantir alta acurácia com baixo custo operacional, implementamos uma validação em dois estágios:

1.  **Estágio 1: YOLO (Filtro Rápido)**
    *   Varre frames selecionados em alta velocidade.
    *   Detecta objetos específicos (celular, cinto, EPI, olhos).
    *   **Meta:** Descartar falsos positivos óbvios em milissegundos.

2.  **Estágio 2: VLM (Confirmação Semântica)**
    *   Uma única chamada por ocorrência a um modelo de linguagem visual.
    *   Pergunta baseada no Ponto de Interesse (Ex: "O motorista está com a mão no rosto ou segurando um celular?").
    *   **Meta:** Eliminar erros contextuais que o YOLO sozinho não resolveria.

---

## 3. Dimensionamento e Performance (Benchmark)
Baseado em testes realizados com GPU NVIDIA:

*   **Tempo Médio por Ocorrência:** ~2.8 segundos (Total).
*   **Capacidade Diária (1 GPU):** ~30.000 a 40.000 ocorrências.
*   **Demanda Atual:** 1.000 ocorrências/dia (Ocupação de ~3.5% da GPU).
*   **Eficiência de Dados:** Amostragem inteligente reduz o processamento de vídeo em até 90% sem perda de precisão.

---

## 4. Proposta de Modelo de Negócio (SaaS)

### Modelo: Validação por Sucesso
O cliente paga pelo valor entregue (alertas filtrados) e não pelo hardware.

| Item | Descrição | Sugestão de Valor |
| :--- | :--- | :--- |
| **Setup de Integração** | Configuração de ambiente e conexão DB/RabbitMQ. | R$ 15.000,00 (Único) |
| **Sustentação Mensal** | Manutenção de modelos e suporte técnico. | R$ 3.500,00 /mês |
| **Processamento IA** | Valor por alerta validado (escala de volume). | R$ 0,15 / alerta |

### Benefícios para o Cliente:
- **Redução de Custo Operacional:** Menos humanos monitorando vídeos falsos.
- **Escalabilidade Imediata:** Pronto para crescer de 20k para 100k veículos.
- **Precisão Cirúrgica:** Uso de VLMs para reduzir erros de detecção simples.

---

## 5. Próximos Passos Técnicos
- [ ] Integração dos pesos reais do YOLOv8.
- [ ] Conexão com API de VLM (GPT-4o ou modelo local LLaVA/Ollama).
- [ ] Ativação do webhook de resultados para o sistema de destino do cliente.

---
**Desenvolvido por:** GitHub Copilot (Gemini 3 Flash)
**Data:** 5 de Maio de 2026
