# HuggingFace to Ollama Integration Guide

## Prerequisites & Hardware Check
```bash
df -h .                                                    # Check disk space
system_profiler SPHardwareDataType | grep Memory          # Check RAM (macOS)
git lfs version                                            # Verify Git LFS installed
```

**Memory Requirements:**
- 7B models: ~14-20GB RAM | 13B: ~26-40GB | 32B: ~64-120GB | 70B+: 140GB+
- **Rule**: Model size × 2 = minimum RAM needed

## Complete Workflow

### 1. Download from HuggingFace
```bash
mkdir -p ~/Development/ollama-upload/[MODEL_NAME]
cd ~/Development/ollama-upload/[MODEL_NAME]
git lfs clone https://huggingface.co/[OWNER]/[MODEL_NAME] .
```

### 2. Monitor Download Progress
```bash
# Copy monitoring script
cp ~/Development/ollama-upload/monitor_download.sh .

# Auto-detect everything
./monitor_download.sh

# Or specify: files, size_gb, display_name
./monitor_download.sh 17 32 "CodeLlama-13B"

# Start download with monitoring
git lfs pull &
./monitor_download.sh
```

### 3. Create Ollama Modelfile
```bash
cat > Modelfile << 'EOF'
FROM .
PARAMETER temperature 0.1
PARAMETER top_p 0.9
PARAMETER num_ctx 4096
SYSTEM "You are a helpful AI assistant specialized in coding tasks."
TEMPLATE """{{ if .System }}<|system|>{{ .System }}<|end|>{{ end }}{{ if .Prompt }}<|user|>{{ .Prompt }}<|end|>{{ end }}<|assistant|>{{ .Response }}<|end|>"""
EOF
```

### 4. Integrate with Ollama
```bash
# Only when download complete
ollama create [model-name] -f Modelfile
ollama run [model-name] "Test message"
```

## Model Storage Understanding

### File Locations
- **Working models**: `~/.ollama/models/` (persistent, used by Ollama)
- **Project files**: Local download directories (temporary, safe to delete after integration)
- **Modelfiles**: Configuration templates that reference working models

### Download Management
```bash
git lfs status                                   # Check download status
git lfs pull                                     # Resume interrupted download
find . -name "model-*.safetensors" | wc -l      # Count model files
```

## Hardware-Appropriate Model Selection

### 64GB M1 Max (Recommended)
- **Best choices**: CodeLlama-13B, Qwen2.5-Coder-14B, DeepSeek-Coder-33B
- **Currently working**: devstral:24b, deepseek-r1:1.5b, qwen3:8b
- **Avoid**: >35B parameters, >50GB downloads

### Storage Cleanup
```bash
# Find unused model directories
for dir in */; do
    if [[ -f "$dir/config.json" && -f "$dir"/model-*.safetensors ]]; then
        model_name=$(basename "$dir" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
        if ! ollama list | grep -q "$model_name"; then
            size=$(du -sh "$dir" | cut -f1)
            echo "UNUSED: $dir ($size) - not integrated with Ollama"
        fi
    fi
done
```

## Best Practices

### Before Download
1. Verify hardware compatibility (memory × 2 rule)
2. Check available disk space (model size × 1.5)
3. Confirm model choice meets your requirements

### After Integration
1. Test the model with Ollama
2. Clean up temporary download directories
3. Verify integration with your development tools

---

**Target**: Local AI Development | **Updated**: August 2024 