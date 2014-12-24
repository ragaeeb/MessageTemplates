#include "precompiled.h"

#include "applicationui.hpp"
#include "AccountImporter.h"
#include "AppLogFetcher.h"
#include "CardUtils.h"
#include "InvocationUtils.h"
#include "IOUtils.h"
#include "Logger.h"
#include "LogMonitor.h"
#include "MessageImporter.h"
#include "MessageTemplatesCollector.h"
#include "PimUtil.h"

namespace messagetemplates {

using namespace bb::cascades;
using namespace canadainc;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) :
        QObject(app), m_importer(NULL), m_cover("Cover.qml"), m_root(NULL)
{
    INIT_SETTING(CARD_KEY, true);
    INIT_SETTING(UI_KEY, true);
    INIT_SETTING("days", 3);

	switch ( m_invokeManager.startupMode() )
	{
    case ApplicationStartupMode::LaunchApplication:
        LogMonitor::create(UI_KEY, UI_LOG_FILE, this);
        initRoot("main.qml");
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
	}
}


void ApplicationUI::invoked(bb::system::InvokeRequest const& request)
{
    LOGGER( request.action() << request.target() << request.mimeType() << request.metadata() << request.uri().toString() << QString( request.data() ) );

    QMap<QString,QString> targetToQML;

    QString qml = targetToQML.value( request.target() );

    if ( qml.isNull() ) {
        qml = "TemplatesPage.qml";
    }

    initRoot(qml);

    m_request = request;
}


void ApplicationUI::initRoot(QString const& qmlDoc)
{
    QMap<QString, QObject*> context;
    context.insert("localizer", &m_locale);

    LOGGER("Instantiate" << qmlDoc);
    m_root = CardUtils::initAppropriate(qmlDoc, context, this);
    emit initialize();
}


void ApplicationUI::terminateThreads()
{
    if (m_importer) {
        m_importer->cancel();
    }
}


void ApplicationUI::lazyInit()
{
    INIT_SETTING("onlyInbound", 1);

    connect( Application::instance(), SIGNAL( aboutToQuit() ), this, SLOT( terminateThreads() ) );

    AppLogFetcher::create( &m_persistance, new MessageTemplatesCollector(), this );

    if ( !Persistance::hasEmailSmsAccess() ) {
        //m_persist.showToast( tr("Warning: It seems like the app does not have access to your Email/SMS messages Folder. This permission is needed for the app to access the SMS and email services it needs to validatebe able to reply to them via templates. If you leave this permission off, some features may not work properly. Select OK to launch the Application Permissions screen where you can turn these settings on.") );
    }

    qint64 accountId = 0;
    QString messageId = QString::number( PimUtil::extractIdsFromInvoke( m_request.uri().toString(), m_request.data(), accountId ) );
    QStringList tokens = m_request.uri().toString().split(":");

    if ( accountId && !messageId.isNull() )
    {
        QVariantMap map;
        map["id"] = messageId;

        m_root->setProperty("accountId", accountId);
        m_root->setProperty("message", map);
    }

    emit lazyInitComplete();
}


void ApplicationUI::loadAccounts()
{
	AccountImporter* ai = new AccountImporter();
	connect( ai, SIGNAL( importCompleted(QVariantList const&) ), this, SIGNAL( accountsImported(QVariantList const&) ) );
	IOUtils::startThread(ai);
}


void ApplicationUI::loadMessages(qint64 accountId)
{
	LOGGER(accountId);

	terminateThreads();

	m_importer = new MessageImporter( accountId, m_persistance.getValueFor("onlyInbound").toInt() == 1 );
	m_importer->setTimeLimit( m_persistance.getValueFor("days").toInt() );

	connect( m_importer, SIGNAL( importCompleted(QVariantList const&) ), this, SIGNAL( messagesImported(QVariantList const&) ) );
	connect( m_importer, SIGNAL( progress(int, int) ), this, SIGNAL( loadProgress(int, int) ) );

	IOUtils::startThread(m_importer);
}


void ApplicationUI::onMessagesImported(QVariantList const& qvl)
{
    emit messagesImported(qvl);
    m_importer = NULL;
}


void ApplicationUI::processReply(qint64 accountId, QVariantMap const& message, QString const& templateBody)
{
	if (accountId == ACCOUNT_KEY_SMS) {
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
