import bb.cascades 1.0

Page
{
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        leftPadding: 20
        topPadding: 20
        rightPadding: 20
        bottomPadding: 20
        
        PersistCheckBox
        {
            topMargin: 10
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
        
        Label {
            id: infoText
            multiline: true
            textStyle.fontSize: FontSize.XXSmall
            textStyle.textAlign: TextAlign.Center
            verticalAlignment: VerticalAlignment.Bottom
            horizontalAlignment: HorizontalAlignment.Center
        }
    }
}