package;

import hxmocha.Mocha;
import specs.OptionSpec;
import specs.ResultSpec;

class Main {
    static function main() : Void {
        Mocha.addSpec(OptionSpec);
        Mocha.addSpec(ResultSpec);
    }
}
