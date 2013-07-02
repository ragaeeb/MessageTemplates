import bb.cascades 1.0
import bb.system 1.0

Sheet
{
    id: root
    
    Page
    {
        titleBar: TitleBar {
            acceptAction: ActionItem {
                id: saveAction
                title: qsTr("Save") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    prompt.show();
                }

                attachedObjects: [
                    SystemPrompt {
                        id: prompt
                        title: qsTr("Enter Name") + Retranslate.onLanguageChanged
                        body: qsTr("Enter a name for this template:") + Retranslate.onLanguageChanged
                        confirmButton.label: qsTr("OK") + Retranslate.onLanguageChanged
                        cancelButton.label: qsTr("Cancel") + Retranslate.onLanguageChanged

                        onFinished: {
                            if (result == SystemUiResult.ConfirmButtonSelection) {
                                var name = prompt.inputFieldTextEntry();

                                var templates = persist.getValueFor("templates");

                                if (! templates) {
                                    templates = [];
                                }
                                
                                templates.push( {'name': name, 'message': messageField.text} );
                                persist.saveValueFor("templates", templates);

                                root.close();
                            }
                        }
                    }
                ]
            }
            
            dismissAction: ActionItem {
                title: qsTr("Cancel") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    root.close();
                }
            }
        }
        
        TextArea {
            id: messageField
            backgroundVisible: false
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            hintText: qsTr("Enter your template message here...") + Retranslate.onLanguageChanged
            
            onTextChanging: {
                saveAction.enabled = text.length > 0;
            }
        }
    }
    
    onOpened: {
        messageField.requestFocus();
    }
    
    onClosed: {
        destroy();
    }
}