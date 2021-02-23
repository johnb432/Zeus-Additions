#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Arrays for ammunition choice
GVAR(545x39) = ["rhs_30Rnd_545x39_7N6M_plum_AK","rhs_30Rnd_545x39_AK_plum_green","rhs_30Rnd_545x39_7N10_AK","rhs_30Rnd_545x39_7N22_AK","rhs_30Rnd_545x39_7U1_AK","rhs_45Rnd_545X39_7N10_AK","rhs_45Rnd_545X39_7N22_AK","rhs_45Rnd_545X39_7N6_AK","rhs_45Rnd_545X39_7U1_AK","rhs_45Rnd_545X39_AK_Green"];
GVAR(762x39) = ["rhs_30Rnd_762x39mm","rhs_30Rnd_762x39mm_89","rhs_30Rnd_762x39mm_tracer","rhs_30Rnd_762x39mm_U","rhssaf_30Rnd_762x39_M82_api","30Rnd_762x39_Mag_Green_F","30Rnd_762x39_Mag_Tracer_Green_F","hlc_75Rnd_762x39_AP_rpk","rhs_75Rnd_762x39mm","rhs_75Rnd_762x39mm_89","rhs_75Rnd_762x39mm_tracer","75rnd_762x39_AK12_Mag_F","75rnd_762x39_AK12_Mag_Tracer_F","rhs_30Rnd_762x39mm_Savz58","rhs_30Rnd_762x39mm_Savz58_tracer"];
GVAR(762x54R) = ["rhs_10Rnd_762x54mmR_7N14","ACE_10Rnd_762x54_Tracer_mag","hlc_100Rnd_762x54_AP_PKM","hlc_250Rnd_762x54_AP_PKM","hlc_100Rnd_762x54_T_PKM","hlc_250Rnd_762x54_T_PKM","rhs_100Rnd_762x54mmR_7N26"];

GVAR(oddBLU) = ["29rnd_300BLK_STANAG_T","29rnd_300BLK_STANAG","29rnd_300BLK_STANAG_S","hlc_50rnd_300BLK_STANAG_EPR","hlc_30rnd_68x43_OTM","hlc_30rnd_68x43_IRDIM","hlc_30rnd_68x43_Sub","hlc_30rnd_68x43_Tracer","hlc_24Rnd_75x55_ap_stgw","hlc_24Rnd_75x55_T_stgw"];

GVAR(Stanag556) = ["rhs_mag_30Rnd_556x45_M855_Stanag","rhs_mag_30Rnd_556x45_M855A1_Stanag","rhs_mag_30Rnd_556x45_M855A1_Stanag_Tracer_Red","rhs_mag_30Rnd_556x45_Mk262_Stanag","rhs_mag_30Rnd_556x45_Mk318_Stanag","ACE_30Rnd_556x45_Stanag_M995_AP_mag","ACE_30Rnd_556x45_Stanag_Tracer_Dim"];
GVAR(Misc556) = ["rhssaf_30rnd_556x45_EPR_G36","rhssaf_30rnd_556x45_MDIM_G36","rhssaf_30rnd_556x45_Tracers_G36","rhssaf_30rnd_556x45_SPR_G36","rhssaf_30rnd_556x45_SOST_G36","hlc_30Rnd_556x45_EPR_sg550","hlc_30Rnd_556x45_TDIM_sg550","hlc_30Rnd_556x45_SPR_sg550","hlc_30Rnd_556x45_SOST_sg550","hlc_30Rnd_556x45_T_sg550","hlc_30Rnd_556x45_B_AUG","hlc_30Rnd_556x45_TDIM_AUG","hlc_30Rnd_556x45_SPR_AUG","hlc_30Rnd_556x45_SOST_AUG","hlc_30Rnd_556x45_T_AUG","hlc_30rnd_556x45_tdim_HK33","hlc_30rnd_556x45_SPR_HK33","hlc_30rnd_556x45_SOST_HK33","hlc_30rnd_556x45_t_HK33"];
GVAR(Belt556) = ["200Rnd_556x45_Box_Red_F","200Rnd_556x45_Box_Tracer_Red_F","hlc_200rnd_556x45_Mdim_SAW","rhsusf_100Rnd_556x45_soft_pouch","rhsusf_100Rnd_556x45_mixed_soft_pouch","rhsusf_200Rnd_556x45_soft_pouch","rhsusf_200Rnd_556x45_mixed_soft_pouch","rhs_mag_100Rnd_556x45_M855A1_cmag_mixed","rhs_mag_100Rnd_556x45_Mk262_cmag","rhs_mag_100Rnd_556x45_Mk318_cmag","150Rnd_556x45_Drum_Mag_F","150Rnd_556x45_Drum_Mag_Tracer_F","hlc_50rnd_556x45_MDim","hlc_50rnd_556x45_M","hlc_50rnd_556x45_SPR","hlc_50rnd_556x45_SOST"];

GVAR(QBZ58KH65) = ["100Rnd_580x42_Mag_F","100Rnd_580x42_Mag_Tracer_F","30Rnd_580x42_Mag_F","30Rnd_580x42_Mag_Tracer_F","30Rnd_65x39_caseless_green_mag_Tracer","30Rnd_65x39_caseless_green","ACE_30Rnd_65x39_caseless_green_mag_Tracer_Dim"];

GVAR(MX65) = ["30Rnd_65x39_caseless_mag","ACE_30Rnd_65x39_caseless_mag_Tracer_Dim","30Rnd_65x39_caseless_mag_Tracer","100Rnd_65x39_caseless_mag","ACE_100Rnd_65x39_caseless_mag_Tracer_Dim","100Rnd_65x39_caseless_mag_Tracer","200Rnd_65x39_cased_Box_Tracer_Red","200Rnd_65x39_cased_Box","ACE_200Rnd_65x39_cased_Box_Tracer_Dim","30Rnd_65x39_caseless_msbs_mag","30Rnd_65x39_caseless_msbs_mag_Tracer"];

