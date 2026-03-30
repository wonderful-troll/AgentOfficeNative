#!/usr/bin/env python3
"""
Generates AgentOffice.xcodeproj/project.pbxproj
Two targets:
  - AgentOfficeApp  (macOS app, com.agentoffice.app)
  - AgentWidget     (WidgetKit extension, com.agentoffice.app.widget)
"""

import os, uuid, textwrap

# ── Helpers ────────────────────────────────────────────────────────────────

def uid():
    """Return a 24-char uppercase hex string (Xcode PBX UUID format)."""
    return uuid.uuid4().hex[:24].upper()

# ── UUIDs ──────────────────────────────────────────────────────────────────

PROJECT_UID         = uid()
MAIN_GROUP_UID      = uid()
PRODUCTS_GROUP_UID  = uid()

# App target
APP_TARGET_UID       = uid()
APP_NATIVE_TARGET    = uid()
APP_SOURCES_PHASE    = uid()
APP_RESOURCES_PHASE  = uid()
APP_FRAMEWORKS_PHASE = uid()
APP_EMBED_PHASE      = uid()   # Embed PlugIns
APP_PRODUCT_UID      = uid()
APP_BUILD_CONFIG_DEBUG   = uid()
APP_BUILD_CONFIG_RELEASE = uid()
APP_CONFIG_LIST      = uid()

# Widget target
WGT_TARGET_UID       = uid()
WGT_NATIVE_TARGET    = uid()
WGT_SOURCES_PHASE    = uid()
WGT_RESOURCES_PHASE  = uid()
WGT_FRAMEWORKS_PHASE = uid()
WGT_PRODUCT_UID      = uid()
WGT_BUILD_CONFIG_DEBUG   = uid()
WGT_BUILD_CONFIG_RELEASE = uid()
WGT_CONFIG_LIST      = uid()

# Project build configs
PROJ_CONFIG_DEBUG    = uid()
PROJ_CONFIG_RELEASE  = uid()
PROJ_CONFIG_LIST     = uid()

# Source file UUIDs — App
SRC_AGENTOFFICEAPP   = uid()
SRC_CONTENTVIEW      = uid()
SRC_SHAREDMODELS     = uid()
SRC_SHAREDDATASTORE  = uid()

# Source file UUIDs — Widget (shared models also linked)
SRC_WGT_BUNDLE       = uid()
SRC_WGT_WIDGET       = uid()
SRC_WGT_VIEW         = uid()
SRC_WGT_INTENT       = uid()
SRC_WGT_SHAREDMODELS = uid()  # second reference to SharedModels
SRC_WGT_SHAREDDATA   = uid()  # second reference to SharedDataStore

# PBXFileReference UIDs
REF_AGENTOFFICEAPP   = uid()
REF_CONTENTVIEW      = uid()
REF_SHAREDMODELS     = uid()
REF_SHAREDDATASTORE  = uid()
REF_WGT_BUNDLE       = uid()
REF_WGT_WIDGET       = uid()
REF_WGT_VIEW         = uid()
REF_WGT_INTENT       = uid()
REF_APP_INFOPLIST    = uid()
REF_WGT_INFOPLIST    = uid()
REF_APP_ENTITLEMENTS = uid()
REF_WGT_ENTITLEMENTS = uid()
REF_APP_PRODUCT      = uid()
REF_WGT_PRODUCT      = uid()

# Group UIDs
GRP_APP              = uid()
GRP_WGT              = uid()

# Embed build file
EMBED_WGT_FILE       = uid()

# ── PBX content ────────────────────────────────────────────────────────────

