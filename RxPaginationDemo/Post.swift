import Runes
import Argo
import Curry

public struct Post {
    var userId: Int
    var id: Int
    var title: String
    var body: String
}

extension Post: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Post> {
        return curry(Post.init)
        <^> json <| "userId"
        <*> json <| "id"
        <*> json <| "title"
        <*> json <| "body"
    }
}

