#!/bin/bash

# Generic HuggingFace Model Download Monitor
# Usage: ./monitor_download.sh [expected_files] [target_size_gb] [model_name]

# Auto-detect model information
detect_model_info() {
    # Try to get model name from git remote
    if git remote -v 2>/dev/null | grep -q "huggingface.co"; then
        MODEL_NAME=$(git remote get-url origin 2>/dev/null | sed 's/.*huggingface.co\///' | sed 's/\.git$//' | sed 's/.*\///')
    fi
    
    # Fallback to directory name
    if [[ -z "$MODEL_NAME" ]]; then
        MODEL_NAME=$(basename "$(pwd)")
    fi
    
    # Try to detect expected files from existing model files or index
    if [[ -f "model.safetensors.index.json" ]]; then
        EXPECTED_FILES=$(grep -o '"model-[^"]*\.safetensors"' model.safetensors.index.json 2>/dev/null | wc -l | xargs)
    else
        # Count existing model files as a baseline
        EXISTING_FILES=$(find . -name "model-*.safetensors" 2>/dev/null | wc -l | xargs)
        EXPECTED_FILES=${EXISTING_FILES:-1}
    fi
    
    # Try to estimate target size from README or config
    if [[ -f "README.md" ]]; then
        TARGET_SIZE=$(grep -i "size\|gb\|mb" README.md | grep -o "[0-9.]*[GM]B" | head -1 | sed 's/[^0-9.]//g')
    fi
    
    # Set reasonable defaults
    MODEL_NAME=${MODEL_NAME:-"Unknown Model"}
    EXPECTED_FILES=${EXPECTED_FILES:-1}
    TARGET_SIZE=${TARGET_SIZE:-"Unknown"}
}

# Parse command line arguments
EXPECTED_FILES_ARG="$1"
TARGET_SIZE_ARG="$2"
MODEL_NAME_ARG="$3"

# Detect model information
detect_model_info

# Override with command line arguments if provided
[[ -n "$EXPECTED_FILES_ARG" ]] && EXPECTED_FILES="$EXPECTED_FILES_ARG"
[[ -n "$TARGET_SIZE_ARG" ]] && TARGET_SIZE="${TARGET_SIZE_ARG}GB"
[[ -n "$MODEL_NAME_ARG" ]] && MODEL_NAME="$MODEL_NAME_ARG"

# Ensure we have at least basic info
EXPECTED_FILES=${EXPECTED_FILES:-1}
TARGET_SIZE=${TARGET_SIZE:-"Unknown Size"}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Bold colors
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_PURPLE='\033[1;35m'
BOLD_CYAN='\033[1;36m'

# Animation frames
SPINNER=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
PULSE=("●" "●" "○" "○" "●" "●" "○" "○")
ARROWS=("→" "↗" "↑" "↖" "←" "↙" "↓" "↘")

# Animation counter
ANIM_COUNTER=0

# Cache for performance
CACHE_FILE="/tmp/model_download_cache_$(basename "$(pwd)").txt"
CACHE_TIMEOUT=3

