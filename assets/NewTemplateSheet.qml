import bb.cascades 1.0
import bb.system 1.0

Sheet
{
    id: root
    
    Page
    {
        titleBar: TitleBar
        {
            title: qsTr("New Template") + Retranslate.onLanguageChanged
            
            acceptAction: ActionItem
            {
                id: saveAction
                imageSource: "images/dropdown/ic_save.png"
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
            
            dismissAction: ActionItem
            {
                imageSource: "images/dropdown/ic_close.png"
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
        
        if ( tutorialToast.tutorial( "tutorialNewTemplateInfo", qsTr("Each template consists of a title and body. In this screen simply type the body and hit 'Save' which will prompt you to enter a title."), "images/menu/ic_new_template.png" ) ) {}
        else if ( tutorialToast.tutorial( "tutorialBodyInfo", qsTr("You can make the body of the message as long as you want. But just keep in mind that SMS messages can only be sent 160 characters max per message."), "images/menu/ic_new_template.png" ) ) {}
    }
    
    onClosed: {
        destroy();
    }
}