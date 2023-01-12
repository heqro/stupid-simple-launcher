#include <krunner/runnermanager.h>
#include <KServiceGroup>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "Settings.h"
#include "qobjects/ApplicationsModel.h"

int main(int argc, char *argv[]) {

    QGuiApplication a(argc, argv);
    QQmlApplicationEngine engine;

    const auto appModel = new ApplicationsModel();

    qmlRegisterSingletonInstance("StupidSimpleLauncher",
                                 1,
                                 0,
                                 "ApplicationsModel",
                                 appModel);

    engine.load("../ui/RootItem.qml");

    return QGuiApplication::exec();
}
