package hxgnd;

/**
 * Provides a interface for aborting the async task.
 */
typedef Abortable = {
    /**
     * Get a value that indicates whether the async task is active.
     * `true` if the task is active.
     */
    var isActive(default, null): Bool;

    /**
     * Abort the async task.
     */
    function abort(): Void;
}