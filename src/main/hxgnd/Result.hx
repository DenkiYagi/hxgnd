package hxgnd;

enum Result<TSuccess> {
    Success(x: TSuccess);
    Failure(x: Error);
}