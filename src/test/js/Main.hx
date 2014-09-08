package;

import hxmocha.Mocha;
import specs.*;

class Main {
    static function main() {
        Mocha.addSpec(OptionSpec);
        Mocha.addSpec(ResultSpec);
        Mocha.addSpec(PromiseSpec);
        Mocha.addSpec(PromiseBrokerSpec);
        Mocha.addSpec(StreamSpec);
        Mocha.addSpec(StreamBrokerSpec);
        Mocha.addSpec(ArrayToolsSpec);
        Mocha.addSpec(JqHtmlSpec);
    }
}
