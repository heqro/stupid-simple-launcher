//
// Created by heqro on 26/12/22.
//

#include "ApplicationEntry.h"

ApplicationEntry::ApplicationEntry(const KSycocaEntry& entry) {
    m_entryName = entry.property("Name").isValid() ? entry.property("Name").toString() : "";
    m_iconName = entry.property("Icon").isValid() ? entry.property("Icon").toString() : "";
    m_exec = entry.property("Exec").isValid() ? entry.property("Exec").toString() : "";
    m_comment = entry.property("Comment").isValid() ? entry.property("Comment").toString() : "";
}

bool ApplicationEntry::operator==(const ApplicationEntry &e) const {
    return m_entryName == e.m_entryName && m_iconName == m_iconName;
}

bool ApplicationEntry::operator<(const ApplicationEntry &e) const {
    return m_entryName < e.m_entryName;
}

