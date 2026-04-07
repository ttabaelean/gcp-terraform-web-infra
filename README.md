# 🌐 GCP Multi-Region Infrastructure with Terraform

이 프로젝트는 **Terraform(IaC)**을 사용하여 Google Cloud Platform(GCP) 위에 고가용성 멀티 리전 네트워크와 서버 인프라를 자동으로 구축하는 프로젝트입니다. 서울 리전의 Public Web 서버와 오레곤 리전의 Private WAS 서버를 통해 보안적인 계층 구조를 실습합니다.

## 🏗️ Architecture Overview

본 인프라는 보안과 확장성을 고려하여 다음과 같이 설계되었습니다.

![GCP Architecture Diagram](./gcp_architecture.png)

## 📂 Project Structure

모듈 없이 효율적인 관리를 위해 다음과 같이 코드를 분리하여 구성했습니다.

* **`provider.tf`**: GCP 접속을 위한 공급자(Provider) 설정 및 인증 정보 관리.
* **`variables.tf`**: 리전, 존, 프로젝트 ID 등 공통적으로 사용되는 변수 정의.
* **`vpc.tf`**: VPC, 서브넷(서울, 오레곤), 방화벽 규칙, Cloud Router/NAT 등 네트워크 관련 리소스 정의.
* **`main.tf`**: 실제 Compute Engine(VM) 인스턴스(Web, WAS) 생성 및 Startup Script 정의.

## 🚀 Quick Start

### 1. 환경 변수 설정
`variables.tf` 파일에서 `project_id`를 본인의 GCP 프로젝트 ID로 수정합니다.

### 2. 인프라 배포 (WSL 2 터미널)
```bash
# 초기화 (Provider 다운로드)
terraform init

# 실행 계획 확인 (10 to add 확인)
terraform plan

# 인프라 실제 생성
terraform apply -auto-approve
