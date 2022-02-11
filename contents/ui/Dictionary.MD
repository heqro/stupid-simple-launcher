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
