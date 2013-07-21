#include "precompiled.h"

#include "applicationui.hpp"
#include "AccountImporter.h"
#include "InvocationUtils.h"
#include "IOUtils.h"
#include "Logger.h"
#include "MessageImporter.h"

namespace messagetemplates {

using namespace bb::cascades;
using namespace canadainc;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) : QObject(app), m_cover("Cover.qml")
{
	INIT_SETTING("onlyInbound", 1);

	qmlRegisterType<canadainc::InvocationUtils>("com.canadainc.data", 1, 0, "InvocationUtils");

	QmlDocument* qml = QmlDocument::create("asset:///main.qml").parent(this);
    qml->setContextProperty("app", this);
    qml->setContextProperty("persist", &m_persistance);
    qml->setContextProperty("localizer", &m_locale);

    AbstractPane* root = qml->createRootObject<AbstractPane>();
    app->setScene(root);
}


void ApplicationUI::loadAccounts()
{
	AccountImporter* ai = new AccountImporter();
	connect( ai, SIGNAL( importCompleted(QVariantList const&) ), this, SIGNAL( accountsImported(QVariantList const&) ) );
	IOUtils::startThread(ai);
}


void ApplicationUI::loadMessages(qint64 accountId)
{
	LOGGER("===== Load messages for" << accountId);
	MessageImporter* ai = new MessageImporter( accountId, m_persistance.getValueFor("onlyInbound").toInt() == 1 );
	connect( ai, SIGNAL( importCompleted(QVariantList const&) ), this, SIGNAL( messagesImported(QVariantList const&) ) );
	connect( ai, SIGNAL( progress(int, int) ), this, SIGNAL( loadProgress(int, int) ) );
	IOUtils::startThread(ai);
}


void ApplicationUI::create(Application* app) {
	new ApplicationUI(app);
}


ApplicationUI::~ApplicationUI()
{
}

} // salat