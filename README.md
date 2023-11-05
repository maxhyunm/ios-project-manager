# Project Manager🗂️

## 소개<br>
> ToDo 리스트를 입력하고 Doing, Done으로 이동하며 스케줄을 관리하는 앱입니다.<br>
> 마감일이 지나면 날짜가 빨간색으로 표시되며, 내용 수정/삭제가 가능합니다.<br>
> 네트워크가 연결되어 있을 경우 모든 데이터는 원격 저장소에 동기화됩니다.<br>
> 
> **프로젝트 기간**<br>
> 1차: 2023.09.19 ~ 2023.10.06<br>
> 2차: 2023.10.24 ~

## 목차
1. [👩‍💻 팀원 소개](#1.)
2. [📅 타임 라인](#2.)
3. [🛠️ 활용 기술](#3.)
4. [📊 시각화 구조](#4.)
5. [📱 실행 화면](#5.)
6. [📌 핵심 경험](#6.)
7. [🧨 트러블 슈팅](#7.)
8. [📚 참고 자료](#8.)


<a id="1."></a>
## 👩‍💻 팀원 소개
|<Img src="https://hackmd.io/_uploads/rk62zRiun.png" width="200">|
|:-:|
|[**maxhyunm**](https://github.com/maxhyunm)<br>(minhmin219@gmail.com)|

<a id="2."></a>
## 📅 타임 라인
|날짜|내용|
|:--:|--|
|2023.09.19| Firebase 라이브러리 추가 |
|2023.09.24| CoreDataManager 타입 생성<br>Observable 타입 생성<br>ViewModel 타입 생성<br>TableView 포함 기본적인 ViewController 구현<br>TableView Header, Cell 타입 생성<br>AlertBuilder 타입 생성 |
|2023.09.25| Value 타입 생성<br>ViewModel에 handle error 메서드 생성 |
|2023.09.26| 의존성 주입 수정 |
|2023.10.03| ViewController 분할 및 child로 추가<br>TableView 배치 업데이트 추가|
|2023.10.06| ViewModel Input/Output으로 분할<br>UseCase 분리<br>PopOverView 생성 |
|2023.10.09| RxSwift 라이브러리 설치<br>Observable을 Rx로 리팩토링<br>Firebase Database 연결 |
|||
|2023.10.24| DetailViewController 생성 |
|2023.10.27| ViewModel 구조 변경 |
|2023.11.01| NetworkMonitor 타입 생성<br>Firebase CRUD 추가 |
|2023.11.02| DataSyncManager 타입 생성<br>ViewModel 리팩토링 |
|2023.11.03| History Entity 추가<br>History 목록 보기 구현<br>CoreData 복수 접근 오류 수정 |
|2023.11.04| CompletionHandler를 Single 리턴 형식으로 리팩토링 |
|2023.11.05| README 작성 |

<a id="3."></a>
## 🛠️ 활용 기술
|Framework|Architecture|Concurrency|DB|Dependency Manager|
|:-:|:-:|:-:|:-:|:-:|
|UIKit|MVVM|RxSwift|CoreData|SPM|

<a id="4."></a>
## 📊 시각화 구조
### File Tree
    .
    ├── ProjectManager
    │   ├── ProjectManager
    │   │   ├── App
    │   │   │   ├── AppDelegate.swift
    │   │   │   └── SceneDelegate.swift
    │   │   ├── Domain
    │   │   │   ├── Local
    │   │   │   │   ├── Entity
    │   │   │   │   │   ├── History+CoreDataClass.swift
    │   │   │   │   │   ├── History+CoreDataProperties.swift
    │   │   │   │   │   ├── ToDo+CoreDataClass.swift
    │   │   │   │   │   └── ToDo+CoreDataProperties.swift
    │   │   │   │   └── CoreDataManager.swift
    │   │   │   ├── Remote
    │   │   │   │   ├── Entity
    │   │   │   │   │   ├── HistoryDTO.swift
    │   │   │   │   │   └── ToDoDTO.swift
    │   │   │   │   └── FirebaseManager.swift
    │   │   │   ├── HistoryDataSyncManager.swift
    │   │   │   ├── ToDoDataSyncManager.swift
    │   │   │   ├── HistoryUseCase.swift
    │   │   │   └── ToDoUseCase.swift
    │   │   ├── Utility
    │   │   │   ├── AlertBuilder.swift
    │   │   │   ├── KeywordArgument.swift
    │   │   │   ├── NetworkMonitor.swift
    │   │   │   ├── Observable.swift
    │   │   │   ├── Output.swift
    │   │   │   ├── ProjectManagerError.swift
    │   │   │   └── ToDoStatus.swift
    │   │   ├── Presentation
    │   │   │   ├── ViewModelProtocol
    │   │   │   │   ├── ViewModelDelegate.swift
    │   │   │   │   └── ViewModelType.swift
    │   │   │   └── View
    │   │   │       ├── DetailView
    │   │   │       │   ├── DetailViewController.swift
    │   │   │       │   └── DetailViewModel.swift
    │   │   │       ├── ListView
    │   │   │       │   ├── Cell
    │   │   │       │   │   ├── ListHeaderView.swift
    │   │   │       │   │   └── ListTableViewCell.swift
    │   │   │       │   ├── BaseView
    │   │   │       │   │   ├── BaseListViewController.swift
    │   │   │       │   │   ├── BaseListViewModel.swift
    │   │   │       │   │   └── NavigationTitleView.swift
    │   │   │       │   └── ChildView
    │   │   │       │       ├── ChildListViewController.swift
    │   │   │       │       └── ChildListViewModel.swift
    │   │   │       └── PopOverView
    │   │   │           ├── ChangeStatusView
    │   │   │           │   ├── ChangeStatusButton.swift
    │   │   │           │   ├── ChangeStatusViewController.swift
    │   │   │           │   └── ChangeStatusViewModel.swift
    │   │   │           └── HistoryView
    │   │   │               ├── Cell
    │   │   │               │   └── HistoryTableViewCell.swift
    │   │   │               ├── HistoryViewController.swift
    │   │   │               └── HistoryViewModel.swift
    │   │   ├── Resource
    │   │   │   └── Assets.xcassets
    │   │   ├── Info.plist
    │   │   └── ProjectManager.xcdatamodeld
    │   │           └── contents
    │   └── ProjectManager.xcodeproj
    └── README.md


<a id="5."></a>
## 📱 실행 화면
| 일정 추가 |
|:-:|
|<img src="https://hackmd.io/_uploads/Hk0wCJE7T.gif" width="600">|

| 일정 이동 |
|:-:|
|<img src="https://hackmd.io/_uploads/H17O0yNXp.gif" width="600">|

| 일정 삭제 |
|:-:|
|<img src="https://hackmd.io/_uploads/B1eO0JEQT.gif" width="600">|

| 일정 수정 |
|:-:|
|<img src="https://hackmd.io/_uploads/r1Bd01EX6.gif" width="600">|

| 이력 확인 |
|:-:|
|<img src="https://hackmd.io/_uploads/Bku_AkEQa.gif" width="600">|

<a id="6."></a>
## 📌 핵심 경험
#### 🌟 MVVM 패턴 + UseCase 활용
`input` 타입과 `output` 타입을 분리한 `View Model`을 적용한 `MVVM` 패턴을 활용하였습니다. 상세 데이터 처리 로직과 관련된 부분은 `UseCase`로 분리하였습니다.
<details><summary>상세코드</summary><div markdown="1">

```swift
final class ChildListViewModel: ChildViewModelType, ChildViewModelOutputsType {
    var inputs: ChildViewModelInputsType { return self }
    var outputs: ChildViewModelOutputsType { return self }

    func viewWillAppear() {
        delegate?.readData(for: status)
    }

    func swipeToDelete(_ entity: ToDo) {
        guard let index = entityList.firstIndex(of: entity) else { return }
        delegate?.deleteData(entity, index: index)
    }
    ...
}
```

```swift
struct ToDoUseCase {
    let dataSyncManager: ToDoDataSyncManager

    func fetchDataByStatus(for status: ToDoStatus) throws -> [ToDo] {
        ...
    }

    func createData(values: [KeywordArgument]) throws {
        ...
    }
    
    @discardableResult
    func updateData(_ entity: ToDo, values: [KeywordArgument]) throws -> ToDo {
        ...
    }
    
    func deleteData(_ entity: ToDo) throws {
        ...
    }
    ...
}

```
    
</div></details>

#### 🌟 RxSwift를 활용한 데이터 바인딩 구현
`ViewModel`과 `View`를 바인딩하기 위하여 `RxSwift`를 활용하였습니다. 그 외에도 `Firebase`의 처리와 `ViewModel`을 잇는 부분에서도 `Single`을 활용하였습니다.
<details>
<summary>상세코드</summary>
<div markdown="1">
    
```swift
extension ChildListViewController {
    private func setupBinding() {
        viewModel.outputs.action.subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] action in
                ...
            }, onError: { [weak self] error in
                ...
            }).disposed(by: disposeBag)
    }
}
```
```swift
func syncLocalWithRemote() -> Single⟪Void⟫ {
    return mergeRemoteDataToLocal().map { _ in
        try self.mergeLocalDataToRemote(for: .create)
        try self.mergeLocalDataToRemote(for: .update)
        try self.deleteData()
    }
}
```

</div>
</details>
    
#### 🌟 Builder 패턴 활용
`Builder` 패턴을 활용해 `Alert` 처리를 조금 더 깔끔히 할 수 있도록 하였습니다.
<details>
<summary>상세코드</summary>
<div markdown="1">
    
```swift
struct AlertBuilder {
    let configuration: AlertConfiguration
    
    init(prefferedStyle: UIAlertController.Style) {
        ...
    }
    
    @discardableResult
    func setTitle(_ title: String) -> Self {
        ...
    }
    
    @discardableResult
    func setMessage(_ message: String) -> Self {
        ...
    }
    
    @discardableResult
    func addAction(_ actionType: AlertActionType, action: ((UIAlertAction) -> Void)? = nil) -> Self {
        ...
    }
    
    func build() -> UIAlertController {
        ...
    }
}
```
    
```swift
let alertBuilder = AlertBuilder(prefferedStyle: .alert)
    .setMessage(errorMessage)
    .addAction(.confirm) { action in
        self.dismiss(animated: true)
    }
    .build()
```
    
</div>
</details>

#### 🌟 NWPathMonitor를 활용한 네트워크 상태 확인
`NWPathMonitor`의 `status`를 통해 네트워크 연결 상태를 확인할 수 있도록 하였습니다.

<details><summary>상세코드</summary><div markdown="1">

```swift
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global()
    private(set) var isConnected = BehaviorRelay⟪Bool⟫(value: false)
    
    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected.accept(path.status == .satisfied)
        }
    }
    
    public func start() {
        monitor.start(queue: queue)
    }
    
    public func stop() {
        monitor.cancel()
    }
}
```
</div></details>

#### 🌟 Delegate 패턴을 활용한 ViewModel 연결
`ToDo`에서 `Doing`, `Done` 등으로 상태가 바뀔 때마다 `ChildViewModel`간의 연동이 일어나야 했으므로, 각 `ChildViewModel`을 `BaseViewModel`에 `Delegate` 패턴으로 연결하고 `BaseViewModel`에서는 `ChildViewModel`들을 `children`으로 갖고있도록 만들어 관련 처리가 이루어질 수 있도록 구현하였습니다.
    
<details><summary>상세코드</summary><div markdown="1">

```swift
extension ChildListViewModel: ChildViewModelDelegate {
    func changeStatus(_ entity: ToDo, to newStatus: ToDoStatus) {
        guard let index = entityList.firstIndex(of: entity) else { return }
        delegate?.changeStatus(entity, to: newStatus, index: index)
    }
}
```
</div></details>

<a id="7."></a>
## 🧨 트러블 슈팅
### 1️⃣ 여러 개의 CoreData Entity 활용 
**🚨 문제점**</br>
처음에는 `CoreDataManager` 타입 자체에 `Generic`으로 타입을 설정하여 각 Entity에 맞는 매니저를 활용할 수 있도록 구현하였습니다.
```swift
struct CoreDataManager⟪T: NSManagedObject⟫ {
    let persistentContainer: NSPersistentContainer
    ...
    func fetchData(entityName: String, predicate: NSPredicate? = nil, sort: String? = nil, ascending: Bool = true) throws -> [T] {
        ...
    }
    ...
}
```
하지만 이렇게 하니 아래와 같은 오류가 발생하는 것을 확인했습니다.
<img src="https://hackmd.io/_uploads/ry-jEpVXT.png" width="700"><br>
해당 오류 내용과 관련된 사례를 확인한 결과 위의 오류는 여러 개의 `NSPersistentContainer`를 활용하게 되면서 발생하는 오류라는 것을 알 수 있었습니다.

**💡 해결 방법**</br>
타입 자체가 아닌 메서드를 `Generic` 처리하여, 하나의 `CoreDataManager`와 하나의 `NSPersistentContainer`로 여러 가지 `Entity`에 함께 활용할 수 있도록 수정하였습니다.
```swift
struct CoreDataManager {
    let persistentContainer: NSPersistentContainer
    ...
    func fetchData⟪T: NSManagedObject⟫(entityName: String, predicate: NSPredicate? = nil, sort: String? = nil, ascending: Bool = true) throws -> [T] {
        ...
    }
    ...
}
```

### 2️⃣ GestureRecognizer 오류
**🚨 문제점**</br>
`TableView`에서 특정 `Cell`을 오래 누르면 `ToDo / Doing / Done`로 상태를 변경할 수 있도록 `LongPress` 관련 액션을 구현하였습니다. 하지만 실제 `LongPress` 이벤트가 발생할 때마다 아래와 같은 경고 메시지가 발생하였습니다.
<img src="https://hackmd.io/_uploads/SyZiN6EXT.png" width="700"><br>

**💡 해결 방법**</br>
`LongPress`이벤트가 진행중인 상태부터(아직 눌리고 있는 상태) 메서드 내용이 호출되는 것이 원인으로 보여, `GestureRecognizer`의 상태가 `.ended`일 때에만 해당 메서드를 실행할 수 있도록 아래와 같은 코드를 추가하였습니다.
```swift
guard sender.state == .ended else { return }
```

<a id="8."></a>
## 📚 참고 자료
> 🍎 : Apple Developer Documentations<br>
> ⚪️ : 기타 자료<br>

- [🍎 CoreData](https://developer.apple.com/documentation/coredata/)
- [🍎 NWPathMonitor](https://developer.apple.com/documentation/network/nwpathmonitor)
- [🍎 UIGestureRecognizer](https://developer.apple.com/documentation/uikit/uigesturerecognizer)
- [🍎 performBatchUpdates(_:completion:)](https://developer.apple.com/documentation/uikit/uitableview/2887515-performbatchupdates)
- [⚪️ RxSwift](https://github.com/ReactiveX/RxSwift)
- [⚪️ Apple 프로젝트에 Firebase 추가](https://firebase.google.com/docs/ios/setup?hl=ko)
- [⚪️ Kickstarter iOS MVVM](https://github.com/kickstarter/ios-oss)
