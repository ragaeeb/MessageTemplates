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

    Menu.definition: CanadaIncMenu
    {
        help.imageSource: "images/menu/ic_help.png"
        help.title: qsTr("Help") + Retranslate.onLanguageChanged
        projectName: "message-templates"
        settings.imageSource: "images/menu/ic_settings.png"
        settings.title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    Page
    {
        titleBar: LeftLogoTitleBar {}
        
        Container
        {
            layout: DockLayout {}
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            EmptyDelegate
            {
                id: emptyDelegate
                graphic: "images/empty/mail_help.png"
                
                onImageTapped: {
                    console.log("UserEvent: ConversationsEmptyTapped");
                    accountChoice.expanded = true;
                }
            }
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                AccountsDropDown
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
                
                ProgressDelegate
                {
                    id: progressDelegate
                    
                    onCreationCompleted: {
                        app.loadProgress.connect(onProgressChanged);
                    }
                }
                
                ListView
                {
                    id: listView
                    property variant localization: localizer
                    
                    dataModel: ArrayDataModel {
                        id: adm
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
                    emptyDelegate.labelText = qsTr("No messages found for this account. We are only showing inbound messages. If you would like to show all messages, swipe-down from the top-bezel go to Settings and turn off the 'Show Only Inbound Messages' setting.");
                } else {
                    emptyDelegate.labelText = qsTr("No messages found for this account.");
                }
            }
            
            listView.visible = results.length > 0;
            emptyDelegate.delegateActive = !listView.visible;
        }
    }
}