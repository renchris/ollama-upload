# Qwen3-Coder 30B Comparison
## MacBook Pro 16" M1 Max (64GB RAM)

**Device**: M1 Max, 64GB RAM, 8TB SSD  
**Constraint**: Model size × 2 = RAM needed (~30GB model max)

---

## Rankings

### 🥇 `Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8` ⭐ RECOMMENDED
- **Official Qwen** | 30.5B MoE | 256K context | ~35GB | ~30-40GB RAM
- **Why**: Official support + memory efficient + optimal for M1 Max

### 🥈 `Qwen/Qwen3-Coder-30B-A3B-Instruct`
- **Official Qwen** | 30.5B MoE | 256K context | ~65GB | ~40-50GB RAM  
- **Why**: Standard precision, larger download

### 🥉 `unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF` ⭐ LOCAL DEPLOYMENT
- **Community** | 30.5B | 256K context | ~25GB | ~40-50GB RAM
- **Advantages**: Purpose-built for local deployment, no proprietary backend dependency, optimal Zed IDE integration

### 4️⃣ `unsloth/Qwen3-Coder-30B-A3B-Instruct-1M-GGUF`
- **Community** | 30.5B | 1M context | ~25GB | ~40-50GB RAM
- **Issue**: Quality degradation from context extension

### 5️⃣ `unsloth/Qwen3-Coder-30B-A3B-Instruct` ❌
- **Community** | Same as #2 but no official support

---

## Install

### Recommended (FP8 Official)
```bash
cd ~/models
git lfs clone https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8
cd Qwen3-Coder-30B-A3B-Instruct-FP8
~/Development/ollama-upload/monitor_download.sh
ollama create qwen3-coder:30b-fp8 -f Modelfile
```

### Alternative (Standard Official)
```bash
git lfs clone https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct
# ... same process, use: ollama create qwen3-coder:30b-standard -f Modelfile
```

### Alternative (GGUF Community - Optimal for Zed IDE)
```bash
# Direct Ollama download (recommended by Unsloth)
ollama run hf.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:UD-Q4_K_XL

# ✅ COMPLETED: Model downloaded and verified (17GB, 53.36 tokens/s)
```

---

## 🎯 Zed IDE Configuration

### Add Unsloth Model to Zed Settings

1. **Open Zed Settings** (`Cmd + ,`)
2. **Add the model configuration**:

```json
{
  "assistant": {
    "version": "2",
    "default_model": {
      "provider": "ollama",
      "model": "hf.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:UD-Q4_K_XL"
    },
    "provider": {
      "ollama": {
        "api_url": "http://localhost:11434"
      }
    }
  },
  "language_models": {
    "hf.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:UD-Q4_K_XL": {
      "provider": "ollama"
    },
    "qwen3-coder:30b-unsloth": {
      "provider": "ollama"
    }
  }
}
```

### Usage in Zed IDE

- **AI Assistant Panel**: `Cmd + ?` or click the assistant icon
- **Inline Completions**: Automatic as you type
- **Code Explanation**: Select code + `Cmd + ?`
- **Refactoring**: Select code + ask for improvements

### Performance Verified ✅

- **Model Size**: 17GB (4-bit quantized)
- **Load Time**: 15ms
- **Generation Speed**: 53.36 tokens/s
- **Memory Usage**: ~25-30GB RAM
- **Integration**: Native Ollama support

---

## Integration

**Storage**: 19GB current + 35GB new = 54GB total  
**Memory**: 30-40GB usage, may need to unload devstral:24b  
**Zed**: Add `"qwen3-coder:30b-fp8": {"provider": "ollama"}`

---

## Why FP8 Official?

✅ **Official support** - guaranteed updates/compatibility  
✅ **Memory efficient** - 30-40GB vs 40-50GB for others  
✅ **256K context** - handles entire large repositories  
✅ **Optimal size** - smaller than standard, official vs community

**256K tokens** = ~800 pages of code = entire large repos

---

## 🔬 Deep Research: GGUF vs FP8 for Local Deployment

### GGUF Advantages (Unsloth Community Model)

**✅ Purpose-Built for Local Deployment**
- No dependency on proprietary backend systems
- Compatible with multiple open-source inference engines:
  - `llama.cpp` - Lightweight C++ implementation
  - `Ollama` - Recommended by Zed IDE
  - `LM Studio` - GUI-based inference
  - `Kobold/Chat UI` - Web-based interfaces

**✅ Apple Silicon Optimization**
- Fully utilizes Apple GPU via Metal for matrix operations
- Native C++ application performance
- Optimized memory usage patterns for unified memory architecture

**✅ Zed IDE Integration**
- Zed officially encourages using Ollama for local models
- Plug-and-play setup: `ollama run hf.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:UD-Q4_K_XL`
- No custom Python environment required

**✅ Flexibility & Future-Proofing**
- Freedom to choose any GGUF-compatible runtime
- Not locked into PyTorch/Transformers ecosystem
- Satisfies "no specific inference backend" requirement

### FP8 Limitations for Local Use

**⚠️ Backend Dependencies**
- May require specific Python environment setup
- Potential dependency on PyTorch/Transformers infrastructure
- Less flexible for runtime switching

### Conclusion: GGUF for Zed IDE

For Zed IDE integration specifically, **GGUF offers superior local deployment** with:
- Native Ollama integration (Zed's preferred method)
- Lightweight C++ runtime
- Full Apple Silicon optimization
- Maximum flexibility across inference engines

---

*Sources*: [Official](https://huggingface.co/collections/Qwen/qwen3-coder-687fc861e53c939e52d52d10) | [Community](https://huggingface.co/collections/unsloth/qwen3-coder-687ff47700270447e02c987d) | [Unsloth Guide](https://docs.unsloth.ai/basics/qwen3-coder-how-to-run-locally) 