// This is an ad hoc to allow creating category buttons in a fast fashion without cluttering MenuRepresentation.qml's code.

import QtQuick 2.0

import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
// for using the button itself
import org.kde.plasma.components 2.0 as PlasmaComponents
// for using RowLayout
import QtQuick.Layouts 1.1

Item {
    property Component component

    function createComponent() {
        component = Qt.createComponent("CategoryButton.qml")
    }

    function getModelIndex(modelKey) {
        return rootModel.index(modelKey,0)
    }
    function getCategoryName(modelKey) {
        return rootModel.data(getModelIndex(modelKey), Qt.DisplayRole)
    }

    function getCategoryIcon(modelKey) {
        return rootModel.data(getModelIndex(modelKey), Qt.DecorationRole)
    }

    function createCategoryButton(modelKey, indexInCategoriesModel) { // you always want to be using this function if you can - less painful route
        return createHandmadeCategoryButton(indexInCategoriesModel, getCategoryName(modelKey), getCategoryIcon(modelKey))
    }

    function createHandmadeCategoryButton(appsGridModelKey, categoryName, categoryIcon) { // function more difficult to operate - you want to use createCategoryButton unless you want to add the favorites category, which is not really a category per se and must always go through this route instead
        if (!component) createComponent()
        const categoryButton =  component.createObject(parent,
        {
            appsGridModelKey: appsGridModelKey,
            categoryName: categoryName,
            customizeCategoriesFontSize: Qt.binding(
                function() {
                    return plasmoid.configuration.customizeCategoriesFontSize
                }),
            categoriesFontSize: Qt.binding(
                function() {
                    return plasmoid.configuration.categoriesFontSize
                }),
            buttonHeight: Qt.binding(
                function() {
                    return plasmoid.configuration.categoriesButtonHeight
                }),
            buttonWidth: Qt.binding(
                function() {
                    return plasmoid.configuration.categoriesButtonWidth
                }),
            showCategoriesIcon: Qt.binding(
                function() {
                    return plasmoid.configuration.categoriesIcon
                }),
            showCategoriesIconAndText: Qt.binding(
                function() {
                    return plasmoid.configuration.categoriesIconAndText
                }),
            showCategoriesText: Qt.binding(
                function() {
                    return plasmoid.configuration.categoriesText
                }),
            showCategoriesOnTheRight: Qt.binding(
                function() {
                    return plasmoid.configuration.showCategoriesOnTheRight
                }),
            showCategoriesTooltip: Qt.binding(
                function() {
                    return plasmoid.configuration.showCategoriesTooltip
                }),
            categoriesListCurrentIndex: Qt.binding(
                function() {
                    return categoriesList.currentIndex
                }),
            indexInCategoriesList: categoriesModel.count,
            visible: Qt.binding(
                function() {
                    switch(appsGridModelKey) {
                        case -1: return plasmoid.configuration.showFavoritesCategory // Favorites are hard-tagged as index -1
                        case -2: return plasmoid.configuration.showRecentAppsCategory // Recent documents are hard-tagged as index -2
                        case -3: return plasmoid.configuration.showRecentFilesCategory // Recent Applications are hard-tagged as index -3
                        default: return true // Generic category or All applications
                    }
                }
            ),
        })
        categoryButton.setSourceIcon(categoryIcon)
        return categoryButton
    }
}
