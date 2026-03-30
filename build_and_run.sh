#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "🔧 xcode-select 설정 확인..."
if [ "$(xcode-select -p)" != "/Applications/Xcode.app/Contents/Developer" ]; then
    echo "⚠️  xcode-select가 Xcode를 가리키지 않습니다. 변경합니다..."
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
fi

echo "📐 project.pbxproj 생성..."
python3 generate_project.py

echo ""
echo "🔨 빌드 시작..."
echo "   (서명을 위해 Xcode에 Apple ID가 등록되어 있어야 합니다)"
echo ""

xcodebuild \
    -project AgentOffice.xcodeproj \
    -scheme AgentOfficeApp \
    -configuration Debug \
    -derivedDataPath build \
    CODE_SIGN_STYLE=Automatic \
    2>&1 | grep -E "(error:|warning:|Build succeeded|BUILD FAILED|Compiling|Linking)" | head -80

echo ""
if [ -d "build/Build/Products/Debug/AgentOffice.app" ]; then
    echo "✅ 빌드 성공!"
    echo "🚀 앱 실행 중..."
    open build/Build/Products/Debug/AgentOffice.app
    echo ""
    echo "📌 위젯 추가 방법:"
    echo "   1. 데스크탑 빈 공간 우클릭"
    echo "   2. '위젯 편집...' 선택"
    echo "   3. 왼쪽 목록에서 'Agent Office' 찾기"
    echo "   4. Small / Medium / Large 중 선택하여 추가"
else
    echo "❌ 빌드 실패. Xcode에서 직접 열어서 서명을 설정하세요:"
    echo "   open AgentOffice.xcodeproj"
fi
