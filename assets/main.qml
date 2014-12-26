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
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: TitleBar
        {
            kind: TitleBarKind.FreeForm
            kindProperties: FreeFormTitleBarKindProperties
            {
                Container
                {
                    id: titleBar
                    layout: DockLayout {}
                    
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Top
                    
                    ImageView {
                        id: bgImageView
                        imageSource: "images/title_bg.png"
                        topMargin: 0
                        leftMargin: 0
                        rightMargin: 0
                        bottomMargin: 0
                        
                        horizontalAlignment: HorizontalAlignment.Fill
                    }
                    
                    Container
                    {
                        verticalAlignment: VerticalAlignment.Center
                        leftPadding: 20
                        
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        
                        ImageView {
                            id: logoView
                            imageSource: "images/logo.png"
                            topMargin: 0
                            leftMargin: 0
                            rightMargin: 0
                            bottomMargin: 0
                            verticalAlignment: VerticalAlignment.Center
                        }
                        
                        ImageView {
                            id: titleText
                            imageSource: "images/title_text.png"
                            topMargin: 0
                            leftMargin: 0
                            rightMargin: 0
                            bottomMargin: 0
                            verticalAlignment: VerticalAlignment.Center
                        }
                        
                        animations: [
                            ParallelAnimation {
                                id: translateFade
                                
                                FadeTransition {
                                    easingCurve: StockCurve.CubicIn
                                    fromOpacity: 0
                                    toOpacity: 1
                                    duration: 1000
                                }
                                
                                TranslateTransition {
                                    toX: 0
                                    fromX: -300
                                    duration: 1000
                                }
                            }
                        ]
                        
                        onCreationCompleted: {
                            translateFade.play();
                        }
                    }
                }
                
                expandableArea
                {
                    expanded: true
                    
                    content: Container
                    {
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        leftPadding: 10; rightPadding: 10; topPadding: 5
                        
                        AccountsDropDown
                        {
                            id: accountChoice
                            selectedAccountId: persist.getValueFor("accountId")
                            
                            onAccountsLoaded: {
                                if (numAccounts == 0) {
                                    persist.showToast( qsTr("No accounts found. Did you find forget to enable permissions?"), "", "asset:///images/dropdown/ic_account.png" );
                                }
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
                        
                        Slider {
                            value: persist.getValueFor("days")
                            horizontalAlignment: HorizontalAlignment.Fill
                            fromValue: 1
                            toValue: 30
                            
                            onValueChanged: {
                                var actualValue = Math.floor(value);
                                var changed = persist.saveValueFor("days", actualValue, false);
                                
                                if (accountChoice.selectedOption != null)
                                {
                                    if (changed) {
                                        accountChoice.reloadMessages("onlyInbound");
                                    }
                                }
                            }
                        }
                        
                        ImageView
                        {
                            topMargin: 0; bottomMargin: 0
                            imageSource: "images/divider_threshold.png"
                            horizontalAlignment: HorizontalAlignment.Center
                        }
                    }
                }
            }
        }
        
        Container
        {
            layout: DockLayout {}
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
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
                                description: ListItemData.text ? ListItemData.text.trim().replace(/\n/g, " ").substr(0, 80) + "..." : ""
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
            
            EmptyDelegate
            {
                id: emptyDelegate
                graphic: "images/empty/mail_help.png"
                
                onImageTapped: {
                    console.log("UserEvent: ConversationsEmptyTapped");
                    accountChoice.expanded = true;
                }
            }
            
            PermissionToast
            {
                id: tm
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
                labelColor: Color.Black
                
                function onReady()
                {
                    var allMessages = [];
                    var allIcons = [];
                    
                    if ( !persist.hasEmailSmsAccess() ) {
                        allMessages.push("Warning: It seems like the app does not have access to your Email/SMS messages Folder. This permission is needed for the app to access the SMS and emails to be able to reply to them with the appropriate templates.");
                        allIcons.push("images/toast/mail_warning.png");
                    }
                    
                    if (allMessages.length > 0)
                    {
                        messages = allMessages;
                        icons = allIcons;
                        delegateActive = true;
                    } else {
                        if ( tutorialToast.tutorial( "tutorialAccounts", qsTr("You can change the list of messages you see by changing the account using the dropdown! Simply tap on the dropdown at the top to expand it and switch accounts."), "images/dropdown/ic_account.png" ) ) {
                            accountChoice.expanded = true;
                        }
                        
                        else if ( tutorialToast.tutorial( "tutorialSMS", qsTr("If you want to reply to a SMS messages, simply tap on the dropdown at the top and choose the 'SMS' account."), "images/dropdown/ic_sms.png" ) ) {}
                        else if ( tutorialToast.tutorial( "tutorialWelcome", qsTr("In this main screen you can tap on the email that you want to reply with a template with."), "images/ic_email.png" ) ) {}
                        else if ( tutorialToast.tutorial( "tutorialThreshold", qsTr("Use the slider at the top to increase or decrease the number of days worth of messages to fetch. The maximum is 30 days and the minimum is 1 day."), "images/empty/mail_help.png" ) ) {}
                        else if ( tutorialToast.tutorial( "tutorialFastLoad", qsTr("If you want to speed up load times of this screen, decrease the threshold slider at the top to 1 day only and you will be able to get the latest messages to reply to."), "images/menu/ic_help.png" ) ) {}
                        else if ( tutorialToast.tutorial( "tutorialSettings", qsTr("To customize settings in the app, swipe-down from the top-bezel and choose 'Settings'."), "images/menu/ic_settings.png" ) ) {}
                        else if ( tutorialToast.tutorial( "tutorialHelp", qsTr("To get additional help about the app and the developers, please swipe-down from the top-bezel and choose 'Help'."), "images/menu/ic_help.png" ) ) {}
                    }
                }
                
                onCreationCompleted: {
                    app.lazyInitComplete.connect(onReady);
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