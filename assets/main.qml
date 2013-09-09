import bb.cascades 1.0

NavigationPane
{
    id: navigationPane
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]

    onPopTransitionEnded: {
        page.destroy();
    }

    Menu.definition: CanadaIncMenu {
        projectName: "message-templates"
    }
    
    Page
    {
        titleBar: LeftLogoTitleBar {}
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill

            ProgressDelegate
            {
                id: progressDelegate
                
                onCreationCompleted: {
                    app.loadProgress.connect(onProgressChanged);
                }
            }
            
            ListView {
                id: listView
                property variant localization: localizer

                dataModel: ArrayDataModel {
                    id: adm
                }
                
                leadingVisual: AccountsDropDown
                {
                    id: accountChoice
                    selectedAccountId: persist.getValueFor("accountId")
                    
                    onAccountsLoaded: {
                        listView.scrollToPosition(0, ScrollAnimation.None);
                        listView.scroll(-100, ScrollAnimation.Smooth);
                    }
                    
                    onSelectedValueChanged: {
                        persist.saveValueFor("accountId", selectedValue);
                        reloadMessages("onlyInbound");
                    }
                    
                    function reloadMessages(key)
                    {
                        if (key == "onlyInbound") {
                            app.loadMessages(selectedValue);
                        }
                    }
                    
                    onCreationCompleted: {
                        persist.settingChanged.connect(reloadMessages);
                    }
                }
                
                onTriggered: {
                    definition.source = "TemplatesPage.qml";
                    
                    var data = dataModel.data(indexPath);
                    var page = definition.createObject();
                    page.message = data;
                    page.accountId = accountChoice.selectedValue;

                    navigationPane.push(page);
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        StandardListItem {
                            id: rootItem
                            imageSource: ListItemData.smallPhotoFilepath ? ListItemData.smallPhotoFilepath : "images/ic_email.png"
                            title: ListItemData.sender
                            description: ListItemData.text.replace(/\n/g, " ").substr(0, 80) + "..."
                            status: ListItem.view.localization.renderStandardTime(ListItemData.time)

                            animations: [
                                FadeTransition {
                                    id: slider
                                    fromOpacity: 0
                                    toOpacity: 1
                                    easingCurve: StockCurve.SineInOut
                                    duration: 400
                                }
                            ]
                            
                            onCreationCompleted: {
                                slider.play()
                            }
                        }
                    }
                ]
            }
        }
        
        onCreationCompleted: {
            app.messagesImported.connect(onMessagesImported);
        }
        
        function onMessagesImported(results)
        {
            adm.clear();
            adm.append(results);
            
            if (results.length == 0)
            {
                if ( persist.getValueFor("onlyInbound") == 1 ) {
                    persist.showToast( qsTr("No messages found for this account. We are only showing inbound messages. If you would like to show all messages, swipe-down from the top-bezel go to Settings and turn off the 'Show Only Inbound Messages' setting."), qsTr("OK") );
                } else {
                    persist.showToast( qsTr("No messages found for this account."), qsTr("OK") );
                }
            }
            
            listView.scrollToPosition(0, ScrollAnimation.None);
            listView.scroll(-100, ScrollAnimation.Smooth);
        }
    }
}