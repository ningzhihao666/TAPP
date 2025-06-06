cmake_minimum_required(VERSION 3.27)

project(tiantiankupao VERSION 0.1 LANGUAGES CXX)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(apptiantiankupao)

qt_add_qml_module(apptiantiankupao
    URI tiantiankupao
    VERSION 1.0
    QML_FILES Main.qml
    SOURCES main.cpp
    QML_FILES MainMenu.qml
    QML_FILES GameScreen.qml
    QML_FILES Player.qml
    QML_FILES GameControlPanel.qml
    QML_FILES DaojuGenerator.qml
    QML_FILES DaojuDetector.qml
    RESOURCES images.qrc
    QML_FILES Page_jiesuan.qml
    QML_FILES Page_begin.qml
    RESOURCES android/gradle/wrapper/gradle-wrapper.jar android/gradle/wrapper/gradle-wrapper.properties
    RESOURCES android/AndroidManifest.xml android/build.gradle android/gradle.properties android/gradlew android/gradlew.bat
    RESOURCES android/res/values/libs.xml
    QML_FILES ObstacleGenerator.qml
    QML_FILES Bonus_level.qml
    QML_FILES Boss_level.qml
)

target_compile_features(apptiantiankupao PRIVATE cxx_std_20)

set_target_properties(apptiantiankupao PROPERTIES
    AUTORCC TRUE
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(apptiantiankupao
    PRIVATE 
        Qt6::Quick
)

include(GNUInstallDirs)

install(TARGETS apptiantiankupao
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

#设置安卓xml文件配置位置
set_target_properties(
    apptiantiankupao   #目标名称
    PROPERTIES
    QT_ANDROID_PACKAGE_SOURCE_DIR           #指定Android平台打包使用的资源目录
    "${CMAKE_SOURCE_DIR}/android"    #构建时会从该目录下复制所有资源文件
                                            #放在最后生成的APK文件中，覆盖QT默认生成的Android配置
)
















































#qt_add_executable(tiantiankupao)  //Creates and finalizes an application target of a platform-specific type.
#This command performs the following tasks:
#    1. Create a CMake target of the appropriate type for the target platform.
#    2. Link the target to the Qt::Core library.
#    3. Handle finalization of the CMake target.



# qt_standard_project_setup()     #set(CMAKE_AUTOUIC ON)  set(CMAKE_AUTOMOC ON)

# @if %{HasTranslation}
# find_package(Qt6 REQUIRED COMPONENTS Core Quick LinguistTools)
# @else
# find_package(Qt6 REQUIRED COMPONENTS Core Quick)
# @endif

# target_sources(apptiantiankupao
#     PRIVATE
#         main.cpp
#         qml.qrc
#     @if %{HasTranslation}
#         %{TsFileName}
#     @endif
#         
#     PUBLIC
#         
# )

# qt_import_qml_plugins(tiantiankupao)

















# cmake_minimum_required(VERSION 3.16)
# 
# project(tiantiankupao VERSION 0.1 LANGUAGES CXX)
# 
# @if !true
# set(CMAKE_AUTOMOC ON)
# @endif
# set(CMAKE_CXX_STANDARD_REQUIRED ON)
# 
# find_package(Qt6 6.5 REQUIRED COMPONENTS Quick)
# 
# @if true
# @if true
# qt_standard_project_setup(REQUIRES 6.5)
# @else
# qt_standard_project_setup()
# @endif
# @endif
# 
# qt_add_executable(apptiantiankupao
#     main.cpp
# )
# 
# qt_add_qml_module(apptiantiankupao
#     URI tiantiankupao
#     VERSION 1.0
#     QML_FILES Main.qml
# )
# 
# # Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# # If you are developing for iOS or macOS you should consider setting an
# # explicit, fixed bundle identifier manually though.
# set_target_properties(apptiantiankupao PROPERTIES
# #    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.apptiantiankupao
#     MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
#     MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
#     MACOSX_BUNDLE TRUE
#     WIN32_EXECUTABLE TRUE
# )
# 
# target_link_libraries(apptiantiankupao
#     PRIVATE Qt6::Quick
# )
# 
# include(GNUInstallDirs)
# install(TARGETS apptiantiankupao
#     BUNDLE DESTINATION .
#     LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
#     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
# )
