import bb.cascades 1.0
import bb.system 1.0

Page
{
    property variant accountId
    property variant message
    
    actions: [
        ActionItem {
            title: qsTr("New Template") + Retranslate.onLanguageChanged
            imageSource: "images/ic_new_template.png"
            ActionBar.placement: ActionBarPlacement.OnBar

            onTriggered: {
                var sheet = sheetDefinition.createObject();
                sheet.open();
            }
            
            attachedObjects: [
                ComponentDefinition {
                    id: sheetDefinition
                    source: "NewTemplateSheet.qml"
                }
            ]
        },

        DeleteActionItem {
            id: clearAllAction
            title: qsTr("Delete All") + Retranslate.onLanguageChanged

            onTriggered: {
                prompt.show()
            }

            attachedObjects: [
                SystemDialog {
                    id: prompt
                    title: qsTr("Confirm") + Retranslate.onLanguageChanged
                    body: qsTr("Are you sure you want to delete all the templates?") + Retranslate.onLanguageChanged
                    confirmButton.label: qsTr("Yes") + Retranslate.onLanguageChanged
                    cancelButton.label: qsTr("No") + Retranslate.onLanguageChanged

                    onFinished: {
                        if (result == SystemUiResult.ConfirmButtonSelection) {
                            persist.remove("templates");
                            persist.showToast( qsTr("Cleared all templates!") );
                        }
                    }
                }
            ]
        }
    ]
    
    titleBar: TitleBar {
        title: qsTr("New Template") + Retranslate.onLanguageChanged
    }

    Container
    {
        leftPadding: 10; rightPadding: 10; topPadding: 10
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        
        Label {
            id: instruction
            multiline: true
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.textAlign: TextAlign.Center
            textStyle.fontSize: FontSize.XSmall
        }
        
        Divider {
            topMargin: 0; bottomMargin: 0
        }
        
        ListView {
            dataModel: ArrayDataModel {
                id: adm
            }

            function performDelete(indexPath)
            {
                var templates = persist.getValueFor("templates");

                if (! templates) {
                    templates = [];
                }

                templates.splice(indexPath[0], 1);
                persist.saveValueFor("templates", templates);

                adm.removeAt(indexPath[0]);
            }

            listItemComponents: [
                ListItemComponent {
                    StandardListItem {
                        id: rootItem
                        title: ListItemData.name
                        description: ListItemData.message.replace(/\n/g, " ").substr(0, 60) + "..."
                        imageSource: "images/ic_template.png"

                        contextActions: [
                            ActionSet {
                                title: rootItem.title
                                subtitle: rootItem.description

                                DeleteActionItem {
                                    onTriggered: {
                                        rootItem.ListItem.view.performDelete(rootItem.ListItem.indexPath);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]

            onTriggered: {
                var data = dataModel.data(indexPath);
                app.processReply(accountId, message, data.message);
            }

            function onSettingChanged(key)
            {
                if (key == "templates") {
                    adm.clear();
                    var templates = persist.getValueFor("templates");

                    if (templates && templates.length > 0) {
                        adm.append(templates);
                        clearAllAction.enabled = true;
                        instruction.text = qsTr("Choose which template to reply with:");
                    } else {
                        clearAllAction.enabled = false;
                        instruction.text = qsTr("No templates saved. Click on the 'New Template' action below to create one.");
                    }
                }
            }

            onCreationCompleted: {
                onSettingChanged("templates");
                persist.settingChanged.connect(onSettingChanged);
            }
        }
    }
}