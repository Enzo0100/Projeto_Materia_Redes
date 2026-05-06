import os
from minio import Minio
from core.config import settings
import uuid

class MinioService:
    client = None
    bucket_name = "inferences"

    @classmethod
    def get_client(cls):
        if cls.client is None:
            minio_host = os.getenv("MINIO_HOST", "minio:9000")
            minio_user = os.getenv("MINIO_USER", "minioadmin")
            minio_password = os.getenv("MINIO_PASSWORD", "minioadmin")
            
            cls.client = Minio(
                minio_host,
                access_key=minio_user,
                secret_key=minio_password,
                secure=False
            )
            
            try:
                found = cls.client.bucket_exists(cls.bucket_name)
                if not found:
                    cls.client.make_bucket(cls.bucket_name)
                    # Set bucket policy to public read
                    policy = f"""{{
                        "Version": "2012-10-17",
                        "Statement": [
                            {{
                                "Effect": "Allow",
                                "Principal": {{"AWS": ["*"]}},
                                "Action": ["s3:GetObject"],
                                "Resource": ["arn:aws:s3:::{cls.bucket_name}/*"]
                            }}
                        ]
                    }}"""
                    cls.client.set_bucket_policy(cls.bucket_name, policy)
            except Exception as e:
                print(f" [MINIO] Erro ao inicializar bucket: {e}")
                
        return cls.client

    @classmethod
    def upload_file(cls, file_path, content_type="video/mp4"):
        try:
            client = cls.get_client()
            file_name = f"{uuid.uuid4()}_{os.path.basename(file_path)}"
            
            client.fput_object(
                cls.bucket_name, 
                file_name, 
                file_path,
                content_type=content_type
            )
            
            # Since it's public, the URL will be just the host/bucket/file
            # In a local environment, we return localhost for the frontend to access
            public_host = os.getenv("MINIO_PUBLIC_HOST", "localhost:9000")
            return f"http://{public_host}/{cls.bucket_name}/{file_name}"
        except Exception as e:
            print(f" [MINIO] Erro ao fazer upload do arquivo {file_path}: {e}")
            return None
