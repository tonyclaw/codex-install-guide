# OpenAI Codex CLI 설치 가이드

OpenAI의 자율 코딩 에이전트 **Codex CLI**를 설치하고 설정하는 방법을 안내합니다.

---

## 🚀 빠른 설치 (한 줄)

```bash
curl -fsSL https://raw.githubusercontent.com/tonyclaw/codex-install-guide/main/install.sh | bash
```

---

## 📋 요구사항

| 항목 | 버전 | 확인 방법 |
|------|------|-----------|
| **Node.js** | 18+ | `node --version` |
| **npm** | 9+ | `npm --version` |
| **Git** | 2.x+ | `git --version` |
| **OpenAI API 키** | - | [platform.openai.com](https://platform.openai.com/api-keys) |

> ⚠️ **Codex는 git 저장소 안에서만 실행됩니다.** 스크래치 작업용이라면 임시 저장소를 만들어야 합니다.

---

## 🔧 설치 방법

### 1. Node.js 설치 (없다면)

**macOS (Homebrew):**
```bash
brew install node
```

**Ubuntu/Debian:**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 2. Codex CLI 설치

```bash
npm install -g @openai/codex
```

### 3. 버전 확인

```bash
codex --version
```

### 4. OpenAI API 키 설정

```bash
# 방법 1: 환경변수 (추천)
export OPENAI_API_KEY="sk-proj-..."

# 방법 2: .env 파일
echo 'OPENAI_API_KEY=sk-proj-...' >> ~/.env
source ~/.env

# 방법 3: Codex 실행 시 직접 입력
# 첫 실행 시 프롬프트에서 입력 가능
```

---

## 🎯 기본 사용법

### One-shot 실행
```bash
cd my-project
codex exec "Add a dark mode toggle to settings"
```

### 자동 모드 (파일 변경 자동 승인)
```bash
codex exec --full-auto "Refactor the auth module to use JWT"
```

### YOLO 모드 (샌드박스 없이, 가장 빠름)
```bash
codex --yolo exec "Fix the login bug"
```

### 인터랙티브 모드
```bash
cd my-project
codex
# 프롬프트에서 대화식으로 작업 지시
```

### 스크래치 작업 (git 저장소가 필요하므로)
```bash
cd $(mktemp -d) && git init
codex exec "Build a snake game in Python"
```

---

## 🏗️ 고급 패턴

### 병렬 이슈 수정 (Worktree)
```bash
# 워크트리 생성
git worktree add -b fix/issue-1 /tmp/fix-1 main
git worktree add -b fix/issue-2 /tmp/fix-2 main

# 각 워크트리에서 Codex 병렬 실행
codex --yolo exec "Fix issue #1" &
codex --yolo exec "Fix issue #2" &
wait

# 푸시 및 PR 생성
cd /tmp/fix-1 && git push -u origin fix/issue-1
gh pr create --title "Fix issue #1" --body "Auto-fixed by Codex"
```

### PR 리뷰
```bash
# 임시 디렉토리에 클론
REVIEW=$(mktemp -d)
git clone https://github.com/user/repo.git $REVIEW
cd $REVIEW
gh pr checkout 42
codex exec "Review this PR and suggest improvements"
```

---

## ⚙️ 주요 플래그

| 플래그 | 설명 |
|--------|------|
| `exec "prompt"` | 프롬프트 실행 후 종료 |
| `--full-auto` | 워크스페이스 내 파일 변경 자동 승인 |
| `--yolo` | 샌드박스 없음, 모든 변경 자동 승인 (위험但빠름) |
| `--model` | 사용할 모델 지정 (예: `o3`, `o4-mini`) |

---

## ❌ 문제 해결

### `codex: command not found`
```bash
# npm 글로벌 경로 확인
npm config get prefix
# 경로가 PATH에 있는지 확인
echo $PATH
```

### `Error: Codex must be run inside a git repository`
```bash
git init  # 임시 저장소 생성
```

### API 키 오류
```bash
echo $OPENAI_API_KEY  # 키가 설정되었는지 확인
# 키가 유효한지 https://platform.openai.com/account/api-keys 에서 확인
```

### 권한 오류 (macOS)
```bash
# npm 글로벌 설치 권한 문제 시
sudo chown -R $(whoami) $(npm config get prefix)/{lib/node_modules,bin,share}
```

---

## 💰 비용 안내

Codex는 OpenAI API를 사용하므로 토큰 사용량에 따라 과금됩니다.
- 모델: `o3`, `o4-mini` 등 선택 가능
- 예상 비용: 작업 복잡도에 따라 $0.01~$0.50/작업
- 사용량 확인: [OpenAI Dashboard](https://platform.openai.com/usage)

---

## 📚 더 알아보기

- [공식 GitHub 저장소](https://github.com/openai/codex)
- [OpenAI API 문서](https://platform.openai.com/docs)
