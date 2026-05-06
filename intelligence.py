import os

class FrameIntelligence:
    """
    Módulo responsável por decidir a estratégia de inferência para otimizar o uso da GPU.
    """
    
    @staticmethod
    def get_inference_strategy(alarm_type, video_path):
        """
        Decide quantos frames analisar e em quais pontos do vídeo.
        Evita processar o vídeo todo desnecessariamente.
        """
        # Regras de Negócio Otimizadas
        rules = {
            "Bocejo": {"sample_rate": 5, "max_frames": 20, "priority": "middle"}, # Foca no meio do vídeo
            "Uso de Celular": {"sample_rate": 2, "max_frames": 50, "priority": "full"}, # Precisa de mais frames
            "Fumar": {"sample_rate": 3, "max_frames": 30, "priority": "full"},
            "EPI": {"sample_rate": 10, "max_frames": 5, "priority": "start"}, # Geralmente no início já resolve
            "Acompanhante": {"sample_rate": 15, "max_frames": 3, "priority": "start"}
        }

        # Busca regra específica ou usa padrão genérico
        strategy = rules.get(alarm_type, {"sample_rate": 5, "max_frames": 10, "priority": "full"})
        
        print(f" [INTEL] Estratégia para '{alarm_type}': Processar {strategy['max_frames']} frames (1 a cada {strategy['sample_rate']})")
        return strategy

    @staticmethod
    def get_vlm_prompt_by_poi(alarm_type, yolo_result):
        """
        Gera um prompt específico para o VLM baseado no 'Ponto de Interesse' (POI) 
        detectado pelo YOLO. Isso ajuda o VLM a não alucinar e focar no problema.
        """
        prompts = {
            "Bocejo": f"O motorista foi detectado com sinal de fadiga ({yolo_result}). Verifique se ele está realmente bocejando ou apenas respirando fundo.",
            "Celular": f"O motorista parece estar usando o celular. Confirme se o objeto na mão dele é um smartphone ou outro item (como um rádio ou garrafa).",
            "EPI": f"O YOLO indicou falta de EPI ({yolo_result}). Analise minuciosamente se o motorista está usando capacete e colete refletivo.",
            "Acompanhante": "Verifique se a pessoa no banco do passageiro é um acompanhante não autorizado ou apenas uma sombra/objeto no banco."
        }
        
        default_prompt = f"O sistema detectou um possível alerta de {alarm_type}. Analise o frame e confirme se é um falso positivo ou uma infração real."
        return prompts.get(alarm_type, default_prompt)

    @staticmethod
    def should_process_all_videos(occurrence_id, files):
        """
        Decide se precisamos baixar e processar todos os vídeos da ocorrência.
        Ex: Se em uma ocorrência de 5 vídeos, o 1º já confirmar Faltas de EPI graves, 
        talvez não precise dos outros 4.
        """
        if len(files) > 3:
            print(f" [INTEL] Ocorrência {occurrence_id} tem muitos vídeos ({len(files)}). Iniciando amostragem por relevância.")
            return False # Indica que deve rodar apenas os mais relevantes primeiro
        return True
