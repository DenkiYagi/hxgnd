package;

class TestTools {
    public static function wait(msec: Int, fn: Void -> Void) {
        #if js
        haxe.Timer.delay(fn, msec);
        // #elseif (sys && !macro && !iterp)
        // haxe.Timer.delay(fn, msec);
        //tasks.add({ fn: fn, delay: msec });
        #elseif (neko && !macro)
        mutex.acquire();
        tasks.push({ fn: fn, tick: Math.ceil(msec / 10) });
        mutex.release();
        #else
        buddy.tools.AsyncTools.wait(msec).then(function (_) fn());
        #end
    }

    #if (neko && !macro)
    static var mutex = new neko.vm.Mutex();
    static var tasks = new Array<{tick: Int, fn: Void -> Void}>();
    static var running = false;

    public static function run(): Void {
        mutex.acquire();
        if (running) {
            mutex.release();
            return;
        } else {
            running = true;
            mutex.release();
        }

        // neko.vm.Thread.create(function () {
        haxe.EntryPoint.addThread(function () {
            var tick = 0;
            var schedule = new haxe.ds.IntMap<Array<Void -> Void>>();
            while (running) {
                mutex.acquire();
                for (task in tasks) {
                    var t = task.tick + tick;
                    if (schedule.exists(t)) {
                        schedule.get(t).push(task.fn);
                    } else {
                        schedule.set(t, [task.fn]);
                    }
                }
                tasks = [];
                mutex.release();

                if (schedule.exists(tick)) {
                    for (f in schedule.get(tick)) {
                        haxe.EntryPoint.runInMainThread(f);
                        // try {
                        //     f();
                        // } catch (e: Dynamic) {
                        //     trace(e);
                        // }
                    }
                    schedule.remove(tick);
                }

                tick++;
                Sys.sleep(0.01);
            }
        });
    }

    public static function stop(): Void {
        mutex.acquire();
        running = false;
        mutex.release();
    }
    #end
}
