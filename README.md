# Worker-comfyui custom (vídeo + áudio + texto)

Imagem custom do `runpod/worker-comfyui` com os custom nodes para **narração (TTS Kokoro)**,
**texto na tela (essentials)** e **mux de áudio (VideoHelperSuite)**. Música usa **ACE-Step nativo**.
Os **modelos ficam no Network Volume** (`/runpod-volume/models`), não na imagem.

## 1) Criar o repositório no GitHub
```bash
# nesta pasta (rancher/comfyui-worker):
git init && git add Dockerfile README.md && git commit -m "custom worker-comfyui"
git branch -M main
git remote add origin https://github.com/<voce>/comfyui-worker.git
git push -u origin main
```
> Só o `Dockerfile` precisa estar na raiz do repo.

## 2) Conectar no RunPod (ele builda a imagem)
1. RunPod Console → **Serverless** → **New Endpoint** → aba **GitHub Repo** (autorize o GitHub se pedir).
2. Selecione o repo `comfyui-worker`, branch `main`, **Dockerfile path** = `Dockerfile`.
3. **GPU**: as mesmas (RTX 4090 / A40 primeiro).
4. **Advanced → Network Volume**: anexe o **MESMO volume** (`comfyui` / `rgcnml7ds0`, EU-RO-1) — é onde estão os modelos.
5. **Container Start Command**: deixe o padrão (vazio). Idle timeout 120s, Execution timeout 1200s, Max workers 1.
6. Deploy. O RunPod vai **buildar a imagem** (alguns minutos) e subir o endpoint.

## 3) Pegar o novo Endpoint ID
Copie o ID do endpoint criado e me passe — eu atualizo `ENDPOINT_ID` no `n8n-secret`
(o workflow passa a usar este endpoint, que tem os nós de áudio/texto).

## 4) Modelos extras no volume (eu faço)
Depois do endpoint no ar, eu baixo no volume (via pod CPU barato):
- `ace_step_v1_3.5b.safetensors` → `models/checkpoints/` (música, ~3.5GB)
- modelo/vozes do Kokoro → caminho do node (narração)

## 5) Grafo condicional (eu faço)
Atualizo o nó **Build Graph** do n8n para, conforme os switches do Groq:
- `on_screen_text.enabled` → adiciona overlay de texto (essentials)
- `narration.enabled` → adiciona Kokoro TTS (voz)
- `music.enabled` → adiciona ACE-Step (música)
- junta tudo no **VHS_VideoCombine** (vídeo + voz + música) → mp4 final

> Atualize `FROM runpod/worker-comfyui:latest` para uma tag fixa (ex. `5.x.x-base`) quando quiser
> travar a versão. Se algum custom node mudar de nome no Registry, ajusta-se aqui e re-builda.
