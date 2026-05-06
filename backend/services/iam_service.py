import os

class IAMService:
    """
    Identity and Access Management (IAM) para controlar quais IMEIs 
    têm permissão para usar quais funcionalidades e modelos.
    """
    
    # Simulação de base de dados de permissões
    # Em produção, isso viria de um DB ou Redis
    _PERMISSIONS = {
        "GLOBAL_DEFAULT": {
            "use_yolo": True,
            "use_vlm": False,
            "allowed_models": ["EPI", "Bocejo"]
        },
        "14681536": { # Exemplo de IMEI com acesso total
            "use_yolo": True,
            "use_vlm": True,
            "allowed_models": ["Bocejo", "Distração", "Uso de Celular", "Fumar", "EPI", "Capacete", "Acompanhante"]
        },
        "14681538": { # Exemplo de IMEI restrito
            "use_yolo": True,
            "use_vlm": False,
            "allowed_models": ["EPI"]
        }
    }

    @classmethod
    def get_device_policy(cls, imei):
        """ Retorna a política de acesso para um IMEI específico """
        return cls._PERMISSIONS.get(str(imei), cls._PERMISSIONS["GLOBAL_DEFAULT"])

    @classmethod
    def can_process_alarm(cls, imei, alarm_type):
        """ Verifica se o IMEI pode processar um tipo específico de alarme/modelo """
        policy = cls.get_device_policy(imei)
        return alarm_type in policy["allowed_models"]

    @classmethod
    def should_use_vlm(cls, imei):
        """ Verifica se o VLM está ativado para este cliente/dispositivo """
        policy = cls.get_device_policy(imei)
        return policy.get("use_vlm", False)

    @classmethod
    def is_imei_authorized(cls, imei):
        """ Verifica se o IMEI está cadastrado na plataforma """
        return str(imei) in cls._PERMISSIONS
