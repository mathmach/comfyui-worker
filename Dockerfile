# Worker-comfyui CUSTOM para o pipeline de vídeo viral.
# Adiciona custom nodes para áudio/texto. Os MODELOS ficam no Network Volume
# (/runpod-volume/models), NÃO na imagem — mantém a imagem leve e o build rápido.
#
# Build: feito pelo RunPod a partir deste repo (Serverless > New Endpoint > GitHub).
# Base "latest" = ComfyUI limpo, sem modelos (igual ao que já usamos hoje).
FROM runpod/worker-comfyui:latest

# Custom nodes (via helper do worker-comfyui, que usa o Comfy Registry):
#  - comfyui-videohelpersuite : combina frames + áudio em mp4 (VHS_VideoCombine) -> MUX
#  - comfyui_essentials       : desenhar texto sobre imagem (overlay "JUST DO IT")
#  - comfyui-kokoro           : TTS multilíngue (narração / voz)
RUN comfy-node-install \
      comfyui-videohelpersuite \
      comfyui_essentials \
      comfyui-kokoro

# MÚSICA: ACE-Step roda com nós NATIVOS do ComfyUI (sem custom node).
#   Modelo: ace_step_v1_3.5b.safetensors  ->  /runpod-volume/models/checkpoints/
# TTS Kokoro: modelo/vozes ficam no volume (ver README) p/ não baixar a cada cold start.
#
# Nada de COPY de modelos aqui de propósito — tudo vem do volume.
