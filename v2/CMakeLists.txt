cmake_minimum_required(VERSION 3.23)
project(runner_model_cacharreo)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

add_compile_options(-gdwarf-4)

find_package(Qt5 COMPONENTS
        Qml
        Quick
        Gui
        REQUIRED)
find_package(KF5I18n)
find_package(KF5Runner)

add_executable(runner_model_cacharreo main.cpp Settings.h qobjects/ApplicationsModel.cpp qobjects/ApplicationsModel.h qobjects/ApplicationEntry.cpp qobjects/ApplicationEntry.h)

target_link_libraries(runner_model_cacharreo
        Qt5::Qml
        Qt5::Quick
        Qt5::Gui
        KF5::Runner
        )

