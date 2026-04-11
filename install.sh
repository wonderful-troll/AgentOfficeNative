#!/bin/bash
# AgentOffice 자동 빌드 & 설치 스크립트
# 사용법: bash install.sh

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="AgentOffice"
SCHEME="AgentOfficeApp"
BUILD_DIR="$PROJECT_DIR/build/release"
INSTALL_PATH="/Applications/$APP_NAME.app"

echo "🔨 빌드 시작..."
cd "$PROJECT_DIR"

xcodebuild \
  -project "$APP_NAME.xcodeproj" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR" \
  -destination "platform=macOS" \
  CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION=YES \
  clean build 2>&1 | grep -E "error:|warning:|Build succeeded|BUILD"

APP_PATH="$BUILD_DIR/Build/Products/Release/$APP_NAME.app"

if [ ! -d "$APP_PATH" ]; then
  echo "❌ 빌드 실패 — 앱을 찾을 수 없습니다"
  exit 1
fi

echo "📦 /Applications 에 설치 중..."
pkill -f "$APP_NAME" 2>/dev/null || true
sleep 1
rm -rf "$INSTALL_PATH"
cp -R "$APP_PATH" "$INSTALL_PATH"

echo "🚀 앱 실행..."
open "$INSTALL_PATH"

echo "✅ 완료! AgentOffice가 설치되었습니다."
echo "   다음 로그인부터는 자동으로 실행됩니다."