# Get animation frame
get_spinner() {
    local index=$((ANIM_COUNTER % ${#SPINNER[@]}))
    echo -n "${SPINNER[$index]}"
}

get_pulse() {
    local index=$((ANIM_COUNTER % ${#PULSE[@]}))
    echo -n "${PULSE[$index]}"
}

get_arrows() {
    local index=$((ANIM_COUNTER % ${#ARROWS[@]}))
    echo -n "${ARROWS[$index]}"
}

# Cursor control
move_to_position() { echo -en "\033[${1};${2}H"; }
hide_cursor() { echo -en "\033[?25l"; }

# Get stats with proper error handling
get_stats() {
    local current_time=$(date +%s)
    local cache_age=999
    
    if [ -f "$CACHE_FILE" ]; then
        local cache_time=$(head -1 "$CACHE_FILE" 2>/dev/null)
        if [[ "$cache_time" =~ ^[0-9]+$ ]]; then
            cache_age=$((current_time - cache_time))
        fi
    fi
    
    if [ $cache_age -lt $CACHE_TIMEOUT ]; then
        tail -n +2 "$CACHE_FILE" 2>/dev/null
    else
        local current_size=$(du -sh . 2>/dev/null | cut -f1 || echo "0M")
        local model_files=$(find . -name "model-*.safetensors" 2>/dev/null | wc -l | xargs)
        local lfs_processes=$(ps aux 2>/dev/null | grep -c "git-lfs filter-process" | grep -v grep | xargs)
        local files_downloading=$(git lfs status 2>/dev/null | grep "File: deleted" | wc -l | xargs)
        local files_completed=$(git lfs status 2>/dev/null | grep "File: tracked" | wc -l | xargs)
        
        model_files=${model_files:-0}
        lfs_processes=${lfs_processes:-0}
        files_downloading=${files_downloading:-0}
        files_completed=${files_completed:-0}
        
        {
            echo "$current_time"
            echo "$current_size"
            echo "$model_files"
            echo "$lfs_processes"
            echo "$files_downloading"
            echo "$files_completed"
        } > "$CACHE_FILE"
        
        echo "$current_size"
        echo "$model_files"
        echo "$lfs_processes"
        echo "$files_downloading"
        echo "$files_completed"
    fi
}

# Progress bar function
draw_progress_bar() {
    local percent=$1
    local width=40
    local filled=$((width * percent / 100))
    local empty=$((width - filled))
    
    local bar=""
    local i
    
    # Add filled characters
    for ((i=0; i<filled; i++)); do
        bar+="█"
    done
    
    # Add empty characters
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done
    
    echo "[${bar}] ${percent}%"
}

# Calculate percentage from size (generic approach)
calculate_percentage() {
    local size="$1"
    local percentage=0
    
    # If we have a numeric target size, calculate percentage
    if [[ "$TARGET_SIZE" =~ ^[0-9]+GB$ ]]; then
        local target_gb=$(echo "$TARGET_SIZE" | sed 's/GB//')
        case $size in
            *G)
                local size_gb=$(echo $size | sed 's/G//' | sed 's/[^0-9.]//g')
                if [[ "$size_gb" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                    percentage=$(echo "scale=0; $size_gb * 100 / $target_gb" | bc -l 2>/dev/null || echo "0")
                fi
                ;;
            *M)
                local size_mb=$(echo $size | sed 's/M//' | sed 's/[^0-9.]//g')
                if [[ "$size_mb" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                    local size_gb=$(echo "scale=2; $size_mb / 1024" | bc -l 2>/dev/null || echo "0")
                    percentage=$(echo "scale=0; $size_gb * 100 / $target_gb" | bc -l 2>/dev/null || echo "0")
                fi
                ;;
        esac
    fi
    
    if [ "$percentage" -gt 100 ]; then percentage=100; fi
    echo $percentage
}

# Initial display (only once)
display_initial() {
    clear
    hide_cursor
    
    # Dynamic header with model name
    local header_text="🚀 $(echo "$MODEL_NAME" | tr '[:lower:]' '[:upper:]') DOWNLOAD MONITOR 🚀"
    local header_length=${#header_text}
    local padding=$(( (75 - header_length) / 2 ))
    local padded_header=$(printf "%*s%s%*s" $padding "" "$header_text" $padding "")
    
    # Header
    echo -e "${BOLD_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD_CYAN}║${padded_header}║${NC}"
    echo -e "${BOLD_CYAN}║                         HuggingFace Model Download                         ║${NC}"
    echo -e "${BOLD_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Time placeholder (line 6)
    echo -e "${BOLD_YELLOW}⏰ Time: ${WHITE}00:00:00${NC} ${BOLD_CYAN}⠋${NC}  📅 Date: ${WHITE}0000-00-00${NC}"
    echo ""
    
    # Download size placeholder (line 8-10)
    echo -e "${BOLD_BLUE}📦 DOWNLOAD SIZE ${NC}○"
    echo -e "   ${WHITE}Current: ${BOLD_GREEN}0G${NC}  ${WHITE}Target: ${BOLD_YELLOW}~${TARGET_SIZE}${NC}"
    echo -e "   ${BOLD_CYAN}Progress: ${NC}[░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░]   0%"
    echo ""
    
    # Model files placeholder (line 12-14)
    echo -e "${BOLD_PURPLE}📄 MODEL FILES ${NC}→"
    echo -e "   ${WHITE}Downloaded: ${BOLD_GREEN}0${NC}/${BOLD_YELLOW}${EXPECTED_FILES}${NC}"
    echo -e "   ${BOLD_CYAN}Files: ${NC}[░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░]   0%"
    echo ""
    
    # Processes placeholder (line 16-20)
    echo -e "${BOLD_GREEN}🔄 ACTIVE PROCESSES ${NC}"
    echo -e "   ${WHITE}Git LFS Downloads: ${BOLD_CYAN}0${NC}"
    echo -e "   ${WHITE}Still Downloading: ${BOLD_YELLOW}0${NC} ○"
    echo -e "   ${WHITE}Completed: ${BOLD_GREEN}0${NC}"
    echo ""
    
    # Status placeholder (line 22)
    echo -e "${BOLD_YELLOW}⚠️  STATUS: INITIALIZING ○${NC}"
    echo ""
    
    # Next steps (line 24-25)
    echo -e "${BOLD_PURPLE}💡 NEXT STEPS ${NC}→"
    local model_slug=$(echo "$MODEL_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
    echo -e "   ${WHITE}When complete: ${BOLD_GREEN}ollama create ${model_slug} -f Modelfile${NC}"
    echo ""
    
    # Footer
    echo -e "${BOLD_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD_CYAN}║ ${WHITE}Press ${BOLD_RED}Ctrl+C${WHITE} to stop monitoring                                           ${BOLD_CYAN}║${NC}"
    echo -e "${BOLD_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
}

# Global variables to track last values
LAST_SIZE=""
LAST_MODEL_FILES=""
LAST_LFS_PROCESSES=""
LAST_FILES_DOWNLOADING=""
LAST_FILES_COMPLETED=""

# Update display (data when changed, animations always)
update_display() {
    local stats=($(get_stats))
    local current_size="${stats[0]:-0M}"
    local model_files="${stats[1]:-0}"
    local lfs_processes="${stats[2]:-0}"
    local files_downloading="${stats[3]:-0}"
    local files_completed="${stats[4]:-0}"
    
    local percentage=$(calculate_percentage "$current_size")
    local file_percent=0
    if [ "$model_files" -gt 0 ] && [ "$EXPECTED_FILES" -gt 0 ]; then
        file_percent=$((model_files * 100 / EXPECTED_FILES))
    fi
    
    # Always update time and animation icons
    move_to_position 6 16
    printf "${WHITE}$(date '+%H:%M:%S')${NC} ${BOLD_CYAN}$(get_spinner)${NC}  📅 Date: ${WHITE}$(date '+%Y-%m-%d')${NC}"
    
    # Update size animation icon
    move_to_position 8 19
    printf "${BOLD_CYAN}$(get_pulse)${NC}"
    
    # Update files animation icon  
    move_to_position 12 16
    printf "${BOLD_PURPLE}$(get_arrows)${NC}"
    
    # Update processes animation icon
    move_to_position 16 28
    printf "${BOLD_GREEN}$(get_spinner)${NC}"
    
    # Update downloading animation icon
    move_to_position 18 43
    printf "${BOLD_YELLOW}$(get_pulse)${NC}"
    
    # Update footer animation icon
    move_to_position 28 50
    printf "${BOLD_CYAN}$(get_spinner)${NC}"
    
    # Only update data when it changes
    if [ "$current_size" != "$LAST_SIZE" ]; then
        LAST_SIZE="$current_size"
        move_to_position 9 13
        printf "${BOLD_GREEN}$current_size${NC}  ${WHITE}Target: ${BOLD_YELLOW}~${TARGET_SIZE}${NC}"
        move_to_position 10 13
        echo -n "${BOLD_CYAN}$(draw_progress_bar $percentage)${NC}"
    fi
    
    if [ "$model_files" != "$LAST_MODEL_FILES" ]; then
        LAST_MODEL_FILES="$model_files"
        move_to_position 13 17
        printf "${BOLD_GREEN}$model_files${NC}/${BOLD_YELLOW}${EXPECTED_FILES}${NC}"
        move_to_position 14 10
        echo -n "${BOLD_CYAN}$(draw_progress_bar $file_percent)${NC}"
    fi
    
    if [ "$lfs_processes" != "$LAST_LFS_PROCESSES" ]; then
        LAST_LFS_PROCESSES="$lfs_processes"
        move_to_position 17 23
        printf "${BOLD_CYAN}$lfs_processes${NC}"
    fi
    
    if [ "$files_downloading" != "$LAST_FILES_DOWNLOADING" ]; then
        LAST_FILES_DOWNLOADING="$files_downloading"
        move_to_position 18 24
        printf "${BOLD_YELLOW}$files_downloading${NC}"
    fi
    
    if [ "$files_completed" != "$LAST_FILES_COMPLETED" ]; then
        LAST_FILES_COMPLETED="$files_completed"
        move_to_position 19 15
        printf "${BOLD_GREEN}$files_completed${NC}"
    fi
    
    # Update status
    move_to_position 22 1
    if [ "$model_files" -eq "$EXPECTED_FILES" ] && [ "$EXPECTED_FILES" -gt 0 ]; then
        printf "${BOLD_GREEN}🎉 STATUS: DOWNLOAD COMPLETE! 🎉${NC}"
    elif [ "$lfs_processes" -gt 0 ]; then
        printf "${BOLD_CYAN}⏳ STATUS: DOWNLOADING...${NC}"
        move_to_position 22 28
        printf "${BOLD_CYAN}$(get_spinner)${NC}"
    else
        printf "${BOLD_YELLOW}⚠️  STATUS: NO ACTIVE DOWNLOADS${NC}"
        move_to_position 22 28
        printf "${BOLD_YELLOW}$(get_pulse)${NC}"
    fi
}

# Print usage information
show_usage() {
    echo "Generic HuggingFace Model Download Monitor"
    echo ""
    echo "Usage: $0 [expected_files] [target_size_gb] [model_name]"
    echo ""
    echo "Arguments:"
    echo "  expected_files   - Number of model files expected (auto-detected if not provided)"
    echo "  target_size_gb   - Target download size in GB (auto-detected if not provided)"
    echo "  model_name       - Model name for display (auto-detected if not provided)"
    echo ""
    echo "Examples:"
    echo "  $0                           # Auto-detect everything"
    echo "  $0 17 32                     # 17 files, 32GB target"
    echo "  $0 17 32 \"MyModel-7B\"       # Custom model name too"
    echo ""
    echo "Auto-detection sources:"
    echo "  - Model name: Git remote URL or directory name"
    echo "  - File count: model.safetensors.index.json or existing files"
    echo "  - Target size: README.md content"
    echo ""
}

# Handle help flags
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# Show detected information
echo "🔍 Detected Model Information:"
echo "   Model Name: $MODEL_NAME"
echo "   Expected Files: $EXPECTED_FILES"
echo "   Target Size: $TARGET_SIZE"
echo ""
echo "Press Enter to start monitoring, or Ctrl+C to cancel..."
read -r

# Main execution
display_initial

while true; do
    ANIM_COUNTER=$((ANIM_COUNTER + 1))
    update_display
    sleep 0.1
done 