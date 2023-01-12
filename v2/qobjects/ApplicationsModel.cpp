//
// Created by heqro on 25/12/22.
//

#include <KServiceGroup>
#include "ApplicationsModel.h"
#include "ApplicationEntry.h"

QVariant ApplicationsModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || role != Qt::DisplayRole)
        return {};
    return m_allApplications[index.row()];
}

int ApplicationsModel::rowCount(const QModelIndex &parent) const {
//    return mCategories.length();
    return m_allApplications.length();
}

bool sortVariants(QVariant &a, QVariant &b) {
    auto appA = a.value<ApplicationEntry>();
    auto appB = b.value<ApplicationEntry>();
    return appA < appB;
}

ApplicationsModel::ApplicationsModel() {
    gatherAllApplications();
}

ApplicationEntry ApplicationsModel::getApplicationEntryAt(int index) const {
    return data(createIndex(index, 0), Qt::DisplayRole).value<ApplicationEntry>();
}

void ApplicationsModel::gatherAllApplications() {
    auto group = KServiceGroup::root();
    auto options = QFlags<KServiceGroup::EntriesOption>(KServiceGroup::ExcludeNoDisplay);

    auto categories = group->groupEntries(options);
    QSet<ApplicationEntry> qSet;

    m_allApplications.empty();

    for (const auto &category: categories) {
        for (const auto &app: category->entries()) {
            if (app.constData()->property("Name").toString() != "") {
                ApplicationEntry a(*app.constData());
                if (!qSet.contains(a)) {
                    qSet.insert(a);
                    m_allApplications.push_back(QVariant::fromValue(a));
                }
            }
        }
    }
    std::sort(m_allApplications.begin(), m_allApplications.end(), sortVariants);
    qSet.empty();
}

//ApplicationsModel::ApplicationsModel() {
//    auto group = KServiceGroup::root();
//    auto options = QFlags<KServiceGroup::EntriesOption>(KServiceGroup::ExcludeNoDisplay);
//
//    auto list = group->groupEntries(options);
//    QSet<QApplicationEntry> qSet;
//
//    m_allApplications.empty();
//    const auto allApps = list[0];
//    for (auto& app: allApps->entries()) {
//        if (app.constData()->property("Name").toString() != "") {
////            auto pApplicationEntry = new QApplicationEntry(*apps.constData());
////            if (!qSet.contains(*pApplicationEntry)) {
////                qSet.insert(*pApplicationEntry);
////                categories[i].push_back(pApplicationEntry);
////            }
//        }
//    }
//
//    for (int i = 0; i < list.length(); i++) {
//        auto& category = list[i];
////        mCategories.push_back(QVariant::fromValue())
////        categories.push_back(QList<QApplicationEntry*>());
//        qSet.empty();
//        for (auto &apps: category->entries()) {
//            if (apps.constData()->property("Name").toString() != "") {
//                auto pApplicationEntry = new QApplicationEntry(*apps.constData());
//                if (!qSet.contains(*pApplicationEntry)) {
//                    qSet.insert(*pApplicationEntry);
//                    categories[i].push_back(pApplicationEntry);
//                }
//            }
//        }
//        std::sort(categories[i].begin(), categories[i].end(), comparePointers);
//    }
//    mCategories = categories;
//}
