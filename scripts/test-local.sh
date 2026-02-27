#!/usr/bin/env bash
# =============================================================================
# test-local.sh — GitHub Actions 빌드를 로컬에서 재현하는 스크립트
#
# 사용법:
#   ./scripts/test-local.sh            # 전체 책 렌더링 (느림, CI와 동일)
#   ./scripts/test-local.sh <장 번호>  # 특정 장만 빠르게 렌더링
#
# 예시:
#   ./scripts/test-local.sh 19-time-to-event
#   ./scripts/test-local.sh 24-evidence
#   ./scripts/test-local.sh 20-doubly-robust
#
# CI(GitHub Actions)와의 차이:
#   - 폰트 설치(sudo apt-get) 단계는 생략됨 (로컬에 이미 설치 가정)
#   - pixi 캐시/Actions 캐시 사용 없음 (pixi install이 로컬 캐시 사용)
#   - freeze 캐시(_freeze/)가 있으면 cached 결과로 빠르게 실행됨
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✔]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
die()  { echo -e "${RED}[✘]${NC} $*" >&2; exit 1; }

CHAPTER="${1:-}"

# ── 사전 조건 확인 ────────────────────────────────────────────────────────────
log "pixi 버전 확인..."
pixi --version || die "pixi가 설치되어 있지 않습니다. https://prefix.dev/docs/pixi/installation"

# ── Step 1: pixi 환경 설치 (CI의 'pixi install' 에 해당) ─────────────────────
log "Step 1: pixi 환경 설치 중..."
pixi install

# ── Step 2: 렌더링 ────────────────────────────────────────────────────────────
if [[ -z "$CHAPTER" ]]; then
  # ── 전체 책 렌더링 (R 패키지 설치 포함, CI와 동일한 render 태스크) ──────────
  log "Step 2: 전체 책 렌더링 중..."
  warn "  이 작업은 R 패키지 설치를 포함하므로 수 분이 걸릴 수 있습니다."
  pixi run render-only
  log "완료! 결과물: ./_book/index.html"
else
  # ── 특정 장만 빠르게 렌더링 ──────────────────────────────────────────────
  QMD_FILE="chapters/${CHAPTER}.qmd"
  [[ -f "$QMD_FILE" ]] || die "파일을 찾을 수 없습니다: $QMD_FILE\n  (예: ./scripts/test-local.sh 19-time-to-event)"

  log "Step 2: 단일 장 렌더링 중: $QMD_FILE"
  warn "  freeze 캐시(_freeze/)가 있으면 일부 청크는 캐시에서 실행됩니다."
  warn "  캐시 없이 강제 재실행: rm -rf _freeze/chapters/${CHAPTER} 후 다시 실행"

  pixi run -- quarto render "$QMD_FILE"

  OUT_HTML="_book/chapters/${CHAPTER}.html"
  if [[ -f "$OUT_HTML" ]]; then
    log "완료! 결과물: $OUT_HTML"
    # 브라우저로 열기 (선택적)
    if command -v xdg-open &>/dev/null; then
      xdg-open "$OUT_HTML" 2>/dev/null &
    fi
  else
    warn "HTML 출력 파일을 찾을 수 없습니다. 경로를 확인하세요: $OUT_HTML"
  fi
fi
