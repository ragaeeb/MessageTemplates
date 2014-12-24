import bb.cascades 1.0

Page
{
    property variant accountId
    property variant message
    
    actions: [
        ActionItem {
            id: newTemplateAction
            title: qsTr("New Template") + Retranslate.onLanguageChanged
            imageSource: "images/ic_new_template.png"
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
                    persist.remove("templates", false);
                    adm.clear();
                    persist.showToast( qsTr("Cleared all templates!") );
                    updatePlaceholder();
                }
            }
        }
    ]
    
    titleBar: TitleBar {
        title: qsTr("Select Template") + Retranslate.onLanguageChanged
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
                console.log("UserEvent: Empty Templates Triggered");
                newTemplateAction.triggered();
            }
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
                templates.splice(indexPath[0], 1);
                persist.saveValueFor("templates", templates);

                adm.removeAt( indexPath[0] );
                updatePlaceholder();
                
                persist.showToast( qsTr("Removed template!"), "", "asset:///images/menu/ic_delete_template.png" );
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
                            ActionSet {
                                title: rootItem.title
                                subtitle: rootItem.description

                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_delete_template.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: DeleteTemplate");
                                        itemDeletedAnim.play();
                                    }
                                }
                            }
                        ]
                        
                        animations: [
                            ScaleTransition {
                                id: itemDeletedAnim
                                fromX: 1
                                toX: 0
                                duration: 500
                                easingCurve: StockCurve.QuarticInOut
                                onEnded: {
                                    rootItem.ListItem.view.performDelete(rootItem.ListItem.indexPath);
                                    rootItem.scaleX = 1;
                                }
                            }
                        ]
                    }
                }
            ]

            onTriggered: {
                console.log("UserEvent: TemplateSelected");
                
                var data = dataModel.data(indexPath);
                app.processReply(accountId, message, data.message);
            }

            function onSettingChanged(key)
            {
                if (key == "templates")
                {
                    adm.clear();
                    
                    var templates = persist.getValueFor("templates");
                    
                    if (templates && templates.length > 0) {
                        adm.append(templates);
                    }
                    
                    updatePlaceholder();
                }
            }

            onCreationCompleted: {
                onSettingChanged("templates");
                persist.settingChanged.connect(onSettingChanged);
            }
        }
    }
    
    function updatePlaceholder()
    {
        emptyDelegate.delegateActive = adm.isEmpty();
        listView.visible = !emptyDelegate.delegateActive;
    }
}