package hxgnd;

enum Result<T> {
    Success(value: T);
    Failed(error: Dynamic);
}