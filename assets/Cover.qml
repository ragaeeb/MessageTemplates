import bb.cascades 1.0

Container
{
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Center
    background: back.imagePaint

    layout: DockLayout {}

    attachedObjects: [
        ImagePaintDefinition {
            id: back
            imageSource: "images/cover_bg.png"
        }
    ]

    Container {
        verticalAlignment: VerticalAlignment.Center
        horizontalAlignment: HorizontalAlignment.Center

        ImageView {
            imageSource: "images/logo.png"
            horizontalAlignment: HorizontalAlignment.Center
        }

        Label {
            text: qsTr("Message\nTemplates") + Retranslate.onLanguageChanged

            horizontalAlignment: HorizontalAlignment.Fill
            multiline: true
            textStyle.color: Color.White
            textStyle.textAlign: TextAlign.Center
            textStyle.base: SystemDefaults.TextStyles.TitleText
            textStyle.fontWeight: FontWeight.Bold
            opacity: 0.8
        }
    }
}