//
//  ConstantParamInit.swift
//  GlucoPredTest
//
//  Created by Peter Stige on 04/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class ParamInit {
    
    // Parameter string names
    static let P_STR_KMG    = "Kmg"
    static let P_STR_ALFA   = "alfa"
    static let P_STR_KDIA   = "kDia"
    static let P_STR_KIL    = "kIL"
    static let P_STR_BETA   = "beta"
    static let P_STR_GNEO   = "Gneo"
    static let P_STR_RM     = "Rm"
    static let P_STR_TD     = "Td"
    static let P_STR_IHALF  = "Ihalf"
    static let P_STR_RI     = "Ri"
    static let P_STR_UB     = "Ub"
    static let P_STR_NH     = "nh"
    static let P_STR_NI     = "ni"
    static let P_STR_TY     = "TY"
    static let P_STR_I0     = "I0"
    static let P_STR_AP     = "aP"
    static let P_STR_MLMX   = "MlMx"
    static let P_STR_HRB    = "HRB"
    static let P_STR_KABS   = "kabs" // Måltid
    static let P_STR_TMAX   = "Tmax"
    static let P_STR_TDS    = "Tds"
    static let P_STR_SI     = "Si" // Ins sens
    static let P_STR_KGB    = "kgb" // Baseline
    static let P_STR_KHL    = "kHL" // Baseline
    static let P_STR_KDEL   = "kDel"
    static let P_STR_ENEO   = "Eneo" // Baseline
    static let P_STR_KGM    = "kgm" // Baseline
    static let P_STR_GI     = "GI"
    static let P_STR_GH     = "GH"
    static let P_STR_P2     = "p2" // hvor rask virkning av insulin, hvor fort I til X
    static let P_STR_F      = "f" // Måltid
    static let P_STR_UII    = "Uii"
    static let P_STR_VI     = "Vi"
    static let P_STR_RHBAS  = "Rhbas"
    static let P_STR_SCOMP  = "sComp"
    static let P_STR_N      = "n"
    static let P_STR_RHMAX  = "Rhmax"
    static let P_STR_R      = "r"
    static let P_STR_KGLG   = "kglg" // Baseline
    static let P_STR_VG     = "Vg"
    static let P_STR_HRM    = "HRM"
    
    // List of parameter string names
    static let pStrList = [P_STR_KMG,
                           P_STR_ALFA,
                           P_STR_KDIA,
                           P_STR_KIL,
                           P_STR_BETA,
                           P_STR_GNEO,
                           P_STR_RM,
                           P_STR_TD,
                           P_STR_IHALF,
                           P_STR_RI,
                           P_STR_UB,
                           P_STR_NH,
                           P_STR_NI,
                           P_STR_TY,
                           P_STR_I0,
                           P_STR_AP,
                           P_STR_MLMX,
                           P_STR_HRB,
                           P_STR_KABS,
                           P_STR_TMAX,
                           P_STR_TDS,
                           P_STR_SI,
                           P_STR_KGB,
                           P_STR_KHL,
                           P_STR_KDEL,
                           P_STR_ENEO,
                           P_STR_KGM,
                           P_STR_GI,
                           P_STR_GH,
                           P_STR_P2,
                           P_STR_F,
                           P_STR_UII,
                           P_STR_VI,
                           P_STR_RHBAS,
                           P_STR_SCOMP,
                           P_STR_N,
                           P_STR_RHMAX,
                           P_STR_R,
                           P_STR_KGLG,
                           P_STR_VG,
                           P_STR_HRM]
    
    
    // Parameter init values for healthy subject
    static let healthy = [P_STR_KMG: 120.0,
                          P_STR_ALFA: 0.02,
                          P_STR_KDIA: 0.0,
                          P_STR_KIL: 750.0,
                          P_STR_BETA: 1.0,
                          P_STR_GNEO: 0.3,
                          P_STR_RM: 21.0,
                          P_STR_TD: 1000.0,
                          P_STR_IHALF: 40.0,
                          P_STR_RI: 118.0,
                          P_STR_UB: 0.0,
                          P_STR_NH: 6.4,
                          P_STR_NI: 4.2,
                          P_STR_TY: 6.0,
                          P_STR_I0: 15.0,
                          P_STR_AP: 0.1,
                          P_STR_MLMX: 100.0,
                          P_STR_HRB: 71.0,
                          P_STR_KABS: 0.05,
                          P_STR_TMAX: 600.0,
                          P_STR_TDS: 1000.0,
                          P_STR_SI: 0.2,
                          P_STR_KGB: 0.0012,
                          P_STR_KHL: 3.6,
                          P_STR_KDEL: 0.1,
                          P_STR_ENEO: 50.0,
                          P_STR_KGM: 0.4,
                          P_STR_GI: 150.0,
                          P_STR_GH: 55.0,
                          P_STR_P2: 0.02,
                          P_STR_F: 0.8,
                          P_STR_UII: 0.78,
                          P_STR_VI: 15.7,
                          P_STR_RHBAS: 130.0,
                          P_STR_SCOMP: 2.0,
                          P_STR_N: 0.142,
                          P_STR_RHMAX: 665.0,
                          P_STR_R: 1.1,
                          P_STR_KGLG: 0.6]
    
    // Parameter init values for DM1 subject
    static let dm1 = [P_STR_KMG: 120.0,
                      P_STR_ALFA: 0.02,
                      P_STR_KDIA: 10.0,
                      P_STR_KIL: 750.0,
                      P_STR_BETA: 1.0,
                      P_STR_GNEO: 0.3,
                      P_STR_RM: 0.0,
                      P_STR_TD: 15.0,
                      P_STR_IHALF: 40.0,
                      P_STR_RI: 0.0,
                      P_STR_UB: 0.0,
                      P_STR_NH: 6.4,
                      P_STR_NI: 4.2,
                      P_STR_TY: 6.0,
                      P_STR_I0: 15.0,
                      P_STR_AP: 0.1,
                      P_STR_MLMX: 150.0,
                      P_STR_HRB: 71.0,
                      P_STR_KABS: 0.04,
                      P_STR_TMAX: 600.0,
                      P_STR_TDS: 1000.0,
                      P_STR_SI: 0.2,
                      P_STR_KGB: 0.0012,
                      P_STR_KHL: 2.0,
                      P_STR_KDEL: 0.1,
                      P_STR_ENEO: 50.0,
                      P_STR_KGM: 0.4,
                      P_STR_GI: 150.0,
                      P_STR_GH: 55.0,
                      P_STR_P2: 0.02,
                      P_STR_F: 0.8,
                      P_STR_UII: 0.78,
                      P_STR_VI: 15.7,
                      P_STR_RHBAS: 130.0,
                      P_STR_SCOMP: 2.0,
                      P_STR_N: 0.142,
                      P_STR_RHMAX: 665.0,
                      P_STR_R: 1.1,
                      P_STR_KGLG: 0.6]
    
    // Parameter init for DM2 subject
    static let dm2 = [P_STR_KMG: 120.0,
                          P_STR_ALFA: 0.02,
                          P_STR_KDIA: 0.0,
                          P_STR_KIL: 750.0,
                          P_STR_BETA: 1.0,
                          P_STR_GNEO: 0.3,
                          P_STR_RM: 21.0,
                          P_STR_TD: 10.0,
                          P_STR_IHALF: 40.0,
                          P_STR_RI: 118.0,
                          P_STR_UB: 0.0,
                          P_STR_NH: 6.4,
                          P_STR_NI: 4.2,
                          P_STR_TY: 6.0,
                          P_STR_I0: 15.0,
                          P_STR_AP: 0.1,
                          P_STR_MLMX: 100.0,
                          P_STR_HRB: 71.0,
                          P_STR_KABS: 0.062,
                          P_STR_TMAX: 600.0,
                          P_STR_TDS: 1000.0,
                          P_STR_SI: 0.001,
                          P_STR_KGB: 0.0012,
                          P_STR_KHL: 2.0,
                          P_STR_KDEL: 0.1,
                          P_STR_ENEO: 50.0,
                          P_STR_KGM: 0.4,
                          P_STR_GI: 150.0,
                          P_STR_GH: 55.0,
                          P_STR_P2: 0.01,
                          P_STR_F: 0.8,
                          P_STR_UII: 0.78,
                          P_STR_VI: 15.7,
                          P_STR_RHBAS: 130.0,
                          P_STR_SCOMP: 2.0,
                          P_STR_N: 0.142,
                          P_STR_RHMAX: 665.0,
                          P_STR_R: 1.1,
                          P_STR_KGLG: 0.6]
    
}
