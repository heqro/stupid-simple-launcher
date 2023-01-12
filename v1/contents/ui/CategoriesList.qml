import QtQuick 2.4

import org.kde.plasma.components 2.0    as PlasmaComponents
import org.kde.plasma.components 3.0    as PlasmaComponents3
import org.kde.plasma.extras 2.0        as PlasmaExtras

import QtQml.Models 2.4

PlasmaComponents3.ScrollView { // dedicated to storing the categories list

    visible: categoriesModel.count > 0

    ListView {

        id: categoriesList

        width: categoriesSidebarWidth
        height: parent.height

        model: ObjectModel {
            id: categoriesModel
        }

        // only add some fancy spacing between the buttons if they are only icons.
        //spacing: showCategoriesIcon ? units.iconSizes.small : 0

        // the following lines help maintaining consistency in highlighting with respect to whatever you have set in your Plasma Style. (This is taken from ItemGridDelegate.qml)
        highlight: PlasmaExtras.Highlight {}
        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0

        CategoryButtonFactory {
            id: factory
        }

        Connections {
            id: rootModelCategoryConnections
            target: rootModel

            function onCountChanged() { // make sure categories are only updated when rootModel really changes (to avoid repeating the same calculation when it's not needed)
                categoriesList.updateCategories()
            }
        }

        function updateCategories() { // build categoriesModel

            function addToModel(modelKey, indexInCategoriesModel) { // generic append function
                const object = factory.createCategoryButton(modelKey, indexInCategoriesModel)
                categoriesModel.append(object)
                object.changeCategoryRequested.connect(changeCategory)
            }

            function addFavoritesToModel() {
                // manually create favorites category button (because this info cannot be reached with the rest of the tools)
                const object = factory.createHandmadeCategoryButton(-1, i18n("Favorites"), "favorite")
                categoriesModel.append(object)
                object.changeCategoryRequested.connect(changeCategory)
            }

            function changeCategory(indexInRootModel, indexInCategoriesList) {
                searchField.unfocus()
                appsGridLoader.item.changeCategory(indexInRootModel)
                appsGridLoader.item.highlightItemAt(0, 0)
                categoriesList.currentIndex = indexInCategoriesList
            }

            function addMetaCategoriesToModel() { // sui generis append function to add hard-coded categories (Favorites, Recent Docs, Recent Apps)
                addToModel(1, -2) // add recent documents
                addToModel(0, -3) // add recent applications
            }


            categoriesModel.clear() // preemptive action

            if (!showCategories) return

            var categoryStartIndex = rootModel.showRecentDocs + rootModel.showRecentApps // rootModel adds recent docs and recent apps to the very start of it. We skip these metacategories (if they are to be present) to add them right after "All applications".
            var categoryEndIndex = rootModel.count


            addToModel(categoryStartIndex, categoryStartIndex) // manually add "All apps" category (to make sure the meta-categories & favorites are added right after it)
            addFavoritesToModel()
            addMetaCategoriesToModel()
            for (let i = categoryStartIndex + 1; i < categoryEndIndex; i++) // add the rest of "normal" categories
                addToModel(i, i)

            // visual band-aid that corrects a way ListView could start visually collapsing items
            for(let step=0; step < categoriesList.count; step++) {
                categoriesList.positionViewAtIndex(step, ListView.Visible)
            }
            categoriesList.positionViewAtBeginning()
        }

    }

    function updateCategories() {
        categoriesList.updateCategories()
    }

    function setCurrentIndex(index) {
        categoriesList.currentIndex = index
    }

    function positionViewAtBeginning() {
        categoriesList.positionViewAtBeginning()
    }
}