pbx = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
\t\t{SRC_AGENTOFFICEAPP} /* AgentOfficeApp.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {REF_AGENTOFFICEAPP}; }};
\t\t{SRC_CONTENTVIEW} /* ContentView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {REF_CONTENTVIEW}; }};
\t\t{SRC_SHAREDMODELS} /* SharedModels.swift in Sources (App) */ = {{isa = PBXBuildFile; fileRef = {REF_SHAREDMODELS}; }};
\t\t{SRC_SHAREDDATASTORE} /* SharedDataStore.swift in Sources (App) */ = {{isa = PBXBuildFile; fileRef = {REF_SHAREDDATASTORE}; }};
\t\t{SRC_WGT_BUNDLE} /* AgentWidgetBundle.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {REF_WGT_BUNDLE}; }};
\t\t{SRC_WGT_WIDGET} /* AgentWidget.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {REF_WGT_WIDGET}; }};
\t\t{SRC_WGT_VIEW} /* AgentWidgetView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {REF_WGT_VIEW}; }};
\t\t{SRC_WGT_INTENT} /* AgentWidgetIntent.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {REF_WGT_INTENT}; }};
\t\t{SRC_WGT_SHAREDMODELS} /* SharedModels.swift in Sources (Widget) */ = {{isa = PBXBuildFile; fileRef = {REF_SHAREDMODELS}; }};
\t\t{SRC_WGT_SHAREDDATA} /* SharedDataStore.swift in Sources (Widget) */ = {{isa = PBXBuildFile; fileRef = {REF_SHAREDDATASTORE}; }};
\t\t{EMBED_WGT_FILE} /* AgentWidget.appex in Embed App Extensions */ = {{isa = PBXBuildFile; fileRef = {REF_WGT_PRODUCT}; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};
/* End PBXBuildFile section */

/* Begin PBXCopyFilesBuildPhase section */
\t\t{APP_EMBED_PHASE} /* Embed App Extensions */ = {{
\t\t\tisa = PBXCopyFilesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tdstPath = "";
\t\t\tdstSubfolderSpec = 13;
\t\t\tfiles = (
\t\t\t\t{EMBED_WGT_FILE} /* AgentWidget.appex in Embed App Extensions */,
\t\t\t);
\t\t\tname = "Embed App Extensions";
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXCopyFilesBuildPhase section */

/* Begin PBXFileReference section */
\t\t{REF_AGENTOFFICEAPP} /* AgentOfficeApp.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AgentOfficeApp.swift; sourceTree = "<group>"; }};
\t\t{REF_CONTENTVIEW} /* ContentView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; }};
\t\t{REF_SHAREDMODELS} /* SharedModels.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SharedModels.swift; sourceTree = "<group>"; }};
\t\t{REF_SHAREDDATASTORE} /* SharedDataStore.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SharedDataStore.swift; sourceTree = "<group>"; }};
\t\t{REF_WGT_BUNDLE} /* AgentWidgetBundle.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AgentWidgetBundle.swift; sourceTree = "<group>"; }};
\t\t{REF_WGT_WIDGET} /* AgentWidget.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AgentWidget.swift; sourceTree = "<group>"; }};
\t\t{REF_WGT_VIEW} /* AgentWidgetView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AgentWidgetView.swift; sourceTree = "<group>"; }};
\t\t{REF_WGT_INTENT} /* AgentWidgetIntent.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AgentWidgetIntent.swift; sourceTree = "<group>"; }};
\t\t{REF_APP_INFOPLIST} /* AgentOfficeApp/Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};
\t\t{REF_WGT_INFOPLIST} /* AgentWidget/Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};
\t\t{REF_APP_ENTITLEMENTS} /* AgentOfficeApp.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = AgentOfficeApp.entitlements; sourceTree = "<group>"; }};
\t\t{REF_WGT_ENTITLEMENTS} /* AgentWidget.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = AgentWidget.entitlements; sourceTree = "<group>"; }};
\t\t{REF_APP_PRODUCT} /* AgentOffice.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "AgentOffice.app"; sourceTree = BUILT_PRODUCTS_DIR; }};
\t\t{REF_WGT_PRODUCT} /* AgentWidget.appex */ = {{isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = AgentWidget.appex; sourceTree = BUILT_PRODUCTS_DIR; }};
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{APP_FRAMEWORKS_PHASE} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{WGT_FRAMEWORKS_PHASE} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{MAIN_GROUP_UID} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{GRP_APP} /* AgentOfficeApp */,
\t\t\t\t{GRP_WGT} /* AgentWidget */,
\t\t\t\t{PRODUCTS_GROUP_UID} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{PRODUCTS_GROUP_UID} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{REF_APP_PRODUCT} /* AgentOffice.app */,
\t\t\t\t{REF_WGT_PRODUCT} /* AgentWidget.appex */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{GRP_APP} /* AgentOfficeApp */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{REF_AGENTOFFICEAPP} /* AgentOfficeApp.swift */,
\t\t\t\t{REF_CONTENTVIEW} /* ContentView.swift */,
\t\t\t\t{REF_SHAREDMODELS} /* SharedModels.swift */,
\t\t\t\t{REF_SHAREDDATASTORE} /* SharedDataStore.swift */,
\t\t\t\t{REF_APP_INFOPLIST} /* Info.plist */,
\t\t\t\t{REF_APP_ENTITLEMENTS} /* AgentOfficeApp.entitlements */,
\t\t\t);
\t\t\tpath = AgentOfficeApp;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{GRP_WGT} /* AgentWidget */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{REF_WGT_BUNDLE} /* AgentWidgetBundle.swift */,
\t\t\t\t{REF_WGT_WIDGET} /* AgentWidget.swift */,
\t\t\t\t{REF_WGT_VIEW} /* AgentWidgetView.swift */,
\t\t\t\t{REF_WGT_INTENT} /* AgentWidgetIntent.swift */,
\t\t\t\t{REF_WGT_INFOPLIST} /* Info.plist */,
\t\t\t\t{REF_WGT_ENTITLEMENTS} /* AgentWidget.entitlements */,
\t\t\t);
\t\t\tpath = AgentWidget;
\t\t\tsourceTree = "<group>";
\t\t}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{APP_NATIVE_TARGET} /* AgentOfficeApp */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {APP_CONFIG_LIST} /* Build configuration list for PBXNativeTarget "AgentOfficeApp" */;
\t\t\tbuildPhases = (
\t\t\t\t{APP_SOURCES_PHASE} /* Sources */,
\t\t\t\t{APP_FRAMEWORKS_PHASE} /* Frameworks */,
\t\t\t\t{APP_RESOURCES_PHASE} /* Resources */,
\t\t\t\t{APP_EMBED_PHASE} /* Embed App Extensions */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t\t{APP_TARGET_UID} /* PBXTargetDependency */,
\t\t\t);
\t\t\tname = AgentOfficeApp;
\t\t\tproductName = AgentOffice;
\t\t\tproductReference = {REF_APP_PRODUCT} /* AgentOffice.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
\t\t{WGT_NATIVE_TARGET} /* AgentWidget */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {WGT_CONFIG_LIST} /* Build configuration list for PBXNativeTarget "AgentWidget" */;
\t\t\tbuildPhases = (
\t\t\t\t{WGT_SOURCES_PHASE} /* Sources */,
\t\t\t\t{WGT_FRAMEWORKS_PHASE} /* Frameworks */,
\t\t\t\t{WGT_RESOURCES_PHASE} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = AgentWidget;
\t\t\tproductName = AgentWidget;
\t\t\tproductReference = {REF_WGT_PRODUCT} /* AgentWidget.appex */;
\t\t\tproductType = "com.apple.product-type.app-extension";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{PROJECT_UID} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1500;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{APP_NATIVE_TARGET} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t\t{WGT_NATIVE_TARGET} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {PROJ_CONFIG_LIST} /* Build configuration list for PBXProject */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = ko;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tko,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {MAIN_GROUP_UID};
\t\t\tproductRefGroup = {PRODUCTS_GROUP_UID} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{APP_NATIVE_TARGET} /* AgentOfficeApp */,
\t\t\t\t{WGT_NATIVE_TARGET} /* AgentWidget */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{APP_RESOURCES_PHASE} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{WGT_RESOURCES_PHASE} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{APP_SOURCES_PHASE} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{SRC_AGENTOFFICEAPP} /* AgentOfficeApp.swift in Sources */,
\t\t\t\t{SRC_CONTENTVIEW} /* ContentView.swift in Sources */,
\t\t\t\t{SRC_SHAREDMODELS} /* SharedModels.swift in Sources */,
\t\t\t\t{SRC_SHAREDDATASTORE} /* SharedDataStore.swift in Sources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{WGT_SOURCES_PHASE} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{SRC_WGT_BUNDLE} /* AgentWidgetBundle.swift in Sources */,
\t\t\t\t{SRC_WGT_WIDGET} /* AgentWidget.swift in Sources */,
\t\t\t\t{SRC_WGT_VIEW} /* AgentWidgetView.swift in Sources */,
\t\t\t\t{SRC_WGT_INTENT} /* AgentWidgetIntent.swift in Sources */,
\t\t\t\t{SRC_WGT_SHAREDMODELS} /* SharedModels.swift in Sources */,
\t\t\t\t{SRC_WGT_SHAREDDATA} /* SharedDataStore.swift in Sources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
\t\t{APP_TARGET_UID} /* PBXTargetDependency */ = {{
\t\t\tisa = PBXTargetDependency;
\t\t\ttarget = {WGT_NATIVE_TARGET} /* AgentWidget */;
\t\t\ttargetProxy = {WGT_TARGET_UID};
\t\t}};
\t\t{WGT_TARGET_UID} /* PBXContainerItemProxy */ = {{
\t\t\tisa = PBXContainerItemProxy;
\t\t\tcontainerPortal = {PROJECT_UID} /* Project object */;
\t\t\tproxyType = 1;
\t\t\tremoteGlobalIDString = {WGT_NATIVE_TARGET};
\t\t\tremoteInfo = AgentWidget;
\t\t}};
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
\t\t{PROJ_CONFIG_DEBUG} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = ("DEBUG=1", "$(inherited)");
\t\t\t\tMACOSX_DEPLOYMENT_TARGET = 14.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t\tSDKROOT = macosx;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{PROJ_CONFIG_RELEASE} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tMACOSX_DEPLOYMENT_TARGET = 14.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tSDKROOT = macosx;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{APP_BUILD_CONFIG_DEBUG} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSTCAT_COMPILER_SKIP_APP_STORE_DEPLOYMENT = YES;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = AgentOfficeApp/AgentOfficeApp.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCOMBINE_HIDPI_IMAGES = YES;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tINFOPLIST_FILE = AgentOfficeApp/Info.plist;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/../Frameworks");
\t\t\t\tMACOSX_DEPLOYMENT_TARGET = 14.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "com.agentoffice.app";
\t\t\t\tPRODUCT_NAME = AgentOffice;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tSDKROOT = macosx;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{APP_BUILD_CONFIG_RELEASE} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = AgentOfficeApp/AgentOfficeApp.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCOMBINE_HIDPI_IMAGES = YES;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tINFOPLIST_FILE = AgentOfficeApp/Info.plist;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/../Frameworks");
\t\t\t\tMACOSX_DEPLOYMENT_TARGET = 14.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "com.agentoffice.app";
\t\t\t\tPRODUCT_NAME = AgentOffice;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tSDKROOT = macosx;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{WGT_BUILD_CONFIG_DEBUG} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = AgentWidget/AgentWidget.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tINFOPLIST_FILE = AgentWidget/Info.plist;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/../Frameworks", "@executable_path/../../../../Frameworks");
\t\t\t\tMACOSX_DEPLOYMENT_TARGET = 14.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "com.agentoffice.app.widget";
\t\t\t\tPRODUCT_NAME = AgentWidget;
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tSDKROOT = macosx;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{WGT_BUILD_CONFIG_RELEASE} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = AgentWidget/AgentWidget.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tINFOPLIST_FILE = AgentWidget/Info.plist;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/../Frameworks", "@executable_path/../../../../Frameworks");
\t\t\t\tMACOSX_DEPLOYMENT_TARGET = 14.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "com.agentoffice.app.widget";
\t\t\t\tPRODUCT_NAME = AgentWidget;
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tSDKROOT = macosx;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{PROJ_CONFIG_LIST} /* Build configuration list for PBXProject */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{PROJ_CONFIG_DEBUG} /* Debug */,
\t\t\t\t{PROJ_CONFIG_RELEASE} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{APP_CONFIG_LIST} /* Build configuration list for PBXNativeTarget "AgentOfficeApp" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{APP_BUILD_CONFIG_DEBUG} /* Debug */,
\t\t\t\t{APP_BUILD_CONFIG_RELEASE} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{WGT_CONFIG_LIST} /* Build configuration list for PBXNativeTarget "AgentWidget" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{WGT_BUILD_CONFIG_DEBUG} /* Debug */,
\t\t\t\t{WGT_BUILD_CONFIG_RELEASE} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */

\t}};
\trootObject = {PROJECT_UID} /* Project object */;
}}
"""

# ── Write ──────────────────────────────────────────────────────────────────

proj_dir = os.path.join(os.path.dirname(__file__), "AgentOffice.xcodeproj")
os.makedirs(proj_dir, exist_ok=True)
out = os.path.join(proj_dir, "project.pbxproj")
with open(out, "w") as f:
    f.write(pbx)
print(f"✅ Generated: {out}")
