<p align="center">
  <img src="https://github.com/user-attachments/assets/46526513-86e0-4e46-9fcf-cc31735857e7" 
       alt="App Icon" width="100px" />
</p>

<h1 align="center">
  소분해요 (SoBunHaeYo)
  <p align="center">
  <img src="https://img.shields.io/badge/프로젝트 기간-2025.07.24 ~ -fab2ac?style=flat&logo=&logoColor=white" alt="프로젝트 기간" />
  <img src="https://img.shields.io/badge/release-v26.0.0-4fc08d?style=flat&logo=apple&logoColor=white" alt="릴리즈 버전" />
  </p>
  <p align="center">
    <a href="https://apps.apple.com/kr/app/%EC%86%8C%EB%B6%44%ED%95%B4%EC%9A%94/id6761189518">
      <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Download on the App Store" height="40">
    </a>
  </p>
</h1>


## 🛒 프로젝트 소개
<div align="left">
  <h3>함께 장보고, 정산까지 간편하게! &nbsp; 마트 대용량 상품 공동구매 플랫폼</h3>
  <p>
    마트의 대용량 상품이나 묶음 상품, 혼자 사기엔 너무 많아 망설여진 적 없으신가요?<br>
    <strong>소분해요</strong>는 코스트코·트레이더스의 대용량 식재료는 물론, 혼자서는 다 먹기 부담스러운 홀케이크, 유통기한이 짧은 묶음 상품까지!<br>
    내 주변에서 함께 나눌 이웃을 찾고, 채팅으로 조율하며, 복잡한 정산까지 한 번에 해결해주는 <strong>오프라인 소분 공동구매 앱</strong>입니다.
  </p>
</div>
<br>

## 📱 주요 기능

### 🔐 간편한 로그인
* **소셜 로그인 연동**: 카카오 및 애플 계정을 연동하여 복잡한 절차 없이 간편하게 시작할 수 있습니다.

### 📍 맞춤형 모임 탐색
* **카테고리 필터** : 식재료, 생필품 등 나에게 필요한 카테고리만 골라볼 수 있습니다.
* **스마트 정렬 시스템** : **최신순**으로 올라온 따끈따끈한 모임부터, 놓치면 아쉬운 **마감임박순**까지 원하는 조건으로 빠르게 탐색하세요.

### 💬 참여자들과 실시간 소통
* **모임 채팅방** : 무엇을 얼마나 살지 미리 조율하여 오프라인 만남을 준비하세요.
* **준비 완료** : 만나기 전 상세한 협의로 불필요한 동선을 줄여줍니다.

### 💰 스마트한 소분과 정산
* **자동 정산 시스템** : 함께 구매한 물품을 나눈 만큼 금액을 자동으로 계산해 드립니다.
* **정산 카드 전송** : 채팅방 내에서 정산 내역을 투명하게 공유하고 관리하세요.

### 🔔 실시간 알림 서비스
* **즉각적인 소통** : 새로운 **댓글**이나 **채팅 메시지**가 도착하면 놓치지 않도록 실시간 푸시 알림을 보내드립니다.
* **정산 현황 확인** : 잊기 쉬운 **정산서 전송** 알림을 통해 빠르고 정확한 비용 정산을 도와줍니다.

### 🤝 믿을 수 있는 참여자 확인
* **활동 점수 및 매너 평가** : 함께 활동한 이웃의 신뢰도를 미리 확인하여 안심하고 참여할 수 있습니다.

<br>

## 👥 팀 소개 (Team 일팔삼)

우리는 1인 가구의 더 나은 장보기 경험을 위해 고민하는 **일팔삼** 팀입니다.

