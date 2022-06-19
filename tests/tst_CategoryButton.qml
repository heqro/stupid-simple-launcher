import QtQuick 2.7
import QtTest 1.2

import org.kde.plasma.core 2.0

import "../contents/ui"

Rectangle {
    width: 700
    height: 300
    color: theme.backgroundColor

    property Component categoryComponent;
    property CategoryButton button;

    SignalSpy {
        id: changeCategorySpy
    }

    function createUnbindedCategory() { // creates category without any bindings
        const button = categoryComponent.createObject(parent,
        {
            appsGridModelKey: -5, // stub model key
            categoryName: 'Dummy category',
            customizeCategoriesFontSize: false,
            buttonHeight: 50,
            buttonWidth: 250,
            showCategoriesIcon: false,
            showCategoriesText: false,
            showCategoriesIconAndText: true,
            showCategoriesOnTheRight: true,
            showCategoriesTooltip: false,
            categoriesListCurrentIndex: -1,// stub the category button being in an actual ListView
            indexInCategoriesList: 0,      // stub the category button being in an actual ListView
        })
        button.setSourceIcon('favorite')
        return button
    }

    TestCase {

        name: "ootb attributes"
        when: windowShown

        function test_visibilityFlags() { // checks for correct visibility
                // given
            categoryComponent = Qt.createComponent("../contents/ui/CategoryButton.qml")
                // when
            button = createUnbindedCategory()
                //then
            verify(button.isIconVisible() && button.isTextVisible(), 'Icon & text are visible')
            button.showCategoriesIcon =         true
            button.showCategoriesText =         false
            button.showCategoriesIconAndText =  false
            verify(button.isIconVisible() && !button.isTextVisible(), 'Only the icon is visible')
            button.showCategoriesIcon =         false
            button.showCategoriesText =         true
            button.showCategoriesIconAndText =  false
            verify(!button.isIconVisible() && button.isTextVisible(), 'Only the text is visible')
            button.destroy(0)
        }

        function test_layoutDirection() {
                // given
            categoryComponent = Qt.createComponent("../contents/ui/CategoryButton.qml")
                // when
            button = createUnbindedCategory()
                // then
            verify(button.getLayoutDirection() == Qt.RightToLeft, "Elements are correctly aligned when on the right side")
            button.showCategoriesOnTheRight = false
            verify(button.getLayoutDirection() == Qt.LeftToRight, "Elements are correctly aligned when on the left side")
            button.destroy(0)
        }

        function test_dimensions() { // checks for correct height and width
                // given
            categoryComponent = Qt.createComponent("../contents/ui/CategoryButton.qml")
                // when
            button = createUnbindedCategory()
                // then
            verify(button.height == button.buttonHeight && button.width == button.buttonWidth, 'The button height of a visible category should equal buttonHeight. Width should also be buttonWidth.')
            button.visible = false
            verify(button.height == 0 && button.width == button.buttonWidth, 'The button height of an invisible category be zero. Width should remain.')
            button.destroy(0)
        }
    }

    TestCase {
        name: 'mouse input -> basic functionality'
        when: windowShown

        function test_opacity() { // verifies a change in opacity when the user hovers on the category (thus ensuring the design is responsive)
            // given
            categoryComponent = Qt.createComponent("../contents/ui/CategoryButton.qml")
            // when
            button = createUnbindedCategory()

            const dummyRec = Qt.createQmlObject("
                import QtQuick 2.0

                Rectangle {
                color: 'red'
                anchors.leftMargin: 400
                anchors.left: parent.left
                width: 20
                height: 20
                }
                ",
                button.parent)

            const oldOpacity = button.opacity
            mouseMove(button)
            const newOpacity = button.opacity
            // then
            verify(oldOpacity != newOpacity, 'Opacity should differ to show responsiveness.')

            mouseClick(dummyRec) // move the mouse somewhere away from the category button
            wait(100) // wait for the mouseClick to work and for the opacity to be updated
            verify(oldOpacity == button.opacity, 'Opacity should be restored when the mouse leaves the category button region.')
            dummyRec.destroy(0)
            button.destroy(0)
        }

        function test_changeCategory() {
            // given
            categoryComponent = Qt.createComponent("../contents/ui/CategoryButton.qml")
            // when
            button = createUnbindedCategory()
            // then
            changeCategorySpy.target = button
            changeCategorySpy.signalName = 'changeCategoryRequested'
            mouseClick(button)
            verify(changeCategorySpy.count == 1, 'Only a signal should have been emitted')
            verify(changeCategorySpy.signalArguments[0][0] == button.appsGridModelKey && changeCategorySpy.signalArguments[0][1] == button.indexInCategoriesList, 'Verify signal parameters are right')
            button.destroy(0)
        }
    }
    TestCase {
        name: 'mouse input -> tooltips'
        when: windowShown
        function test_activity() {
            // given
            categoryComponent = Qt.createComponent("../contents/ui/CategoryButton.qml")
            // when
            button = createUnbindedCategory()
            // then
            // 1. verify tool-tip is active when it should be ootb
            verify(!button.isTooltipActive(), 'Tooltip shouldn\'t be active')
            button.showCategoriesTooltip = true
            verify(!button.isTooltipActive(), 'Tooltip should still not be active (there is enough room)')

            // 2. Verify tool-tips are shown with icons and showCategoriesTooltip == true
            button.showCategoriesIcon =  true
            button.showCategoriesText = false
            button.showCategoriesIconAndText =  false
            verify(button.isTooltipActive(), 'Tooltip should be active now (icons-only design)')

            // 3. Verify tool-tips are shown when the text is long enough
            button.categoryName = "Some extremely looooooooooooooooooong name"
            button.showCategoriesText = true
            button.showCategoriesIcon = false
            button.showCategoriesIconAndText =  false
            verify(button.isTooltipActive(), 'Tooltip should be active (text is long enough)')

            // 4. Verify showCategoriesTooltip is an effective kill-switch -for tool-tips

            button.showCategoriesTooltip = false
            verify(!button.isTooltipActive(), 'Tooltip should not be active with a long text (tooltip is set not to show)')

            button.destroy(0)

        }
    }
}
