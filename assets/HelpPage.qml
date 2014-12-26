import bb.cascades 1.0

Page
{
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: AboutTitleBar
    {
        id: atb
        labelColor: 'Signature' in ActionBarPlacement ? Color.Black : Color.White
    }
    
    actions: [
        ActionItem
        {
            imageSource: "file:///usr/share/icons/bb_action_openbbmchannel.png"
            title: atb.channelTitle
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: OpenChannelTriggered");
                persist.openChannel();
            }
        }
    ]

    Container
    {
        leftPadding: 10; rightPadding: 10;
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill

        ScrollView
        {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Fill

            Label {
                multiline: true
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.Small
                content.flags: TextContentFlag.ActiveText
                text: qsTr("\n\nOften for business we need to convey the same information to multiple customers. For example if the customer is having some trouble with a product, we may have a set of troubleshooting instructions we need to provide to them.\n\nThis is where Message Templates comes in to make it easy. Using this app you can define some reply templates that you often use. Then when it comes time to replying to one of the messages, simply open this app, choose the message you want to reply to, and select your predefined template!\n\nYou can also reply directly from the BB10 Hub! Simply press-and-hold on an email you want to reply to, choose \"Share | Message Templates\" and choose the template you want to reply with! Easy as that!\n\n") + Retranslate.onLanguageChanged
                topMargin: 0;
            }
        }
    }
}