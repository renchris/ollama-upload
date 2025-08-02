# Zed IDE + Qwen3-Coder-30B Setup Guide

## Optimized local coding assistant with 256K context window

## 🚀 Quick Start

This guide will set up Qwen3-Coder-30B-GGUF as your local AI coding assistant in Zed IDE with full 256K context support.

---

## 📋 Prerequisites

- **Ollama installed** ([Download here](https://ollama.com/download))
- **Zed IDE installed** ([Download here](https://zed.dev/download))
- **Hardware**: 32GB+ RAM recommended (64GB optimal)
- **Storage**: 20GB available space

---

## 📥 Step 1: Download the Model

### Download from Public Repository

```bash
# Download the optimized GGUF model (17GB)
ollama run renchris/qwen3-coder

# Verify download
ollama list
```

#### Expected output

```text
NAME                            SIZE      MODIFIED
renchris/qwen3-coder:latest     18 GB     X minutes ago
```

### Model Specifications

- **Size**: 18GB (4-bit quantized GGUF)
- **Parameters**: 30.5B total, 3.3B activated (MoE)
- **Context**: 256K tokens (262,144)
- **Performance**: 53+ tokens/s on Apple M1 Max
- **Features**: Tool calling, agentic coding, long context

---

## ⚙️ Step 2: Configure Zed IDE

### Option A: Via Zed Settings UI

1. Open Zed IDE
2. Press `Cmd + ,` (macOS) or `Ctrl + ,` (Linux/Windows)
3. Replace the entire contents with the configuration below

### Option B: Direct File Edit

Edit your Zed settings file directly:

#### File Location

- **macOS**: `~/.config/zed/settings.json`
- **Linux**: `~/.config/zed/settings.json`
- **Windows**: `%APPDATA%\Zed\settings.json`

### Complete Settings Configuration

```json
// Zed settings
//
// For information on how to configure Zed, see the Zed
// documentation: https://zed.dev/docs/configuring-zed
//
// To see all of Zed's default settings without changing your
// custom settings, run `zed: open default settings` from the
// command palette (cmd-shift-p / ctrl-shift-p)
{
  "agent": {
    "always_allow_tool_actions": true,
    "default_model": {
      "provider": "ollama",
      "model": "renchris/qwen3-coder:latest"
    }
  },
  "language_models": {
    "ollama": {
      "api_url": "http://localhost:11434",
      "available_models": [
        {
          "name": "renchris/qwen3-coder:latest",
          "display_name": "Qwen3-Coder 30B GGUF",
          "max_tokens": 262144,
          "supports_tools": true,
          "supports_thinking": false,
          "supports_images": false,
          "keep_alive": "10m"
        }
      ]
    }
  },
  "telemetry": {
    "diagnostics": false,
    "metrics": false
  },
  "ui_font_size": 16,
  "buffer_font_size": 16,
  "theme": {
    "mode": "system",
    "light": "One Light",
    "dark": "Ayu Mirage"
  }
}
```

---

## ✅ Verification

### 1. Test Basic Functionality

```text
Open Zed → Press Cmd+? → Type: "Write a hello world function in Python"
```

### 2. Test Long Context

```text
Open a large file → Select all → Cmd+? → Ask: "Explain this code structure"
```

### 3. Check Model Status

```bash
# Verify model is running
ollama ps

# Check model details
ollama show renchris/qwen3-coder
```

---

## 🔧 Configuration Details

### Key Settings Explained

| Setting | Value | Purpose |
|---------|-------|---------|
| `max_tokens` | 262144 | Full 256K context window |
| `supports_tools` | true | Enable function calling |
| `keep_alive` | "10m" | Keep model loaded for 10 minutes |
| `always_allow_tool_actions` | true | Auto-approve tool usage |

### Performance Optimization

- **Memory Usage**: ~25-35GB RAM for full context
- **Response Time**: 53+ tokens/s on Apple Silicon
- **Context Loading**: 15ms model load time
- **Recommended**: Close other heavy applications for best performance

---

## 🛠️ Troubleshooting

### Model Not Found

```bash
# Re-download if needed
ollama pull renchris/qwen3-coder
```

### Slow Performance

- Reduce `max_tokens` to 131072 (128K) for better speed
- Close other applications to free memory
- Ensure Ollama service is running: `ollama serve`

### Zed Not Recognizing Model

1. Restart Zed IDE
2. Check Ollama is running: `ollama ps`
3. Verify settings.json syntax is valid

---

## 🔗 Additional Resources

- **Model Page**: [ollama.com/renchris/qwen3-coder](https://ollama.com/renchris/qwen3-coder)
- **Zed Documentation**: [zed.dev/docs/ai](https://zed.dev/docs/ai)
- **Unsloth Guide**: [docs.unsloth.ai/basics/qwen3-coder-how-to-run-locally](https://docs.unsloth.ai/basics/qwen3-coder-how-to-run-locally)
- **GitHub Repository**: Contains comparison studies and performance analysis

---

## 📈 Performance Results

#### Verified on Apple M1 Max (64GB RAM)

- ✅ **Generation Speed**: 53.36 tokens/second
- ✅ **Load Time**: 15ms
- ✅ **Memory Usage**: ~25-30GB
- ✅ **Context Utilization**: Full 256K tokens
- ✅ **Coding Accuracy**: 99% vs full precision model

#### Perfect for

- Full-stack web development
- Large codebase analysis
- Multi-file refactoring
- Complex coding tasks
- Repository-scale understanding

---

Created by: renchris | Optimized for local development workflows
