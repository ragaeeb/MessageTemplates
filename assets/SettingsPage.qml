import bb.cascades 1.0

BasePage
{
    contentContainer: Container
    {
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
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
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