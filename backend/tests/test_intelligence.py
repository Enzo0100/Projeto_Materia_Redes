import pytest
import sys
import os

# Adiciona backend ao PYTHONPATH para resolver imports
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from services.intelligence import FrameIntelligence

def test_inference_strategy_bocejo():
    strategy = FrameIntelligence.get_inference_strategy("Bocejo", "fake_path.mp4")
    assert strategy["sample_rate"] == 5
    assert strategy["priority"] == "middle"

def test_inference_strategy_epi():
    strategy = FrameIntelligence.get_inference_strategy("EPI", "fake_path.mp4")
    assert strategy["priority"] == "start"
    assert strategy["max_frames"] == 5

def test_inference_strategy_default():
    strategy = FrameIntelligence.get_inference_strategy("AlarmeDesconhecido", "fake_path.mp4")
    assert strategy["sample_rate"] == 5
    assert strategy["priority"] == "full"

def test_get_vlm_prompt_by_poi():
    prompt_bocejo = FrameIntelligence.get_vlm_prompt_by_poi("Bocejo", "DETECTADO_1")
    assert "fadiga" in prompt_bocejo.lower()
    
    prompt_default = FrameIntelligence.get_vlm_prompt_by_poi("NovoAlarme", "DETECTADO_2")
    assert "falso positivo" in prompt_default.lower()
    assert "NovoAlarme" in prompt_default

def test_should_process_all_videos():
    assert FrameIntelligence.should_process_all_videos(123, ["v1.mp4", "v2.mp4"]) == True
    assert FrameIntelligence.should_process_all_videos(123, ["v1", "v2", "v3", "v4"]) == False
