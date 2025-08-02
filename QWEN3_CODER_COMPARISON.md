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

### 🥉 `unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF`
- **Community** | 30.5B | 256K context | ~25GB | ~40-50GB RAM
- **Trade-off**: Smaller download, no official support

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

*Sources*: [Official](https://huggingface.co/collections/Qwen/qwen3-coder-687fc861e53c939e52d52d10) | [Community](https://huggingface.co/collections/unsloth/qwen3-coder-687ff47700270447e02c987d) 