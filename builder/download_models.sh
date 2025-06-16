#!/bin/bash

set -e

CACHE_DIR="/cache/models"
MODELS_DIR="/models"

mkdir -p /root/.cache/torch/hub/checkpoints

download() {
  local file_url="$1"
  local destination_path="$2"
  local cache_path="${CACHE_DIR}/${destination_path##*/}"

  mkdir -p "$(dirname "$cache_path")"
  mkdir -p "$(dirname "$destination_path")"
  
  if [ ! -e "$cache_path" ]; then
    echo "Downloading $file_url to cache..."
    wget -O "$cache_path" "$file_url"
  else
    echo "Using cached version of ${cache_path##*/}"
  fi

  cp "$cache_path" "$destination_path"
}

faster_whisper_model_dir="${MODELS_DIR}/faster-whisper-large-v3-turbo-ct2"
mkdir -p $faster_whisper_model_dir

download "https://huggingface.co/deepdml/faster-whisper-large-v3-turbo-ct2/resolve/main/config.json" "$faster_whisper_model_dir/config.json"
download "https://huggingface.co/deepdml/faster-whisper-large-v3-turbo-ct2/resolve/main/model.bin" "$faster_whisper_model_dir/model.bin"
download "https://huggingface.co/deepdml/faster-whisper-large-v3-turbo-ct2/resolve/main/preprocessor_config.json" "$faster_whisper_model_dir/preprocessor_config.json"
download "https://huggingface.co/deepdml/faster-whisper-large-v3-turbo-ct2/resolve/main/tokenizer.json" "$faster_whisper_model_dir/tokenizer.json"
download "https://huggingface.co/deepdml/faster-whisper-large-v3-turbo-ct2/resolve/main/vocabulary.json" "$faster_whisper_model_dir/vocabulary.json"

# VAD model is already copied to /root/.cache/torch/whisperx-vad-segmentation.bin in the Dockerfile
# No need to download it or use get_vad_model_url.py

# wav2vec2 model is already copied to /root/.cache/torch/hub/checkpoints/wav2vec2_fairseq_base_ls960_asr_ls960.pth in the Dockerfile
# No need to download it

python3 -c "
from huggingface_hub import snapshot_download
snapshot_download(repo_id='speechbrain/spkrec-ecapa-voxceleb')
"

echo "All models downloaded successfully."