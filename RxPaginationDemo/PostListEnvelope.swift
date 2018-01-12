import Runes
import Argo
import Curry

public struct PostListEnvelope {
    var posts: [Post]
}

extension PostListEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<PostListEnvelope> {
        return curry(PostListEnvelope.init)
        <^> json <|| "posts"
    }
}
