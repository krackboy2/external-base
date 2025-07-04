#include "../../includess.h"

namespace executor {
	namespace bridge {
        void init()
        {
            std::thread([] {
                std::filesystem::path library = std::filesystem::current_path();
                std::filesystem::path executeFile = library / "bridge.txt";
                std::filesystem::path autoexec = library / "autoexec";
                std::filesystem::path workspace = library / "workspace";

                if (!std::filesystem::exists(executeFile)) {
                    FILE* f = fopen(executeFile.string().c_str(), "w");
                    if (f)
                        fclose(f);
                }

                std::filesystem::file_time_type lastFileTime = std::filesystem::last_write_time(executeFile);

                while (true) {
                    std::filesystem::file_time_type ftime = std::filesystem::last_write_time(executeFile);
                    if (ftime != lastFileTime) {
                        lastFileTime = ftime;

                        FILE* file = fopen(executeFile.string().c_str(), "rb");
                        if (!file) continue;

                        fseek(file, 0, SEEK_END);
                        size_t fileSize = ftell(file);
                        rewind(file);

                        std::string script(fileSize, '\0');
                        size_t bytesread = fread(&script[0], 1, fileSize, file);
                        fclose(file);

                        if (bytesread <= 2) continue;

                        execution::execute(script);
                    }

                    if (!std::filesystem::is_directory(autoexec))
                        std::filesystem::create_directory(autoexec);

                    if (!std::filesystem::is_directory(workspace))
                        std::filesystem::create_directory(workspace);

                    std::this_thread::sleep_for(std::chrono::milliseconds(10));
                }
            }).detach();
        }

	};
};