import bb.cascades 1.0

Page
{
    titleBar: LeftLogoTitleBar {}
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        leftPadding: 20
        topPadding: 20
        rightPadding: 20
        bottomPadding: 20
        
        SettingPair
        {
            title: qsTr("Show Only Inbound Messages");
            key: "onlyInbound"
    
            toggle.onCheckedChanged:
            {
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