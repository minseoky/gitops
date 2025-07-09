#!/bin/bash

# 사용법: ./force-delete-namespace.sh <namespace>
NAMESPACE=$1

if [ -z "$NAMESPACE" ]; then
  echo "❌ 사용법: $0 <namespace>"
  exit 1
fi

echo "📦 $NAMESPACE 네임스페이스를 강제로 삭제합니다..."

# kubectl proxy 백그라운드 실행
kubectl proxy > /dev/null 2>&1 &
PROXY_PID=$!

# 잠시 대기
sleep 1

# finalizer 제거된 JSON 파일 생성
kubectl get namespace "$NAMESPACE" -o json | jq '.spec = {"finalizers":[]}' > temp.json

# curl로 finalize 엔드포인트 호출
curl -s -k -H "Content-Type: application/json" \
  -X PUT --data-binary @temp.json \
  "http://127.0.0.1:8001/api/v1/namespaces/${NAMESPACE}/finalize"

# proxy 종료
kill $PROXY_PID

# 파일 삭제
rm temp.json

echo "✅ 삭제 요청 완료: $NAMESPACE"
