# ====================== GROK CREATOR - SCRIPT COMPLETO ======================
# pip install openai python-dotenv
# Coloque sua chave no arquivo .env

import os
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

client = OpenAI(
    api_key=os.getenv("XAI_API_KEY"),
    base_url="https://api.x.ai/v1"
)

class GrokCreator:
    def __init__(self):
        self.system_prompt = """[COLE O SYSTEM_PROMPT ACIMA AQUI]"""

    def _chat(self, messages):
        response = client.chat.completions.create(
            model="grok-4.20-reasoning",  # ou grok-4.20-non-reasoning
            messages=messages,
            temperature=0.85,
            max_tokens=4096
        )
        return response.choices[0].message.content

    # ====================== IMAGENS ======================
    def criar_imagem(self, prompt: str, pro: bool = False):
        model = "grok-imagine-image-pro" if pro else "grok-imagine-image"
        print(f"🖼️  Gerando imagem com {model}...")
        
        response = client.images.generate(
            model=model,
            prompt=prompt,
            n=1,
            size="1024x1024",  # ou 2048x2048 se disponível
            response_format="url"
        )
        return response.data[0].url

    # ====================== VÍDEOS (com áudio nativo) ======================
    def criar_video(self, prompt: str, image_url: str = None, duration: int = 10):
        print(f"🎥 Gerando vídeo de {duration}s com áudio nativo...")
        
        if image_url:
            # Image-to-Video
            response = client.video.generate(
                model="grok-imagine-video",
                prompt=prompt,
                image_url=image_url,
                duration=duration,
                aspect_ratio="16:9"
            )
        else:
            # Text-to-Video
            response = client.video.generate(
                model="grok-imagine-video",
                prompt=prompt,
                duration=duration,
                aspect_ratio="16:9"
            )
        return response.data[0].url  # URL do MP4 com áudio

    # ====================== ÁUDIO (via vídeo ou voice) ======================
    def criar_audio(self, texto: str, voice: str = "default"):
        # Uma forma fácil é gerar um vídeo curto só com áudio
        prompt = f"Áudio limpo: {texto}. Voz clara, sem música de fundo."
        return self.criar_video(prompt, duration=5)

    # ====================== APPS ======================
    def criar_app(self, descricao: str):
        messages = [
            {"role": "system", "content": self.system_prompt},
            {"role": "user", "content": f"Crie um aplicativo completo: {descricao}. Forneça todo o código pronto para rodar."}
        ]
        return self._chat(messages)

    # ====================== MODELOS 3D ======================
    def criar_modelo_3d(self, descricao: str, engine: str = "blender"):
        messages = [
            {"role": "system", "content": self.system_prompt},
            {"role": "user", "content": f"Crie um modelo 3D de: {descricao}. Use {engine} e forneça o código/script completo."}
        ]
        return self._chat(messages)

    # ====================== MÉTODO MÁGICO (tudo em um) ======================
    def criar(self, pedido: str):
        messages = [
            {"role": "system", "content": self.system_prompt},
            {"role": "user", "content": pedido}
        ]
        
        resposta = self._chat(messages)
        
        if "GERANDO_IMAGEM:" in resposta:
            prompt_otimizado = resposta.split("GERANDO_IMAGEM:")[-1].strip()
            return self.criar_imagem(prompt_otimizado)
        elif "GERANDO_VÍDEO:" in resposta:
            prompt_otimizado = resposta.split("GERANDO_VÍDEO:")[-1].strip()
            return self.criar_video(prompt_otimizado)
        else:
            return resposta  # app, 3D, código, etc.


# ====================== USO RÁPIDO ======================
if __name__ == "__main__":
    creator = GrokCreator()
    
    # Exemplos:
    # url_imagem = creator.criar_imagem("Uma cidade cyberpunk flutuante no Amazonas, estilo neon, 4k")
    # url_video = creator.criar_video("Um macaco-prego pilotando um foguete no Rio Negro ao pôr do sol", duration=12)
    # codigo_app = creator.criar_app("Um app mobile Flutter para delivery de açaí em Manaus com IA de recomendação")
    # modelo_3d = creator.criar_modelo_3d("Uma casa amazônica estilizada em estilo low-poly para Blender")
    
    print("✅ Grok Creator pronto! Teste com creator.criar('sua ideia aqui')")