GVAR(All762) = ["ACE_20Rnd_762x51_M118LR_Mag","ACE_20Rnd_762x51_M993_AP_Mag","ACE_20Rnd_762x51_Mk316_Mod_0_Mag","ACE_20Rnd_762x51_Mk319_Mod_0_Mag","ACE_20Rnd_762x51_Mag_Tracer_Dim","ACE_20Rnd_762x51_Mag_Tracer","rhs_mag_20Rnd_762x51_m61_fnfal","rhs_mag_20Rnd_762x51_m62_fnfal","rhs_mag_30Rnd_762x51_m61_fnfal","rhs_mag_30Rnd_762x51_m62_fnfal","rhs_mag_20Rnd_SCAR_762x51_m118_special_bk","rhs_mag_20Rnd_SCAR_762x51_m61_ap_bk","rhs_mag_20Rnd_SCAR_762x51_m62_tracer_bk","rhs_mag_20Rnd_SCAR_762x51_mk316_special_bk"];
GVAR(Belt762) = ["rhsusf_100Rnd_762x51_m61_ap","rhsusf_100Rnd_762x51_m62_tracer","rhsusf_100Rnd_762x51_m80a1epr","hlc_100Rnd_762x51_Mdim_M60E4","hlc_200Rnd_762x51_B_M60E4","hlc_200Rnd_762x51_Mdim_M60E4","hlc_200Rnd_762x51_Barrier_M60E4","UK3CB_BAF_762_200Rnd_T"];

GVAR(12G) = ["rhsusf_8Rnd_00Buck","rhsusf_8Rnd_Slug","hlc_12rnd_12g_buck_S12","hlc_12rnd_12g_slug_S12"];

GVAR(PistolBLU) = ["rhsusf_mag_15Rnd_9x19_FMJ","rhsusf_mag_15Rnd_9x19_JHP","rhsusf_mag_7x45acp_MHP","rhsusf_mag_17Rnd_9x19_FMJ","rhsusf_mag_17Rnd_9x19_JHP","UK3CB_BAF_9_17Rnd","UK3CB_BAF_9_15Rnd","hlc_15Rnd_9x19_B_P226","hlc_15Rnd_9x19_JHP_P226","hlc_15Rnd_9x19_SD_P226","ACE_16Rnd_9x19_mag","30Rnd_9x21_Mag_SMG_02","hlc_30Rnd_9x19_B_MP5","hlc_30Rnd_9x19_GD_MP5","hlc_30Rnd_9x19_SD_MP5","30Rnd_9x21_Green_Mag","30Rnd_9x21_Red_Mag","30Rnd_9x21_Mag","50Rnd_570x28_SMG_03","hlc_50Rnd_57x28_FMJ_P90","hlc_50Rnd_57x28_JHP_P90","rhsusf_mag_40Rnd_46x30_AP","rhsusf_mag_40Rnd_46x30_FMJ"];
GVAR(PistolRED) = ["rhs_mag_9x18_8_57N181S","rhs_mag_9x19_17","rhs_mag_9x19mm_7n31_20","rhs_mag_9x19mm_7n31_44","rhs_18rnd_9x21mm_7N29","16Rnd_9x21_Mag","16Rnd_9x21_green_Mag","rhsgref_20rnd_765x17_vz61"];

GVAR(UGLBLU) = ["1Rnd_HE_Grenade_shell","rhs_mag_M433_HEDP","1Rnd_SmokeBlue_Grenade_shell","1Rnd_SmokeGreen_Grenade_shell","1Rnd_SmokeRed_Grenade_shell","1Rnd_Smoke_Grenade_shell"];
GVAR(UGLRED) = ["hlc_VOG25_AK","hlc_GRD_blue","hlc_GRD_green","hlc_GRD_Red","hlc_GRD_White"];

GVAR(LATBLU) = ["UK3CB_BAF_AT4_CS_AP_Launcher","UK3CB_BAF_AT4_CS_AT_Launcher","rhs_weap_M136","rhs_weap_M136_hedp","rhs_weap_M136_hp","rhs_weap_m72a7"];
GVAR(LATRED) = ["rhs_weap_rpg26","rhs_weap_rshg2","rhs_weap_m80","rhs_weap_rpg75"];

GVAR(MATBLU) = ["rhs_mag_maaws_HE","rhs_mag_maaws_HEAT","MRAWS_HE_F","MRAWS_HEAT_F","rhs_mag_smaw_HEDP","rhs_mag_smaw_HEAA"];
GVAR(MATRED) = ["rhs_rpg7_OG7V_mag","rhs_rpg7_PG7V_mag","rhs_rpg7_PG7VL_mag","rhs_rpg7_PG7VM_mag","rhs_rpg7_PG7VR_mag","rhs_rpg7_TBG7V_mag","rhs_rpg7_type69_airburst_mag","RPG7_F","RPG32_HE_F","RPG32_F"];

GVAR(HATBLU) = ["UK3CB_BAF_Javelin_Slung_Tube"];
GVAR(HATBLUAMMO) = ["rhs_fgm148_magazine_AT"];
GVAR(HATRED) = ["Vorona_HE","Vorona_HEAT"];

GVAR(AABLU) = ["rhs_fim92_mag","Titan_AA"];
GVAR(AARED) = ["rhs_mag_9k38_rocket","Titan_AA"];



#include "initSettings.sqf"

ADDON = true;
