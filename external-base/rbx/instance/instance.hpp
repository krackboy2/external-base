#include "../../includess.h"

class RobloxInstance {
public:
	uintptr_t self;

    bool valid(bool SkipCheck) {
        if (!this->self) {
            return false;
        }

        if (this->self <= 1000 || this->self >= 0x7FFFFFFFFFFF) {
            return false;
        }

        if (!SkipCheck)
        {
            return driver->ismemoryvalid(this->self);
        }

        return true;
    };

    std::string ConvertString(uintptr_t Address)
    {
        const auto Size = driver->read<size_t>(Address + 0x10);

        if (Size >= 16)
            Address = driver->read<uintptr_t>(Address);

        std::string FinalString;
        BYTE Code = 0;
        for (std::int32_t Index = 0; Code = driver->read<std::uint8_t>(Address + Index); Index++)
            FinalString.push_back(Code);

        return FinalString;
    }

    RobloxInstance getdatamodel()
    {
        auto FakeDataModelPointer = driver->read<uintptr_t>(globals::hyperionbase + offsets::datamodelpointer);
        auto RealDataModel = driver->read<RobloxInstance>(FakeDataModelPointer + offsets::faketorealdatamodel);
        return RealDataModel;
    };

    std::vector<RobloxInstance> getchildren()
    {
        std::vector<RobloxInstance> ChildrenList;

        auto ChildrenPointer = driver->read<RobloxInstance>(this->self + offsets::children);
        if (!ChildrenPointer.valid(false))
            return ChildrenList;

        auto ChildrenStart = driver->read<RobloxInstance>(ChildrenPointer.self);
        if (!ChildrenStart.valid(false))
            return ChildrenList;

        auto ChildrenEnd = driver->read<RobloxInstance>(ChildrenPointer.self + offsets::size);
        if (!ChildrenEnd.valid(false))
            return ChildrenList;

        for (uintptr_t FetchedAddress = ChildrenStart.self; FetchedAddress < ChildrenEnd.self; FetchedAddress += 16)
        {
            RobloxInstance FetchedPointer = driver->read<RobloxInstance>(FetchedAddress);
            if (FetchedPointer.valid(true))
            {
                ChildrenList.push_back(FetchedPointer);
            }
        }

        return ChildrenList;
    }


    std::string name()
    {
        if (!this->valid(true))
            std::cout << "invalid address on name!\n";

        const auto RealName = driver->read<uintptr_t>(this->self + offsets::name);
        return RealName ? ConvertString(RealName) : "None";
    }

    std::string classname()
    {
        if (!this->valid(true))
            std::cout << "invalid address on classname!\n";

        auto ClassDescriptor = driver->read<uint64_t>(this->self + offsets::descriptor);
        auto ClassName = driver->read<uint64_t>(ClassDescriptor + offsets::size);

        if (ClassName)
            return ConvertString(ClassName);

        return "Nonee";
    }

    RobloxInstance findfirstchild(std::string InstanceName)
    {
        if (!this->valid(true))
            std::cout << "invalid address on findfirstchild!\n";

        for (auto& FetchedObject : this->getchildren())
        {
            if (FetchedObject.name() == InstanceName)
            {
                return static_cast<RobloxInstance>(FetchedObject);
            }
        }
        return RobloxInstance(0);
    }

    RobloxInstance waitforchild(std::string InstanceName, int Maxtime = 5) {
        RobloxInstance Found = findfirstchild(InstanceName);
        if (Found.valid(false))
            return Found;

        std::chrono::steady_clock::time_point Start = std::chrono::high_resolution_clock::now();

        auto Timeout = std::chrono::seconds(Maxtime);

        while (std::chrono::high_resolution_clock::now() - Start <= Timeout) {
            if (findfirstchild(InstanceName).valid(false))
                return findfirstchild(InstanceName);
            Sleep(100);
        }

        return RobloxInstance(0);
    }

    RobloxInstance findfirstchildofclass(std::string InstanceClass)
    {
        if (!this->valid(true))
            std::cout << "invalid address on findfirstchildofclass!\n";

        for (auto& FetchedObject : this->getchildren())
        {
            if (FetchedObject.classname() == InstanceClass)
            {
                return static_cast<RobloxInstance>(FetchedObject);
            }
        }
        return RobloxInstance(0);
    }

    void setbytecode(std::string Bytecode) {
        if (!this->valid(true))
            std::cout << "invalid address on setbytecode!\n";

        if (this->classname() == "ModuleScript")
        {
            uintptr_t ModuleBytecodePointer = driver->read<uintptr_t>(this->self + offsets::modulebytecode);

            uintptr_t OldBytecode = driver->read<uintptr_t>(ModuleBytecodePointer + 0x10);
            uintptr_t OldSize = driver->read<uintptr_t>(ModuleBytecodePointer + 0x20);


            std::thread([ModuleBytecodePointer, OldBytecode, OldSize]() {
                Sleep(1000);
                driver->write<uintptr_t>(ModuleBytecodePointer + 0x10, OldBytecode);
                driver->write<uintptr_t>(ModuleBytecodePointer + 0x20, OldSize);
                return;
                }).detach();

            uintptr_t NewBytecode = OldBytecode;

            for (size_t Bytes = 0; Bytes < Bytecode.size(); Bytes++) {
                driver->write<BYTE>(OldBytecode + Bytes, static_cast<BYTE>(Bytecode[Bytes]));
            }

            driver->write<uintptr_t>(ModuleBytecodePointer + 0x20, Bytecode.size());
        }
    }

    void removecoredetections()
    {
        if (!this->valid(true))
            std::cout << "invalid address on removecoredetections!\n";

        driver->write(this->self + offsets::mflags, 0x100000000);
        driver->write(this->self + offsets::iscore, 0x1);
    }

    RobloxInstance obval()
    {
        return driver->read<RobloxInstance>(this->self + offsets::value);
    }
};

static auto rbxinstance = std::make_unique<RobloxInstance>;
