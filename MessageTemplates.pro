APP_NAME = MessageTemplates

INCLUDEPATH += ../src  ../../quazip/src/ ../../canadainc/src/
LIBS += -lbbsystem -lbbpim -lbbutilityi18n -lbb
CONFIG += qt warn_on cascades10

CONFIG(release, debug|release) {
    DESTDIR = o.le-v7
    LIBS += -L../../canadainc/arm/o.le-v7 -lcanadainc -Bdynamic
}

CONFIG(debug, debug|release) {
    DESTDIR = o.le-v7-g
    LIBS += -L../../canadainc/arm/o.le-v7-g -lcanadainc -Bdynamic
}

include(config.pri)