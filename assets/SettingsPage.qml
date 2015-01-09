import bb.cascades 1.0
import bb.cascades.pickers 1.0

Page
{
    id: settingsPage
    
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    actions: [
        ActionItem
        {
            title: qsTr("Backup") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_backup.png"
            
            onTriggered: {
                console.log("UserEvent: Backup");

                filePicker.title = qsTr("Select Destination");
                filePicker.mode = FilePickerMode.Saver;
                filePicker.defaultSaveFileNames = ["templates_backup.json"]
                filePicker.allowOverwrite = true;
                filePicker.open();
            }
            
            function onSaved(result) {
                tutorialToast.init( qsTr("Successfully backed up to %1").arg( result.substring(15) ), "images/menu/ic_backup.png" );
            }
            
            onCreationCompleted: {
                app.backupComplete.connect(onSaved);
            }
        },
        
        ActionItem
        {
            title: qsTr("Restore") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_restore.png"
            
            onTriggered: {
                console.log("UserEvent: Restore");

                filePicker.title = qsTr("Select File");
                filePicker.mode = FilePickerMode.Picker;
                filePicker.open();
            }
            
            function onRestored(result)
            {
                if (result) {
                    persist.showBlockingDialog( qsTr("Exit"), qsTr("Successfully restored! The app will now close itself so when you re-open it the restored database can take effect!"), qsTr("OK"), "" );
                    Application.quit();
                } else {
                    tutorialToast.init( qsTr("The database could not be restored. Please re-check the backup file to ensure it is valid, and if the problem persists please file a bug report. Make sure to attach the backup file with your report!"), "images/toast/restore_error.png" );
                }
            }
            
            onCreationCompleted: {
                app.restoreComplete.connect(onRestored);
            }
        }
    ]
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        leftPadding: 10
        topPadding: 10
        rightPadding: 10
        bottomPadding: 10
        
        PersistCheckBox
        {
            key: "onlyInbound"
            text: qsTr("Show Only Inbound Messages") + Retranslate.onLanguageChanged

            onCheckedChanged: {
                if (checked) {
                    infoText.text = qsTr("Only inbound messages will be shown to speed up loading times.")
                } else {
                    infoText.text = qsTr("Both inbound and outbound messages will be shown.")
                }
            }
        }

        ImageView
        {
            topMargin: 40
            imageSource: "images/ic_divider.png"
            horizontalAlignment: HorizontalAlignment.Center
        }

        Label {
            id: infoText
            multiline: true
            textStyle.fontSize: FontSize.XXSmall
            textStyle.textAlign: TextAlign.Center
            verticalAlignment: VerticalAlignment.Bottom
            horizontalAlignment: HorizontalAlignment.Center
        }
    }
    
    function onPushed(page)
    {
        navigationPane.pushTransitionEnded.disconnect(onPushed);

        if ( tutorialToast.tutorial( "tutorialOnlyInbound", qsTr("Enable the 'Show Only Inbound Messages' setting to speed up startup loading times by displaying only the incoming messages for your accounts."), "images/menu/ic_settings.png" ) ) {}
        
        reporter.initPage(rootPage);
    }
    
    onCreationCompleted: {
        navigationPane.pushTransitionEnded.connect(onPushed);
    }
    
    attachedObjects: [
        FilePicker {
            id: filePicker
            defaultType: FileType.Other
            filter: ["*.json"]
            
            directories :  {
                return ["/accounts/1000/removable/sdcard", "/accounts/1000/shared/misc"]
            }
            
            onFileSelected : {
                console.log("UserEvent: FileSelected", selectedFiles[0]);
                
                if (mode == FilePickerMode.Picker) {
                    app.restore(selectedFiles[0]);
                } else {
                    app.backup(selectedFiles[0]);
                }
            }
        }
    ]
}