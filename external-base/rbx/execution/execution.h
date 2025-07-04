#include <../includess.h>

namespace execution {
    static void execute(std::string Source) {
        auto DataModel = rbxinstance()->getdatamodel();
        if (!DataModel.valid(true))
        {
            std::cout << "oh, shit, error while getting datamodel!\n";
            while (true) {}
        }

        auto CoreGui = DataModel.findfirstchildofclass("CoreGui");
        if (!CoreGui.valid(true))
        {
            std::cout << "oh, shit, error while getting coregui!\n";
            while (true) {}
        }

        auto ScriptsHolder = CoreGui.findfirstchild("external_holder");
        if (!ScriptsHolder.valid(true))
        {
            std::cout << "oh, shit, error while getting 'external_holder'!\n";
            while (true) {}
        }

        auto HolderValue = ScriptsHolder.obval();
        while (!HolderValue.valid(true))
        {
            std::this_thread::sleep_for(std::chrono::milliseconds(25));
            HolderValue = ScriptsHolder.obval();
        }

        HolderValue.setbytecode(luau::zstdcompresse(luau::compilee("return {['external'] = function(...)\n" + Source + "\nend}")));

        HolderValue.removecoredetections();
    }

};