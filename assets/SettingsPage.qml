import bb.cascades 1.0

Page
{
    id: settingsPage
    
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
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
}