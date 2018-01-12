import Alamofire
import RxSwift
import Result
import Argo
import Moya

public enum RxKoreaAPI {
    case getPostList(page: Int, limit: Int)
}

extension RxKoreaAPI: TargetType {
    
    /// The target's base `URL`.
    public var baseURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .getPostList:
            return "/posts"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Moya.Method {
        return .get
    }
    
    /// Provides stub data for use in testing.
    public var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    /// The type of HTTP task to be performed.
    public var task: Moya.Task {
        switch self {
        case let .getPostList(page, limit):
            return .requestParameters(parameters: ["_start": page * limit, "_limit": limit], encoding: URLEncoding.default)
        }
       
    }
    
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    public var validate: Bool { return false }
    
    /// The headers to be used in the request.
    public var headers: [String : String]? {
        return nil
    }
}

public protocol APIProviderType {

    func  getPostList(page: Int, limit: Int) -> Observable<[Post]>
}

public struct RxAPIProvider: APIProviderType {
    
    public static var shared = RxAPIProvider()
    
    public func getPostList(page: Int, limit: Int = 20) -> Observable<[Post]> {
        return km_request(.getPostList(page: page, limit: limit))
    }
    
    private var provider: MoyaProvider<RxKoreaAPI> = MoyaProvider<RxKoreaAPI>()
    
    private func km_request<M: Argo.Decodable>(_ api: RxKoreaAPI) -> Observable<[M]> where M == M.DecodedType {
        return self.provider
            .rx
            .request(api)
            .mapArray()
            .observeOn(MainScheduler.instance)
    }
    
    private func km_request<M: Argo.Decodable>(_ api: RxKoreaAPI) -> Observable<M> where M == M.DecodedType {
        return self.provider
            .rx
            .request(api)
            .mapObject()
            .observeOn(MainScheduler.instance)
    }
}

/// Mark: - Priva