| 프로필 | 이름 | 역할 | 담당 업무 | GitHub |
| :---: | :---: | :---: | :---: | :---: |
| <img src="https://github.com/heopill.png" width="80px"> | **허성필** | **PM, iOS** | 프로젝트 매니징, 로그인/회원가입, 정산 시스템 로직, <br> 마이페이지 구현, UI 컴포넌트 개발 | [🔗](https://github.com/heopill) |
| <img src="https://github.com/hugesilver.png" width="80px"> | **김태은** | **iOS** | 실시간 채팅 기능 및 WebSocket/Stomp 통신 처리, <br> 홈 화면, 글 작성, UI 컴포넌트 개발, <br> 알림, 프로젝트 시스템 구축| [🔗](https://github.com/hugesilver) |
| <img src="https://github.com/yechan9981.png" width="80px"> | **천예찬** | **Backend** | 서버 인프라 구축, DB 설계 및 전체 API 설계/운영 | [🔗](https://github.com/yechan9981) |
| <img src="https://github.com/user-attachments/assets/46526513-86e0-4e46-9fcf-cc31735857e7" width="80px"> | **염지윤** | **Designer** | 전체 UI/UX 컨셉 설계, 디자인 시스템 구축, 스토어 에셋 제작 | - |

<br>

## 🛠 기술 스택 (Tech Stack)

### 📱 iOS
| 분류 | 기술 명세 |
| :--- | :--- |
| **Architecture** | `ReactorKit(MVI-based)` |
| **UI Framework** | `UIKit`, `SnapKit`, `Gifu(GIF)`, `Kingfisher(Image Caching)` |
| **Reactive** | `RxSwift`, `RxCocoa`, `RxGesture` |
| **Networking** | `RxMoya`, `WebSocket`, `SwiftStomp` |
| **Social Login** | `KakaoOpenSDK`, `AuthenticationServices(Apple Login)` |
| **Push Notification** | `Firebase Cloud Messaging (FCM)` |
| **Storage** | `Keychain`, `GRDB(SQLite)` |

<br>

### ⚙️ Backend
| 분류 | 기술 명세 |
| :--- | :--- |
| **Core** | `Java 17`, `Spring Boot 3.5.4` |
| **Database** | `MySQL(운영)`, `H2(테스트용)`, `Redis(Cache & Pub/Sub)` |
| **ORM / Data** | `Spring Data JPA(Hibernate)` |
| **Auth / Security** | `JWT(Access 30m / Refresh 60d)`, `Spring Security`, `OAuth 2.0` |
| **Real-time** | `WebSocket + STOMP`, `Redis Pub/Sub(메시지 브로커)` |
| **Notification** | `Firebase Admin SDK(FCM)` |
| **HTTP Client** | `Spring WebFlux(WebClient)` |
| **Build / DevOps** | `Gradle`, `Docker(Local DB)`, `Log4j2`, `Swagger(OpenAPI)` |

<br>

## 💡 기술적 의사결정 (iOS)

### 아키텍처 : ReactorKit
* **상태 일관성** : View와 Reactor 간의 단방향 데이터 흐름(Unidirectional Data Flow)을 강제하여, <br> 복잡한 상태 변화에서도 UI 업데이트의 일관성을 유지하고 디버깅 효율을 높였습니다.
* **관심사 분리** : 비즈니스 로직과 UI 로직을 엄격히 분리하여, 코드의 재사용성을 높이고 팀 협업 시 코드 충돌을 최소화했습니다.

### 반응형 프로그래밍 : RxSwift & RxCocoa
* **비동기 처리 관리** : 네트워크 요청, 사용자 입력, 실시간 이벤트 등 다양한 비즈니스 로직을 **스트림(Stream)** 형태로 통합 관리하여 <br> 코드의 가독성을 확보했습니다.
* **선언적 코드** : 명령형 프로그래밍보다 간결한 선언적 문법을 통해 데이터의 흐름을 한눈에 파악할 수 있도록 설계했습니다.

### 네트워크 : RxMoya
* **타입 안전 추상화** : API 요청을 열거형(Enum)으로 정의하여 엔드포인트를 중앙 집중식으로 관리함으로써, <br> 오타로 인한 런타임 에러를 방지하고 모듈화 가능성을 극대화했습니다.
* **스트림 통합** : 네트워크 레이어를 RxSwift와 결합하여 응답 데이터 처리부터 에러 핸들링까지 하나의 체인으로 매끄럽게 연결했습니다.

### 실시간 통신 : WebSocket & STOMP
* **발행/구독 프로토콜** : 단순 웹소켓보다 상위 프로토콜인 STOMP를 도입하여 메시지 브로커(Redis)와의 연동을 최적화했습니다. <br> 이를 통해 채팅방별 구독(Subscribe)과 발행(Publish) 구조를 명확히 하여 실시간 메시징의 안정성을 확보했습니다.

### 미디어 및 메모리 최적화 : Gifu & Kingfisher
* **GIF 리소스 최적화 (Gifu)** : 다수의 GIF 이미지를 로드할 때 발생하는 **메모리 스파이크(Memory Spike)** 현상을 방지하고, <br> CPU 사용량을 최적화하여 저사양 기기에서도 부드러운 스크롤 경험을 제공하기 위해 채택했습니다.
* **이미지 캐싱 및 로딩 (Kingfisher)** : 네트워크 이미지를 메모리 및 디스크에 **캐싱(Caching)** 하여 불필요한 네트워크 요청을 줄이고, <br> 로딩 속도를 향상시켜 쾌적한 사용자 경험을 제공합니다.

### 보안 : Keychain
* **보안 강화** : UserDefaults와 달리 데이터가 암호화되어 저장되는 **Keychain**을 활용했습니다. <br> 특히 유출 시 치명적인 **Access/Refresh Token**을 안전하게 보호하여 앱의 보안 수준을 높였습니다.

<br>

## 📸 App Previews

<p align="center">
  <img src="https://github.com/user-attachments/assets/f6b78c76-08b7-4509-97ca-c92b82ac27bd" width="19%" alt="최종앱스토어이미지1" />
  <img src="https://github.com/user-attachments/assets/6569190e-4cc8-4d1b-905d-67aec21c3be5" width="19%" alt="최종앱스토어이미지2" />
  <img src="https://github.com/user-attachments/assets/8df4d912-8550-401c-8c66-bca48dc27e98" width="19%" alt="최종앱스토어이미지3" />
  <img src="https://github.com/user-attachments/assets/6a2a7127-4a50-469f-9531-2494c81d593a" width="19%" alt="최종앱스토어이미지4" />
  <img src="https://github.com/user-attachments/assets/ca205c38-9236-4453-99f7-d7a36e0c9208" width="19%" alt="최종앱스토어이미지5" />
</p>

<br>

## 🚀 Release History

| Version | Date | Description |
|:---|:---|:---|
| **v26.0.0** | 2026.04.03 | 첫 공식 배포 (Initial Release) |

<br>

## License
Copyright © 2026 Seongpil Heo. All rights reserved.
