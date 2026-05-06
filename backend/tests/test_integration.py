import pytest
import sys
import os
import requests
from unittest.mock import patch, MagicMock

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from services.database import get_alarm_files
from worker.consumer import download_video

@patch("services.database.mysql.connector.connect")
def test_get_alarm_files_success(mock_connect):
    # Mocking o retorno do banco de dados
    mock_conn = MagicMock()
    mock_cursor = MagicMock()
    mock_connect.return_value = mock_conn
    mock_conn.cursor.return_value = mock_cursor
    
    mock_cursor.fetchall.return_value = [
        {"file_name": "video1.mp4", "device_imei": "123456", "alarm_type": "Fumar"}
    ]
    
    result = get_alarm_files(1)
    
    assert len(result) == 1
    assert result[0]["alarm_type"] == "Fumar"
    mock_cursor.execute.assert_called_once()
    mock_cursor.close.assert_called_once()
    mock_conn.close.assert_called_once()

@patch("services.database.mysql.connector.connect")
def test_get_alarm_files_failure(mock_connect):
    # Força exceção para testar as retentativas
    mock_connect.side_effect = Exception("DB Connection Error")
    
    result = get_alarm_files(99, retries=2, delay=0.1)
    
    assert result == []
    assert mock_connect.call_count == 2

@patch("worker.consumer.requests.get")
def test_download_video_success(mock_get):
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.content = b"fake_video_data"
    mock_get.return_value = mock_response
    
    # Executa o download
    path = download_video("imei123", "test_video.mp4", 404)
    
    assert path is not None
    assert "test_video.mp4" in path
    assert os.path.exists(path)
    
    # Limpa o arquivo criado
    os.remove(path)

@patch("worker.consumer.requests.get")
def test_download_video_failure(mock_get):
    mock_response = MagicMock()
    mock_response.raise_for_status.side_effect = requests.exceptions.HTTPError("404 Not Found")
    mock_get.return_value = mock_response
    
    path = download_video("imei123", "not_found.mp4", 404)
    assert path is None
