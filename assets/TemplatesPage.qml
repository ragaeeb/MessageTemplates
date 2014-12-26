import bb.cascades 1.0

Page
{
    id: root
    property variant accountId
    property variant message
    
    actions: [
        ActionItem {
            id: newTemplateAction
            title: qsTr("New Template") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_new_template.png"
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar

            onTriggered: {
                console.log("UserEvent: NewTemplateAction");
                var sheet = sheetDefinition.createObject();
                sheet.open();
            }
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            attachedObjects: [
                ComponentDefinition {
                    id: sheetDefinition
                    source: "NewTemplateSheet.qml"
                }
            ]
        },

        DeleteActionItem
        {
            id: clearAllAction
            imageSource: "images/menu/ic_clear_templates.png"
            title: qsTr("Delete All") + Retranslate.onLanguageChanged

            onTriggered: {
                console.log("UserEvent: DeleteAllTemplates");
                var ok = persist.showBlockingDialog( qsTr("Confirmation"), qsTr("Are you sure you want to delete all the templates?") );
                console.log("UserEvent: ClearTemplatesConfirm", ok);
                
                if (ok) {
                    persist.remove("templates");
                    tutorialToast.init( qsTr("Cleared all templates!"), "images/menu/ic_clear_templates.png" );
                }
            }
        }
    ]
    
    titleBar: TitleBar {
        title: qsTr("Select Template") + Retranslate.onLanguageChanged
        
        acceptAction: ActionItem
        {
            id: acceptAction
            enabled: toUse.visible
            imageSource: "images/menu/ic_accept.png"
            title: qsTr("Accept") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: AcceptTemplates");
                
                var all = [];
                var n = selectionModel.size();
                
                for (var i = 0; i < n; i++) {
                    all.push( selectionModel.value(i).message );
                }
                
                app.processReply(accountId, message, all);
            }
        }
    }

    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        EmptyDelegate
        {
            id: emptyDelegate
            graphic: "images/empty/empty_templates.png"
            labelText: qsTr("No templates saved. Click on the 'New Template' action below to create one.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                console.log("UserEvent: EmptyTemplatesTapped");
                newTemplateAction.triggered();
            }
        }
        
        Container
        {
            id: listViewContainer
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            EmptyDelegate
            {
                id: allUsedDelegate
                graphic: "images/empty/all_templates_used.png"
                labelText: qsTr("You have used up all the templates. Tap on one of the templates below to bring it back for reuse.") + Retranslate.onLanguageChanged
            }
            
            ListView
            {
                id: listView
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                function performDelete(indexPath)
                {
                    var templates = persist.getValueFor("templates");
                    var target = dataModel.data(indexPath);
                    
                    for (var i = templates.length-1; i >= 0; i--)
                    {
                        var current = templates[i];
                        
                        if (current.name == target.name && current.message == target.message) {
                            templates.splice(i,1);
                            break;
                        }
                    }
                    
                    persist.saveValueFor("templates", templates);
                    tutorialToast.init( qsTr("Removed template!"), "images/menu/ic_delete_template.png" );
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        StandardListItem
                        {
                            id: rootItem
                            title: ListItemData.name
                            description: ListItemData.message.replace(/\n/g, " ").substr(0, 60) + "..."
                            imageSource: "images/ic_template.png"
                            
                            contextActions: [
                                ActionSet
                                {
                                    title: rootItem.title
                                    subtitle: rootItem.description
                                    
                                    DeleteActionItem
                                    {
                                        imageSource: "images/menu/ic_delete_template.png"
                                        
                                        onTriggered: {
                                            console.log("UserEvent: DeleteTemplate");
                                            rootItem.ListItem.view.performDelete(rootItem.ListItem.indexPath);
                                        }
                                    }
                                }
                            ]
                        }
                    }
                ]
                
                onTriggered: {
                    console.log("UserEvent: TemplateSelected");
                    
                    var data = dataModel.data(indexPath);
                    selectionModel.append(data);
                    dataModel.removeAt(indexPath[0]);
                    
                    toUse.visible = true;
                    allUsedDelegate.delegateActive = adm.isEmpty();
                    listView.visible = !allUsedDelegate.delegateActive;
                    selectedHeader.subtitle = selectionModel.size();
                }
            }
            
            ImageView
            {
                visible: toUse.visible
                topMargin: 0; bottomMargin: 0
                imageSource: "images/header_divider.png"
                horizontalAlignment: HorizontalAlignment.Center
            }
            
            Header {
                id: selectedHeader
                visible: toUse.visible
                title: qsTr("Selected Templates to Use for Reply") + Retranslate.onLanguageChanged
            }
            
            ListView
            {
                id: toUse
                visible: false
                
                dataModel: ArrayDataModel {
                    id: selectionModel
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        StandardListItem
                        {
                            id: rootItem2
                            title: "[%1] %2".arg(ListItem.indexPath[0]+1).arg(ListItemData.name)
                            description: ListItemData.message.replace(/\n/g, " ").substr(0, 60) + "..."
                            imageSource: "images/ic_template.png"
                        }
                    }
                ]
                
                onTriggered: {
                    console.log("UserEvent: UsedTemplateSelected");
                    
                    var data = dataModel.data(indexPath);
                    adm.append(data);
                    selectionModel.removeAt(indexPath[0]);
                    
                    allUsedDelegate.delegateActive = adm.isEmpty();
                    toUse.visible = !selectionModel.isEmpty();
                    selectedHeader.subtitle = selectionModel.size();
                }
            }
        }
    }
    
    function updatePlaceholder(key)
    {
        if (key == "templates")
        {
            var templates = persist.getValueFor("templates");
            
            if (!templates) {
                templates = [];
            }
            
            adm.clear();
            
            if ( selectionModel.size() > 0 )
            {
                var n = templates.length;
                
                for (var i = 0; i < n; i++)
                {
                    var current = templates[i];
                    
                    for (var j = selectionModel.size()-1; j >= 0; j--)
                    {
                        var stored = selectionModel.value(j);

                        if (current.name != stored.name && current.message != stored.message) {
                            adm.append(current);
                        }
                    }
                }
            } else {
                adm.append(templates);
            }
            
            emptyDelegate.delegateActive = adm.isEmpty();
            listViewContainer.visible = !emptyDelegate.delegateActive;
            
            if ( tutorialToast.tutorial( "tutorialTemplatesPage", qsTr("You can create customized templates here. Once you create one you can tap on it to reply to the selected message with."), "images/menu/ic_new_template.png" ) ) {}
            else if ( tutorialToast.tutorial( "tutorialDeleteTemplate", qsTr("Deleting templates are really easy! Simply press-and-hold on the list item and from the menu choose 'Delete'"), "images/menu/ic_delete_template.png" ) ) {}
            else if ( tutorialToast.tutorial( "tutorialClearTemplates", qsTr("If you want to delete all the templates in one shot, tap on the '...' to expand the menu and choose 'Delete All'."), "images/menu/ic_clear_templates.png" ) ) {}
        }
    }
    
    onCreationCompleted: {
        updatePlaceholder("templates");
        persist.settingChanged.connect(updatePlaceholder);
    }
}