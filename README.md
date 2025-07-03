# GitOps Kubernetes Configuration

이 프로젝트는 **Kubernetes 클러스터의 선언적 인프라 관리**를 위한 GitOps 구성 저장소입니다.  
ArgoCD를 통해 클러스터 상태를 지속적으로 동기화하며, Helm과 Kustomize를 조합해 다양한 컴포넌트를 배포 및 관리합니다.

## 📁 디렉토리 구조

.
├── argocd/                         # ArgoCD 자체를 GitOps로 관리
│   ├── argocd/                     # ArgoCD Application 리소스 정의
│   │   └── application.yaml
│   └── istio-system/              # Istio 리소스를 ArgoCD로 관리
│       └── application.yaml
├── argocd-custom-values.yaml       # Helm 배포 시 사용하는 사용자 정의 values.yaml
├── check/                          # 향후 클러스터 상태 점검 스크립트 저장용
├── istio-system/                   # Istio 컴포넌트 정의 (Kustomize 사용)
│   ├── kustomization.yaml
│   └── istio/
│       ├── kustomization.yaml
│       ├── namespace.yaml
│       └── values.yaml
└── kustomization.yaml              # 최상위 Kustomize 진입점

## 🚀 배포 방식

- **ArgoCD**는 Helm으로 배포되며, 클러스터 내에서 자기 자신을 관리하는 구조(self-managing)로 구성
- 각 네임스페이스별 애플리케이션은 `argocd/{namespace}/application.yaml`로 정의
- 컴포넌트 정의는 Kustomize 또는 Helm을 혼용하여 관리

## 🔧 사용 도구

- Kubernetes (v1.28+)
- ArgoCD (Helm chart 기반 배포)
- Helm 3.x
- Kustomize

## 💡 특징

- **GitOps 방식으로 클러스터 상태 관리**
- ArgoCD 자체도 Git으로 관리 → ArgoCD 업데이트 또한 GitOps로 제어
- Helm + Kustomize 혼합 관리
- 프로덕션, 스테이징 등 멀티 환경 구성을 고려한 구조 확장 가능

## 🐳 클러스터 적용 방법

```bash
kubectl apply -k gitops/
# or
kubectl apply -k .
```

## 🦎 배포 확인 방법

```bash
sh check
```

## ❗주의/참고사항

- `argocd-custom-values.yaml`의 변경 사항은 ArgoCD가 자동 반영하지 않으므로 `helm upgrade`를 별도로 수행하거나 HelmOperator 등을 사용하는 방법 고려 필요
- ArgoCD가 자기 자신을 관리하려면 최소 한 번은 수동으로 부트스트랩 해야 함
- istio 배포시 특정 필드가 git의 상태와 매번 달라져서 OutOfSync 사태가 발생합니다. 이를 해결하기 위해, istio의 application.yaml에 ignoreDifferences 설정을 추가하였습니다.
