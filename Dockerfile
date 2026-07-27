# Worker-comfyui CUSTOM — CRIACAO DE IMAGEM (Ideogram 4: turbo / normal / ultra).
# Modelos EMBUTIDOS na imagem (baixados no build do RunPod) -> SEM volume, cold-start rapido.
# Build: RunPod Console > Serverless > New Endpoint > GitHub Repo (branch: ideogram).
FROM runpod/worker-comfyui:5.8.6-base

# curl p/ os downloads (a base pode nao ter)
RUN command -v curl >/dev/null 2>&1 || (apt-get update -qq && apt-get install -y -qq curl && rm -rf /var/lib/apt/lists/*)

# 1) ComfyUI -> master. A base 5.8.x tem ComfyUI velho demais pros nos Ideogram4/Flux2
#    (Ideogram4Scheduler, DualModelGuider, CFGOverride, EmptyFlux2LatentImage). master ja tem.
RUN cd /comfyui && git fetch --depth 1 origin master && git reset --hard origin/master \
 && pip install --no-cache-dir -r requirements.txt

# 2) GGUF com suporte a Ideogram (fork molbal — o city96 nao reconhece o arch 'ideogram')
#    + inpaint LaMa (remove o sparkle do Ideogram no canto inf. dir.)
RUN rm -rf /comfyui/custom_nodes/ComfyUI-GGUF \
 && git clone --depth 1 https://github.com/molbal/ComfyUI-GGUF /comfyui/custom_nodes/ComfyUI-GGUF \
 && pip install --no-cache-dir --upgrade gguf \
 && comfy-node-install comfyui-inpaint-nodes

# 3) Modelos Ideogram embutidos (~23GB). Nos: UnetLoaderGGUF, CLIPLoader(type=ideogram4),
#    VAELoader, LoraLoaderModelOnly (turbo), INPAINT_LoadInpaintModel.
#    unconditional_transformer = usado no normal/ultra (dual-model).
RUN mkdir -p /comfyui/models/unet /comfyui/models/text_encoders /comfyui/models/vae /comfyui/models/loras /comfyui/models/inpaint \
 && curl -fL -o /comfyui/models/unet/ideogram4-transformer-q4_0.gguf               'https://huggingface.co/molbal/ideogram-4-gguf/resolve/main/ideogram4-transformer-q4_0.gguf' \
 && curl -fL -o /comfyui/models/unet/ideogram4-unconditional_transformer-q4_0.gguf 'https://huggingface.co/molbal/ideogram-4-gguf/resolve/main/ideogram4-unconditional_transformer-q4_0.gguf' \
 && curl -fL -o /comfyui/models/text_encoders/qwen3vl_8b_fp8_scaled.safetensors    'https://huggingface.co/Comfy-Org/Qwen3-VL/resolve/main/text_encoders/qwen3vl_8b_fp8_scaled.safetensors' \
 && curl -fL -o /comfyui/models/vae/flux2-vae.safetensors                          'https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors' \
 && curl -fL -o /comfyui/models/loras/ideogram_4_turbotime_v1.safetensors          'https://huggingface.co/ostris/ideogram_4_turbotime_lora/resolve/main/ideogram_4_turbotime_v1.safetensors' \
 && curl -fL -o /comfyui/models/inpaint/big-lama.pt                                 'https://github.com/Sanster/models/releases/download/add_big_lama/big-lama.pt'
