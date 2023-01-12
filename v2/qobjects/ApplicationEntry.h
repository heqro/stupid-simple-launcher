//
// Created by heqro on 26/12/22.
//

#ifndef RUNNER_MODEL_CACHARREO_APPLICATIONENTRY_H
#define RUNNER_MODEL_CACHARREO_APPLICATIONENTRY_H


#include <QConstOverload>
#include <QString>
#include <KSycocaEntry>

class ApplicationEntry {
    Q_GADGET

    Q_PROPERTY(QString entryName MEMBER m_entryName CONSTANT)
    Q_PROPERTY(QString iconName MEMBER m_iconName CONSTANT)
    Q_PROPERTY(QString exec MEMBER m_exec CONSTANT)
    Q_PROPERTY(QString comment MEMBER m_comment CONSTANT)
public:
    ApplicationEntry() = default;
    ~ApplicationEntry() = default;
    ApplicationEntry(const ApplicationEntry&) = default;
    explicit ApplicationEntry(const KSycocaEntry& entry);

    bool operator==(const ApplicationEntry &e) const;
    bool operator<(const ApplicationEntry &e) const;

    static uint hashAux(const ApplicationEntry& key, uint seed) {
        return ::qHash(key.m_entryName, seed) ^ ::qHash(key.m_iconName, seed);
    }
private:
    QString m_entryName, m_iconName, m_exec, m_comment;
};

inline uint qHash(const ApplicationEntry &key, uint seed) {
    return ApplicationEntry::hashAux(key, seed);
}

Q_DECLARE_METATYPE(ApplicationEntry)

#endif //RUNNER_MODEL_CACHARREO_APPLICATIONENTRY_H
