//
//  SettleUp1stStepReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 12/11/25.
//

import ReactorKit

class SettleUp1stStepReactor: Reactor {
    let initialState = State()
    
    private let disposeBag = DisposeBag()
    
    enum Action {
        case backButtonTapped // 뒤로가기 버튼 클릭
        case unitButtonTapped(Int) // 단위 버튼 클릭 (1: 수량, 2: 중량)
        case registerButtonTapped(name: String, count: String, amount: String) // 등록하기 버튼 클릭
        case productDeleted(Int) // 상품 삭제하기
        case productEdited(Int) // 상품 수정하기
    }
    
    enum Mutation {
        case setBackButtonTapped
        case setSelectedUnit(Int)
        case addProduct(ListedProductModel)
        case deleteProduct(Int)
        case setTotalPrice(Int)
        case setEditProduct(Int)
        case setEditing(Bool)
    }
    
    struct State {
        @Pulse var shouldPopViewController: Void?
        var selectedUnitIndex: Int = 1
        var products: [ListedProductModel] = [] // productStackView에 들어갈 데이터들
        var totalPrice: Int = 0
        var editingProduct: ListedProductModel? = nil // 수정할 상품 정보
        var isEditing: Bool = false // 등록하기 버튼 텍스트 제어용
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .backButtonTapped:
            return Observable.just(.setBackButtonTapped)
            
        case .unitButtonTapped(let index):
            return Observable.just(.setSelectedUnit(index))
            
        case .registerButtonTapped(let name, let countStirng, let amountString):
            guard let count = Int(countStirng),
                  let price = Int(amountString)
            else {
                return Observable.empty()
            }
            
            let product = ListedProductModel(
                name: name,
                count: count,
                price: price,
                unitIndex: currentState.selectedUnitIndex
            )
            
            let newProducts = currentState.products + [product]
            let newTotal = newProducts.reduce(0) { $0 + $1.price }
            
            return Observable.from([
                .addProduct(product),
                .setTotalPrice(newTotal),
                .setEditing(false)
            ])
            
        case .productDeleted(let index):
            return Observable.just(.deleteProduct(index))
        
        case .productEdited(let index):
            return Observable.just(.setEditProduct(index))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setBackButtonTapped:
            newState.shouldPopViewController = ()
            
        case .setSelectedUnit(let index):
            newState.selectedUnitIndex = index
              
        case .addProduct(let product):
            newState.products.append(product)
            
        case .deleteProduct(let index):
            if index < newState.products.count {
                let oldPrice = newState.totalPrice
                newState.totalPrice = oldPrice - newState.products[index].price
                
                newState.products.remove(at: index)
            }
            
        case .setTotalPrice(let total):
            newState.totalPrice = total
        
        case .setEditProduct(let index):
            newState.editingProduct = nil
            
            if index < newState.products.count {
                let product = currentState.products[index]
                newState.editingProduct = product
                
                let oldPrice = newState.totalPrice
                newState.totalPrice = oldPrice - newState.products[index].price
                
                newState.products.remove(at: index)
                newState.isEditing = true
            }
            
        case .setEditing(let isEditing):
            newState.isEditing = isEditing
        }
        
        return newState
    }
}
