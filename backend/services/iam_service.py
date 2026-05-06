import os
import json
from services import timescale_db

class IAMService:
    """
    Identity and Access Management (IAM) para controlar quais IMEIs 
    têm permissão para usar quais funcionalidades e modelos (via TimescaleDB).
    """

    @classmethod
    def load_permissions(cls):
        perms = timescale_db.get_all_permissions()
        if not perms:
            # Fallback if DB is empty or fails
            return {
                "GLOBAL_DEFAULT": {
                    "use_yolo": True,
                    "use_vlm": False,
                    "allowed_models": ["EPI", "Bocejo"]
                }
            }
        return perms

    @classmethod
    def save_permissions(cls, data):
        timescale_db.save_permissions(data)

    @classmethod
    def get_all_permissions(cls):
        return cls.load_permissions()

    @classmethod
    def get_device_policy(cls, imei):
        """ Retorna a política de acesso para um IMEI específico """
        perms = cls.load_permissions()
        return perms.get(str(imei), perms.get("GLOBAL_DEFAULT", {}))

    @classmethod
    def can_process_alarm(cls, imei, alarm_type):
        """ Verifica se o IMEI pode processar um tipo específico de alarme/modelo """
        policy = cls.get_device_policy(imei)
        return alarm_type in policy.get("allowed_models", [])

    @classmethod
    def should_use_vlm(cls, imei):
        """ Verifica se o VLM está ativado para este cliente/dispositivo """
        policy = cls.get_device_policy(imei)
        return policy.get("use_vlm", False)

    @classmethod
    def is_imei_authorized(cls, imei):
        """ Verifica se o IMEI está cadastrado na plataforma """
        perms = cls.load_permissions()
        return str(imei) in perms
