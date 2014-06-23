package;

import hxmocha.Mocha;
import specs.OptionSpec;
import specs.ResultSpec;
import specs.ArrayToolsSpec;
import specs.PromiseSpec;
import specs.StreamSpec;

class Main {
    static function main() {
        Mocha.addSpec(OptionSpec);
        Mocha.addSpec(ResultSpec);
        Mocha.addSpec(PromiseSpec);
        Mocha.addSpec(StreamSpec);
        Mocha.addSpec(ArrayToolsSpec);
    }
}
