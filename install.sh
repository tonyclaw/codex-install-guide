#!/bin/bash
#
# OpenAI Codex CLI 자동 설치 스크립트
# 사용: curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/codex-install-guide/main/install.sh | bash
# 또는: chmod +x install.sh && ./install.sh
#

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   OpenAI Codex CLI — 자동 설치 스크립트     ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ──────────────────────────────────────────────
# 1. OS 감지
# ──────────────────────────────────────────────
OS="$(uname -s)"
log_info "운영체제: $OS"

# ──────────────────────────────────────────────
# 2. Node.js 확인 및 설치
# ──────────────────────────────────────────────
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        log_success "Node.js $(node --version) 설치됨"
    else
        log_error "Node.js 18 이상이 필요합니다. 현재: $(node --version)"
        log_info "Node.js를 먼저 업그레이드하세요."
        exit 1
    fi
else
    log_warn "Node.js가 설치되지 않았습니다."

    case "$OS" in
        Darwin)
            if command -v brew &> /dev/null; then
                log_info "Homebrew로 Node.js 설치 중..."
                brew install node
            else
                log_error "Homebrew가 없습니다. 먼저 설치하세요:"
                log_error '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
                exit 1
            fi
            ;;
        Linux)
            if command -v apt-get &> /dev/null; then
                log_info "NodeSource 레포지토리로 Node.js 20 설치 중..."
                curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
                sudo apt-get install -y nodejs
            elif command -v yum &> /dev/null; then
                log_info "NodeSource로 Node.js 20 설치 중..."
                curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
                sudo yum install -y nodejs
            else
                log_error "지원하지 않는 패키지 관리자입니다. Node.js를 수동으로 설치하세요."
                exit 1
            fi
            ;;
        *)
            log_error "지원하지 않는 OS입니다. Node.js를 수동으로 설치하세요."
            exit 1
            ;;
    esac
    log_success "Node.js $(node --version) 설치 완료"
fi

# ──────────────────────────────────────────────
# 3. Git 확인
# ──────────────────────────────────────────────
if command -v git &> /dev/null; then
    log_success "Git $(git --version | cut -d' ' -f3) 설치됨"
else
    log_warn "Git이 설치되지 않았습니다."

    case "$OS" in
        Darwin)
            brew install git
            ;;
        Linux)
            if command -v apt-get &> /dev/null; then
                sudo apt-get install -y git
            elif command -v yum &> /dev/null; then
                sudo yum install -y git
            fi
            ;;
    esac
    log_success "Git 설치 완료"
fi

# ──────────────────────────────────────────────
# 4. Codex CLI 설치
# ──────────────────────────────────────────────
log_info "Codex CLI 설치 중..."

if command -v codex &> /dev/null; then
    log_warn "Codex가 이미 설치되어 있습니다. 최신 버전으로 업데이트합니다."
    npm update -g @openai/codex
else
    npm install -g @openai/codex
fi

log_success "Codex CLI 설치 완료: $(codex --version)"

# ──────────────────────────────────────────────
# 5. API 키 설정
# ──────────────────────────────────────────────
echo ""
echo "──────────────────────────────────────────────"
echo "  OpenAI API 키 설정"
echo "──────────────────────────────────────────────"
echo ""

if [ -n "$OPENAI_API_KEY" ]; then
    log_success "OPENAI_API_KEY 환경변수가 이미 설정되어 있습니다."
else
    log_warn "OPENAI_API_KEY가 설정되지 않았습니다."
    echo ""
    echo "API 키를 입력하세요 (https://platform.openai.com/api-keys 에서 발급):"
    read -s -p "API Key: " API_KEY_INPUT
    echo ""

    if [ -n "$API_KEY_INPUT" ]; then
        # shell 선택
        SHELL_RC=""
        case "$SHELL" in
            */zsh)  SHELL_RC="$HOME/.zshrc" ;;
            */bash) SHELL_RC="$HOME/.bashrc" ;;
            *)      SHELL_RC="$HOME/.profile" ;;
        esac

        echo ""
        echo "어디에 저장할까요?"
        echo "  1) $SHELL_RC (추천)"
        echo "  2) ~/.env 파일"
        echo "  3) 건너뛰기 (나중에 수동 설정)"
        read -p "선택 [1-3]: " SAVE_CHOICE

        case "$SAVE_CHOICE" in
            1)
                echo 'export OPENAI_API_KEY="'"$API_KEY_INPUT"'"' >> "$SHELL_RC"
                export OPENAI_API_KEY="$API_KEY_INPUT"
                log_success "$SHELL_RC에 저장되었습니다. 새로운 터미널에서 자동 로드됩니다."
                ;;
            2)
                echo "OPENAI_API_KEY=$API_KEY_INPUT" >> "$HOME/.env"
                export OPENAI_API_KEY="$API_KEY_INPUT"
                log_success "~/.env에 저장되었습니다."
                ;;
            3)
                log_warn "API 키 설정을 건너뛰었습니다."
                ;;
            *)
                log_warn "잘못된 선택입니다. API 키를 수동으로 설정하세요."
                ;;
        esac
    else
        log_warn "API 키 입력이 취소되었습니다."
    fi
fi

# ──────────────────────────────────────────────
# 6. 설치 검증
# ──────────────────────────────────────────────
echo ""
echo "──────────────────────────────────────────────"
echo "  설치 검증"
echo "──────────────────────────────────────────────"
echo ""

PASS=true

# Codex 버전 확인
if command -v codex &> /dev/null; then
    log_success "Codex CLI: $(codex --version)"
else
    log_error "Codex CLI 설치 실패"
    PASS=false
fi

# API 키 확인
if [ -n "$OPENAI_API_KEY" ]; then
    MASKED_KEY="${OPENAI_API_KEY:0:12}..."
    log_success "API 키: $MASKED_KEY"
else
    log_warn "API 키가 설정되지 않았습니다. 아래 명령어로 설정하세요:"
    echo "  export OPENAI_API_KEY='sk-proj-...'"
fi

# Git 저장소 확인 (현재 디렉토리)
if git rev-parse --git-dir &> /dev/null; then
    log_success "현재 디렉토리는 git 저장소입니다."
else
    log_info "현재 디렉토리는 git 저장소가 아닙니다. (Codex는 git 저장소에서 실행해야 합니다)"
fi

echo ""
if [ "$PASS" = true ]; then
    echo "╔══════════════════════════════════════════════╗"
    echo "║         🎉 설치 완료!                        ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    echo "사용법:"
    echo "  cd my-project"
    echo "  codex exec \"Add a new feature\""
    echo ""
    echo "더 많은 옵션은 README.md를 참고하세요."
else
    echo "╔══════════════════════════════════════════════╗"
    echo "║         ❌ 설치 중 오류가 발생했습니다       ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    echo "README.md의 문제 해결 섹션을 참고하세요."
    exit 1
fi
