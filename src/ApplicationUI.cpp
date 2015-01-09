#include "precompiled.h"

#include "applicationui.hpp"
#include "AccountImporter.h"
#include "CardUtils.h"
#include "InvocationUtils.h"
#include "IOUtils.h"
#include "Logger.h"
#include "LogMonitor.h"
#include "MessageImporter.h"
#include "MessageTemplatesCollector.h"
#include "PimUtil.h"

namespace {

QString performBackup(QString const& destination)
{
    QSettings s;
    QVariant qvl = s.value("templates");

    bb::data::JsonDataAccess jda;
    jda.save(qvl, destination);

    return destination;
}


bool performRestore(QString const& source)
{
    bb::data::JsonDataAccess jda;
    QVariant result = jda.load(source);

    if ( result.isValid() )
    {
        QSettings s;
        s.setValue("templates", result);
        return true;
    }

    return false;
}

}

namespace messagetemplates {

using namespace bb::cascades;
using namespace canadainc;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) :
        QObject(app), m_importer(NULL), m_root(NULL)
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
	    LogMonitor::create(CARD_KEY, CARD_LOG_FILE, this);
	    connect( &m_invokeManager, SIGNAL( cardPooled(bb::system::CardDoneMessage const&) ), app, SLOT( quit() ) );
        connect( &m_invokeManager, SIGNAL( childCardDone(bb::system::CardDoneMessage const&) ), this, SLOT( childCardDone(bb::system::CardDoneMessage const&) ) );
		connect( &m_invokeManager, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
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
    QmlDocument* qml = QmlDocument::create("asset:///NotificationToast.qml").parent(this);
    QObject* toast = qml->createRootObject<QObject>();
    QmlDocument::defaultDeclarativeEngine()->rootContext()->setContextProperty("tutorialToast", toast);

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

    if ( !m_request.target().isNull() )
    {
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
    }

    qmlRegisterType<bb::cascades::pickers::FilePicker>("bb.cascades.pickers", 1, 0, "FilePicker");
    qmlRegisterUncreatableType<bb::cascades::pickers::FileType>("bb.cascades.pickers", 1, 0, "FileType", "Can't instantiate");
    qmlRegisterUncreatableType<bb::cascades::pickers::FilePickerMode>("bb.cascades.pickers", 1, 0, "FilePickerMode", "Can't instantiate");

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


void ApplicationUI::processReply(qint64 accountId, QVariantMap const& message, QVariantList const& templateBodies)
{
    LOGGER(accountId << message << templateBodies);
    QString templateBody;

    foreach (QVariant const& body, templateBodies) {
        templateBody += body.toString() + "\r\n\r\n";
    }

    templateBody = templateBody.trimmed();

	if (accountId == ACCOUNT_KEY_SMS) {
		PimUtil::replyToSMS( message.value("senderAddress").toString(), templateBody, m_invokeManager );
	} else {
        m_persistance.copyToClipboard(templateBody, false);
        m_persistance.showBlockingToast( tr("Template has been copied to the clipboard! Please press-and-hold on an empty space and choose to Paste your message."), "", "asset:///images/toast/copy.png" );
		InvocationUtils::replyToMessage( accountId, message.value("id").toString(), m_invokeManager );
	}
}


void ApplicationUI::backup(QString const& destination)
{
    LOGGER(destination);

    QFutureWatcher<QString>* qfw = new QFutureWatcher<QString>(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onSaved() ) );

    QFuture<QString> future = QtConcurrent::run(performBackup, destination);
    qfw->setFuture(future);
}


void ApplicationUI::restore(QString const& source)
{
    LOGGER(source);

    QFutureWatcher<bool>* qfw = new QFutureWatcher<bool>(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onRestored() ) );

    QFuture<bool> future = QtConcurrent::run(performRestore, source);
    qfw->setFuture(future);
}


void ApplicationUI::onSaved()
{
    QFutureWatcher<QString>* qfw = static_cast< QFutureWatcher<QString>* >( sender() );
    QString result = qfw->result();

    emit backupComplete(result);

    qfw->deleteLater();
}


void ApplicationUI::onRestored()
{
    QFutureWatcher<bool>* qfw = static_cast< QFutureWatcher<bool>* >( sender() );
    qfw->deleteLater();
    bool result = qfw->result();

    LOGGER("RestoreResult" << result);
    emit restoreComplete(result);
}


void ApplicationUI::childCardDone(bb::system::CardDoneMessage const& message)
{
    LOGGER( message.reason() );
	m_invokeManager.sendCardDone(message);
}


void ApplicationUI::create(Application* app) {
	new ApplicationUI(app);
}


ApplicationUI::~ApplicationUI()
{
}

} // salat
