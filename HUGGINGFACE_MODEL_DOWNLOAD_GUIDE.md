# HuggingFace Model Download Guide for AI Assistants

## Prerequisites & Hardware Check
```bash
df -h .                                                    # Disk space
system_profiler SPHardwareDataType | grep Memory          # RAM (macOS)
git lfs version                                            # Git LFS installed
```

**Memory Requirements:**
- 7B models: ~14-20GB RAM | 13B: ~26-40GB | 32B: ~64-120GB | 70B+: 140GB+ (datacenter only)
- **Rule**: Model size × 2 = minimum RAM needed

## Setup & Download Process

### 1. Clone Repository
```bash
mkdir -p ~/Development/ollama-upload/[MODEL_NAME]
cd ~/Development/ollama-upload/[MODEL_NAME]
git lfs clone https://huggingface.co/[OWNER]/[MODEL_NAME] .
```

### 2. Monitor Download (Enhanced Script)
```bash
# Copy or create monitor_download.sh
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

## Critical System Understanding

### Working Models vs Project Files
- **Working models**: `~/.ollama/models/` (separate, persistent)
- **Project files**: Local download directories (temporary)
- **Modelfiles**: Configuration only, reference working models
- **Safe to delete**: Project directories don't affect working Ollama models

### Systematic Cleanup (Prevents 1TB+ Waste)
```bash
# Find ALL model directories (not just target)
for dir in */; do
    if [[ -f "$dir/config.json" && -f "$dir"/model-*.safetensors ]]; then
        model_name=$(basename "$dir" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
        if ! ollama list | grep -q "$model_name"; then
            size=$(du -sh "$dir" | cut -f1)
            echo "UNUSED MODEL: $dir ($size) - not in ollama list"
        fi
    fi
done

# Remove unused models incompatible with hardware
# Check hardware compatibility BEFORE downloading
```

## Model Selection by Hardware

### 64GB M1 Max (Target System)
- **Recommended**: CodeLlama-13B, Qwen2.5-Coder-14B, DeepSeek-Coder-33B
- **Avoid**: >35B parameters, >50GB downloads
- **Working**: devstral:24b, deepseek-r1:1.5b, qwen3:8b

### Download Commands
```bash
git lfs status                                   # Check status
git lfs pull                                     # Resume download
find . -name "model-*.safetensors" | wc -l      # Count files
```

## AI Assistant Execution Notes

### Pre-execution
1. Verify hardware compatibility (memory × 2 rule)
2. Check disk space (model size × 1.5)
3. Validate model choice against constraints

### Post-execution
1. Verify complete download
2. **Audit ALL model directories** (not just target)
3. Remove unused models incompatible with hardware
4. Test integration

---

**Target**: Claude Sonnet 4.0 | **Updated**: August 2024 