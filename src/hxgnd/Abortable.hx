package hxgnd;

/**
 * Provides a interface for aborting the async task.
 */
typedef Abortable = {
    /**
     * Abort the async task.
     */
    function abort(): Void;
}