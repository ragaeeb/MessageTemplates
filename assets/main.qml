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

    Menu.definition: MenuDefinition
    {
        helpAction: HelpActionItem
        {
            property Page helpPage
            
            onTriggered:
            {
                if (!helpPage) {
                    definition.source = "HelpPage.qml"
                    helpPage = definition.createObject();
                }

                navigationPane.push(helpPage);
            }
        }
    }
    
    BasePage
    {
        contentContainer: Container
        {
            topPadding: 10;
            
            Label {
                id: instructions
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.fontSize: FontSize.XXSmall
                textStyle.textAlign: TextAlign.Center
                multiline: true
            }

            ControlDelegate {
                id: progressDelegate
                horizontalAlignment: HorizontalAlignment.Center
                delegateActive: false

                function onProgressChanged(current, total) {
                    delegateActive = current != total;

                    if (delegateActive) {
                        control.value = current;
                        control.toValue = total;
                    }
                }

                onCreationCompleted: {
                    app.loadProgress.connect(onProgressChanged);
                }

                sourceComponent: ComponentDefinition {
                    ProgressIndicator {
                        fromValue: 0
                        horizontalAlignment: HorizontalAlignment.Center
                        state: ProgressIndicatorState.Progress
                    }
                }
            }

            Divider {
                topMargin: 0; bottomMargin: 0;
                visible: !progressDelegate.delegateActive
            }
            
            ListView {
                id: listView
                property variant localization: localizer

                dataModel: ArrayDataModel {
                    id: adm
                }
                
                leadingVisual: DropDown {
                    id: accountChoice
                    title: qsTr("Account") + Retranslate.onLanguageChanged
                    
                    onSelectedValueChanged: {
                        persist.saveValueFor("accountId", selectedValue);
                        app.loadMessages(selectedValue);
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
                            description: ListItemData.text.replace(/\n/g, " ").substr(0, 60) + "..."
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
            var accountKey = persist.getValueFor("accountId");
            app.accountsImported.connect(onAccountsImported);
            app.messagesImported.connect(onMessagesImported);

            app.loadAccounts();

            if (!accountKey) {
                instructions.text = qsTr("Select which account to load messages for.");
            } else {
                instructions.text = qsTr("Tap on a message to reply to it with a template.");
            }
        }
        
        function onAccountsImported(results)
        {
            var accountId = persist.getValueFor("accountId");

            for (var i = 0; i < results.length; i++)
            {
                var current = results[i];
                var option = optionDefinition.createObject();
                option.text = current.name;
                option.description = current.address;
                option.value = current.accountId;
                option.selected = accountId == current.accountId;

                accountChoice.add(option);
            }
            
            if (!accountId) {
                listView.scrollToPosition(0, ScrollAnimation.None);
                listView.scroll(-100, ScrollAnimation.Smooth);
            } else {
                app.loadMessages(accountKey);
            }
        }
        
        function onMessagesImported(results) {
            adm.clear();
            adm.append(results);
        }
        
        attachedObjects: [
            ComponentDefinition
            {
                id: optionDefinition
                
                Option {
                    imageSource: "images/ic_account.png"
                }
            }
        ]
    }
}