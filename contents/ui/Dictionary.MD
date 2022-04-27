# `if rootModel.showRecentApps == false` and you didn't add new entries to the menu...
* All applications:     `rootModel.modelForRow(0).modelForRow(1)`
* Favorites:            `rootModel.modelForRow(0).modelForRow(0)`
* Development:          `rootModel.modelForRow(1).modelForRow(0)`
* Education:            `rootModel.modelForRow(2).modelForRow(0)`
* Games:                `rootModel.modelForRow(3).modelForRow(0)`
* Graphics:             `rootModel.modelForRow(4).modelForRow(0)`
* Internet:             `rootModel.modelForRow(5).modelForRow(0)`
* Multimedia: ...       `rootModel.modelForRow(6).modelForRow(0)`
* Office:         ...   `rootModel.modelForRow(7).modelForRow(0)`
* Science & Math: ...   `rootModel.modelForRow(8).modelForRow(0)`
* Settings:       ...   `rootModel.modelForRow(9).modelForRow(0)`
* Utilities   :   ...   `rootModel.modelForRow(10).modelForRow(0)`

`else`, the first `modelForRow` sentence's index has to be increased by one. And "All applications" go idk where.

rootModel's own functions:

objectNameChanged
dataChanged
headerDataChanged
layoutChanged
layoutAboutToBeChanged
rowsAboutToBeInserted
rowsInserted
rowsAboutToBeRemoved
rowsRemoved
columnsAboutToBeInserted
columnsInserted
columnsAboutToBeRemoved
columnsRemoved
modelAboutToBeReset
modelReset
rowsAboutToBeMoved
rowsMoved
columnsAboutToBeMoved
columnsMoved
submit
revert
resetInternalData
hasIndex
index
parent
sibling
rowCount
columnCount
hasChildren
data
setData
headerData
fetchMore
canFetchMore
flags
match
descriptionChanged
countChanged
separatorCountChanged
iconSizeChanged
favoritesModelChanged
trigger
refresh
labelForRow
modelForRow
rowForModel
cleared
autoPopulateChanged
paginateChanged
pageSizeChanged
flatChanged
sortedChanged
showSeparatorsChanged
showTopLevelItemsChanged
appNameFormatChanged
appletInterfaceChanged
hiddenEntriesChanged
refreshed
systemFavoritesModelChanged
showAllAppsChanged
showAllAppsCategorizedChanged
showRecentAppsChanged
showRecentDocsChanged
showRecentContactsChanged
showPowerSessionChanged
recentOrderingChanged
recentAppsModelChanged
showFavoritesPlaceholderChanged


rootModel's own properties:
objectName
description
count
separatorCount
iconSize
favoritesModel
autoPopulate
paginate
pageSize
flat
sorted
showSeparators
showTopLevelItems
appNameFormat
appletInterface




runnerModel's own functions & properties:
qml: objectName:
qml: count: 0
qml: favoritesModel: KAStatsFavoritesModel(0x561f072ca6f0)
qml: appletInterface: AppletInterface(0x561f07455a70)
qml: runners: services
qml: query:
qml: mergeResults: false
qml: deleteWhenEmpty: false
qml: objectNameChanged: function() { [native code] }
qml: dataChanged: function() { [native code] }
qml: headerDataChanged: function() { [native code] }
qml: layoutChanged: function() { [native code] }
qml: layoutAboutToBeChanged: function() { [native code] }
qml: rowsAboutToBeInserted: function() { [native code] }
qml: rowsInserted: function() { [native code] }
qml: rowsAboutToBeRemoved: function() { [native code] }
qml: rowsRemoved: function() { [native code] }
qml: columnsAboutToBeInserted: function() { [native code] }
qml: columnsInserted: function() { [native code] }
qml: columnsAboutToBeRemoved: function() { [native code] }
qml: columnsRemoved: function() { [native code] }
qml: modelAboutToBeReset: function() { [native code] }
qml: modelReset: function() { [native code] }
qml: rowsAboutToBeMoved: function() { [native code] }
qml: rowsMoved: function() { [native code] }
qml: columnsAboutToBeMoved: function() { [native code] }
qml: columnsMoved: function() { [native code] }
qml: submit: function() { [native code] }
qml: revert: function() { [native code] }
qml: resetInternalData: function() { [native code] }
qml: hasIndex: function() { [native code] }
qml: index: function() { [native code] }
qml: parent: function() { [native code] }
qml: sibling: function() { [native code] }
qml: rowCount: function() { [native code] }
qml: columnCount: function() { [native code] }
qml: hasChildren: function() { [native code] }
qml: data: function() { [native code] }
qml: setData: function() { [native code] }
qml: headerData: function() { [native code] }
qml: fetchMore: function() { [native code] }
qml: canFetchMore: function() { [native code] }
qml: flags: function() { [native code] }
qml: match: function() { [native code] }
qml: countChanged: function() { [native code] }
qml: favoritesModelChanged: function() { [native code] }
qml: appletInterfaceChanged: function() { [native code] }
qml: runnersChanged: function() { [native code] }
qml: queryChanged: function() { [native code] }
qml: mergeResultsChanged: function() { [native code] }
qml: deleteWhenEmptyChanged: function() { [native code] }
qml: modelForRow: function() { [native code] }

CODE:
for (var p in item)
    console.log(p + ": " + item[p]);
