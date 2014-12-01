#include "precompiled.h"

#include "applicationui.hpp"
#include "AccountImporter.h"
#include "InvocationUtils.h"
#include "IOUtils.h"
#include "Logger.h"
#include "MessageImporter.h"
#include "MessageManager.h"
#include "PimUtil.h"

namespace messagetemplates {

using namespace bb::cascades;
using namespace canadainc;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) : QObject(app), m_cover("Cover.qml"), m_root(NULL)
{
	INIT_SETTING("onlyInbound", 1);
    INIT_SETTING(CARD_KEY, true);
    INIT_SETTING(UI_KEY, true);

	switch ( m_invokeManager.startupMode() )
	{
    case ApplicationStartupMode::LaunchApplication:
        LogMonitor::create(UI_KEY, UI_LOG_FILE, this);
        init("main.qml");
        break;

	case ApplicationStartupMode::InvokeCard:
		connect( &m_invokeManager, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
		connect( &m_invokeManager, SIGNAL( childCardDone(bb::system::CardDoneMessage const&) ), this, SLOT( childCardDone(bb::system::CardDoneMessage const&) ) );
		break;

    case ApplicationStartupMode::InvokeApplication:
        LogMonitor::create(UI_KEY, UI_LOG_FILE, this);
        connect( &m_invokeManager, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
        break;

	default:
	    break;
		break;
	}
}


void ApplicationUI::invoked(bb::system::InvokeRequest const& request)
{
    LOGGER( request.action() << request.target() << request.mimeType() << request.metadata() << request.uri().toString() << QString( request.data() ) );

    QMap<QString,QString> targetToQML;

    QString qml = targetToQML.value(target);

    if ( qml.isNull() ) {
        qml = "TemplatesPage.qml";
    }

    init(qml);

    m_request = request;
}


QObject* ApplicationUI::initRoot(QString const& qmlSource)
{
    QMap<QString, QObject*> context;
    context.insert("localizer", &m_locale);

    LOGGER("Instantiate" << qmlDoc);
    m_root = CardUtils::initAppropriate(qmlDoc, context, this);
    emit initialize();

	return root;
}


void ApplicationUI::lazyInit()
{
    if ( !Persistance::hasEmailSmsAccess() ) {
        m_persist.showToast( tr("Warning: It seems like the app does not have access to your Email/SMS messages Folder. This permission is needed for the app to access the SMS and email services it needs to validatebe able to reply to them via templates. If you leave this permission off, some features may not work properly. Select OK to launch the Application Permissions screen where you can turn these settings on.") );
    }

    QStringList tokens = m_request.uri().toString().split(":");

    if ( tokens.size() > 3 )
    {
        qint64 accountId = tokens[2].toLongLong();
        QString messageId = tokens[3];

        QVariantMap map;
        map["id"] = messageId;

        m_root->setProperty("accountId", accountId);
        m_root->setProperty("message", map);
    }
}


void ApplicationUI::loadAccounts()
{
	AccountImporter* ai = new AccountImporter();
	connect( ai, SIGNAL( importCompleted(QVariantList const&) ), this, SIGNAL( accountsImported(QVariantList const&) ) );
	IOUtils::startThread(ai);
}


void ApplicationUI::loadMessages(qint64 accountId)
{
	LOGGER("Load messages for" << accountId);
	MessageImporter* ai = new MessageImporter( accountId, m_persistance.getValueFor("onlyInbound").toInt() == 1 );
	connect( ai, SIGNAL( importCompleted(QVariantList const&) ), this, SIGNAL( messagesImported(QVariantList const&) ) );
	connect( ai, SIGNAL( progress(int, int) ), this, SIGNAL( loadProgress(int, int) ) );
	IOUtils::startThread(ai);
}


void ApplicationUI::processReply(qint64 accountId, QVariantMap const& message, QString const& templateBody)
{
	if (accountId == MessageManager::account_key_sms) {
		PimUtil::replyToSMS( message.value("senderAddress").toString(), templateBody, m_invokeManager );
	} else {
        m_persistance.copyToClipboard(templateBody, false);
        m_persistance.showBlockingToast( tr("Template has been copied to the clipboard! Please press-and-hold on an empty space and choose to Paste your message."), tr("OK") );
		InvocationUtils::replyToMessage( accountId, message.value("id").toString(), m_invokeManager );
	}
}


void ApplicationUI::childCardDone(bb::system::CardDoneMessage const& message)
{
	m_invokeManager.sendCardDone(message);
}


void ApplicationUI::create(Application* app) {
	new ApplicationUI(app);
}


ApplicationUI::~ApplicationUI()
{
}

} // salat
