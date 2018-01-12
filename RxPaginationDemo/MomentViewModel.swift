import Foundation
import RxSwift
import RxCocoa
import Result
import Argo
import RxSwiftExt

public final class MomentViewModel {
    // Property
    let refreshTrigger = PublishSubject<Void>()
    let loadNextPageTrigger = PublishSubject<Void>()
    let loading = Variable<Bool>(false)
    let posts = Variable<[Post]>([])
    var pageIndex: Int = 0
    let error = PublishSubject<Swift.Error>()
    private let disposeBag = DisposeBag()

    public init() {
        
        let refreshRequest = loading.asObservable()
            .sample(refreshTrigger)
            .flatMap { loading -> Observable<Int> in
                if loading {
                    return Observable.empty()
                } else {
                    return Observable<Int>.create { observer in
                        self.pageIndex = 0
                        print("reset page index to 0")
                        observer.onNext(0)
                        observer.onCompleted()
                        return Disposables.create()
                    }
                }
        }
        .debug("refreshRequest", trimOutput: true)
        
        let nextPageRequest = loading.asObservable()
            .sample(loadNextPageTrigger)
            .flatMap { loading -> Observable<Int> in
                if loading {
                    return Observable.empty()
                } else {
                    return Observable<Int>.create { [unowned self] observer in
                        self.pageIndex += 1
                        print(self.pageIndex)
                        observer.onNext(self.pageIndex)
                        observer.onCompleted()
                        return Disposables.create()
                    }
                }
        }
        .debug("nextPageRequest", trimOutput: true)
        
        let request = Observable.merge(refreshRequest, nextPageRequest)
            .share(replay: 1)
        	.debug("😀 Start request", trimOutput: true)
        
        let response = request.flatMapLatest { page in
            	RxAPIProvider.shared.getPostList(page: page).materialize()
            }
            .share(replay: 1)
            .elements()
        	.debug("😈 Start response", trimOutput: true)
        
        Observable
            .combineLatest(request, response, posts.asObservable()) { request, response, posts in
                return self.pageIndex == 0 ? response : posts + response
            }
            .sample(response)
			.bind(to: posts)
        	.disposed(by: disposeBag)
        
        Observable
            .merge(request.map{_ in true},
                response.map { _ in false },
                error.map { _ in false })
            .bind(to: loading)
        	.disposed(by: disposeBag)
    }
}
