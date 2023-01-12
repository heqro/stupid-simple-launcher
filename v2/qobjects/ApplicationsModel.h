#ifndef RUNNER_MODEL_CACHARREO_APPLICATIONSMODEL_H
#define RUNNER_MODEL_CACHARREO_APPLICATIONSMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include "ApplicationEntry.h"

class ApplicationsModel : public QAbstractListModel {
    Q_OBJECT
public:
    ApplicationsModel();
    Q_PROPERTY(QVector<QVariant> allApplications MEMBER m_allApplications)
    Q_INVOKABLE ApplicationEntry getApplicationEntryAt(int index) const;

private:
    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent) const override;

    void gatherAllApplications();

    QVector<QVariant> m_allApplications;
    QVector<QVector<QVariant>> m_categories;
};


#endif //RUNNER_MODEL_CACHARREO_APPLICATIONSMODEL_H
