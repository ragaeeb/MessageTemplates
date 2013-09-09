import bb.cascades 1.0
import bb 1.0

Page
{
    attachedObjects: [
        ApplicationInfo {
            id: appInfo
        },

        PackageInfo {
            id: packageInfo
        }
    ]
    
    titleBar: LeftLogoTitleBar {}

    Container
    {
        leftPadding: 20; rightPadding: 20;

        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill

        ScrollView {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Fill

            Label {
                multiline: true
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.Small
                content.flags: TextContentFlag.ActiveText
                text: qsTr("\n\n(c) 2013 %1. All Rights Reserved.\n%2 %3\n\nPlease report all bugs to:\nsupport@canadainc.org\n\nOften for business we need to convey the same information to multiple customers. For example if the customer is having some trouble with a product, we may have a set of troubleshooting instructions we need to provide to them.\n\nThis is where Message Templates comes in to make it easy. Using this app you can define some reply templates that you often use. Then when it comes time to replying to one of the messages, simply open this app, choose the message you want to reply to, and select your predefined template!\n\nFor performance reasons we only load incoming messages and not the ones you already sent out.\n\nTo switch the account you want to associate Message Templates with, simply pull down in the main screen list and from the dropdown select a different account.\n\n").arg(packageInfo.author).arg(appInfo.title).arg(appInfo.version)
            }
        }
    }
}