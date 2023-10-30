class CfgSettings {
    class CBA {
        class Versioning {
            class PREFIX {
                class Dependencies {
                    ACE[] = {"ace_main", {3, 16, 0}, QUOTE(isClass (configFile >> 'CfgPatches' >> 'ace_main'))};
                    CBA[] = {"cba_main", {3, 16, 0}, "true"};
                    ZEN[] = {"zen_main", {1, 14, 0}, "true"};
                };
            };
        };
    };
};
