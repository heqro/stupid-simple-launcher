import QtQuick 2.0
import QtTest 1.2

import "../contents/ui"
import org.kde.kcoreaddons 1.0 as KCoreAddons

Rectangle {
    width: 700
    height: 300
    color: "white"

    KCoreAddons.KUser { // this is needed for the greeting message (saying hello whatever the user name is)
        id: kuser
    }

    TestCase {
        name: "Focus test for basic designs"
        when: windowShown
        function test_createBasicDesigns() {
            const greet = "Some text"
            const component = Qt.createComponent("../contents/ui/SearchBar.qml");
            const designs = [
                "",
                "../ui/searchbar_designs/Underlining.qml",
                "../ui/searchbar_designs/FullyFledged.qml",
                "../ui/searchbar_designs/MaterialOutlined.qml",
            ]

            if (component.status == Component.Error)
                fail(component.errorString())

            for (const path of designs) {
                let searchBar = component.createObject(parent,
                    {
                        writeSomething: true,
                        greetingText: "Some text",
                        searchBarDesign: path,
                        searchBarOpacity: 10,
                    });
                searchBar.anchors.centerIn = parent

                verify(searchBar.placeholderText == searchBar.greetingText, "placeholderText is equals to Some text for design " + searchBar.searchBarDesign)

                searchBar.writeSomething = false

                verify(searchBar.placeholderText == "Howdy, " + kuser.loginName + "! Type to start searching...", "placeholderText is equals to Some text for design " + searchBar.searchBarDesign)

                verify(!searchBar.isSearchBarFocused, "SearchBar is not focused")
                mouseClick(searchBar)
                verify(searchBar.isSearchBarFocused, "SearchBar is focused")
                searchBar.toggleFocus()
                verify(!searchBar.isSearchBarFocused, "SearchBar is not focused anymore")
                searchBar.toggleFocus()
                verify(searchBar.isSearchBarFocused, "SearchBar is focused again")

                searchBar.destroy(0) // immediately destroy
            }
        }

        function test_createModernComfy() {
            const greet = "Some text"
            const component = Qt.createComponent("../contents/ui/SearchBar.qml");
            const path = "../ui/searchbar_designs/ModernComfy.qml"

            if (component.status == Component.Error)
                fail(component.errorString())

            const searchBar = component.createObject(parent,
                            {
                                writeSomething: true,
                                greetingText: "Some text",
                                searchBarDesign: path,
                                searchBarOpacity: 10,
                            });

            searchBar.anchors.centerIn = parent

            verify(searchBar.placeholderText == "","placeholderText should be empty with writeSomething = true ")

            searchBar.writeSomething = false

            verify(searchBar.placeholderText == "", "placeholderText should be empty with writeSomething = false")

            verify(!searchBar.isSearchBarFocused, "SearchBar is not focused")

            mouseClick(searchBar)
            verify(searchBar.isSearchBarFocused, "SearchBar is focused")
            searchBar.toggleFocus()
            verify(!searchBar.isSearchBarFocused, "SearchBar is not focused anymore")
            searchBar.toggleFocus()
            verify(searchBar.isSearchBarFocused, "SearchBar is focused again")

            searchBar.toggleFocus()

            // Design testing: searchIconContainer (now not focused)
            mouseClick(searchBar.design.item.searchIconCircle)
            verify(searchBar.isSearchBarFocused, "SearchBar is focused by clicking in the built-in design button")
            wait(500) // wait because the test fucking blows up if we don't
            mouseClick(searchBar.design.item.searchIconCircle)


            verify(!searchBar.isSearchBarFocused, "SearchBar loses focus by clicking in the built-in design button")

            searchBar.destroy(0) // immediately destroy

        }

    }

}
